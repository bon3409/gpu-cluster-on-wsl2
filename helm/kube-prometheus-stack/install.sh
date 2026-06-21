#/bin/sh

export HELM_CHART_VERSION=86.2.2

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# specific version of kube-prometheus-stack to install
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
    --values values.yaml \
    --namespace monitoring \
    --create-namespace \
    --version $HELM_CHART_VERSION

kubectl apply -f dashboard/dcgm-dashboard-configmap.yaml -n monitoring
