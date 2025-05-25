{{- define "GeoserverCloud.image.registry" -}}
{{- default .svc.image.registry $.Values.global.image.registry -}}
{{- end }}

{{- define "GeoserverCloud.image.tag" -}}
{{- default $.Values.global.image.tag .svc.image.tag -}}
{{- end }}

{{- define "GeoserverCloud.image.pullPolicy" -}}
{{- default .svc.image.pullPolicy $.Values.global.image.pullPolicy -}}
{{- end }}

{{- define "GeoserverCloud.image.full" -}}
{{- $registry := include "GeoserverCloud.image.registry" (dict "svc" .svc "Values" $.Values) }}
{{- $name := .svc.image.image }}
{{- $tag := include "GeoserverCloud.image.tag" (dict "svc" .svc "Values" $.Values) }}
{{- printf "%s%s:%s" $registry $name $tag -}}
{{- end }}

{{- define "GeoserverCloud.imagePullSecrets" -}}
{{- $svc := .svc -}}
{{- $global := .global -}}
{{- $secrets := list -}}
{{- if $svc.imagePullSecrets }}
  {{- $secrets = $svc.imagePullSecrets }}
{{- else if $global.imagePullSecrets }}
  {{- $secrets = $global.imagePullSecrets }}
{{- end }}
{{- if $secrets }}
imagePullSecrets:
  {{- range $secret := $secrets }}
  - name: {{ $secret.name }}
  {{- end }}
{{- end }}
{{- end }}