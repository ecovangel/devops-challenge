{{/* Return the chart version for labels */}}
{{- define "ecovangel-skyward-challenge.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version }}
{{- end -}}
