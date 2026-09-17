{{/*
Expand the name of the chart.
*/}}
{{- define "local-mcp-gateway.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name (max 63 chars, DNS-safe).
*/}}
{{- define "local-mcp-gateway.fullname" -}}
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
{{- define "local-mcp-gateway.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "local-mcp-gateway.labels" -}}
helm.sh/chart: {{ include "local-mcp-gateway.chart" . }}
{{ include "local-mcp-gateway.selectorLabels" . }}
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
{{- define "local-mcp-gateway.selectorLabels" -}}
app.kubernetes.io/name: {{ include "local-mcp-gateway.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
ServiceAccount name to use.
*/}}
{{- define "local-mcp-gateway.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "local-mcp-gateway.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Fully resolved image reference. Digest takes precedence over tag.
*/}}
{{- define "local-mcp-gateway.image" -}}
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
{{- define "local-mcp-gateway.secretName" -}}
{{- if .Values.secret.existingSecret }}
{{- .Values.secret.existingSecret }}
{{- else }}
{{- include "local-mcp-gateway.fullname" . }}
{{- end }}
{{- end }}

{{/*
Whether a Secret reference should be wired into the pod (existing or chart-managed).
*/}}
{{- define "local-mcp-gateway.usesSecret" -}}
{{- if or .Values.secret.existingSecret .Values.secret.create -}}
true
{{- end -}}
{{- end }}

{{/*
Validate that route and ingress are not both enabled.
*/}}
{{- define "local-mcp-gateway.validateRouting" -}}
{{- if and .Values.route.enabled .Values.ingress.enabled -}}
{{- fail "route.enabled and ingress.enabled cannot both be true. Use Route (OpenShift) or Ingress (vanilla Kubernetes), not both." -}}
{{- end -}}
{{- end -}}
