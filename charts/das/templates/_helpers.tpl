{{/*
Expand the name of the chart.
*/}}
{{- define "das.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "das.fullname" -}}
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
{{- define "das.chart" -}}
{{- printf "%s" .Chart.Name | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "das.labels" -}}
helm.sh/chart: {{ include "das.chart" . }}
{{ include "das.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "das.selectorLabels" -}}
app.kubernetes.io/name: {{ include "das.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "das.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "das.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "startupProbe" -}}
curl "http://localhost:{{ index .Values.configmap.data "rpc-port" }}" -X POST \
      -H 'Content-Type: application/json' \
      -d '{"jsonrpc":"2.0","id":0,"method":"das_healthCheck","params":[]}'
{{- end -}}

{{- define "livenessProbe" -}}
curl "http://localhost:{{ index .Values.configmap.data "rpc-port" }}" -X POST \
      -H 'Content-Type: application/json' \
      -d '{"jsonrpc":"2.0","id":0,"method":"das_healthCheck","params":[]}'   
{{- end -}}

{{- define "readinessProbe" -}}
curl "http://localhost:{{ index .Values.configmap.data "rpc-port" }}" -X POST \
      -H 'Content-Type: application/json' \
      -d '{"jsonrpc":"2.0","id":0,"method":"das_healthCheck","params":[]}'   
{{- end -}}

{{- define "relay.env" -}}
{{- end -}}



