#/bin/sh

kubectl delete -f time-slicing-config.yaml

helm upgrade gpu-operator nvidia/gpu-operator \
    -n gpu-operator \
    --create-namespace \
    --set driver.enabled=false \
    --set toolkit.enabled=false \
    --set mig.enabled=false \
    --set devicePlugin.enabled=true \
    --set validator.driver.env[0].name=DISABLE_DEV_CHAR_SYMLINK_CREATION \
    --set-string validator.driver.env[0].value="true"

# GPU Feature Discovery (GFD) 有時會有標籤快取。為了防止 K8s 排程器誤判，我們手動將先前打上的「欺騙標籤」以及 GFD 產生的共享標籤進行修正或移除
kubectl label node minikube nvidia.com/gpu.sharing-strategy- --overwrite
kubectl label node minikube nvidia.com/gpu.replicas- --overwrite
kubectl label node minikube nvidia.com/gpu.product=NVIDIA-GeForce-GTX-1050-Ti-with-Max-Q-Design --overwrite

# Delete existing GPU Operator pods to apply the new time-slicing configuration
kubectl delete pod -n gpu-operator --all