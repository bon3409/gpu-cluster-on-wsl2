# Phase 2 — GPU Scheduling (Weeks 5-8)

**Duration:** 4 weeks (10-20 hrs/week)

**Goal:** Master Volcano scheduler, time-slicing internals, gang scheduling, and workload placement

**Prerequisite:** Phase 1 complete (observability baseline established)

---

## Week 5: Volcano Internals

### Tasks

#### 5.1 Study Volcano Architecture
```bash
kubectl get pods -n volcano-system
kubectl describe pod -n volcano-system -l app=volcano-scheduler
```

Document:
- Scheduler pod architecture
- How it integrates with kube-scheduler
- Scheduling queue architecture

#### 5.2 Trace Scheduling Cycle
Enable scheduler debug logging:
```bash
kubectl patch configmap/volcano-scheduler-configmap -n volcano-system \
  --type merge -p '{"data":{"scheduler.conf":"KubeGlobal.Client: 200\nKubeManager.Client: 200\n"}}}}'
```

Trace pod scheduling: apply job → observe scheduler logs → pod bound

#### 5.3 Understand Gang Scheduling
Study gang scheduling semantics:
- All-or-nothing job placement
- `minAvailable` parameter
- What happens when partial resources available

#### 5.4 Experiment with minAvailable
```bash
# Create job with 4 replicas, minAvailable=4
# Observe: job waits until all 4 GPUs available
# Compare: set minAvailable=2, observe partial scheduling
```

Document behavior differences

### Deliverables
- [ ] Volcano architecture study notes
- [ ] Scheduling cycle trace report
- [ ] Gang scheduling behavior experiments

---

## Week 6: Time-Slicing Mastery

### Tasks

#### 6.1 Current Config Review
```bash
kubectl get configmap -n gpu-operator
kubectl get configmap nvidia-time-slicing -n gpu-operator -o yaml
```

Document current configuration and behavior

#### 6.2 Replica Count Tuning
Test with different replica counts:
```bash
# Test 2 replicas
kubectl patch configmap nvidia-time-slicing -n gpu-operator \
  --type merge -p '{"data":{"time-slicing-config.yaml":"..."}}'

# Run concurrent gpu-burn pods and measure:
# - Per-replica utilization
# - Context switch overhead
# - Temperature stability
```

Record metrics for each configuration

#### 6.3 Context Switching Overhead
Measure overhead by:
- Comparing single-job throughput vs multi-replica throughput
- Calculating efficiency: `(sum of replica throughput) / single job throughput`

#### 6.4 Find Optimal Slice Count
Based on your 1050 Ti (4GB memory, 75W TDP):
- Small ML inference jobs: recommend X replicas
- Medium training jobs: recommend Y replicas
- Large batch jobs: recommend Z replicas

### Deliverables
- [ ] Time-slicing configuration variants tested
- [ ] Benchmark data for each replica count
- [ ] Optimal slice count recommendations

---

## Week 7: Queue Policies

### Tasks

#### 7.1 Queue Configuration Deep Dive
```bash
kubectl get queue -n volcano-system
kubectl describe queue volcano-queue
```

Study:
- Queue resource limits
- Priority classes
- Reclaim policy

#### 7.2 Priority Levels
Configure multiple priority levels:
```bash
# Create high-priority and low-priority jobs
# Submit both simultaneously
# Observe: high-priority preempts low-priority
```

Document preemption behavior

#### 7.3 Fair Share Configuration
Configure fair share across queues:
```yaml
# queue.yaml
spec:
  fairShare:
    - weight: 1
  reclamation:
    minReclaimable: {"nvidia.com/gpu": 1}
```

Test with competing workloads

#### 7.4 Priority Inversion Study
Study scenario: low-priority job holds GPU, high-priority job queued
- Preemption vs waiting tradeoffs
- Starvation prevention

### Deliverables
- [ ] Queue configuration guide
- [ ] Priority/preemption test results
- [ ] Fair share configuration examples

---

## Week 8: Workload Placement

### Tasks

#### 8.1 Bin-Packing Strategy
Design bin-packing for GPU allocation:
- First-fit vs best-fit for GPU jobs
- Fragmentation impact on scheduling

#### 8.2 Anti-Affinity Rules
```yaml
# Prevent pods from same job on same node
affinity:
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchLabels:
            app: gpu-job
        topologyKey: kubernetes.io/hostname
```

Test placement distribution

#### 8.3 Node Selector Constraints
Use custom labels for placement:
```yaml
nodeSelector:
  hardware-type: gpu
  nvidia.com/gpu.product: WSL-GPU
```

Test constraint effectiveness

#### 8.4 Placement Best Practices
Document:
- When to use anti-affinity
- Node selector patterns
- Taint/toleration use cases

### Deliverables
- [ ] Bin-packing strategy document
- [ ] Placement configuration examples
- [ ] Best practices guide

---

## Phase 2 Final Deliverables

1. `roadmap/phase2/volcano-internals.md` — Scheduler architecture study
2. `roadmap/phase2/time-slicing-benchmark.md` — Replica count benchmarks
3. `roadmap/phase2/queue-configurations/` — Queue policy examples
4. `roadmap/phase2/placement-strategy.md` — Workload placement guide
5. `roadmap/phase2/scheduling-debug-logs.md` — Scheduling trace logs

---

## Success Criteria

- [ ] Gang scheduling behavior fully understood
- [ ] Time-slicing optimal replica count determined
- [ ] Queue policies tested and documented
- [ ] Workload placement strategies mastered

---

## Next Phase Preview

Phase 3 focuses on **MLOps Foundations** — NGC containers, CI/CD for ML, and inference serving basics.