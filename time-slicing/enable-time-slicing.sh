#/bin/sh

NVIDIA_GPU_OPERATOR_HELM_CHART_VERSION="26.3.3"

kubectl apply -f time-slicing-config.yaml

helm upgrade gpu-operator nvidia/gpu-operator \
    -n gpu-operator \
    --create-namespace \
    --version $NVIDIA_GPU_OPERATOR_HELM_CHART_VERSION \
    --set driver.enabled=false \
    --set toolkit.enabled=false \
    --set mig.enabled=false \
    --set devicePlugin.enabled=true \
    --set devicePlugin.config.name=time-slicing-config \
    --set devicePlugin.config.default=config \
    --set validator.driver.env[0].name=DISABLE_DEV_CHAR_SYMLINK_CREATION \
    --set-string validator.driver.env[0].value="true"

# Delete existing GPU Operator pods to apply the new time-slicing configuration
kubectl delete pod -n gpu-operator --all