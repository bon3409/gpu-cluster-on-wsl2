# Triton Inference Server on Kubernetes

## Overview

使用 Terraform 部署 NVIDIA Triton Inference Server 到 Kubernetes (minikube)，支援 GPU 加速與模型儲存庫掛載。

- **Chart 位置**: `./chart`
- **模型儲存庫**: 透過 minikube `--mount` 將 `1.setup/data/model_repository` 掛載到 VM 的 `/mnt/data/model_repository`，PV 從此路徑讀取
- **命名空間**: `triton`
- **服務**: 
  - HTTP: `triton-server-service.triton.svc.cluster.local:8000`
  - gRPC: `triton-server-service.triton.svc.cluster.local:8001`
  - Metrics: `triton-server-service.triton.svc.cluster.local:8002`

---

## How to deploy to kubernetes with terraform

### 前置需求
- minikube 已啟動且啟用 GPU (`minikube start --driver=docker --gpus=all`)
- Terraform >= 1.0
- kubectl 已設定指向 minikube

### 部署步驟

```bash
cd terraform/triton

# 初始化
tofu init

# 規劃部署
tofu plan

# 套用部署
tofu apply

# 驗證部署
kubectl -n triton get pods
kubectl -n triton get svc
kubectl -n triton logs -l app=triton-server
```

### 刪除部署
```bash
tofu destroy
```

---

## How to download model and mount into minikube

### 架構說明

模型檔案管理流程：

```
1.setup/data/model_repository/          (專案原始碼管理的模型目錄)
    ↓ minikube --mount 參數自動掛載
minikube VM 內的 /mnt/data/model_repository/   (PV 掛載來源)
    ↓ hostPath volume
Pod 內 /models/                         (Triton 讀取路徑)
```

### 掛載機制 (在 `1.setup/minikube.sh` 完成)

`minikube.sh` 啟動 minikube 時會自動掛載 `1.setup/data` 到 minikube VM 內部：

```bash
# 1.setup/minikube.sh 片段
SCRIPT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)

minikube start \
    --driver=docker \
    --mount \
    --mount-string="$SCRIPT_DIR/data:/mnt/data" \  # 關鍵：將 1.setup/data 掛載到 VM 的 /mnt/data
    --gpus all \
    ...
```

**結果**：
- `1.setup/data/model_repository/` 自動出現在 minikube VM 的 `/mnt/data/model_repository/`
- Terraform Helm chart 的 PV 直接使用 `hostPath: /mnt/data/model_repository` (minikube VM 內路徑)
- **不需手動 rsync/cp** - minikube 的 `--mount` 機制自動同步

### Terraform PV 設定 (chart/values.yaml)

```yaml
modelRepository:
  hostPath: "/mnt/data/model_repository"  # minikube VM 內路徑
  mountPath: "/models"                    # 容器內路徑
```

### 模型儲存庫結構 (位於 `1.setup/data/model_repository/`)

```
1.setup/data/model_repository/
├── densenet_onnx/
│   ├── config.pbtxt
│   └── 1/
│       └── model.onnx
├── resnet50/
│   ├── config.pbtxt
│   └── 1/
│       └── model.onnx
└── mobilenetv2/
    ├── config.pbtxt
    └── 1/
        └── model.onnx
```

### 下載模型 (在 `1.setup/data/model_repository/` 下操作)

參考各模型目錄下的 `README.md` (如 `1.setup/data/model_repository/densenet_onnx/README.md`)：

```bash
# 進入模型版本目錄 (以 densenet_onnx 為例)
cd 1.setup/data/model_repository/densenet_onnx/1

# 下載 DenseNet-121 ONNX 模型 (使用 raw.githubusercontent.com 避免下載到 HTML)
curl -fL -o model.onnx https://raw.githubusercontent.com/onnx/models/main/validated/vision/classification/densenet-121/model/densenet-121.onnx

# 驗證模型檔案 (需安裝 onnx: pip install onnx)
python -c "import onnx; onnx.checker.check_model(onnx.load('model.onnx')); print('Valid ONNX model')"
```

> **注意**: 必須使用 `raw.githubusercontent.com` 或 `ghproxy.net` 代理，直接用 `github.com/blob/` 會下載到 HTML 頁面導致模型載入失敗 (錯誤: `Protobuf parsing failed`)

### 部署流程總結

```bash
# 1. 下載模型到 1.setup/data/model_repository/
cd 1.setup/data/model_repository/densenet_onnx/1
curl -fL -o model.onnx https://raw.githubusercontent.com/onnx/models/main/validated/vision/classification/densenet-121/model/densenet-121.onnx

# 2. 啟動 minikube (自動掛載 1.setup/data → /mnt/data)
cd 1.setup
./minikube.sh

# 3. 部署 Triton (PV 自動從 /mnt/data/model_repository 讀取)
cd ../terraform/triton
tofu init && tofu apply
```

---

## Run an example job to call triton server model api

提供兩個測試 Job：

### 1. Mock 測試 (`example/densenet_onnx_mock.yaml`)

使用全零張量測試 API 連通性，不需真實圖片。

```bash
# 確認 Triton server 已就緒
kubectl -n triton get pods -l app=triton-server

# 套用測試 Job
kubectl apply -f terraform/triton/example/densenet_onnx_mock.yaml

# 查看 Job 執行狀態
kubectl -n triton get job triton-inference-test
kubectl -n triton logs job/triton-inference-test -f
```

#### 預期輸出

```
=== Triton Client Job ===
Triton URL : http://triton-server-service.triton.svc.cluster.local:8000
Model      : densenet_onnx

[1] Waiting for Triton server...
Triton server is READY

[2] Checking model readiness...
Model densenet_onnx is READY

[3] Creating test tensor...
Input shape: [1, 3, 224, 224]

[4] Calling Triton inference API...

=== Prediction ===
class_id   : xxx
confidence : 0.xxxxxx

=== Top-5 ===
class xxxx probability=0.xxxxxx
...
Inference test PASSED
```

---

### 2. 真實圖片推理測試 (`example/densenet_sea_lion_test.yaml`)

使用真實海獅圖片 (`sea_lion.jpg`) 進行完整推理驗證，**已知此圖為 sea lion (ImageNet class_id=150, synset=n02077923)**。

此 Job 會：
- 掛載 `1.setup/data/model_repository/densenet_onnx/` (含 `sea_lion.jpg`、`synset.txt`) 到 Pod 的 `/data/`
- 載入圖片並進行 DenseNet 標準前處理 (resize 256→center crop 224→ImageNet normalize)
- 呼叫 Triton 推理 API
- 計算 Softmax 機率並輸出 Top-5
- **驗證 Top-1 是否為預期的 sea lion**

#### 先決條件

確認模型目錄有以下檔案：
```bash
ls -la 1.setup/data/model_repository/densenet_onnx/
# sea_lion.jpg  synset.txt  config.pbtxt  1/
```

> `synset.txt` 為 ImageNet 1000 類別標籤對照表 (每行格式: `n02077923 sea lion`)

#### 執行測試

```bash
# 套用測試 Job (會自動建立 PV/PVC 掛載模型資產目錄)
kubectl apply -f terraform/triton/example/densenet_sea_lion_test.yaml

# 查看 Job 執行狀態
kubectl -n triton get job densenet-sea-lion-test
kubectl -n triton logs job/densenet-sea-lion-test -f
```

#### 預期輸出

```
=== Triton DenseNet Integration Test ===
Triton URL : http://triton-server-service.triton.svc.cluster.local:8000
Model      : densenet_onnx
Image      : /data/sea_lion.jpg
Expected   : n02077923

[1] Checking Triton readiness...
Triton server is READY

[2] Checking model readiness...
Model densenet_onnx is READY

[3] Loading ImageNet labels...
Loaded labels: 1000
Expected class_id: 150

[4] Loading image...
Original image size: (250, 179)

[5] Preprocessing image...
Model image size: (224, 224)
Tensor values: 150528
Tensor shape: [1, 3, 224, 224]

[6] Calling Triton inference API...
Output name : fc6_1
Output shape: [1, 1000, 1, 1]
Output count: 1000

[7] Calculating probabilities...

=== Top-5 Predictions ===
 150 0.985369 n02077923 sea lion
 268 0.004897 n02113978 Mexican hairless
 360 0.003075 n02444819 otter
 344 0.001085 n02398521 hippopotamus, hippo, river horse, Hippopotamus amphibius
 356 0.001026 n02441942 weasel

=== Prediction ===
class_id   : 150
synset     : n02077923
label      : n02077923 sea lion
confidence : 0.985369

=== Validation ===
Expected class_id : 150
Predicted class_id: 150
Expected synset   : n02077923
Predicted synset  : n02077923

✅ PASS: DenseNet correctly predicted sea lion. 
```

#### 驗證邏輯

| 項目 | 預期值 | 實際值 | 結果 |
|---|---|---|---|
| class_id | 150 | 150 | ✅ |
| synset | n02077923 | n02077923 | ✅ |
| label | sea lion | sea lion | ✅ |
| confidence | - | 0.985369 | 高信心度 |

---

### 手動呼叫 API (HTTP)

```bash
# 健康檢查
curl -i http://localhost:8000/v2/health/ready

# 模型就緒檢查
curl -i http://localhost:8000/v2/models/densenet_onnx/ready

# 推理請求 (需 port-forward: kubectl -n triton port-forward svc/triton-server-service 8000:8000)
curl -X POST http://localhost:8000/v2/models/densenet_onnx/infer \
  -H 'Content-Type: application/json' \
  -d '{"inputs":[{"name":"data_0","shape":[1,3,224,224],"datatype":"FP32","data":[0.0]}]}'
```
