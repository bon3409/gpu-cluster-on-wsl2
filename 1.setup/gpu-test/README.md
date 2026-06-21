# How to test GPU support in Minikube

1. Simple GPU test

```bash
$ kubectl apply -f gpu-test.yaml
$ kubectl logs -f gpu-test
```

2. Pressure test

```bash
$ kubectl apply -f gpu-burn-30s.yaml
$ kubectl logs -f gpu-burn-30s
```
