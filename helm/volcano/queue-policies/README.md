# Volcano Queue Priority Test

## Configuration Summary

| Queue | Priority | Weight | GPU Capability |
|-------|----------|--------|----------------|
| high-priority | 1000 | 10 | 4 |
| medium-priority | 500 | 5 | 4 |
| low-priority | 100 | 1 | 2 |

| Job | Queue | Replicas | minAvailable | GPU/pod |
|-----|-------|----------|--------------|---------|
| job-high-priority | high-priority | 4 | 2 | 2 |
| job-medium-priority | medium-priority | 4 | 1 | 2 |
| job-low-priority | low-priority | 4 | 1 | 1 |

## Test

```bash
./queue-priority-test.sh
```

Script flow:
1. Create 3 priority queues
2. Create all 3 jobs simultaneously (high / medium / low)
3. Observe PodGroup and Pod allocation results
4. Auto-cleanup after 10 seconds (Ctrl+C to interrupt)