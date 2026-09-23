#densenet_onnx model

> ONNX Model
> - Github [Densenet-121 Model](https://github.com/onnx/models/tree/main/validated/vision/classification/densenet-121)
> - Hagging Face [densenet-12 Model](https://huggingface.co/onnxmodelzoo/densenet-12)

## How to download 

```bash
$ curl -fL -o model.onnxhttps://github.com/onnx/models/raw/refs/heads/main/validated/vision/classification/densenet-121/model/densenet-12.onnx
```

## How to download synset.txt

```bash
$ curl -fL -o synset.txt https://s3.amazonaws.com/onnx-model-zoo/synset.txt
```

## Model health check

```bash
$ curl -i http://localhost:8000/v2/models/densenet_onnx/ready
```

## How to call api

```bash
$ python3 - <<'PY' | curl -s \
  -X POST http://localhost:8000/v2/models/densenet_onnx/infer \
  -H 'Content-Type: application/json' \
  -d @-
import json

data = [0.0] * (1 * 3 * 224 * 224)

request = {
    "inputs": [
        {
            "name": "data_0",
            "shape": [1, 3, 224, 224],
            "datatype": "FP32",
            "data": data
        }
    ]
}

print(json.dumps(request))
PY
```