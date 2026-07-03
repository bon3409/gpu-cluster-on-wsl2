# Phase 3 — MLOps Foundations (Weeks 9-12)

**Duration:** 4 weeks (10-20 hrs/week)

**Goal:** Understand ML workload patterns, CI/CD for ML, and inference serving basics

**Prerequisite:** Phase 1 and 2 complete (observability + scheduling)

---

## Week 9: NGC Containers & Workload Patterns

### Tasks

#### 9.1 NGC Catalog Familiarization
Visit https://catalog.ngc.nvidia.com
- Browse available containers (PyTorch, TensorFlow, Triton, etc.)
- Understand versioning scheme (e.g., 24.04-tf2-py3)
- Note container categories: training, inference, data science

#### 9.2 Pull and Run NGC Containers
```bash
# Pull TensorFlow container
docker pull nvcr.io/nvidia/tensorflow:24.04-tf2-py3

# Pull PyTorch container
docker pull nvcr.io/nvidia/pytorch:24.04-py3

# Run basic test in each
docker run --rm --gpus all nvcr.io/nvidia/tensorflow:24.04-tf2-py3 \
  python -c "import tensorflow as tf; print(tf.reduce_sum(tf.random.normal([1000,1000])))"
```

#### 9.3 Understand Container GPU Enablement
Study:
- How nvidia-container-toolkit enables GPU in containers
- Container manifest and GPU driver requirements
- Common compatibility issues

#### 9.4 Identify ML Workload Patterns
Study common patterns:
- Training jobs (long-running, GPU-intensive)
- Inference jobs (low-latency, batching)
- Distributed training (multi-GPU, gradient sync)
- Data preprocessing (CPU-bound, feeding GPU)

Document characteristics of each

### Deliverables
- [ ] NGC container usage guide
- [ ] GPU enablement explanation document
- [ ] ML workload pattern matrix

---

## Week 10: CI/CD for ML Pipelines

### Tasks

#### 10.1 Sample ML Pipeline Architecture
Design a basic ML pipeline:
```
Code Commit → Build Image → Unit Tests → Integration Tests → Model Training → 
Model Validation → Artifact Storage → Deployment
```

#### 10.2 Implement Training Pipeline
Create GitHub Actions workflow `.github/workflows/ml-pipeline.yml`:
```yaml
name: ML Training Pipeline
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build Docker image
        run: docker build -t ml-train:${{ github.sha }} .
      - name: Run training
        run: docker run --gpus all ml-train:${{ github.sha }}
      - name: Upload model artifact
        uses: actions/upload-artifact@v4
        with:
          name: model
          path: ./model.pt
```

#### 10.3 Add Model Validation
- Implement validation step (accuracy metrics, loss thresholds)
- Fail pipeline if metrics below threshold
- Document acceptance criteria

#### 10.4 Model Registry Concept
Implement artifact versioning:
- Tag model with git commit SHA
- Store model metadata (training dataset, hyperparameters)
- Document model registry pattern

### Deliverables
- [ ] GitHub Actions ML pipeline example
- [ ] Model validation implementation
- [ ] Model registry pattern document

---

## Week 11: Inference Serving

### Tasks

#### 11.1 Deploy Triton Inference Server
```bash
# Using Helm chart or direct deployment
kubectl apply -f triton-server.yaml
```

#### 11.2 Model Loading
- Upload a simple model to Triton
- Configure model repository
- Verify model loads successfully

#### 11.3 Understand Batching
Study Triton batching:
- Static batching vs dynamic batching
- Batching parameters: max_batch_size, preferred_batch_size
- Performance impact of batching

#### 11.4 Benchmark Inference
```bash
# Use perf analyzer or curl for testing
# Measure throughput (infer/sec)
# Measure latency (ms per inference)
```

Document benchmark results

### Deliverables
- [ ] Triton deployment configs
- [ ] Model repository configuration
- [ ] Inference benchmark report

---

## Week 12: Distributed Training Basics

### Tasks

#### 12.1 Study Distributed Training Concepts
Learn:
- Data parallelism (each GPU has full model, gradient sync)
- Model parallelism (model split across GPUs)
- Pipeline parallelism (staged execution)
- Tensor parallelism (tensor shard across GPUs)

#### 12.2 Simulate on Single GPU
On your 1050 Ti, simulate multi-GPU concepts:
```python
# Gradient accumulation (simulate larger batch)
batch_size = 32
accum_steps = 4
effective_batch = batch_size * accum_steps
```

#### 12.3 Understand NCCL Basics
- NCCL (NVIDIA Collective Communications) for multi-GPU
- AllReduce, Broadcast, Reduce operations
- How distributed training uses NCCL

#### 12.4 Architecture Study
Study NVIDIA distributed training stack:
- PyTorch DDP (DistributedDataParallel)
- Horovod (Uber's distributed training framework)
- DeepSpeed (Microsoft's optimization library)

### Deliverables
- [ ] Distributed training concepts document
- [ ] Gradient accumulation example
- [ ] NCCL operations explanation

---

## Phase 3 Final Deliverables

1. `roadmap/phase3/ngc-container-guide.md` — NGC usage guide
2. `roadmap/phase3/ml-pipeline/` — CI/CD pipeline code
3. `roadmap/phase3/triton-deployment/` — Triton configs
4. `roadmap/phase3/inference-benchmark.md` — Benchmark results
5. `roadmap/phase3/distributed-training-study.md` — Distributed training notes

---

## Success Criteria

- [ ] NGC containers running on your cluster
- [ ] CI/CD pipeline builds and trains model
- [ ] Triton inference server deployed
- [ ] Distributed training concepts understood

---

## Next Phase Preview

Phase 4 focuses on **Cluster Operations** — multi-node concepts, fault tolerance, cost optimization, and production deployment patterns.