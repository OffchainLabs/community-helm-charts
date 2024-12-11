{{/*
Expand the name of the chart.
*/}}
{{- define "timeboost.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "timeboost.fullname" -}}
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
{{- define "timeboost.chart" -}}
{{- printf "%s" .Chart.Name | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels Auctioneer
*/}}
{{- define "timeboost.auctioneer.labels" -}}
helm.sh/chart: {{ include "timeboost.chart" . }}
{{ include "timeboost.auctioneer.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels Auctioneer
*/}}
{{- define "timeboost.auctioneer.selectorLabels" -}}
app.kubernetes.io/name: {{ include "timeboost.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "startupProbe" -}}
{{- if .Values.startupProbe.command }}
{{ .Values.startupProbe.command }}
{{- else }}
curl "http://localhost:{{ .Values.configmap.data.http.port }}{{ .Values.configmap.data.http.rpcprefix }}" -H "Content-Type: application/json" \
         -sd "{\"jsonrpc\":\"2.0\",\"id\":0,\"method\":\"eth_syncing\",\"params\":[]}" \
         | jq -ne "input.result == false"
{{- end }}
{{- end -}}

{{/*
auctioneer args
*/}}
{{- define "timeboost.auctioneer.customArgs" -}}

{{- $auctioneerCustomArgs := list -}}
{{- range $k, $v := .Values.auctioneer.auctioneerCustomArgs -}}
  {{- $auctioneerCustomArgs = concat $auctioneerCustomArgs (list (printf "--%s" $v)) -}}
{{- end -}}

{{- $auctioneerCustomArgs | compact | toStrings | toYaml -}}

{{- end -}}

{{- define "timeboost.initContainers" -}}
{{- end }}

{{- define "timeboost.sidecars" -}}
{{- end }}

{{/*
Process config data automatically depending on values that are set.
Currently primarily used for stateless validator configuration
*/}}
{{- define "timeboost.auctioneer.configProcessor" -}}

{{- /* Make a deep copy of the values from the Helm chart */ -}}
{{- $values := deepCopy .Values -}}

{{- /* Process the final configmap data into pretty JSON format */ -}}
{{- $processed := $values.auctioneer.configmap.data | toPrettyJson | replace "\\u0026" "&" | replace "\\u003c" "<" | replace "\\u003e" ">" -}}

{{- /* Return the processed JSON data */ -}}
{{- $processed -}}

{{- end -}}