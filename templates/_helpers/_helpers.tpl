{{- define "GeoserverCloud.isStatefulService" -}}
{{- $svcName := . | lower }}
{{- $statefulServices := list "discovery" }}
{{- if has $svcName $statefulServices }}true{{ else }}false{{ end }}
{{- end }}

{{- define "GeoserverCloud.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "GeoserverCloud.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "GeoserverCloud.labels" -}}
helm.sh/chart: {{ include "GeoserverCloud.chart" . }}
{{ include "GeoserverCloud.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "GeoserverCloud.selectorLabels" -}}
app.kubernetes.io/name: {{ include "GeoserverCloud.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "GeoserverCloud.env" -}}
{{- $svcEnv := .svc.env | default list }}
{{- $globalEnv := .Values.global.extraEnv | default list }}
{{- toYaml (concat $svcEnv $globalEnv) -}}
{{- end }}

{{- define "GeoserverCloud.securityContext" -}}
{{- $global := .Values.global.securityContext }}
{{- $local := .svc.securityContext }}
{{- if $global }}
{{ toYaml $global }}
{{- else if $local }}
{{ toYaml $local }}
{{- end }}
{{- end }}

{{- define "GeoserverCloud.probe" -}}
{{- $probe := .probe }}
{{- $svc := .svc }}
{{- if $probe.httpGet }}
httpGet:
  path: {{ $probe.httpGet.path }}
  port: {{ $svc.service.healthPort }}
{{- if $probe.httpGet.scheme }}
  scheme: {{ $probe.httpGet.scheme }}
{{- end }}
{{- else if $probe.tcpSocket }}
tcpSocket:
  port: {{ $svc.service.healthPort }}
{{- end }}
{{- if $probe.initialDelaySeconds }}
initialDelaySeconds: {{ $probe.initialDelaySeconds }}
{{- end }}
{{- if $probe.periodSeconds }}
periodSeconds: {{ $probe.periodSeconds }}
{{- end }}
{{- if $probe.timeoutSeconds }}
timeoutSeconds: {{ $probe.timeoutSeconds }}
{{- end }}
{{- if $probe.failureThreshold }}
failureThreshold: {{ $probe.failureThreshold }}
{{- end }}
{{- if $probe.successThreshold }}
successThreshold: {{ $probe.successThreshold }}
{{- end }}
{{- end }}