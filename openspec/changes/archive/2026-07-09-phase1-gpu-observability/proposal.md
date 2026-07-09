## Why

GPU observability is critical for effective resource management in our minikube environment with the NVIDIA GTX 1050 Ti. Without proper DCGM metric understanding and alerting, we risk thermal throttling, memory exhaustion, and unoptimized workload placement. This 4-week phase establishes the foundation for production-grade GPU monitoring.

## What Changes

- Catalog all DCGM exporter metrics with GTX 1050 Ti specific ranges
- Build custom Grafana dashboard for real-time GPU monitoring
- Create Prometheus alerting rules for temperature, memory, and error conditions
- Establish workload profiling baselines using gpu-burn and ML workloads
- Document capacity planning data for time-slicing overhead
- Create runbooks for alert escalation

## Capabilities

### New Capabilities

- `dcgm-metrics-reference`: Document all DCGM metrics with descriptions and healthy ranges for GTX 1050 Ti
- `gpu-grafana-dashboard`: Custom Grafana dashboard JSON with GPU utilization, memory, temperature, power, and PCIe panels
- `prometheus-alerts`: Alert rules for GPU temperature, memory pressure, and Xid errors
- `alert-runbooks`: Runbook documents per alert type with root cause analysis and mitigation steps
- `gpu-profiling`: Workload profiling reports from gpu-burn and ML workloads
- `capacity-planning`: Time-slicing benchmark data and capacity planning guide

### Modified Capabilities

- (none)

## Impact

- DCGM exporter metrics in `gpu-operator` namespace
- Grafana dashboard JSON at `roadmap/phase1/gpu-grafana-dashboard.json`
- Prometheus alert rules at `roadmap/phase1/prometheus-alerts.yaml`
- Runbook documents at `roadmap/phase1/alert-runbooks/`
- Profiling report at `roadmap/phase1/profiling-report.md`
- Capacity planning guide at `roadmap/phase1/capacity-planning.md`