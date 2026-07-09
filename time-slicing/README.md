# Time-Slicing

GPU time-slicing configuration and benchmarks for GTX 1050 Ti (4GB, 4 replicas).

## Files

| File | Description |
|------|-------------|
| `enable-time-slicing.sh` | Enable time-slicing (4 replicas) on GTX 1050 Ti |
| `disable-time-slicing.sh` | Disable time-slicing and restore original GPU labels |
| `time-slicing-config.yaml` | ConfigMap for time-slicing resources |
| `benchmark-time-slicing.sh` | Benchmark script for 1/2/4/6/8 replica tests |
| `capacity-planning.md` | Capacity planning guide and benchmark results |

## Quick Start

### Enable Time-Slicing

```bash
./enable-time-slicing.sh
```

### Run Benchmark

```bash
chmod +x benchmark-time-slicing.sh
./benchmark-time-slicing.sh
```

Results saved to `benchmark-results/` directory.

### Disable Time-Slicing

```bash
./disable-time-slicing.sh
```

## Time-Slicing Configuration

Current config splits GTX 1050 Ti into 4 virtual GPUs:

```yaml
sharing:
  timeSlicing:
    resources:
    - name: nvidia.com/gpu
      replicas: 4
```

## Notes

- GTX 1050 Ti has 4GB VRAM shared across all slices
- Time-slicing adds context switch overhead
- Monitor temperature during benchmarks (85C warning, 90C critical)