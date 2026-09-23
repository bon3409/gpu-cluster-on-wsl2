#/bin/sh

export CPUS=4
export MEMORY=8192

SCRIPT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)

minikube start \
    --driver=docker \
    --mount \
    --mount-string="$SCRIPT_DIR/data:/mnt/data" \
    --gpus all \
    --cpus=$CPUS \
    --memory=$MEMORY \
    -p minikube
