aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 647348626155.dkr.ecr.us-east-1.amazonaws.com

docker build -t dr-detection-deploy-images .

docker tag dr-detection-deploy-images:latest 647348626155.dkr.ecr.us-east-1.amazonaws.com/dr-detection-deploy-images:latest

docker push 647348626155.dkr.ecr.us-east-1.amazonaws.com/dr-detection-deploy-images:latest