{{/*
Expand the name of the chart.
*/}}
{{- define "mcp-gateway.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name (max 63 chars, DNS-safe).
*/}}
{{- define "mcp-gateway.fullname" -}}
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
Chart name and version, for the helm.sh/chart label.
*/}}
{{- define "mcp-gateway.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "mcp-gateway.labels" -}}
helm.sh/chart: {{ include "mcp-gateway.chart" . }}
{{ include "mcp-gateway.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels (immutable across upgrades).
*/}}
{{- define "mcp-gateway.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mcp-gateway.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
ServiceAccount name to use.
*/}}
{{- define "mcp-gateway.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "mcp-gateway.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Fully resolved image reference. Digest takes precedence over tag.
*/}}
{{- define "mcp-gateway.image" -}}
{{- $registry := .Values.image.registry -}}
{{- $repo := .Values.image.repository -}}
{{- /* Gateway release tags and the chart appVersion are unified. */ -}}
{{- $tag := default (printf "v%s" .Chart.AppVersion) .Values.image.tag -}}
{{- $base := $repo -}}
{{- if $registry -}}
{{- $base = printf "%s/%s" $registry $repo -}}
{{- end -}}
{{- if .Values.image.digest -}}
{{- printf "%s@%s" $base .Values.image.digest -}}
{{- else -}}
{{- printf "%s:%s" $base $tag -}}
{{- end -}}
{{- end }}

{{/*
Name of the Secret holding sensitive env vars (existing takes precedence).
*/}}
{{- define "mcp-gateway.secretName" -}}
{{- if .Values.secret.existingSecret }}
{{- .Values.secret.existingSecret }}
{{- else }}
{{- include "mcp-gateway.fullname" . }}
{{- end }}
{{- end }}

{{/*
Whether a Secret reference should be wired into the pod (existing or chart-managed).
*/}}
{{- define "mcp-gateway.usesSecret" -}}
{{- if or .Values.secret.existingSecret .Values.secret.create -}}
true
{{- end -}}
{{- end }}

{{/*
Validate that route and ingress are not both enabled.
*/}}
{{- define "mcp-gateway.validateRouting" -}}
{{- if and .Values.route.enabled .Values.ingress.enabled -}}
{{- fail "route.enabled and ingress.enabled cannot both be true. Use Route (OpenShift) or Ingress (vanilla Kubernetes), not both." -}}
{{- end -}}
{{- end -}}
