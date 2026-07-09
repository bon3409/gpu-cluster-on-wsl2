## ADDED Requirements

### Requirement: GPU high temperature alert
The system SHALL fire a `GPUHighTemperature` alert when DCGM_FI_DEV_GPU_TEMP exceeds 85 for 5 minutes, with warning severity.

### Requirement: GPU critical temperature alert
The system SHALL fire a `GPUCriticalTemperature` alert when DCGM_FI_DEV_GPU_TEMP exceeds 90 for 1 minute, with critical severity.

### Requirement: GPU memory high alert
The system SHALL fire a `GPUMemoryHigh` alert when framebuffer memory utilization exceeds 95% (FB_USED / (FB_USED + FB_FREE) > 0.95) for 5 minutes.

### Requirement: GPU Xid errors alert
The system SHALL fire a `GPUXidErrors` alert immediately (for: 0m) when DCGM_FI_DEV_XID_ERRORS exceeds 0.

### Requirement: Alert labels
The system SHALL include appropriate severity labels and annotations for each alert.

### Requirement: Prometheus rules format
The system SHALL provide Prometheus rules in the standard prometheus-operator format with groups and rules.

## ADDED Scenarios

#### Scenario: Temperature warning fires
- **WHEN** GPU temperature exceeds 85C continuously for 5 minutes
- **THEN** GPUHighTemperature alert fires with summary "GPU temperature high"

#### Scenario: Temperature critical fires
- **WHEN** GPU temperature exceeds 90C for 1 minute
- **THEN** GPUCriticalTemperature alert fires immediately

#### Scenario: Memory exhaustion warning
- **WHEN** GPU memory utilization exceeds 95% for 5 minutes
- **THEN** GPUMemoryHigh alert fires

#### Scenario: Xid error detected
- **WHEN** any Xid error occurs
- **THEN** GPUXidErrors alert fires immediately (0m pending duration)

## ALERT RULES

```yaml
groups:
  - name: gpu-alerts
    rules:
      - alert: GPUHighTemperature
        expr: DCGM_FI_DEV_GPU_TEMP > 85
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "GPU temperature high"
          description: "GPU temperature is {{ $value }}C"
      - alert: GPUCriticalTemperature
        expr: DCGM_FI_DEV_GPU_TEMP > 90
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "GPU temperature critical"
          description: "GPU temperature is {{ $value }}C - thermal throttling"
      - alert: GPUMemoryHigh
        expr: DCGM_FI_DEV_FB_USED / (DCGM_FI_DEV_FB_USED + DCGM_FI_DEV_FB_FREE) > 0.95
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "GPU memory utilization high"
          description: "GPU memory usage is {{ $value | humanizePercentage }}"
      - alert: GPUXidErrors
        expr: DCGM_FI_DEV_XID_ERRORS > 0
        for: 0m
        labels:
          severity: critical
        annotations:
          summary: "GPU Xid error detected"
          description: "GPU Xid error count is {{ $value }}"
```