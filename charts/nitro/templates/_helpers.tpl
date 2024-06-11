{{/*
Expand the name of the chart.
*/}}
{{- define "nitro.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "nitro.fullname" -}}
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
{{- define "nitro.chart" -}}
{{- printf "%s" .Chart.Name | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "nitro.labels" -}}
helm.sh/chart: {{ include "nitro.chart" . }}
{{ include "nitro.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "nitro.selectorLabels" -}}
app.kubernetes.io/name: {{ include "nitro.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "nitro.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "nitro.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
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
nitro args
*/}}
{{- define "nitro.customArgs" -}}

{{- $customArgs := list -}}
{{- range $k, $v := .Values.customArgs -}}
  {{- $customArgs = concat $customArgs (list (printf "--%s" $v)) -}}
{{- end -}}

{{- $customArgs | compact | toStrings | toYaml -}}

{{- end -}}

{{- define "nitro.initContainers" -}}
{{- end }}

{{- define "nitro.sidecars" -}}
{{- end }}

{{/*
Process config data automatically depending on values that are set.
Currently primarily used for stateless validator configuration
*/}}
{{- define "nitro.configProcessor" -}}

{{- /* Make a deep copy of the values from the Helm chart */ -}}
{{- $values := deepCopy .Values -}}

{{- /* Check if auto config processing is enabled */ -}}
{{- if .Values.enableAutoConfigProcessing -}}
  
  {{- /* Check if the validator is enabled */ -}}
  {{- if .Values.validator.enabled -}}
    
    {{- /* Initialize an empty list to hold deployment configurations */ -}}
    {{- $deployments := list -}}
    
    {{- /* Get the full name for the deployment using the included nitro.fullname template */ -}}
    {{- $fullName := include "nitro.fullname" . -}}
    
    {{- /* Retrieve the port number from the validator's configuration */ -}}
    {{- $port := int .Values.validator.splitvalidator.global.configmap.data.auth.port -}}
    
    {{- /* Iterate over each deployment in the validator splitvalidator deployments */ -}}
    {{- range .Values.validator.splitvalidator.deployments -}}
      
      {{- /* Construct the URL for the websocket connection */ -}}
      {{- $url := printf "ws://%s-val-%s:%d" $fullName .name $port -}}
      
      {{- /* Create a deployment configuration dictionary with jwtsecret and URL */ -}}
      {{- $deployment := dict "jwtsecret" "/secrets/jwtsecret" "url" $url -}}
      
      {{- /* Append the deployment configuration to the deployments list */ -}}
      {{- $deployments = append $deployments $deployment -}}
    {{- end -}}

    {{- /* Create the validation server config list in the configmap */ -}}
    {{- $valconfig := dict "configmap" (dict "data" (dict "node" (dict "block-validator" (dict "validation-server-configs-list" (toJson $deployments | replace "\\" "")))) ) -}}
    
    {{- /* Merge the new validation config into the original values */ -}}
    {{- $values = merge $values $valconfig -}}
  {{- end -}}
{{- end -}}

{{- /* Process the final configmap data into pretty JSON format */ -}}
{{- $processed := $values.configmap.data | toPrettyJson | replace "\\u0026" "&" | replace "\\u003c" "<" | replace "\\u003e" ">" -}}

{{- /* Return the processed JSON data */ -}}
{{- $processed -}}

{{- end -}}


