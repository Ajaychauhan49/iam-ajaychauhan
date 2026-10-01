Login to ECR (replace and with your actual values)
$ aws ecr get-login-password --region | docker login --username AWS --password-stdin .dkr.ecr..amazonaws.com

Build the Docker image (replace with your ECR repository name)
$ docker build -t .dkr.ecr..amazonaws.com/:latest .

Push the Docker image to ECR (replace with your ECR repository name)
$ docker push .dkr.ecr..amazonaws.com/:latest