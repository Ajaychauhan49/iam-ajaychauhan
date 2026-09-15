#!/bin/bash
#set -e is use stop script immediatly if any statements fails without set -e, the script may continue to the next command even though the previous command failed.
set -e

#Pull The Docker image from Docker Hub

docker pull ajaychauhan586/iam_ajaychauhan586:simple-python-flask-app

#Run the Docker image as container
#-d                 → run container in background
#--name             → give container a name
#-p 80:5000         → host port 80 → container port 5000
#IMAGE:TAG          → Docker image to run

docker run -d --name simple-python-app -p 5000:5000 ajaychauhan586/iam_ajaychauhan586:simple-python-flask-app