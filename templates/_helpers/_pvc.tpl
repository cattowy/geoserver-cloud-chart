{{- define "GeoserverCloud.volumes" -}}
{{- $root := .root -}}
{{- $svc := .svc -}}
{{- range $vol := $svc.volumes }}
  {{- if eq $vol.type "pvc" }}
  - name: {{ $vol.name }}
    persistentVolumeClaim:
      claimName: {{- if $vol.claimName }}
        {{ $vol.claimName }}
      {{- else if $vol.claimRef }}
        {{ (get $root.persistentVolumeClaims $vol.claimRef).claimName }}
      {{- end }}
  {{- end }}
{{- end }}
{{- end }}

{{- define "GeoserverCloud.volumeMounts" -}}
{{- $svc := .svc -}}
{{- range $mount := $svc.volumeMounts }}
- name: {{ $mount.name }}
  mountPath: {{ $mount.mountPath }}
  {{- if $mount.subPath }}
  subPath: {{ $mount.subPath }}
  {{- end }}
  {{- if $mount.readOnly }}
  readOnly: {{ $mount.readOnly }}
  {{- end }}
{{- end }}
{{- end }}