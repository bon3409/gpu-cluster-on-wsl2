## Context

GPU observability setup in minikube with GPU Operator. DCGM exporter runs in `gpu-operator` namespace, exposing metrics on port 9400. GTX 1050 Ti has 4GB VRAM, 75W TDP, Max-Q design (SM clock range 607-1911 MHz, memory clock 3004 MHz). Currently no alerting or dashboards configured beyond raw metric exposure.

## Goals / Non-Goals

**Goals:**
- Establish DCGM metric baseline understanding for GTX 1050 Ti
- Deploy production-ready Grafana dashboard with key GPU panels
- Configure Prometheus alerting for temperature, memory, and error conditions
- Profile GPU workloads (compute-bound vs memory-bound)
- Quantify time-slicing overhead for capacity planning

**Non-Goals:**
- Modifying GPU Operator or DCGM exporter configuration (only consuming metrics)
- Multi-GPU cluster support (single GTX 1050 Ti)
- ML training optimization (observability only)

## Decisions

1. **Grafana Dashboard Panels**
   - GPU Utilization (DCGM_FI_DEV_GPU_UTIL) - area chart, 1s resolution
   - Memory Usage (DCGM_FI_DEV_FB_USED/DCGM_FI_DEV_FB_FREE) - stacked area
   - GPU Temperature (DCGM_FI_DEV_GPU_TEMP) - with 85C threshold line
   - Power Draw (DCGM_FI_DEV_POWER_USAGE) - with 75W max line
   - PCIe Throughput (DCGM_FI_DEV_PCIE_TX_THROUGHPUT + RX) - dual line
   - SM/Memory Clocks (DCGM_FI_DEV_SM_CLOCK, DCGM_FI_DEV_MEM_CLOCK)
   - Xid Errors (DCGM_FI_DEV_XID_ERRORS) - should always be 0

2. **Alert Thresholds (GTX 1050 Ti specific)**
   - GPUHighTemperature: > 85C for 5m → warning
   - GPUCriticalTemperature: > 90C for 1m → critical
   - GPUMemoryHigh: FB_USED/FB_FREE > 0.95 for 5m
   - GPUXidErrors: > 0 immediately

3. **Time-Slicing Benchmark Points**
   - 1, 2, 4, 6, 8 replicas to measure degradation
   - Metrics: effective GPU time per replica, context switch overhead, temperature

## Risks / Trade-offs

- [Temp monitoring accuracy] → Use DCGM_FI_DEV_GPU_TEMP (not MEMORY_TEMP which shows 0 on this GPU)
- [Metric availability] → Not all DCGM metrics available on consumer GPUs vs data center GPUs
- [Alert fatigue] → Start with conservative thresholds, tune based on false positives

## Open Questions

- Should we enable DCGM_FI_DEV_GPU_TEMP or DCGM_FI_DEV_MEMORY_TEMP for alerting? (MEMORY_TEMP reports 0 on GTX 1050 Ti)
- GPU utilization counter accuracy during time-slicing (replicas share GPU)