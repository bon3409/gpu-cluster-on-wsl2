#/bin/sh

export CPUS=
export MEMORY=8192
minikube start --driver=docker --gpus all --cpus=$CPUS --memory=$MEMORY -p minikube
