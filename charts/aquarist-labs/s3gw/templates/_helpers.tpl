{{/*
Expand the name of the chart.
*/}}
{{- define "s3gw.name" -}}
{{- .Chart.Name }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "s3gw.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "s3gw.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "s3gw.labels" -}}
helm.sh/chart: {{ include "s3gw.chart" . }}
{{ include "s3gw.commonSelectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "s3gw.commonSelectorLabels" -}}
app.kubernetes.io/name: {{ include "s3gw.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "s3gw.selectorLabels" -}}
{{ include "s3gw.commonSelectorLabels" . }}
app.kubernetes.io/component: gateway
{{- end }}

{{- define "s3gw-ui.selectorLabels" -}}
{{ include "s3gw.commonSelectorLabels" . }}
app.kubernetes.io/component: ui
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "s3gw.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "s3gw.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Version helpers for the image tag
*/}}
{{- define "s3gw.image" -}}
{{- $defaulttag := printf "v%s" .Chart.Version }}
{{- $tag := default $defaulttag .Values.imageTag }}
{{- $name := default "s3gw/s3gw" .Values.imageName }}
{{- $registry := default "quay.io" .Values.imageRegistry }}
{{- printf "%s/%s:%s" $registry $name $tag }}
{{- end }}

{{- define "s3gw-ui.image" -}}
{{- $tag := default (printf "v%s" .Chart.Version) .Values.ui.imageTag }}
{{- $name := default "s3gw/s3gw-ui" .Values.ui.imageName }}
{{- $registry := default "quay.io" .Values.imageRegistry }}
{{- printf "%s/%s:%s" $registry $name $tag }}
{{- end }}

{{/*
Image Pull Secret
*/}}
{{- define "s3gw.imagePullSecret" -}}
{{- $un := .Values.imageCredentials.username }}
{{- $pw := .Values.imageCredentials.password }}
{{- $em := .Values.imageCredentials.email }}
{{- $rg := .Values.imageRegistry }}
{{- $au := (printf "%s:%s" $un $pw | b64enc) }}
{{- printf "{\"auths\":{\"%s\":{\"username\":\"%s\",\"password\":\"%s\",\"email\":\"%s\",\"auth\":\"%s\"}}}" $rg $un $pw $em $au | b64enc}}
{{- end }}
