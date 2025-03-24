{{/* Get the image repository */}}
{{- define "timeboost.image.repository" -}}
{{- $component := .component -}}
{{- if and $component.image (not (empty $component.image)) $component.image.repository -}}
{{- $component.image.repository -}}
{{- else -}}
{{- .root.Values.image.repository -}}
{{- end -}}
{{- end -}}

{{/* Get the image pullPolicy */}}
{{- define "timeboost.image.pullPolicy" -}}
{{- $component := .component -}}
{{- if and $component.image (not (empty $component.image)) $component.image.pullPolicy -}}
{{- $component.image.pullPolicy -}}
{{- else -}}
{{- .root.Values.image.pullPolicy -}}
{{- end -}}
{{- end -}}

{{/* Get the image tag */}}
{{- define "timeboost.image.tag" -}}
{{- $component := .component -}}
{{- if and $component.image (not (empty $component.image)) $component.image.tag -}}
{{- $component.image.tag -}}
{{- else if .root.Values.image.tag -}}
{{- .root.Values.image.tag -}}
{{- else -}}
{{- .root.Chart.AppVersion -}}
{{- end -}}
{{- end -}}

{{/* Get the image pull secrets */}}
{{- define "timeboost.imagePullSecrets" -}}
{{- $component := .component -}}
{{- if and $component.imagePullSecrets (not (empty $component.imagePullSecrets)) -}}
{{- toYaml $component.imagePullSecrets -}}
{{- else -}}
{{- toYaml .root.Values.image.pullSecrets -}}
{{- end -}}
{{- end -}}
