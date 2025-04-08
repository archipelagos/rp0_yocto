#!/bin/bash

# INFO: Tag name for image will be used system wide.
TAG_NAME=github-self-hosted-yocto-runner

# INFO: Run docker container as Github self-hosted runner dedicated to Yocto.
docker \
    run \
    --rm \
    -v $(pwd)/launch_github_self_hosted_runner.sh:/home/docker/launch_github_self_hosted_runner.sh \
    -t ${TAG_NAME}

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

# INFO: Run docker image from built image.
#docker run \
#	-it \
#	--rm \
#    --hostname ${HOSTNAME} \
#    -u $(id -u):$(id -g) \
#    -v /etc/passwd:/etc/passwd:ro \
#    -v /etc/group:/etc/group:ro \
#    -v ${WORKDIR}:${HOME} \
#    -v ${HOME}/.gitconfig:${HOME}/.gitconfig \
#    -v ${HOME}/.ssh/gsep/gsep.crt:${HOME}/.ssh/gsep/gsep.crt:ro \
#    -v ${HOME}/.ssh/gsep/gsep.key:${HOME}/.ssh/gsep/gsep.key:ro \
#	${TAG_NAME}:latest
