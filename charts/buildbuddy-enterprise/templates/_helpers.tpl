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
Scheduler RPC scheme used for app-to-app scheduler traffic.
*/}}
{{- define "buildbuddy.schedulerRPCScheme" -}}
{{- $scheme := default "grpc" .Values.distributed.schedulerRPCScheme | toString | lower -}}
{{- if not (has $scheme (list "grpc" "grpcs")) -}}
{{- fail "distributed.schedulerRPCScheme must be either \"grpc\" or \"grpcs\"" -}}
{{- end -}}
{{- if and (eq $scheme "grpcs") (not .Values.service.internalGRPCSPort) -}}
{{- fail "distributed.schedulerRPCScheme=grpcs requires service.internalGRPCSPort to be set" -}}
{{- end -}}
{{- $scheme -}}
{{- end -}}
