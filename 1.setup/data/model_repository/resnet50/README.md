# How to download resnet50 model

> ONNX Model
> - Github [ResNet Model](https://github.com/onnx/models/tree/main/validated/vision/classification/resnet)

```bash
$ curl -fL -o model.onnx https://github.com/onnx/models/raw/refs/heads/main/validated/vision/classification/resnet/model/resnet50-v2-7.onnx
```

## Model health check

```bash
$ curl -i http://localhost:8000/v2/models/resnet50/ready
```

## How to call api

```bash
$ python3 - <<'PY' | curl -s \
  -X POST http://localhost:8000/v2/models/resnet50/infer \
  -H 'Content-Type: application/json' \
  -d @-
import json

data = [0.0] * (1 * 3 * 224 * 224)

request = {
    "inputs": [
        {
            "name": "data",
            "shape": [1, 3, 224, 224],
            "datatype": "FP32",
            "data": data
        }
    ]
}

print(json.dumps(request))
PY
```