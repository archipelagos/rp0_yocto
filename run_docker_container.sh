#!/bin/bash

# INFO: Tag name for image will be used system wide.
TAG_NAME=github-self-hosted-yocto-runner

# INFO: Where is work dir located.
#WORKDIR=$(pwd)/workdir

# INFO: Check work directory.
#if [ -d ${WORKDIR} ]; then
    # INFO: Directory exist, ensuring correct ownership.
#    chown $(id -u):$(id -g) ${WORKDIR}
#else
    # INFO: Dorectory do not exist, creating with proper ownership.
#    mkdir -p ${WORKDIR}
#fi

# INFO: Run docker container as Github self-hosted runner dedicated to Yocto.
docker \
    run \
    -i \
    --rm \
    -v $(pwd)/launch_github_self_hosted_runner.sh:/home/docker/launch_github_self_hosted_runner.sh \
    -t ${TAG_NAME}
