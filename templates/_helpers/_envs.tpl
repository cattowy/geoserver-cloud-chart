{{- define "GeoserverCloud.env" -}}
{{- $svcEnv := .svc.env | default list }}
{{- $globalEnv := .Values.global.extraEnv | default list }}

{{- $allEnv := concat $svcEnv $globalEnv }}

{{- if eq (len $allEnv) 0 }}
  {{- toYaml (list) }}
{{- else }}
  {{- toYaml $allEnv }}
{{- end }}
{{- end }}

{{- define "GeoserverCloud.rabbitmq.env" -}}
{{- $rabbitmq := .Values.rabbitmq -}}
{{- $username := default "user" $rabbitmq.auth.username -}}
{{- $port := default 5672 $rabbitmq.service.ports.amqp -}}
{{- $host := printf "%s-rabbitmq" .Release.Name -}}
- name: RABBITMQ_HOST
  value: {{ $host | quote }}
- name: RABBITMQ_PORT
  value: {{ printf "%d" (int $port) | quote }}
- name: RABBITMQ_USER
  value: {{ $username | quote }}
{{- if and $rabbitmq.auth.existingPasswordSecret $rabbitmq.auth.existingSecretPasswordKey }}
- name: RABBITMQ_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ $rabbitmq.auth.existingPasswordSecret | quote }}
      key: {{ $rabbitmq.auth.existingSecretPasswordKey | quote }}
{{- else }}
- name: RABBITMQ_PASSWORD
  value: {{ default "bitnami" $rabbitmq.auth.password | quote }}
{{- end -}}
{{- end }}

{{- define "GeoserverCloud.configGitEnv" -}}
{{- $git := .svc.git }}
{{- if $git }}
- name: SPRING_PROFILES_ACTIVE
  value: git
- name: CONFIG_GIT_BASEDIR
  value: /tmp/git_config
- name: CONFIG_NATIVE_PATH
  value: /tmp/config
- name: XDG_CONFIG_HOME
  value: /tmp
- name: SPRING_CLOUD_CONFIG_SERVER_GIT_URI
  value: {{ $git.uri | quote }}
- name: SPRING_CLOUD_CONFIG_SERVER_GIT_DEFAULT_LABEL
  value: {{ $git.branch | default "main" | quote }}

{{- if eq $git.protocol "ssh" }}
- name: SPRING_CLOUD_CONFIG_SERVER_GIT_IGNORE_LOCAL_SSH_SETTINGS
  value: "false"

{{- if $git.ssh.privateKey }}
- name: SPRING_CLOUD_CONFIG_SERVER_GIT_PRIVATE_KEY
  value: {{ $git.ssh.privateKey | quote }}
{{- else if and $git.ssh.privateKeySecret.name $git.ssh.privateKeySecret.key }}
- name: SPRING_CLOUD_CONFIG_SERVER_GIT_PRIVATE_KEY
  valueFrom:
    secretKeyRef:
      name: {{ $git.ssh.privateKeySecret.name }}
      key: {{ $git.ssh.privateKeySecret.key }}
{{- end }}

{{- if $git.ssh.knownHosts }}
- name: SPRING_CLOUD_CONFIG_SERVER_GIT_KNOWN_HOSTS
  value: {{ $git.ssh.knownHosts | quote }}
{{- else if and $git.ssh.knownHostsSecret.name $git.ssh.knownHostsSecret.key }}
- name: SPRING_CLOUD_CONFIG_SERVER_GIT_KNOWN_HOSTS
  valueFrom:
    secretKeyRef:
      name: {{ $git.ssh.knownHostsSecret.name }}
      key: {{ $git.ssh.knownHostsSecret.key }}
{{- end }}

{{- else if eq $git.protocol "http" }}
{{- if $git.http.username }}
- name: SPRING_CLOUD_CONFIG_SERVER_GIT_USERNAME
  value: {{ $git.http.username | quote }}
{{- end }}

{{- if $git.http.password }}
- name: SPRING_CLOUD_CONFIG_SERVER_GIT_PASSWORD
  value: {{ $git.http.password | quote }}
{{- else if and $git.http.passwordSecret.name $git.http.passwordSecret.key }}
- name: SPRING_CLOUD_CONFIG_SERVER_GIT_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ $git.http.passwordSecret.name }}
      key: {{ $git.http.passwordSecret.key }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{- define "GeoserverCloud.allEnv" -}}
{{- $ctx := dict "svc" .svc "Values" .Values "Release" .Release -}}

{{- $parts := list }}

{{- $env1 := (include "GeoserverCloud.env" $ctx) | trim }}
{{- if and (gt (len $env1) 0) (ne $env1 "[]") (ne $env1 "null") }}
  {{- $parts = append $parts $env1 }}
{{- end }}

{{- $env2 := (include "GeoserverCloud.configGitEnv" $ctx) | trim }}
{{- if and (gt (len $env2) 0) (ne $env2 "[]") (ne $env2 "null") }}
  {{- $parts = append $parts $env2 }}
{{- end }}

{{- $env3 := (include "GeoserverCloud.rabbitmq.env" $ctx) | trim }}
{{- if and (gt (len $env3) 0) (ne $env3 "[]") (ne $env3 "null") }}
  {{- $parts = append $parts $env3 }}
{{- end }}

{{- join "\n" $parts }}
{{- end }}