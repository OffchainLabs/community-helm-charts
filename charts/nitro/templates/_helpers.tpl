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

{{- define "nitro.env" -}}
{{- $envPrefix := index .Values.configmap.data.conf "env-prefix" -}}
{{- if and (get .Values.env.nitro.goMemLimit "enabled" | default false) (not $envPrefix) -}}
{{- fail "configmap.data.conf.env-prefix must be set when goMemLimit is enabled" -}}
{{- end -}}
{{- if and .Values.resources .Values.resources.limits .Values.resources.limits.memory -}}
{{- $memory := .Values.resources.limits.memory -}}
{{- $value := regexFind "^\\d*\\.?\\d+" $memory | float64 -}}
{{- $unit := regexFind "[A-Za-z]+" $memory -}}
{{- $valueMi := 0.0 -}}
{{- if eq $unit "Gi" -}}
  {{- $valueMi = mulf $value 1024 -}}
{{- else if eq $unit "Mi" -}}
  {{- $valueMi = $value -}}
{{- end }}
{{- if $.Values.env.nitro.goMemLimit.enabled }}
- name: GOMEMLIMIT
  value: {{ printf "%dMiB" (int (mulf $valueMi ($.Values.env.nitro.goMemLimit.multiplier | default 0.9))) }}
{{- end }}
{{- if $.Values.env.resourceMgmtMemFreeLimit.enabled }}
- name: {{ $envPrefix }}_NODE_RESOURCE__MGMT_MEM__FREE__LIMIT
  value: {{ printf "%dB" (int (mulf $valueMi ($.Values.env.resourceMgmtMemFreeLimit.multiplier | default 0.05) 1048576)) }}
{{- end }}
{{- if $.Values.env.blockValidatorMemFreeLimit.enabled }}
- name: {{ $envPrefix }}_NODE_BLOCK__VALIDATOR_MEMORY__FREE__LIMIT
  value: {{ printf "%dB" (int (mulf $valueMi ($.Values.env.blockValidatorMemFreeLimit.multiplier | default 0.05) 1048576)) }}
{{- end }}
{{- end -}}

{{/* Calculate GOMAXPROCS based on CPU resources */}}
{{- if $.Values.env.nitro.goMaxProcs.enabled }}
{{- $cpuRequest := 0.0 -}}
{{- $cpuLimit := 0.0 -}}
{{- $multiplier := $.Values.env.nitro.goMaxProcs.multiplier | default 2 -}}

{{/* Get CPU request if set */}}
{{- if and .Values.resources .Values.resources.requests .Values.resources.requests.cpu -}}
  {{- $cpuRequestStr := .Values.resources.requests.cpu -}}
  {{/* Handle different CPU formats: cores (1), millicores (1000m), or decimal (0.5) */}}
  {{- if contains "m" $cpuRequestStr -}}
    {{/* Convert millicores to cores (e.g., 500m -> 0.5) */}}
    {{- $milliCores := regexFind "^\\d+" $cpuRequestStr | int -}}
    {{- $cpuRequest = mulf (divf $milliCores 1000.0) $multiplier -}}
  {{- else -}}
    {{/* Handle decimal or whole cores */}}
    {{- $cpuRequestVal := regexFind "^\\d*\\.?\\d+" $cpuRequestStr | float64 -}}
    {{- $cpuRequest = mulf $cpuRequestVal $multiplier -}}
  {{- end -}}
{{- end -}}

{{/* Get CPU limit if set */}}
{{- if and .Values.resources .Values.resources.limits .Values.resources.limits.cpu -}}
  {{- $cpuLimitStr := .Values.resources.limits.cpu -}}
  {{/* Handle different CPU formats: cores (1), millicores (1000m), or decimal (0.5) */}}
  {{- if contains "m" $cpuLimitStr -}}
    {{/* Convert millicores to cores (e.g., 500m -> 0.5) */}}
    {{- $milliCores := regexFind "^\\d+" $cpuLimitStr | int -}}
    {{- $cpuLimit = divf $milliCores 1000.0 -}}
  {{- else -}}
    {{/* Handle decimal or whole cores */}}
    {{- $cpuLimit = regexFind "^\\d*\\.?\\d+" $cpuLimitStr | float64 -}}
  {{- end -}}
{{- end -}}

{{/* Use the higher value between CPU request*multiplier and CPU limit */}}
{{- $maxProcs := 1 -}}
{{- if gt $cpuRequest $cpuLimit -}}
  {{- $maxProcs = ceil $cpuRequest -}}
{{- else if gt $cpuLimit 0.0 -}}
  {{- $maxProcs = ceil $cpuLimit -}}
{{- else if gt $cpuRequest 0.0 -}}
  {{- $maxProcs = ceil $cpuRequest -}}
{{- end -}}

{{/* Ensure GOMAXPROCS is at least 1 */}}
{{- if lt $maxProcs 1 -}}
  {{- $maxProcs = 1 -}}
{{- end -}}

{{/* Convert to integer */}}
{{- $maxProcsInt := int $maxProcs -}}

- name: GOMAXPROCS
  value: {{ $maxProcsInt | quote }}
{{- end }}
{{- end -}}
{{- end -}}

{{- define "nitro.splitvalidator.env" -}}
{{- if and .Values.validator .Values.validator.splitvalidator .Values.validator.splitvalidator.global .Values.validator.splitvalidator.global.resources .Values.validator.splitvalidator.global.resources.limits .Values.validator.splitvalidator.global.resources.limits.memory -}}
{{- $memory := .Values.validator.splitvalidator.global.resources.limits.memory -}}
{{- $value := regexFind "^\\d*\\.?\\d+" $memory | float64 -}}
{{- $unit := regexFind "[A-Za-z]+" $memory -}}
{{- $valueMi := 0.0 -}}
{{- if eq $unit "Gi" -}}
  {{- $valueMi = mulf $value 1024 -}}
{{- else if eq $unit "Mi" -}}
  {{- $valueMi = $value -}}
{{- end }}
{{- if $.Values.env.splitvalidator.goMemLimit.enabled }}
- name: GOMEMLIMIT
  value: {{ printf "%dMiB" (int (mulf $valueMi ($.Values.env.splitvalidator.goMemLimit.multiplier | default 0.75))) }}
{{- end }}
{{- end -}}

{{/* Calculate GOMAXPROCS for splitvalidator based on CPU resources */}}
{{- if $.Values.env.splitvalidator.goMaxProcs.enabled }}
{{- $cpuRequest := 0.0 -}}
{{- $cpuLimit := 0.0 -}}
{{- $multiplier := $.Values.env.splitvalidator.goMaxProcs.multiplier | default 2 -}}

{{/* Get CPU request if set */}}
{{- if and .Values.validator.splitvalidator.global.resources .Values.validator.splitvalidator.global.resources.requests .Values.validator.splitvalidator.global.resources.requests.cpu -}}
  {{- $cpuRequestStr := .Values.validator.splitvalidator.global.resources.requests.cpu -}}
  {{/* Handle different CPU formats: cores (1), millicores (1000m), or decimal (0.5) */}}
  {{- if contains "m" $cpuRequestStr -}}
    {{/* Convert millicores to cores (e.g., 500m -> 0.5) */}}
    {{- $milliCores := regexFind "^\\d+" $cpuRequestStr | int -}}
    {{- $cpuRequest = mulf (divf $milliCores 1000.0) $multiplier -}}
  {{- else -}}
    {{/* Handle decimal or whole cores */}}
    {{- $cpuRequestVal := regexFind "^\\d*\\.?\\d+" $cpuRequestStr | float64 -}}
    {{- $cpuRequest = mulf $cpuRequestVal $multiplier -}}
  {{- end -}}
{{- end -}}

{{/* Get CPU limit if set */}}
{{- if and .Values.validator.splitvalidator.global.resources .Values.validator.splitvalidator.global.resources.limits .Values.validator.splitvalidator.global.resources.limits.cpu -}}
  {{- $cpuLimitStr := .Values.validator.splitvalidator.global.resources.limits.cpu -}}
  {{/* Handle different CPU formats: cores (1), millicores (1000m), or decimal (0.5) */}}
  {{- if contains "m" $cpuLimitStr -}}
    {{/* Convert millicores to cores (e.g., 500m -> 0.5) */}}
    {{- $milliCores := regexFind "^\\d+" $cpuLimitStr | int -}}
    {{- $cpuLimit = divf $milliCores 1000.0 -}}
  {{- else -}}
    {{/* Handle decimal or whole cores */}}
    {{- $cpuLimit = regexFind "^\\d*\\.?\\d+" $cpuLimitStr | float64 -}}
  {{- end -}}
{{- end -}}

{{/* Use the higher value between CPU request*multiplier and CPU limit */}}
{{- $maxProcs := 1 -}}
{{- if gt $cpuRequest $cpuLimit -}}
  {{- $maxProcs = ceil $cpuRequest -}}
{{- else if gt $cpuLimit 0.0 -}}
  {{- $maxProcs = ceil $cpuLimit -}}
{{- else if gt $cpuRequest 0.0 -}}
  {{- $maxProcs = ceil $cpuRequest -}}
{{- end -}}

{{/* Ensure GOMAXPROCS is at least 1 */}}
{{- if lt $maxProcs 1 -}}
  {{- $maxProcs = 1 -}}
{{- end -}}

{{/* Convert to integer */}}
{{- $maxProcsInt := int $maxProcs -}}

- name: GOMAXPROCS
  value: {{ $maxProcsInt | quote }}
{{- end }}
{{- end -}}

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

{{- define "nitro.lifecycle" -}}
{{- end -}}
