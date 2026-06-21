# Volcano GPU Job Configuration for WSL2 with GTX 1050 Ti

## Purpose

This directory provides Volcano-based GPU job configurations for running batch workloads (e.g., TensorFlow) on a Kubernetes cluster in WSL2 with an NVIDIA GeForce GTX 1050 Ti.

## Files

| File | Description |
|---|---|
| `install.sh` | Install Volcano SHeduler and dashboard via Helm |
| `queue.yaml` | Queue definition (`gpu-queue`, priority 100, 1 GPU, reclaimable) |
| `queue-job.yaml` | Job that submits to `gpu-queue` instead of default queue |
| `vcjob-gpu-test.yaml` | Minimal GPU job (vectoradd, no queue, `restartPolicy: Never`) |
| `volcano-job-gpu.yaml` | TensorFlow job (2 replicas, uses `/dev/shm` volume, `OnFailure`) |
| `dashboard.yaml` | Volcano dashboard Deployment + ServiceAccount + RBAC |

## Why This Setup?

- **Volcano**: Designed for batch workloads, provides gang scheduling, job priority, and preemption—ideal for ML training.
- **GPU Request**: `nvidia.com/gpu: 1` tells the NVIDIA device plugin to allocate a GPU from the host (WSL2 forwards the GTX 1050 Ti).
- **Shared Memory (`/dev/shm`)**: Many GPU frameworks (TensorFlow, PyTorch) need large shared memory; `volcano-job-gpu.yaml` mounts an `emptyDir` medium Memory at `/dev/shm`.
- **Node Selector**: `volcano-job-gpu.yaml` uses `feature.node.kubernetes.io/pci-1414.present=true` to pin pods to the GPU node. Note: other job files use `restartPolicy: Never` (no node selector).
- **Restart Policy**: `volcano-job-gpu.yaml` uses `OnFailure`; `queue-job.yaml` and `vcjob-gpu-test.yaml` use `PodFailed → RestartJob` policy.

## Queue Architecture

```
gpu-queue (priority: 100, weight: 1, GPU: 1)
  └── queue-job.yaml → submits work to gpu-queue
  └── volcano-job-gpu.yaml → uses default queue (no queue specified)
```

## How to Use

### 1. Install Volcano

```bash
./install.sh
```

### 2. Create Queue

```bash
kubectl apply -f queue.yaml
```

### 3. Submit a Job

**Using default queue:**
```bash
kubectl apply -f volcano-job-gpu.yaml
```

**Using gpu-queue:**
```bash
kubectl apply -f queue-job.yaml
```

**Minimal GPU test:**
```bash
kubectl apply -f vcjob-gpu-test.yaml
```

### 4. Monitor

```bash
kubectl get jobs.batch.volcano.sh -w
kubectl logs -f <pod-name>
```

### 5. Access Dashboard

```bash
kubectl -n volcano-system port-forward svc/volcano-dashboard 8080:80 --address 0.0.0.0
# Open http://localhost:8080
```

## Applicable Scenarios

- Deep learning model training (TensorFlow, PyTorch) on a single GPU
- Batch inference jobs
- GPU‑accelerated data processing (RAPIDS, cuDF)
- CI/CD pipelines that need GPU for testing
- Any short‑lived, GPU‑intensive batch workload where gang scheduling or job priority improves resource utilization

## Notes

- The GTX 1050 Ti has limited compute capability (CC 6.1); verify that your container image supports this architecture.
- For multiple GPUs, adjust `replicas` and `nvidia.com/gpu` limits accordingly, and ensure the node has enough GPUs.
- `queue-job.yaml` requires the `gpu-queue` to exist first (`kubectl apply -f queue.yaml`).
- The `pci-1414` in `volcano-job-gpu.yaml`'s nodeSelector matches the PCIe ID exposed by the GPU Operator on this WSL2 setup—verify with `kubectl get node minikube -o jsonpath='{.metadata.labels}'` if you redeploy on different hardware.