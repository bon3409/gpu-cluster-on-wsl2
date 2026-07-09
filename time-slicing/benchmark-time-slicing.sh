#!/bin/bash
set -e

REPLICA_COUNTS=(1 2 4 6 8)
DURATION=90
RESULTS_DIR="benchmark-results"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

mkdir -p ${RESULTS_DIR}

echo "=========================================="
echo "Time-Slicing Benchmark"
echo "GPU: GTX 1050 Ti (4GB, 4 slices)"
echo "Duration per test: ${DURATION}s"
echo "=========================================="

for REPLICAS in "${REPLICA_COUNTS[@]}"; do
    echo ""
    echo ">>> Testing with ${REPLICAS} replica(s)..."

    for i in $(seq 1 $REPLICAS); do
        kubectl delete pod gpu-burn-${i} --ignore-not-found=true 2>/dev/null || true
    done

    sleep 2

    for i in $(seq 1 $REPLICAS); do
        cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: gpu-burn-${i}
  labels:
    app: gpu-burn
    benchmark-replicas: "${REPLICAS}"
spec:
  restartPolicy: OnFailure
  containers:
  - name: gpu-burn
    image: nvidia/cuda:11.8.0-devel-ubuntu22.04
    command: ["/bin/bash", "-c"]
    args:
      - |
        apt-get update && apt-get install -y wget git make g++
        git clone https://github.com/wilicc/gpu-burn.git
        cd gpu-burn
        make COMPUTE=61
        echo "=== Replica $i: GPU Burn 開始 (${DURATION}s) ==="
        ./gpu_burn ${DURATION}
        echo "=== Replica $i: GPU Burn 結束 ==="
    resources:
      limits:
        nvidia.com/gpu: 1
EOF
        sleep 1
    done

    echo "Waiting for all ${REPLICAS} pods to complete..."
    for i in $(seq 1 $REPLICAS); do
        kubectl wait --for=condition= Ready pod/gpu-burn-${i} --timeout=120s 2>/dev/null || true
    done

    kubectl wait --for=condition=Completed pod -l app=gpu-burn --timeout=$((DURATION + 120))s 2>/dev/null || true

    echo "Collecting metrics for ${REPLICAS} replica(s) run..."

    LOG_FILE="${RESULTS_DIR}/replicas-${REPLICAS}-${TIMESTAMP}.log"

    {
        echo "=== Benchmark: ${REPLICAS} Replicas ==="
        echo "Timestamp: $(date)"
        echo ""
        echo "--- Pod Status ---"
        kubectl get pods -l app=gpu-burn | grep gpu-burn || true
        echo ""
        echo "--- GPU Utilization (DCGM) ---"
        kubectl exec -n gpu-operator deploy/dcgm-exporter -- wget -qO- http://localhost:9400/metrics 2>/dev/null | grep DCGM_FI_DEV_GPU_UTIL | tail -5 || echo "DCGM unavailable"
        echo ""
        echo "--- Memory Usage ---"
        kubectl exec -n gpu-operator deploy/dcgm-exporter -- wget -qO- http://localhost:9400/metrics 2>/dev/null | grep DCGM_FI_DEV_FB_USED | tail -5 || echo "DCGM unavailable"
        echo ""
        echo "--- Temperature ---"
        kubectl exec -n gpu-operator deploy/dcgm-exporter -- wget -qO- http://localhost:9400/metrics 2>/dev/null | grep DCGM_FI_DEV_GPU_TEMP | tail -5 || echo "DCGM unavailable"
        echo ""
        echo "--- Pod Logs ---"
        for j in $(seq 1 $REPLICAS); do
            echo "--- gpu-burn-${j} ---"
            kubectl logs gpu-burn-${j} 2>/dev/null | tail -10 || echo "No logs"
        done
    } > "${LOG_FILE}"

    echo "Results saved to ${LOG_FILE}"

    kubectl delete pod -l app=gpu-burn --ignore-not-found=true 2>/dev/null || true
    sleep 5
done

echo ""
echo "=========================================="
echo "Benchmark Complete"
echo "Results in: ${RESULTS_DIR}/"
echo "=========================================="