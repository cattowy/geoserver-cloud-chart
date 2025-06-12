{{- /*
  Вспомогательная функция, которая берет nodeSelector, affinity и tolerations
  с приоритетом: service > global.
  Параметры:
    .svc - блок сервиса
    .global - блок global
*/ -}}
{{- define "GeoserverCloud.podSpecExtras" -}}
{{- $svc := .svc -}}
{{- $global := .global -}}

{{- if or $svc.nodeSelector $global.nodeSelector }}
nodeSelector:
  {{- if $svc.nodeSelector }}
  {{- toYaml $svc.nodeSelector | nindent 2 }}
  {{- else }}
  {{- toYaml $global.nodeSelector | nindent 2 }}
  {{- end }}
{{- end }}

{{- if or $svc.affinity $global.affinity }}
affinity:
  {{- if $svc.affinity }}
  {{- toYaml $svc.affinity | nindent 2 }}
  {{- else }}
  {{- toYaml $global.affinity | nindent 2 }}
  {{- end }}
{{- end }}

{{- if or $svc.tolerations $global.tolerations }}
tolerations:
  {{- if $svc.tolerations }}
  {{- toYaml $svc.tolerations | nindent 2 }}
  {{- else }}
  {{- toYaml $global.tolerations | nindent 2 }}
  {{- end }}
{{- end }}

{{- end }}
