#!/bin/bash
# queue-priority-test.sh
# Test Volcano queue priority scheduling with time-sliced GPUs
# 
# Prerequisites:
# - Volcano installed (via install.sh)
# - Time-slicing enabled with 4 replicas (node reports nvidia.com/gpu: 4)
# - GPU Operator running

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NAMESPACE="default"

echo "=== Volcano Queue Priority Test ==="
echo "Node GPU capacity (time-sliced): 4"
echo ""

# Cleanup function (called on Ctrl+C)
cleanup() {
    echo ""
    echo "=== Cleanup (interrupted) ==="
    kubectl delete -f "$SCRIPT_DIR/job-low-priority.yaml" 2>/dev/null || true
    kubectl delete -f "$SCRIPT_DIR/job-medium-priority.yaml" 2>/dev/null || true
    kubectl delete -f "$SCRIPT_DIR/job-high-priority.yaml" 2>/dev/null || true
    kubectl delete -f "$SCRIPT_DIR/queue-low.yaml" 2>/dev/null || true
    kubectl delete -f "$SCRIPT_DIR/queue-medium.yaml" 2>/dev/null || true
    kubectl delete -f "$SCRIPT_DIR/queue-high.yaml" 2>/dev/null || true
    kubectl delete podgroup --all -n $NAMESPACE 2>/dev/null || true
    exit 1
}

# Trap cleanup on interrupt
trap cleanup INT TERM

# Step 1: Create queues with different priorities
echo "=== Step 1: Create Priority Queues ==="

kubectl apply -f "$SCRIPT_DIR/queue-high.yaml" \
  -f "$SCRIPT_DIR/queue-medium.yaml" \
  -f "$SCRIPT_DIR/queue-low.yaml"

echo "Queues created. Waiting for queues to be ready..."
sleep 2
kubectl get queue

# Step 2: Submit LOW priority job first (should start running)
echo ""
echo "=== Step 2: Submit LOW priority job (4 replicas, minAvailable=4) ==="
kubectl apply -f "$SCRIPT_DIR/job-high-priority.yaml" -f "$SCRIPT_DIR/job-medium-priority.yaml" -f "$SCRIPT_DIR/job-low-priority.yaml"

echo "Waiting for job to be scheduled..."
sleep 5
kubectl get podgroup -n $NAMESPACE
kubectl get pods -n $NAMESPACE -o wide

# Step 3: Submit HIGH priority job while low is running
# echo ""
# echo "=== Step 3: Submit HIGH and Medium priority job (4 replicas, minAvailable=4) ==="
# kubectl apply -f "$SCRIPT_DIR/job-high-priority.yaml" -f "$SCRIPT_DIR/job-medium-priority.yaml"

# echo "Waiting for scheduling decision..."
# sleep 5

# Step 4: Observe results
echo ""
echo "=== Step 4: Results ==="
echo ""
echo "=== PodGroups ==="
kubectl get podgroup -n $NAMESPACE

echo ""
echo "=== Pods ==="
kubectl get pods -n $NAMESPACE -o wide

echo ""
echo "=== Queues ==="
kubectl get queue

echo ""
echo "=== Scheduler Logs (last 50 lines) ==="
kubectl logs -n volcano-system -l app=volcano-scheduler --tail=50

echo ""
echo "=== Test Complete ==="
echo "Sleeping 300 seconds before cleanup (Ctrl+C to skip)..."
sleep 300

echo ""
echo "=== Cleanup ==="
kubectl delete vcjob --all -n $NAMESPACE 2>/dev/null || true
kubectl delete queue --all 2>/dev/null || true
kubectl delete podgroup --all -n $NAMESPACE 2>/dev/null || true

echo ""
echo "Expected behavior:"
echo "  - Low priority job starts first (submitted first)"
echo "  - High priority job should preempt or queue ahead"
echo "  - With time-slicing (4 GPUs), both can potentially run"
echo ""
echo "Check Prometheus metrics at: http://volcano-scheduler:8080/metrics"
echo "Or port-forward: kubectl -n volcano-system port-forward svc/volcano-scheduler 8080:8080"
