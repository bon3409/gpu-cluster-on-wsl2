#/bin/sh

helm repo add volcano-sh https://volcano-sh.github.io/helm-charts

helm repo update

helm install volcano volcano-sh/volcano -n volcano-system --create-namespace

# Install volcano dashboard
kubectl apply -f dashboard.yaml
kubectl -n volcano-system port-forward svc/volcano-dashboard 8080:80 --address 0.0.0.0
