# GPU Cluster on WSL2

## Background

This project sets up a **Minikube + GPU Operator** cluster on **WSL2**, targeting an older **NVIDIA GeForce GTX 1050 Ti** (Pascal architecture, GP107, Compute Capability 6.1) for GPU workloads.

The GTX 1050 Ti is a legacy GPU with limited out-of-the-box support in the K8s ecosystem, requiring the following custom node labels:

| Label Key | Value | Purpose |
|---|---|---|
| `hardware-type=gpu` | `gpu` | Marks node as a GPU node |
| `nvidia.com/gpu.deploy.device-plugin=true` | `true` | Forces NVIDIA Device Plugin deployment |
| `nvidia.com/gpu.product=WSL-GPU` | `WSL-GPU` | Specifies GPU product name |
| `feature.node.kubernetes.io/pci-10de.present=true` | `true` | PCI ID to identify NVIDIA GPU |

`gpu-burn-30s.yaml` also specifies `COMPUTE=61` to compile for the GTX 1050 Ti's Compute Capability.

---

## Architecture Overview

```
WSL2 Host (Windows)
 └── GPU (GTX 1050 Ti)
      └── Docker / Container Runtime (nvidia-container-toolkit)
           └── Minikube (Docker driver, --gpus all)
                ├── kube-system
                │    └── nvidia-device-plugin (GPU Operator)
                ├── gpu-operator
                │    └── gpu-operator (Driver + Device Plugin)
                ├── monitoring
                │    └── kube-prometheus-stack
                │         ├── Prometheus
                │         └── Grafana (+ DCGM Dashboard)
                ├── volcano-system
                │    └── Volcano (Batch Scheduler)
                └── default
                     └── GPU Jobs (TensorFlow, gpu-burn, etc.)
```

---

## Directory Structure

```
./
├── 0.pre-install/              # Host-level pre-installed software
│   ├── install-docker.sh       # Docker Engine + Docker Compose
│   ├── install-minikube.sh     # kubectl, minikube, Helm, k9s
│   └── install-nvidia-container-toolkit.sh
│
├── 1.setup/                    # K8s cluster setup
│   ├── minikube.sh              # Start minikube (--driver=docker --gpus all)
│   ├── install-gpu-operator.sh  # Install GPU Operator + custom node labels
│   └── gpu-test/
│       ├── gpu-test.yaml        # Basic CUDA vectoradd Pod
│       ├── gpu-burn-30s.yaml    # GPU stress test Pod (COMPUTE=61)
│       └── README.md
│
├── helm/
│   ├── volcano/
│   │   ├── install.sh            # Install Volcano Scheduler
│   │   ├── queue.yaml            # Queue definition (1 GPU, reclaimable)
│   │   ├── queue-job.yaml        # QueueJob
│   │   ├── volcano-job-gpu.yaml  # Volcano Job (TensorFlow, 2 replicas)
│   │   ├── dashboard.yaml        # Volcano Dashboard
│   │   └── README.md
│   └── kube-prometheus-stack/
│       ├── install.sh            # Install Prometheus + Grafana
│       ├── values.yaml           # Grafana + DCGM/Volcano scrape configs
│       └── dashboard/
│           └── dcgm-dashboard-configmap.yaml
│
├── time-slicing/
│   └── time-slicing-config.yaml # Time-Slicing ConfigMap (replicas: 4)
│   └── enable-time-slicing.sh   # Enable Time-Slicing feature
```

---

## Deployment Steps

### Step 1: Host Pre-Install

```bash
./0.pre-install/install-docker.sh
./0.pre-install/install-nvidia-container-toolkit.sh
./0.pre-install/install-minikube.sh
```

### Step 2: Start Minikube

```bash
./1.setup/minikube.sh
```

### Step 3: Install GPU Operator

```bash
./1.setup/install-gpu-operator.sh
```

### Step 4: Verify GPU

```bash
kubectl apply -f 1.setup/gpu-test/gpu-test.yaml
kubectl logs -f gpu-test
```

### Step 5: (Optional) Install Monitoring

```bash
./helm/kube-prometheus-stack/install.sh
```

### Step 6: (Optional) Install Volcano Scheduler

```bash
./helm/volcano/install.sh
```

---

## Key Design Decisions

### Time-Slicing (GPU Partitioning)

`time-slicing-config.yaml` virtualizes 1 GTX 1050 Ti into 4 GPU replicas, allowing multiple small workloads to be scheduled concurrently.

### Legacy GPU Label Customization

`install-gpu-operator.sh` explicitly writes multiple labels to the `minikube` node to work around GPU Operator's assumptions about modern GPUs.

### Volcano Gang Scheduling

Volcano provides gang scheduling for batch jobs, ensuring all replicas must succeed simultaneously before any can start, preventing partial GPU resource allocation.