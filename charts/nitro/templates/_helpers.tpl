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

{{/* Validate env-prefix doesn't conflict with service names */}}
{{- $fullName := include "nitro.fullname" . -}}
{{- if and $envPrefix (hasPrefix (upper $envPrefix) (upper $fullName)) -}}
{{- fail (printf "configmap.data.conf.env-prefix '%s' conflicts with service name '%s'. This will cause Kubernetes service environment variables like %s_SERVICE_HOST to be interpreted as configuration keys. Use a different env-prefix or release name." $envPrefix $fullName (upper $fullName)) -}}
{{- end -}}

{{/* MALLOC_ARENA_MAX */}}
{{- if and .Values.env.nitro.mallocArenaMax (get .Values.env.nitro.mallocArenaMax "enabled") -}}
- name: MALLOC_ARENA_MAX
  value: {{ .Values.env.nitro.mallocArenaMax.value | default 2 | quote }}
{{- end }}

{{/* Memory-based environment variables */}}
{{- if and .Values.resources .Values.resources.limits .Values.resources.limits.memory .Values.env.nitro.goMemLimit.enabled -}}
{{- $memory := .Values.resources.limits.memory -}}
{{- $value := regexFind "^\\d*\\.?\\d+" $memory | float64 -}}
{{- $unit := regexFind "[A-Za-z]+" $memory -}}
{{- $valueMi := 0.0 -}}
{{- if eq $unit "Gi" -}}
  {{- $valueMi = mulf $value 1024 -}}
{{- else if eq $unit "Mi" -}}
  {{- $valueMi = $value -}}
{{- end -}}

{{/* Calculate non-Go memory subtraction if enabled */}}
{{- $nonGoMiB := 0.0 -}}
{{- if and .Values.env.nitro.goMemLimit.nonGoMemory (get .Values.env.nitro.goMemLimit.nonGoMemory "enabled") -}}

  {{/* Read database-cache from configmap or use default */}}
  {{- $databaseCache := float64 (.Values.env.nitro.goMemLimit.nonGoMemory.defaults.databaseCache | default 2048) -}}
  {{- if and .Values.configmap.data.execution .Values.configmap.data.execution.caching -}}
    {{- if hasKey .Values.configmap.data.execution.caching "database-cache" -}}
      {{- $databaseCache = index .Values.configmap.data.execution.caching "database-cache" | float64 -}}
    {{- end -}}
  {{- end -}}

  {{/* Pebble memtables = database-cache / 2 (derived, not directly configurable) */}}
  {{- $memtables := divf $databaseCache 2.0 -}}

  {{/* Read trie-clean-cache from configmap or use default */}}
  {{- $trieCleanCache := float64 (.Values.env.nitro.goMemLimit.nonGoMemory.defaults.trieCleanCache | default 600) -}}
  {{- if and .Values.configmap.data.execution .Values.configmap.data.execution.caching -}}
    {{- if hasKey .Values.configmap.data.execution.caching "trie-clean-cache" -}}
      {{- $trieCleanCache = index .Values.configmap.data.execution.caching "trie-clean-cache" | float64 -}}
    {{- end -}}
  {{- end -}}

  {{/* Read snapshot-cache from configmap or use default */}}
  {{- $snapshotCache := float64 (.Values.env.nitro.goMemLimit.nonGoMemory.defaults.snapshotCache | default 400) -}}
  {{- if and .Values.configmap.data.execution .Values.configmap.data.execution.caching -}}
    {{- if hasKey .Values.configmap.data.execution.caching "snapshot-cache" -}}
      {{- $snapshotCache = index .Values.configmap.data.execution.caching "snapshot-cache" | float64 -}}
    {{- end -}}
  {{- end -}}

  {{/* Read stylus-lru-cache-capacity from configmap or use default */}}
  {{- $stylusLruCache := float64 (.Values.env.nitro.goMemLimit.nonGoMemory.defaults.stylusLruCache | default 256) -}}
  {{- if and .Values.configmap.data.execution .Values.configmap.data.execution.caching -}}
    {{- if hasKey .Values.configmap.data.execution.caching "stylus-lru-cache-capacity" -}}
      {{- $stylusLruCache = index .Values.configmap.data.execution.caching "stylus-lru-cache-capacity" | float64 -}}
    {{- end -}}
  {{- end -}}

  {{/* Malloc arena overhead: MALLOC_ARENA_MAX * arenaSize (default 64 MB per arena) */}}
  {{- $arenaOverhead := 0.0 -}}
  {{- if and .Values.env.nitro.mallocArenaMax (get .Values.env.nitro.mallocArenaMax "enabled") -}}
    {{- $arenaCount := float64 (.Values.env.nitro.mallocArenaMax.value | default 2) -}}
    {{- $arenaSize := float64 (.Values.env.nitro.goMemLimit.nonGoMemory.defaults.mallocArenaSize | default 64) -}}
    {{- $arenaOverhead = mulf $arenaCount $arenaSize -}}
  {{- end -}}

  {{/* Total non-Go memory in MiB */}}
  {{- $nonGoMiB = addf $databaseCache $memtables $trieCleanCache $snapshotCache $stylusLruCache $arenaOverhead -}}

{{- end -}}

{{/* GOMEMLIMIT = (memoryLimitMiB - nonGoMiB) * multiplier */}}
{{/* When nonGoMemory is disabled, nonGoMiB is 0, so formula reduces to memoryLimitMiB * multiplier */}}
{{- $goAvailable := subf $valueMi $nonGoMiB -}}
{{- if le $goAvailable 0.0 -}}
{{- fail (printf "non-Go memory (%dMiB) exceeds or equals container memory limit (%dMiB). Reduce cache sizes or increase memory limit." (int $nonGoMiB) (int $valueMi)) -}}
{{- end -}}
- name: GOMEMLIMIT
  value: {{ printf "%dMiB" (int (mulf $goAvailable ($.Values.env.nitro.goMemLimit.multiplier | default 0.9))) | quote }}
{{- end }}

{{- if and .Values.resources .Values.resources.limits .Values.resources.limits.memory .Values.env.resourceMgmtMemFreeLimit.enabled -}}
{{- $memory := .Values.resources.limits.memory -}}
{{- $value := regexFind "^\\d*\\.?\\d+" $memory | float64 -}}
{{- $unit := regexFind "[A-Za-z]+" $memory -}}
{{- $valueMi := 0.0 -}}
{{- if eq $unit "Gi" -}}
  {{- $valueMi = mulf $value 1024 -}}
{{- else if eq $unit "Mi" -}}
  {{- $valueMi = $value -}}
{{- end }}
- name: {{ $envPrefix }}_NODE_RESOURCE__MGMT_MEM__FREE__LIMIT
  value: {{ printf "%dB" (int (mulf $valueMi ($.Values.env.resourceMgmtMemFreeLimit.multiplier | default 0.05) 1048576)) | quote }}
{{- end }}

{{- if and .Values.resources .Values.resources.limits .Values.resources.limits.memory .Values.env.blockValidatorMemFreeLimit.enabled -}}
{{- $memory := .Values.resources.limits.memory -}}
{{- $value := regexFind "^\\d*\\.?\\d+" $memory | float64 -}}
{{- $unit := regexFind "[A-Za-z]+" $memory -}}
{{- $valueMi := 0.0 -}}
{{- if eq $unit "Gi" -}}
  {{- $valueMi = mulf $value 1024 -}}
{{- else if eq $unit "Mi" -}}
  {{- $valueMi = $value -}}
{{- end }}
- name: {{ $envPrefix }}_NODE_BLOCK__VALIDATOR_MEMORY__FREE__LIMIT
  value: {{ printf "%dB" (int (mulf $valueMi ($.Values.env.blockValidatorMemFreeLimit.multiplier | default 0.05) 1048576)) | quote }}
{{- end }}

{{/* CPU-based environment variables */}}
{{- if .Values.env.nitro.goMaxProcs.enabled -}}
{{- $cpuRequest := 0.0 -}}
{{- $cpuLimit := 0.0 -}}
{{- $multiplier := $.Values.env.nitro.goMaxProcs.multiplier | default 2 -}}

{{/* Get CPU request if set */}}
{{- if and .Values.resources .Values.resources.requests .Values.resources.requests.cpu -}}
  {{- $cpuRequestStr := toString .Values.resources.requests.cpu -}}
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
  {{- $cpuLimitStr := toString .Values.resources.limits.cpu -}}
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

{{/* Only set GOMAXPROCS if CPU requests or limits are defined */}}
{{- if or (gt $cpuRequest 0.0) (gt $cpuLimit 0.0) -}}
  {{/* Use the higher value between CPU request*multiplier and CPU limit */}}
  {{- $maxProcs := 0 -}}
  {{- if gt $cpuRequest $cpuLimit -}}
    {{- $maxProcs = ceil $cpuRequest | int -}}
  {{- else if gt $cpuLimit 0.0 -}}
    {{- $maxProcs = ceil $cpuLimit | int -}}
  {{- else if gt $cpuRequest 0.0 -}}
    {{- $maxProcs = ceil $cpuRequest | int -}}
  {{- end -}}

  {{/* Ensure GOMAXPROCS is at least 1 */}}
  {{- if eq $maxProcs 0 -}}
    {{- $maxProcs = 1 -}}
  {{- end }}
- name: GOMAXPROCS
  value: {{ $maxProcs | quote }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "nitro.splitvalidator.env" -}}
{{/* Memory-based environment variables */}}
{{- if and .Values.validator .Values.validator.splitvalidator .Values.validator.splitvalidator.global .Values.validator.splitvalidator.global.resources .Values.validator.splitvalidator.global.resources.limits .Values.validator.splitvalidator.global.resources.limits.memory .Values.env.splitvalidator.goMemLimit.enabled -}}
{{- $memory := .Values.validator.splitvalidator.global.resources.limits.memory -}}
{{- $value := regexFind "^\\d*\\.?\\d+" $memory | float64 -}}
{{- $unit := regexFind "[A-Za-z]+" $memory -}}
{{- $valueMi := 0.0 -}}
{{- if eq $unit "Gi" -}}
  {{- $valueMi = mulf $value 1024 -}}
{{- else if eq $unit "Mi" -}}
  {{- $valueMi = $value -}}
{{- end }}
- name: GOMEMLIMIT
  value: {{ printf "%dMiB" (int (mulf $valueMi ($.Values.env.splitvalidator.goMemLimit.multiplier | default 0.75))) | quote }}
{{- end }}

{{/* CPU-based environment variables */}}
{{- if .Values.env.splitvalidator.goMaxProcs.enabled -}}
{{- $cpuRequest := 0.0 -}}
{{- $cpuLimit := 0.0 -}}
{{- $multiplier := $.Values.env.splitvalidator.goMaxProcs.multiplier | default 2 -}}

{{/* Get CPU request if set */}}
{{- if and .Values.validator.splitvalidator.global.resources .Values.validator.splitvalidator.global.resources.requests .Values.validator.splitvalidator.global.resources.requests.cpu -}}
  {{- $cpuRequestStr := toString .Values.validator.splitvalidator.global.resources.requests.cpu -}}
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
  {{- $cpuLimitStr := toString .Values.validator.splitvalidator.global.resources.limits.cpu -}}
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

{{/* Only set GOMAXPROCS if CPU requests or limits are defined */}}
{{- if or (gt $cpuRequest 0.0) (gt $cpuLimit 0.0) -}}
  {{/* Use the higher value between CPU request*multiplier and CPU limit */}}
  {{- $maxProcs := 0 -}}
  {{- if gt $cpuRequest $cpuLimit -}}
    {{- $maxProcs = ceil $cpuRequest | int -}}
  {{- else if gt $cpuLimit 0.0 -}}
    {{- $maxProcs = ceil $cpuLimit | int -}}
  {{- else if gt $cpuRequest 0.0 -}}
    {{- $maxProcs = ceil $cpuRequest | int -}}
  {{- end -}}

  {{/* Ensure GOMAXPROCS is at least 1 */}}
  {{- if eq $maxProcs 0 -}}
    {{- $maxProcs = 1 -}}
  {{- end }}
- name: GOMAXPROCS
  value: {{ $maxProcs | quote }}
{{- end }}
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

{{- /* Process removals if specified */ -}}
{{- if .Values.configmap.removeKeys -}}
  {{- /* Process each removal key */ -}}
  {{- range .Values.configmap.removeKeys -}}
    {{- $keyPath := . -}}
    {{- $keys := splitList "." $keyPath -}}
    
    {{- /* Navigate to the parent of the key to remove */ -}}
    {{- $current := $values.configmap.data -}}
    {{- $parent := dict -}}
    {{- $parentKey := "" -}}
    
    {{- /* Navigate through the path */ -}}
    {{- range $index, $key := $keys -}}
      {{- if lt $index (sub (len $keys) 1) -}}
        {{- /* Not the last key - navigate deeper */ -}}
        {{- if hasKey $current $key -}}
          {{- $parent = $current -}}
          {{- $parentKey = $key -}}
          {{- $current = index $current $key -}}
        {{- else -}}
          {{- /* Path doesn't exist, break */ -}}
          {{- break -}}
        {{- end -}}
      {{- else -}}
        {{- /* This is the last key - remove it */ -}}
        {{- if hasKey $current $key -}}
          {{- $_ := unset $current $key -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- /* Process the final configmap data into pretty JSON format */ -}}
{{- $processed := $values.configmap.data | toPrettyJson | replace "\\u0026" "&" | replace "\\u003c" "<" | replace "\\u003e" ">" -}}

{{- /* Return the processed JSON data */ -}}
{{- $processed -}}

{{- end -}}

{{- define "nitro.lifecycle" -}}
{{- end -}}
