# templates/helpers.tpl
# This file contains reusable Go template functions for generating labels and names.
{{- define "prometheus-operator-community.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "prometheus-operator-community.fullname" -}}
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

{{- define "prometheus-operator-community.labels" -}}
helm.sh/chart: {{ include "prometheus-operator-community.chart" . }}
{{ include "prometheus-operator-community.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "prometheus-operator-community.selectorLabels" -}}
app.kubernetes.io/name: {{ include "prometheus-operator-community.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "prometheus-operator-community.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "prometheus-operator-community.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "prometheus-operator-community.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
