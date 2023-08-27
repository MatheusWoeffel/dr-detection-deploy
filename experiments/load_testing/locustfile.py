from locust import HttpUser, task
from authorizer import authorize
import config as conf
import json

PAYLOAD = ''
with open('./sample_images/NO_DR.png', mode='rb') as file:  # b is important -> binary
    PAYLOAD = file.read()

class SagemakerUser(HttpUser):
    min_wait = 1
    max_wait = 30000  # No request can last longer than 30 seconds

    @task
    def test_inference(self):
        headers = authorize(PAYLOAD)
        self.client.post(self.host, data=PAYLOAD, headers=headers, name='Post Request')
