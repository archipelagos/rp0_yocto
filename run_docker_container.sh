#!/bin/bash

# INFO: Tag name for image will be used system wide.
TAG_NAME=github-self-hosted-yocto-runner

# INFO: 
SCRIPT_PATH=$(pwd)

# INFO: 
YOCTO_SOURCES_PATH=${SCRIPT_PATH}/yocto/sources

# INFO: Sanity check. Be sure, that sources are present.
if [ ! -d ${YOCTO_SOURCES_PATH}/meta-openembedded ]; then
    echo Repository meta-openembedded is not present in sources.
    exit 1
fi

# INFO: Sanity check. Be sure, that sources are present.
if [ ! -d ${YOCTO_SOURCES_PATH}/meta-raspberrypi ]; then
    echo Repository meta-raspberrypi is not present in sources.
    exit 1
fi

# INFO: Sanity check. Be sure, that sources are present.
if [ ! -d ${YOCTO_SOURCES_PATH}/poky ]; then
    echo Repository poky is not present in sources.
    exit 1
fi

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
    -v ${SCRIPT_PATH}/launch_github_self_hosted_runner.sh:/home/docker/launch_github_self_hosted_runner.sh \
    -v ${SCRIPT_PATH}/token.secret:/home/docker/token.secret \
    -t ${TAG_NAME}
