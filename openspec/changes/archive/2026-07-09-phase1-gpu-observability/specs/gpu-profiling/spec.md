## ADDED Requirements

### Requirement: Gpu-burn baseline profiling
The system SHALL measure GPU utilization, temperature, and power draw during sustained gpu-burn workload to establish baseline performance for GTX 1050 Ti.

### Requirement: ML workload profiling
The system SHALL profile at least one TensorFlow or PyTorch workload to understand real-world GPU utilization patterns.

### Requirement: Memory pattern analysis
The system SHALL document memory allocation patterns including initial spike, sustained usage, and cleanup behavior.

### Requirement: Compute vs memory bound determination
The system SHALL analyze whether workloads are compute-bound (high SM_UTIL) or memory-bound (high FB_USED, lower SM_UTIL).

### Requirement: Time-slicing impact analysis
The system SHALL measure the impact of time-slicing on individual replica utilization, context switching overhead, and temperature under multi-load conditions.

### Requirement: Profiling report
The system SHALL document profiling methodology, measurements, and findings in a structured report.

## ADDED Scenarios

#### Scenario: Baseline established
- **WHEN** gpu-burn runs at 100% GPU utilization
- **THEN** we capture sustained temperature rise, power draw at load, and clock behavior

#### Scenario: Workload characterization
- **WHEN** ML workload runs
- **THEN** we capture initial GPU utilization spike, memory allocation pattern, and utilization curve over time

#### Scenario: Time-slicing overhead measured
- **WHEN** 4 concurrent gpu-burn pods run with time-slicing
- **THEN** we measure individual utilization per slice and context switching overhead

## METRICS TO CAPTURE

| Workload | Metrics |
|----------|---------|
| gpu-burn | Sustained GPU_UTIL, TEMP rise over time, POWER_USAGE at load |
| ML workload | Initial spike pattern, FB_USED allocation, sustained UTIL curve |
| Time-slicing | Per-replica UTIL, context switches, temperature under load |