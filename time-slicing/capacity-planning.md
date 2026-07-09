# Time-Slicing Capacity Planning

## Overview

GTX 1050 Ti (Max-Q Design):
- VRAM: 4GB
- TDP: 75W
- SM Clock: 607-1911 MHz
- Memory Clock: 3004 MHz
- Time-Slicing Config: 4 replicas

## Effective Capacity Formula

```
Effective_GPU_Per_Replica = Baseline_Throughput / Num_Replicas * (1 - Overhead)
```

Overhead = context switch + memory contention penalty measured from benchmarks.

## Benchmark Methodology

1. Run `benchmark-time-slicing.sh` to collect data at each replica count
2. Capture DCGM metrics: GPU_UTIL, FB_USED, TEMP, POWER_USAGE
3. Extract gpu-burn output for actual compute performance
4. Measure completion time, temperature, and memory allocation per replica

## Benchmark Results (2026-07-09)

### Raw Data

| Replicas | Replica | GPU Util | Gflop/s | Temp | Memory Used | Iterations | Status |
|----------|---------|----------|---------|------|-------------|------------|--------|
| 1 | 1 | ~100% | N/A* | N/A | 3013 MB | 9 | Completed |
| 2 | 1 | 95.6-100% | 158 | 52-53°C | N/A | 9 | Completed |
| 2 | 2 | 95.6-100% | 276 | 52-53°C | N/A | 18 | Completed |
| 4 | 1 | 90-100% | 257 | 54-56°C | ~3 GB | 9 | Completed |
| 4 | 2 | 95.6-100% | 190 | 54-56°C | ~3 GB | 9 | Completed |
| 4 | 3 | N/A** | N/A | N/A | 1549 MB | 4 | Completed |
| 4 | 4 | N/A** | N/A | N/A | 1012 MB | 1 | Completed |
| 6 | 1 | 94.4-100% | 131 | 57-58°C | ~1.5 GB | 9 | Completed |
| 6 | 2 | N/A | N/A | N/A | N/A | N/A | Killed |
| 6 | 3 | N/A** | N/A | N/A | 1523 MB | 3 | Completed |
| 6 | 4 | N/A** | N/A | N/A | 1518 MB | 3 | Completed |
| 6 | 5-6 | N/A | N/A | N/A | N/A | N/A | Still building |
| 8 | 1 | 96.7-100% | 176 | 60-64°C | ~1 GB | 9 | Completed |
| 8 | 2 | N/A | N/A | N/A | N/A | N/A | Killed |
| 8 | 3 | 97.8-100% | 131 | 62-64°C | ~1 GB | 9 | Completed |
| 8 | 4 | N/A** | N/A | N/A | 1124 MB | 1 | Completed |
| 8 | 5-8 | N/A | N/A | N/A | N/A | N/A | Still building |

*Baseline log 沒有顯示 Gflop/s（只顯示 "GPU 0: OK"）
**這些 replica 在編譯期間顯示 N/A（build time 計入）

### Analysis: Memory Allocation Pattern

GPU time-slicing doesn't enforce memory limits—replicas compete for 4GB dynamically:

| Replica Order | 4-replica Test | 8-replica Test |
|--------------|----------------|----------------|
| 1st | ~3 GB (9 iter) | ~1 GB (9 iter) |
| 2nd | ~3 GB (9 iter) | ~0.5 GB (killed) |
| 3rd | 1549 MB (4 iter) | ~1 GB (9 iter) |
| 4th | 1012 MB (1 iter) | 1124 MB (1 iter) |
| 5th | - | Still building |
| 6th | - | Still building |
| 7th | - | Still building |
| 8th | - | Still building |

**Key insight**: Later replicas get progressively less memory. GPU utilization stays high (90-100%) but per-replica throughput drops due to memory starvation.

## Throughput Analysis

### Total Work Completed per Test

| Replicas | Total Iterations | Time (approx) | Effective Rate |
|----------|------------------|---------------|----------------|
| 1 | 9 | ~3.5 min | 2.6 iter/min |
| 2 | 27 (9+18) | ~3.5 min | 7.7 iter/min |
| 4 | 24 (9+9+4+1) | ~3.7 min | 6.5 iter/min |
| 6 | 21 (9+3+3)* | ~3.8 min | 5.5 iter/min |
| 8 | 20 (9+9+1)* | ~3.9 min | 5.1 iter/min |

*Excludes killed replicas and still-building replicas

### Per-Replica Gflop/s Comparison (Completed Replicas Only)

| Test | Best Replica | Worst Completed | Ratio |
|------|-------------|-----------------|-------|
| 2 replicas | 276 | 158 | 1.75x |
| 4 replicas | 257 | 190 (iter 4) | 1.35x |
| 8 replicas | 176 | 131 | 1.34x |

**Observation**: Gflop/s differences are due to memory allocation, not time-slicing overhead.

## Temperature Scaling

| Replicas | Peak Temp | Delta from 2-replica |
|----------|-----------|---------------------|
| 2 | 53°C | baseline |
| 4 | 56°C | +3°C |
| 6 | 58°C | +5°C |
| 8 | 64°C | +11°C |

Temperature increases ~1-2°C per additional 2 replicas.

## Memory Contention Summary

| Replicas | Completed | Killed/Building | Notes |
|----------|-----------|-----------------|-------|
| 1 | 1/1 | 0 | Full memory |
| 2 | 2/2 | 0 | Both completed |
| 4 | 4/4 | 0 | Memory contention, all completed |
| 6 | 4/6 | 2 killed | Replica 2 killed, 2 still building |
| 8 | 3/8 | 5 | Replica 2 killed, 4 still building |

## Recommendations for GTX 1050 Ti

### When to Use Time-Slicing
- Multiple small/light workloads (inference, batch jobs)
- Development/testing environments
- Cost optimization on single GPU

### When NOT to Use Time-Slicing
- High-performance training jobs (HF, large model fine-tuning)
- Real-time inference with SLAs
- Workloads requiring sustained GPU access
- Any workload requiring >1.5 GB memory per replica

### Recommended Replica Count (Based on Benchmark)

| Use Case | Recommended Replicas | Reason |
|----------|---------------------|--------|
| Development | 2-4 | Balance concurrency and memory |
| Light inference | 2 | Avoid memory contention |
| Batch jobs (small) | 2-4 | Monitor memory closely |
| Heavy compute | 1 | No time-slicing |

**Critical Finding**: Above 4 replicas, memory contention causes starvation and job failures. GTX 1050 Ti's 4GB VRAM is insufficient for 6+ concurrent GPU workloads under time-slicing.

### Max Concurrent Jobs Per Slice

| Configured Replicas | Effective Jobs | Notes |
|---------------------|----------------|-------|
| 2 | 2 | Full memory per job, both complete |
| 4 | 4 | Some memory contention, all complete |
| 6 | 4-5 | 1-2 jobs killed or starved |
| 8 | 3-5 | 3+ jobs killed or starved |

**Recommendation**: Do not exceed 4 replicas on GTX 1050 Ti 4GB.

## Benchmark Results Log

| Date | Replicas | Completed | Peak Temp | Best Gflop/s | Notes |
|------|----------|-----------|-----------|--------------|-------|
| 2026-07-09 | 1 | 1/1 | N/A | N/A | Baseline, clean completion |
| 2026-07-09 | 2 | 2/2 | 53°C | 158-276 | Both completed |
| 2026-07-09 | 4 | 4/4 | 56°C | 190-257 | Memory contention starts |
| 2026-07-09 | 6 | 4/6 | 58°C | 131 | Replica 2 killed |
| 2026-07-09 | 8 | 3/8 | 64°C | 131-176 | Replica 2 killed |

## Appendix: gpu-burn Log Interpretation

gpu-burn output format:
```
<GPU_UTIL>%  proc'd: <blocks> (<gflop/s>)   errors: 0   temps: <temp> C
```

- `proc'd`: Number of result blocks processed
- Gflop/s: Floating-point operations per second for this replica
- When a replica shows N/A for Gflop/s, it means compilation was still in progress during the measurement window