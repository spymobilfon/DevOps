# Loki Helm Chart

## Prerequisites

Make sure you have Helm [installed](https://helm.sh/docs/using_helm/#installing-helm).

## Get Repo Info

```console
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

_See [helm repo](https://helm.sh/docs/helm/helm_repo/) for command documentation._


## Deploy Loki only

```bash
helm upgrade --install loki grafana/loki
```

## Run Loki behind https ingress

If Loki and Promtail are deployed on different clusters you can add an Ingress in front of Loki.
By adding a certificate you create an https endpoint. For extra security enable basic authentication on the Ingress.

In Promtail set the following values to communicate with https and basic auth

```yaml
loki:
  serviceScheme: https
  user: user
  password: pass
```

Sample helm template for ingress:

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
annotations:
    kubernetes.io/ingress.class: {{ .Values.ingress.class }}
    ingress.kubernetes.io/auth-type: "basic"
    ingress.kubernetes.io/auth-secret: {{ .Values.ingress.basic.secret }}
name: loki
spec:
rules:
- host: {{ .Values.ingress.host }}
    http:
    paths:
    - backend:
        serviceName: loki
        servicePort: 3100
tls:
- secretName: {{ .Values.ingress.cert }}
    hosts:
    - {{ .Values.ingress.host }}
```

## Use Loki Alerting

You can add your own alerting rules with `alerting_groups` in `values.yaml`. This will create a ConfigMap with your rules and additional volumes and mounts for Loki.

This does **not** enable the Loki `ruler` component which does the evaluation of your rules. The `values.yaml` file does contain a simple example. For more details take a look at the official [alerting docs](https://grafana.com/docs/loki/latest/alerting/).