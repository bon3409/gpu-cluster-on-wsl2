## ADDED Requirements

### Requirement: DCGM metrics catalog
The system SHALL provide a complete catalog of all DCGM metrics exposed by the DCGM exporter for the GTX 1050 Ti GPU.

### Requirement: Metric descriptions
The system SHALL document each metric with its description, data type, and unit of measurement.

### Requirement: GTX 1050 Ti baseline ranges
The system SHALL provide healthy operating ranges for each metric specific to the GTX 1050 Ti GPU (4GB VRAM, 75W TDP, Max-Q design).

### Requirement: Threshold guidance
The system SHALL provide warning and critical threshold recommendations for temperature, memory, and utilization metrics.

## ADDED Scenarios

#### Scenario: DCGM metrics are documented
- **WHEN** an operator needs to understand DCGM metrics
- **THEN** they can reference the catalog for metric name, description, type, and GTX 1050 Ti range

#### Scenario: Threshold values are actionable
- **WHEN** an operator sets up alerting
- **THEN** they can use the provided threshold guidance for GTX 1050 Ti specific values (85C warning, 90C critical, 95% memory)

## METRICS CATALOG

| Metric | Description | Type | Unit | GTX 1050 Ti Range |
|--------|-------------|------|------|-------------------|
| DCGM_FI_DEV_SM_CLOCK | SM clock frequency | gauge | MHz | 607-1911 |
| DCGM_FI_DEV_MEM_CLOCK | Memory clock frequency | gauge | MHz | 3004 |
| DCGM_FI_DEV_MEMORY_TEMP | Memory temperature | gauge | C | N/A (reports 0) |
| DCGM_FI_DEV_GPU_TEMP | GPU temperature | gauge | C | 0-~90 |
| DCGM_FI_DEV_PCIE_REPLAY_COUNTER | PCIe retry count | counter | count | 0 (healthy) |
| DCGM_FI_DEV_GPU_UTIL | GPU utilization | gauge | % | 0-100 |
| DCGM_FI_DEV_MEM_COPY_UTIL | Memory utilization | gauge | % | 0-100 |
| DCGM_FI_DEV_ENC_UTIL | Encoder utilization | gauge | % | 0-100 |
| DCGM_FI_DEV_DEC_UTIL | Decoder utilization | gauge | % | 0-100 |
| DCGM_FI_DEV_FB_FREE | Framebuffer free | gauge | MiB | 0-4096 |
| DCGM_FI_DEV_FB_USED | Framebuffer used | gauge | MiB | 0-4096 |
| DCGM_FI_DEV_FB_RESERVED | Framebuffer reserved | gauge | MiB | varies |
| DCGM_FI_DEV_VGPU_LICENSE_STATUS | vGPU license | gauge | status | 0 (N/A consumer) |

## THRESHOLD GUIDANCE

| Metric | Warning | Critical | Notes |
|--------|---------|----------|-------|
| GPU Temperature | > 85C | > 90C | Thermal throttling begins ~85C |
| Memory Usage | > 80% | > 95% | FB_USED / (FB_USED + FB_FREE) |
| SM Clock | < 1000 MHz | N/A | May indicate thermal throttling |
| Xid Errors | > 0 | > 0 | Any occurrence is abnormal |