{{- define "signaltrade.labels" -}}
app.kubernetes.io/part-of: signaltrade
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "signaltrade.image" -}}
{{ $.Values.global.imageRegistry }}/{{ .image }}:{{ .tag }}
{{- end }}
