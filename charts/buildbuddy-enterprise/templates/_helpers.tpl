{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "buildbuddy.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "buildbuddy.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "buildbuddy.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Service account name used by the app pods. Empty if no service account is
created or named, in which case the pods use the namespace's default SA.
*/}}
{{- define "buildbuddy.serviceAccountName" -}}
{{- $sa := .Values.serviceAccount | default dict -}}
{{- if $sa.create -}}
{{- default (include "buildbuddy.fullname" .) $sa.name -}}
{{- else -}}
{{- $sa.name | default "" -}}
{{- end -}}
{{- end -}}

{{/* Keep CR names short enough for the operator's generated Service names. */}}
{{- define "buildbuddy.clickhouse.name" -}}
{{- $name := default (printf "%s-clickhouse" .Release.Name) .Values.clickhouse.nameOverride -}}
{{- if gt (len $name) 40 -}}
{{- printf "%s-%s" ($name | trunc 31 | trimSuffix "-") ($name | sha256sum | trunc 8) -}}
{{- else -}}
{{- $name -}}
{{- end -}}
{{- end -}}

{{- define "buildbuddy.clickhouse.service" -}}
{{- printf "%s-clickhouse-headless" (include "buildbuddy.clickhouse.name" .) -}}
{{- end -}}

{{- define "buildbuddy.clickhouse.secret" -}}
{{- default (printf "%s-auth" (include "buildbuddy.clickhouse.name" .)) .Values.clickhouse.auth.existingSecret -}}
{{- end -}}

{{/* Validate the few constraints required by the bundled OLAP connection. */}}
{{- define "buildbuddy.clickhouse.validate" -}}
{{- if and .Values.clickhouse.enabled .Values.clickhouse_legacy.enabled -}}
{{- fail "Enable only one of clickhouse.enabled and clickhouse_legacy.enabled." -}}
{{- end -}}
{{- if .Values.clickhouse.enabled -}}
{{- if not (regexMatch "^[A-Za-z_][A-Za-z0-9_]*$" .Values.clickhouse.auth.database) -}}
{{- fail "clickhouse.auth.database must be a simple SQL identifier." -}}
{{- end -}}
{{- if or (gt (len .Values.clickhouse.nameOverride) 40) (not (regexMatch "^$|^[a-z0-9]([a-z0-9-]*[a-z0-9])?$" .Values.clickhouse.nameOverride)) -}}
{{- fail "clickhouse.nameOverride must be a lowercase DNS label of at most 40 characters." -}}
{{- end -}}
{{- if and (not .Values.clickhouse.auth.existingSecret) (empty .Values.clickhouse.auth.password) -}}
{{- fail "Set clickhouse.auth.password or clickhouse.auth.existingSecret." -}}
{{- end -}}
{{- if dig "settings" "tls" "required" false .Values.clickhouse.spec -}}
{{- fail "TLS-only ClickHouse is not supported by the bundled plaintext OLAP initialization." -}}
{{- end -}}
{{- end -}}
{{- end -}}
