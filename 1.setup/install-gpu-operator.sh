#/bin/sh

NODE_STATUS=$(kubectl get node minikube -o jsonpath='{.status.conditions[?(@.type=="Ready")].type}')
NVIDIA_GPU_OPERATOR_HELM_CHART_VERSION="26.3.3"

if [ "$NODE_STATUS" != "Ready" ]; then
    echo "Node is not ready. Please ensure minikube is running and the node is in Ready state."
    exit 1
fi

helm repo add nvidia https://helm.ngc.nvidia.com/nvidia && helm repo update

kubectl label node minikube hardware-type=gpu --overwrite
kubectl label node minikube nvidia.com/gpu.deploy.device-plugin=true --overwrite
kubectl label node minikube nvidia.com/gpu.product=WSL-GPU --overwrite
kubectl label node minikube feature.node.kubernetes.io/pci-10de.present=true --overwrite

helm upgrade --install gpu-operator nvidia/gpu-operator \
    -n gpu-operator \
    --create-namespace \
    --version $NVIDIA_GPU_OPERATOR_HELM_CHART_VERSION \
    --set driver.enabled=false \
    --set toolkit.enabled=false \
    --set mig.enabled=false \
    --set devicePlugin.enabled=true \
    --set validator.driver.env[0].name=DISABLE_DEV_CHAR_SYMLINK_CREATION \
    --set-string validator.driver.env[0].value="true"
