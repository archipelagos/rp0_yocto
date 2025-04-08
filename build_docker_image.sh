#!/bin/bash

# INFO: Tag name for image will be used system wide.
TAG_NAME=github-self-hosted-yocto-runner

# INFO: Build docker image based on Dockerfile.
docker \
    build \
    -t ${TAG_NAME} \
    .
