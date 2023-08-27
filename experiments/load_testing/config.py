from dotenv import load_dotenv
import os

# Load environment variables from .env file
load_dotenv()

HOST = 'runtime.sagemaker.us-east-1.amazonaws.com'
REGION = 'us-east-1'
# replace the url below with the sagemaker endpoint you are load testing
SAGEMAKER_ENDPOINT_URL = 'https://runtime.sagemaker.us-east-1.amazonaws.com/endpoints/mobilenet/invocations'
ACCESS_KEY = os.getenv("ACCESS_KEY")
SECRET_KEY = os.getenv("SECRET_KEY")


# replace the context type below as per your requirements
# CONTENT_TYPE = 'text/csv'
CONTENT_TYPE = 'application/octet-stream'
METHOD = 'POST'
SERVICE = 'sagemaker'
SIGNED_HEADERS = 'content-type;host;x-amz-date'
CANONICAL_QUERY_STRING = ''
ALGORITHM = 'AWS4-HMAC-SHA256'
