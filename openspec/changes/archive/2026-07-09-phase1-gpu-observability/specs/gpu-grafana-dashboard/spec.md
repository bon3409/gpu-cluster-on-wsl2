## ADDED Requirements

### Requirement: Grafana dashboard JSON
The system SHALL provide a Grafana dashboard JSON that can be imported into Grafana for GPU monitoring.

### Requirement: GPU utilization panel
The system SHALL include a panel displaying DCGM_FI_DEV_GPU_UTIL as an area chart with 1-second resolution.

### Requirement: Memory usage panel
The system SHALL include a panel displaying framebuffer memory (used/free) as a stacked area chart.

### Requirement: Temperature panel
The system SHALL include a panel displaying DCGM_FI_DEV_GPU_TEMP with a threshold line at 85C.

### Requirement: Power draw panel
The system SHALL include a panel displaying DCGM_FI_DEV_POWER_USAGE with a max line at 75W TDP.

### Requirement: PCIe throughput panel
The system SHALL include panels for DCGM_FI_DEV_PCIE_TX_THROUGHPUT and DCGM_FI_DEV_PCIE_RX_THROUGHPUT.

### Requirement: Clock frequency panels
The system SHALL include panels for DCGM_FI_DEV_SM_CLOCK and DCGM_FI_DEV_MEM_CLOCK.

### Requirement: Xid errors panel
The system SHALL include a panel for DCGM_FI_DEV_XID_ERRORS that shows 0 under normal conditions.

### Requirement: Labels preserved
The system SHALL preserve GPU labels (gpu, UUID, pci_bus_id, device, modelName, Hostname) in all panels.

## ADDED Scenarios

#### Scenario: Dashboard import
- **WHEN** an operator imports the dashboard JSON into Grafana
- **THEN** all panels render with correct queries and display GPU metrics

#### Scenario: Temperature threshold visible
- **WHEN** GPU temperature approaches 85C
- **THEN** the threshold line on the temperature panel provides visual warning

#### Scenario: Multi-metric memory view
- **WHEN** viewing memory utilization
- **THEN** used and free memory are clearly distinguished in stacked format