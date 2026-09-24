#!/usr/bin/env python3
"""Render internal TLS configurations and assert their security/rollout contracts.

Run from any directory: python scripts/test_internal_tls.py
Requires Helm and Python with PyYAML. No cluster access or real Secrets are used.
"""

import base64
import os
from pathlib import Path
import subprocess

import yaml

os.chdir(Path(__file__).resolve().parents[1])
chart = "charts/buildbuddy-enterprise"
overlay = ["-f", chart + "/examples/internal-tls.values.yaml"]


def render(extra=None, failure=None):
    p = subprocess.run(
        ["helm", "template", "bbe", chart, "-n", "buildbuddy"] + (extra or []),
        text=True,
        capture_output=True,
    )
    if failure:
        assert p.returncode and failure in p.stderr, (failure, p.stderr)
        return
    assert p.returncode == 0, p.stderr
    ds = [d for d in yaml.safe_load_all(p.stdout) if d]
    for d in ds:
        if d["kind"] not in ("StatefulSet", "Deployment"):
            continue
        spec = d["spec"]["template"]["spec"]
        volumes = spec.get("volumes", [])
        assert len(volumes) == len({v["name"] for v in volumes})
        for container in spec.get("containers", []):
            mounts = container.get("volumeMounts", [])
            assert len(mounts) == len({m["mountPath"] for m in mounts}), d["metadata"][
                "name"
            ]
    return ds


def config(ds):
    sec = next(
        d
        for d in ds
        if d["kind"] == "Secret"
        and d["metadata"]["name"] == "bbe-buildbuddy-enterprise-config"
    )
    return yaml.safe_load(base64.b64decode(sec["data"]["config.yaml"]))


def app(ds):
    return next(
        d
        for d in ds
        if d["kind"] in ("StatefulSet", "Deployment")
        and d["metadata"]["name"] == "bbe-buildbuddy-enterprise"
    )


def ingress(ds):
    return [d for d in ds if d["kind"] == "Ingress"]


def setting(k, v):
    return ["--set", k + "=" + v]


ds = render()
assert config(ds)["ssl"]["enable_ssl"] is False
assert config(ds)["ssl"]["client_ca_cert_file"] == ""
assert not any(
    x["name"] == "internal-tls" for x in app(ds)["spec"]["template"]["spec"]["volumes"]
)
ds = render(overlay)
c = config(ds)
assert c["ssl"]["enable_ssl"] and c["ssl"]["cert_file"] == "/internal-tls/tls.crt"
assert c["remote_execution"]["scheduler_rpc_scheme"] == "grpcs"
assert c["ssl_port"] == 8081 and c["grpcs_port"] == 1986
assert c["ssl"]["client_ca_cert_file"] == ""
a = app(ds)["spec"]["template"]["spec"]
env = {x["name"]: x.get("value") for x in a["containers"][0]["env"]}
assert env["SSL_CERT_DIR"] == "/etc/ssl/certs:/etc/pki/tls/certs:/internal-ca"
assert (
    env["MY_HOSTNAME"]
    == "$(MY_NAME).buildbuddy-enterprise-headless.$(MY_NAMESPACE).svc.cluster.local"
)
assert "MY_PORT" not in env
assert env["MALLOC_ARENA_MAX"] == "8"
volumes = {v["name"]: v for v in a["volumes"]}
assert volumes["internal-tls"]["secret"]["secretName"] == "buildbuddy-internal-tls"
assert volumes["internal-ca"]["secret"]["secretName"] == "buildbuddy-internal-ca"
assert volumes["internal-tls"]["secret"]["items"] == [
    {"key": "tls.crt", "path": "tls.crt"},
    {"key": "tls.key", "path": "tls.key"},
]
assert volumes["internal-ca"]["secret"]["items"] == [
    {"key": "ca.crt", "path": "ca.crt"}
]
for mount in a["containers"][0]["volumeMounts"]:
    if mount["name"] in ("internal-tls", "internal-ca"):
        assert mount["readOnly"] and "subPath" not in mount

for ing in ingress(ds):
    ann = ing["metadata"]["annotations"]
    proto = ann["nginx.ingress.kubernetes.io/backend-protocol"]
    prefix = "grpc" if proto == "GRPCS" else "proxy"
    assert (
        f"{prefix}_ssl_verify on;"
        in ann["nginx.ingress.kubernetes.io/configuration-snippet"]
    )
    assert (
        f"{prefix}_ssl_name buildbuddy-enterprise.buildbuddy.svc.cluster.local;"
        in ann["nginx.ingress.kubernetes.io/configuration-snippet"]
    )
    assert ing["spec"]["rules"][0]["http"]["paths"][0]["backend"]["service"]["port"][
        "name"
    ] == ("grpcs" if proto == "GRPCS" else "https")
    assert ing["spec"]["tls"][0]["secretName"].endswith(".example.com-tls")
ds = render(
    overlay
    + setting("internalTLS.schedulerRPCScheme", "grpc")
    + setting("internalTLS.ingressTLS", "false")
)
assert config(ds)["remote_execution"]["scheduler_rpc_scheme"] == "grpc"
assert config(ds)["ssl"]["enable_ssl"]
assert all(
    "ssl_verify on"
    not in i["metadata"]["annotations"].get(
        "nginx.ingress.kubernetes.io/configuration-snippet", ""
    )
    for i in ingress(ds)
)
render(overlay + setting("ingress.enabled", "false"))
render(overlay + setting("ingress.controller.enabled", "false"))
ds = render(
    overlay
    + setting("service.internalHTTPSPort", "8443")
    + setting("service.internalGRPCSPort", "9443")
)
assert config(ds)["ssl_port"] == 8443
assert config(ds)["grpcs_port"] == 9443
for k, v, msg in [
    ("distributed.enabled", "false", "requires distributed"),
    ("internalTLS.existingSecret", "", "existingSecret is required"),
    ("internalTLS.caSecret", "buildbuddy-internal-tls", "must be separate"),
    ("internalTLS.serverName", "bad;name", "must be a DNS"),
    ("ingress.class", "alb", "not ALB"),
    ("ingress.controller.allowSnippetAnnotations", "false", "allowSnippetAnnotations"),
    ("internalTLS.schedulerRPCScheme", "https", "must be grpc or grpcs"),
    ("service.internalGRPCSPort", "0", "internalGRPCSPort"),
    ("config.ssl.use_acme", "true", "disable config.ssl.use_acme"),
]:
    render(overlay + setting(k, v), msg)
render(
    overlay + ["--set-json", "ingress.controller.extraVolumes=[]"],
    "requires the CA Secret mounted",
)
render(
    overlay + ["--set-json", 'extraEnvVars=[{"name":"MY_HOSTNAME","value":"wrong"}]'],
    "manages MY_HOSTNAME",
)
render(overlay + setting("certmanager.enabled", "true"), "requires retaining")
# With bundled client-cert issuance retain both existing client CA and new trust mounts.
render(
    overlay
    + setting("certmanager.enabled", "true")
    + [
        "--set-json",
        'ingress.controller.extraVolumes=[{"name":"internal-upstream-ca","secret":{"secretName":"buildbuddy-internal-ca"}},{"name":"client-ca-volume","secret":{"secretName":"buildbuddy-client-ca"}}]',
        "--set-json",
        'ingress.controller.extraVolumeMounts=[{"name":"internal-upstream-ca","mountPath":"/internal-ca","readOnly":true},{"name":"client-ca-volume","mountPath":"/client-ca/","readOnly":true}]',
    ]
)
print(
    "PASS: default, TLS, staged rollout, ingress disabled/external, custom ports, cert-manager compatibility, and 12 invalid configuration cases"
)
