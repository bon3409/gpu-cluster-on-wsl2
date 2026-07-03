# Phase 1 — GPU Observability (Weeks 1-4)

**Duration:** 4 weeks (10-20 hrs/week)

**Goal:** Master DCGM metrics, build production-grade observability stack, establish GPU performance baselines for GTX 1050 Ti

---

## Prerequisites

- [ ] Minikube running with GPU Operator installed
- [ ] kube-prometheus-stack installed (optional but recommended)
- [ ] DCGM exporter running in `gpu-operator` namespace
- [ ] Access to Grafana (if installed)

---

## Week 1: DCGM Deep Dive

### Tasks

#### 1.1 Verify DCGM Exporter
```bash
kubectl get pods -n gpu-operator
kubectl logs -n gpu-operator -l app=nvidia-dcgm-exporter
curl :9400/metrics  # if port-forwarded
```

#### 1.2 Catalog All DCGM Metrics
Document every metric exposed. Key ones for GTX 1050 Ti:

| Metric | Description | GTX 1050 Ti Range |
|--------|-------------|-------------------|
| `DCGM_FI_DEV_GPU_UTIL` | GPU utilization % | 0-100 |
| `DCGM_FI_DEV_MEM_COPY_UTIL` | Memory utilization % | 0-100 |
| `DCGM_FI_DEV_FB_USED` | Frame buffer memory used (MB) | 0-4096 |
| `DCGM_FI_DEV_FB_FREE` | Frame buffer memory free (MB) | 0-4096 |
| `DCGM_FI_DEV_TEMP` | GPU temperature (C) | 0-~90 |
| `DCGM_FI_DEV_POWER_USAGE` | Power draw (W) | 0-75 |
| `DCGM_FI_DEV_PCIE_TX_THROUGHPUT` | PCIe TX (KB/s) | varies |
| `DCGM_FI_DEV_PCIE_RX_THROUGHPUT` | PCIe RX (KB/s) | varies |
| `DCGM_FI_DEV_SM_CLOCK` | SM clock frequency (MHz) | 1000-1911 |
| `DCGM_FI_DEV_MEM_CLOCK` | Memory clock frequency (MHz) | 3004 |
| `DCGM_FI_DEV_XID_ERRORS` | Xid error count | 0 (healthy) |

#### 1.3 Build Custom Grafana Dashboard
Create dashboard with panels:
- GPU Utilization (area chart, 1s resolution)
- Memory Usage (used/free stacked)
- Temperature (with threshold line at 85C)
- Power Draw (with max line at 75W TDP)
- PCIe Throughput (TX + RX)
- SM/Memory Clock frequencies
- Xid Errors (should always be 0)

#### 1.4 Document Metric Definitions
Write doc: `roadmap/phase1/dcgm-metrics-reference.md`
- Each metric explanation
- GTX 1050 Ti specifications (TDP, memory, clocks)
- Healthy ranges vs warning thresholds

### Deliverables
- [ ] DCGM metrics catalog
- [ ] Custom Grafana dashboard JSON
- [ ] Metric reference document

---

## Week 2: Workload Profiling

### Tasks

#### 2.1 Run gpu-burn for Baseline
```bash
kubectl apply -f 1.setup/gpu-test/gpu-burn-30s.yaml
kubectl logs -f gpu-burn
```
Measure:
- Sustained GPU utilization (should be ~100% for compute test)
- Temperature rise over time
- Power draw at sustained load

#### 2.2 Run TensorFlow/PyTorch Workload
Use sample ML workload to profile real-world behavior:
```bash
# TensorFlow example
kubectl run tf-mnist --image=nvidia/tensorflow:24.04-tf2-py3 -- \
  python -c "import tensorflow as tf; print(tf.reduce_sum(tf.random.normal([1000,1000])))"
```

Measure:
- Initial GPU utilization spike
- Memory allocation pattern
- Utilization curve over time

#### 2.3 Identify Bottlenecks
Analyze:
- Is workload memory-bound? (high FB_USED, lower SM_UTIL)
- Is workload compute-bound? (high SM_UTIL)
- PCIe bottleneck? (high PCIe throughput relative to GPU compute)

#### 2.4 Profile Time-Slicing Impact
With time-slicing enabled (4 replicas):
```bash
# Run 4 concurrent gpu-burn pods
kubectl logs gpu-burn-1 &
kubectl logs gpu-burn-2 &
kubectl logs gpu-burn-3 &
kubectl logs gpu-burn-4 &
```
Measure:
- Individual utilization per slice
- Context switching overhead
- Temperature under multi-load

### Deliverables
- [ ] Gpu-burn profiling report
- [ ] ML workload profiling report
- [ ] Time-slicing impact analysis

---

## Week 3: Alerting & Automation

### Tasks

#### 3.1 Configure Prometheus Alerting Rules
Create `prometheus-alerts.yaml`:
```yaml
groups:
  - name: gpu-alerts
    rules:
      - alert: GPUHighTemperature
        expr: DCGM_FI_DEV_TEMP > 85
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "GPU temperature high"
          description: "GPU temperature is {{ $value }}C"
      - alert: GPUCriticalTemperature
        expr: DCGM_FI_DEV_TEMP > 90
        for: 1m
        labels:
          severity: critical
      - alert: GPUMemoryHigh
        expr: DCGM_FI_DEV_FB_USED / DCGM_FI_DEV_FB_FREE > 0.95
        for: 5m
      - alert: GPUXidErrors
        expr: DCGM_FI_DEV_XID_ERRORS > 0
        for: 0m
```

#### 3.2 Set Up Webhook Notifications
Configure alertmanager for Slack/PagerDuty webhook:
```yaml
# alertmanager-config.yaml
receivers:
  - name: slack
    slack_configs:
      - webhook_url: YOUR_WEBHOOK_URL
        channel: "#gpu-alerts"
```

#### 3.3 Build Alert Runbooks
For each alert type, document:
- Root cause analysis steps
- Mitigation actions
- Escalation path
- Prevention measures

#### 3.4 Test Alert Thresholds
- Trigger high temp alert with sustained gpu-burn
- Verify alerting delays
- Refine thresholds based on false positives/negatives

### Deliverables
- [ ] Alert rules YAML
- [ ] Alertmanager config
- [ ] Runbook documents per alert

---

## Week 4: Capacity Planning Baseline

### Tasks

#### 4.1 Time-Slicing Overhead Benchmark
Vary replica count and measure:
- 1 replica: baseline performance
- 2 replicas: degradation %
- 4 replicas: degradation % (current config)
- 6 replicas: degradation %
- 8 replicas: degradation %

Measure: effective GPU time per replica, context switch overhead

#### 4.2 Calculate Effective Capacity
For each workload type:
```
Effective_GPU_Per_Replica = Baseline_Util / Num_Replicas * (1 - Overhead)
```

#### 4.3 Build Capacity Planning Spreadsheet
Document:
- Max concurrent jobs per GPU slice (for small vs large workloads)
- Temperature limits by workload type
- Power budget utilization

#### 4.4 Document Findings
Write comprehensive capacity planning guide:
- How to size GPU workloads
- Time-slicing recommendation for GTX 1050 Ti
- When NOT to use time-slicing (high-performance jobs)

### Deliverables
- [ ] Time-slicing benchmark report
- [ ] Capacity planning spreadsheet
- [ ] Capacity planning guide

---

## Phase 1 Final Deliverables

1. `roadmap/phase1/dcgm-metrics-reference.md` — DCGM metric catalog
2. `roadmap/phase1/gpu-grafana-dashboard.json` — Custom Grafana dashboard
3. `roadmap/phase1/prometheus-alerts.yaml` — Alert rules
4. `roadmap/phase1/alert-runbooks/` — Runbook documents
5. `roadmap/phase1/profiling-report.md` — Workload profiling results
6. `roadmap/phase1/capacity-planning.md` — Capacity planning guide

---

## Success Criteria

- [ ] All DCGM metrics understood and visualized
- [ ] Alerts fire correctly for high temp/memory/Xid conditions
- [ ] Capacity baseline documented for GTX 1050 Ti
- [ ] Time-slicing overhead quantified

---

## Next Phase Preview

Phase 2 focuses on **GPU Scheduling** — Volcano gang scheduling, time-slicing tuning, and workload placement optimization.