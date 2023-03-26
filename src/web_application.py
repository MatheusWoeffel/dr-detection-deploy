from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from PIL import Image
from inference_service import InferenceService
import uvicorn
import io
from tensorflow import keras
import numpy as np
import time

app = FastAPI()

origins = ['*']

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/ping")
async def root():
    return {"status": "up"}


@app.post("/invocations")
async def invocations(request: Request):
    request_start_time = time.time()

    raw_body = await request.body()
    img = Image.open(io.BytesIO(raw_body))

    prediction_start_time = time.time()
    img_array = keras.preprocessing.image.img_to_array(img)
    result = InferenceService().predict(img_array)
    prediction_end_time = time.time()

    request_end_time = time.time()
    request_latency = request_end_time - request_start_time
    prediction_latency = prediction_end_time - prediction_start_time

    return {'predictions': result[0].tolist(), 'requestLatency': request_latency, 'predictionLatency': prediction_latency}

if __name__ == "__main__":
    uvicorn.run(app, host='0.0.0.0', port=8000)
