#/bin/sh

export HELM_CHART_VERSION=1.10.1

helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm upgrade --install alloy grafana/alloy \
    --values values.yaml \
    --namespace monitoring \
    --create-namespace \
    --version $HELM_CHART_VERSION
