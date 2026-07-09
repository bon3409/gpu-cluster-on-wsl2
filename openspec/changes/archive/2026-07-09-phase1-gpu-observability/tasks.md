## 1. Week 1: DCGM Deep Dive

- [x] 1.1 Verify DCGM exporter is running in gpu-operator namespace
- [x] 1.2 Verify DCGM exporter metrics endpoint responds
- [x] 1.3 Document all available DCGM metrics with labels
- [x] 1.4 Build Grafana dashboard JSON with GPU utilization panel
- [x] 1.5 Add memory usage (used/free stacked) panel
- [x] 1.6 Add temperature panel with 85C threshold line
- [x] 1.7 Add power draw panel with 75W max line
- [x] 1.8 Add PCIe throughput (TX + RX) panels
- [x] 1.9 Add SM/Memory clock frequency panels
- [x] 1.10 Add Xid errors panel
- [x] 1.11 Import and verify Grafana dashboard

## 2. Week 2: Workload Profiling

- [x] 2.1 Run gpu-burn for 30s baseline
- [x] 2.2 Measure sustained GPU utilization during load
- [x] 2.3 Measure temperature rise over time during gpu-burn
- [x] 2.4 Measure power draw at sustained load
- [x] 2.5 Run TensorFlow workload (MNIST sample)
- [x] 2.6 Analyze initial GPU utilization spike
- [x] 2.7 Analyze memory allocation pattern
- [x] 2.8 Determine if workload is compute-bound or memory-bound
- [x] 2.9 Run 4 concurrent gpu-burn pods (time-slicing)
- [x] 2.10 Measure per-replica utilization under time-slicing
- [x] 2.11 Document time-slicing overhead findings

## 3. Week 3: Alerting & Automation

- [x] 3.1 Create terraform folder structure for Grafana alerting (tofu)
- [x] 3.2 Configure Grafana provider (local file state)
- [x] 3.3 Create grafana_alerting.tf with GPUHighTemperature rule (85C, 5m, warning)
- [x] 3.4 Add GPUCriticalTemperature rule (90C, 1m, critical)
- [x] 3.5 Add GPUMemoryHigh rule (95% utilization, 5m)
- [x] 3.6 Add GPUXidErrors rule (>0, 0m, critical)
- [x] 3.7 Create grafana_contact_points.tf with Email
- [x] 3.8 Create grafana_notification_policies.tf with routing rules
- [x] 3.9 Run tofu plan/apply to deploy alert rules to local Grafana
- [x] 3.10 Verify alerts appear in Grafana UI
- [x] 3.11 Test alert firing with gpu-burn (temperature)

## 4. Week 4: Capacity Planning Baseline

- [x] 4.1 Benchmark time-slicing at 1 replica (baseline)
- [x] 4.2 Benchmark time-slicing at 2 replicas (degradation %)
- [x] 4.3 Benchmark time-slicing at 4 replicas (degradation %)
- [x] 4.4 Benchmark time-slicing at 6 replicas (degradation %)
- [x] 4.5 Benchmark time-slicing at 8 replicas (degradation %)
- [x] 4.6 Calculate context switch overhead per replica count
- [x] 4.7 Calculate effective capacity per workload type
- [x] 4.8 Create capacity-planning.md guide
- [x] 4.9 Document max concurrent jobs per GPU slice
- [x] 4.10 Document temperature limits by workload type
- [x] 4.11 Document power budget utilization
- [x] 4.12 Provide time-slicing recommendation for GTX 1050 Ti