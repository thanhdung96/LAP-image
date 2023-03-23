# LAP-Stack image

## Description

LAMP stack image without MySQL, suitable for running on resource-constrained VMs on AWS or GCP
Based on https://hub.docker.com/r/mattrayner/lamp

## Build and use

1. git clone git@github.com:thanhdung96/LAP-image.git
2. cd LAP-image
3. docker build --build-arg PHP_VERSION=8.2 -t=thanhdung96/lap_stack:latest -f ./Dockerfile .
4. docker run -p "8090:80" -v <project_dir>:/app thanhdung96/lap_stack:latest
