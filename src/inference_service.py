from tensorflow import keras
import numpy as np
import time

import os
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '0'


class SingletonMeta(type):
    _instances = {}

    def __call__(cls, *args, **kwargs):
        if cls not in cls._instances:
            instance = super().__call__(*args, **kwargs)
            cls._instances[cls] = instance
        return cls._instances[cls]


class InferenceService(metaclass=SingletonMeta):
    def __init__(self):
        prediction_start_time = time.time()
        self.model = keras.models.load_model('../models/MobileNet')
        self.model.summary()
        print('Tempo para carregar o modelo:', time.time() - prediction_start_time)

    def predict(self, image):
        preprocessed_image = self.preprocess_image(image)
        return self.model.predict(preprocessed_image)

    def preprocess_image(self, image_as_array):
        preprocessed_image = keras.applications.mobilenet_v2.preprocess_input(
            image_as_array)
        return np.array([preprocessed_image])
