# Volcano GPU Job Configuration for WSL2 with GTX 1050

## Purpose
This configuration provides a Volcano Job to run GPU‑accelerated workloads (e.g., TensorFlow) on a Kubernetes cluster hosted in WSL2 using an NVIDIA GeForce GTX 1050.

## Files
- `volcano-job-gpu.yaml`: Volcano Job requesting one GPU, using the TensorFlow GPU image, and setting required environment variables for the NVIDIA device plugin.

## Why This Setup?
- **Volcano**: Designed for batch workloads, offers gang scheduling, job priority, and preemption—ideal for ML training.
- **GPU Request**: `nvidia.com/gpu: 1` tells the NVIDIA device plugin to allocate a GPU from the host (WSL2 forwards the GTX 1050).
- **Environment Variables**: `NVIDIA_VISIBLE_DEVICES=all` and `NVIDIA_DRIVER_CAPABILITIES=compute,utility` ensure the container sees the GPU and can use compute/utility drivers.
- **Shared Memory (`/dev/shm`)**: Many GPU frameworks (TensorFlow, PyTorch) need large shared memory for efficient communication; we mount an `emptyDir` medium Memory.
- **Node Selector**: Uses the label `feature.node.kubernetes.io/pci-0300.present=true` that the NVIDIA device plugin adds to nodes with GPUs, ensuring the pod lands on a GPU‑enabled node.
- **Restart Policy**: `OnFailure` with `Evicted → Restart` policy makes the job resilient to preemption.

## Applicable Scenarios
- Deep learning model training (TensorFlow, PyTorch) on a single GPU.
- Batch inference jobs.
- GPU‑accelerated data processing (RAPIDS, cuDF).
- CI/CD pipelines that need GPU for testing.
- Any short‑lived, GPU‑intensive batch workload where gang scheduling improves resource utilization.

## How to Use
1. Ensure the NVIDIA device plugin is running in the WSL2‑based Kubernetes cluster.
2. Apply the job:
   ```bash
   kubectl apply -f volcano-job-gpu.yaml
   ```
3. Monitor:
   ```bash
   kubectl get jobs.batch.volcano.sh -w
   kubectl logs -f <pod-name>
   ```

## Notes
- The GTX 1050 has limited compute capability (CC 6.1); verify that your container image supports this architecture.
- For multiple GPUs, adjust `replicas` and `nvidia.com/gpu` limits accordingly, and ensure the node has enough GPUs.
- If using a different framework, replace the `image` and `command` fields.
