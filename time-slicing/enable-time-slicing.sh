#/bin/sh

kubectl apply -f time-slicing-config.yaml

helm upgrade gpu-operator nvidia/gpu-operator \
    -n gpu-operator \
    --create-namespace \
    --set driver.enabled=false \
    --set toolkit.enabled=false \
    --set mig.enabled=false \
    --set devicePlugin.enabled=true \
    --set devicePlugin.config.name=nvidia-device-plugin-config \
    --set devicePlugin.config.default=config \
    --set validator.driver.env[0].name=DISABLE_DEV_CHAR_SYMLINK_CREATION \
    --set-string validator.driver.env[0].value="true"

# Delete existing GPU Operator pods to apply the new time-slicing configuration
kubectl delete pod -n gpu-operator --all