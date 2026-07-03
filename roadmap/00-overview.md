# AI Infrastructure Engineer Roadmap

## Goal

Transition from Senior DevOps Engineer → Nvidia AI Infrastructure, DevOps, SRE Engineer

**Target environment:** WSL2 + GTX 1050 Ti (Pascal, 4GB) + Minikube + GPU Operator

**Weekly commitment:** 10-20 hours

---

## Timeline Overview

| Phase | Duration | Focus Area | Document |
|-------|----------|------------|----------|
| 1 | Weeks 1-4 | GPU Observability | `phase1-observability.md` |
| 2 | Weeks 5-8 | GPU Scheduling | `phase2-scheduling.md` |
| 3 | Weeks 9-12 | MLOps Foundations | `phase3-mlops.md` |
| 4 | Weeks 13-16 | Cluster Operations | `phase4-operations.md` |

---

## Phase 1 — GPU Observability (Weeks 1-4)

**Goal:** Master DCGM, build observability stack, establish performance baselines

### Week 1: DCGM Deep Dive
- [ ] Verify DCGM exporter running in cluster
- [ ] Understand all DCGM metrics collected
- [ ] Build custom Grafana dashboard (utilization, memory, temperature, power, pcie throughput)
- [ ] Document metric definitions and thresholds for GTX 1050 Ti

### Week 2: Workload Profiling
- [ ] Run gpu-burn, measure sustained vs peak utilization
- [ ] Profile TensorFlow/PyTorch workloads (real or sample)
- [ ] Identify bottlenecks: memory-bound vs compute-bound
- [ ] Document GPU utilization patterns per workload type

### Week 3: Alerting & Automation
- [ ] Configure Prometheus alerting rules (utilization, memory, temperature thresholds)
- [ ] Set up webhook notifications (Slack or similar)
- [ ] Build alert runbook templates
- [ ] Test alert fatigue — refine thresholds

### Week 4: Capacity Planning Baseline
- [ ] Measure time-slicing overhead (4 replicas vs 1)
- [ ] Calculate "effective GPU capacity" per slice
- [ ] Build capacity planning spreadsheet
- [ ] Document findings: how many concurrent small jobs per GPU

### Deliverables
- Custom Grafana dashboard JSON
- Alert rules YAML
- Capacity planning baseline document
- Profiling report with workload characteristics

---

## Phase 2 — GPU Scheduling (Weeks 5-8)

**Goal:** Master Volcano scheduler, time-slicing, gang scheduling

### Week 5: Volcano Internals
- [ ] Study Volcano scheduler architecture
- [ ] Trace scheduling cycle for a job
- [ ] Understand gang scheduling semantics
- [ ] Experiment with `minAvailable` configurations

### Week 6: Time-Slicing Mastery
- [ ] Tune replica count (test 2, 4, 6, 8 replicas)
- [ ] Measure context switching overhead per replica
- [ ] Find optimal slice count for 1050 Ti workloads
- [ ] Document performance degradation curve

### Week 7: Queue Policies
- [ ] Configure queue priority levels
- [ ] Test preemption behavior
- [ ] Implement fair share across queues
- [ ] Study priority inversion scenarios

### Week 8: Workload Placement
- [ ] Build bin-packing strategy for GPU allocation
- [ ] Test anti-affinity rules
- [ ] Experiment with node selector constraints
- [ ] Document placement best practices

### Deliverables
- Time-slicing benchmark report
- Queue policy configurations
- Placement strategy document
- Scheduling failure case studies

---

## Phase 3 — MLOps Foundations (Weeks 9-12)

**Goal:** Understand ML workload patterns, CI/CD for ML, inference basics

### Week 9: NGC Containers & Workload Patterns
- [ ] Pull and run NGC PyTorch/TensorFlow containers
- [ ] Understand container GPU enablement internals
- [ ] Identify common ML workload patterns (training, inference, distributed)
- [ ] Document container usage patterns

### Week 10: CI/CD for ML Pipelines
- [ ] Build sample ML pipeline (GitHub Actions or similar)
- [ ] Implement model training + validation automation
- [ ] Add artifact versioning (model registry concept)
- [ ] Document ML CI/CD patterns

### Week 11: Inference Serving
- [ ] Deploy Triton Inference Server
- [ ] Understand model loading and batching
- [ ] Benchmark inference throughput
- [ ] Document inference optimization techniques

### Week 12: Distributed Training Basics
- [ ] Study distributed training concepts (data parallel, model parallel)
- [ ] Simulate multi-GPU concepts on single GPU (gradient accumulation)
- [ ] Understand NCCL basics
- [ ] Document distributed training architecture

### Deliverables
- NGC container usage guide
- ML CI/CD pipeline example
- Triton inference benchmark
- Distributed training study notes

---

## Phase 4 — Cluster Operations (Weeks 13-16)

**Goal:** Multi-node concepts, fault tolerance, cost optimization, production patterns

### Week 13: Multi-Node GPU Cluster Concepts
- [ ] Study GPU cluster architectures (DGX vs custom)
- [ ] Understand node federation / cluster federation
- [ ] Experiment with topology-aware scheduling
- [ ] Document multi-node architecture patterns

### Week 14: Fault Tolerance & Job Migration
- [ ] Study GPU fault detection (Xid errors, ECC)
- [ ] Implement job checkpoint/restart concepts
- [ ] Test node failure handling
- [ ] Document fault tolerance patterns

### Week 15: Cost Optimization
- [ ] Calculate GPU cost per workload
- [ ] Study GPU lease/spot instance patterns
- [ ] Implement bin-packing for cost efficiency
- [ ] Document cost optimization strategies

### Week 16: Production Deployment Patterns
- [ ] Study rolling updates with GPU workloads
- [ ] Understand canary deployment for ML models
- [ ] Build runbook for common production scenarios
- [ ] Final capstone: deploy complete workload with all learned concepts

### Deliverables
- Multi-node architecture study
- Fault tolerance runbook
- Cost analysis report
- Production deployment playbook

---

## Success Metrics

By Week 16, you should have:

1. **Observable** — Full GPU observability stack with actionable alerting
2. **Schedulable** — Deep understanding of GPU scheduling internals
3. **Operational** — ML workload patterns and CI/CD fluency
4. **Production-ready** — Cluster operations and fault handling knowledge

---

## Key Resources

- Nvidia GPU Operator Documentation
- DCGM Exporter GitHub
- Volcano Scheduler Documentation
- NGC Catalog
- Triton Inference Server Documentation
- Nvidia GPU Best Practices Guide

---

## Notes

- Adjust phase durations based on learning pace
- Revisit and update this roadmap after each phase
- Focus on concepts transferable to production GPU clusters
- Your 1050 Ti is limited but sufficient for learning — optimize for knowledge, not scale