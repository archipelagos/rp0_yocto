# Source of information: https://dev.to/stephendpmurphy/automating-yocto-builds-w-self-hosted-runners-hka
#
# Automating Yocto Builds w/ Self-Hosted Runners

# Links to follow along:
# * https://github.com/glassboard-dev/gl-yocto-runner-image
# * https://github.com/glassboard-dev/gl-yocto-runner-image/pkgs/container/yocto-runner
# * https://github.com/glassboard-dev/gl-yocto-sandbox-software

# Intro

# Building a Linux kernel and rootfs on your local machine can take a LONG
# time to complete and can be taxing on your machines CPU and RAM. We can
# speed the process up by using a machine with more cores but having a better
# machine alone is not always convenient either - You need to access the build
# machine (physically or remotely), pull the new source, begin your build and
# cross your fingers hoping that something doesn't go wrong in the build while
# your not present or looking :-(. Once completed you may want to store the
# output images and SDK generated for future use which you will have to manage
# and distribute yourself.

# The first thing that comes to mind to help solve these problems is to use
# Github Actions and Runners, however the hosted instances offered by Github
# are under powered and lack the necessary storage space we need for our large
# Linux builds (~50GB of scratch space). Which brings us to our solution - A
# self-hosted runner on our own 12-core build server capable of tearing
# through Linux builds in about 30min compared to the usual 3.5hours on our
# laptops. We will also utilize the artifacts functionality for uploading the
# final images and SDK to Github where any developer can retrieve them.

# Self-Hosted Runner setup

# To make setting up our Yocto Build machine an easy process on a server, we
# will be creating our own Docker image that has all of the necessary packages
# and tools to spin up a self-hosted runner as well as the tools necessary to
# build a Yocto project.

# If you'd like to skip the step of building your own image you can pull a
# yocto-runner image from our Github registry!

# The Dockerfile is pretty straight forward. We specify that we want a base
# image of Ubuntu:20.04 and we will be using the latest version of the
# Self-hosted runner source: 2.285.1. Since we want this image to build on its
# own without input, we also add the noninteractive value to our
# DEBIAN_FRONTEND arg.

# base
FROM ubuntu:20.04

# Add a label pointing to our repository
LABEL org.opencontainers.image.source="https://github.com/archipelagos/rp0_yocto"

# set the github runner version
ARG RUNNER_VERSION="2.323.0"

# do a non interactive build
ARG DEBIAN_FRONTEND=noninteractive

# We then update and upgrade all of the packages in our base install and then
# add a new user called docker.

# update the base packages and add a non-sudo user
RUN apt-get update -y && apt-get upgrade -y && useradd -m docker

# Next we install all of the packages needed for a Self-Hosted runner as well
# as the packages required for a Yocto build.

# add additional packages as necessary
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    curl \
    jq \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3 \
    python3-venv \
    python3-dev \
    python3-pip \
    gawk \
    wget \
    git-core \
    diffstat \
    unzip \
    texinfo \
    gcc-multilib \
    chrpath \
    socat \
    libsdl1.2-dev \
    xterm \
    cpio \
    file \
    xxd \
    locales

# When building a Yocto project, you will also need to ensure that the locale
# environment variables are set appropriately.

# Update the locales to UTF-8
RUN locale-gen en_US.UTF-8 && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Next we move to our working directory for our new user - docker. Create a
# folder to hold the action-runner source, download the source and then
# extract it into our folder

# cd into the user directory, download and unzip the github actions runner
RUN cd /home/docker && mkdir actions-runner && cd actions-runner \
    && curl -o actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && echo "0dbc9bf5a58620fc52cb6cc0448abcca964a8d74b5f39773b7afcad9ab691e19  actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz" | shasum -a 256 -c \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# Next we install the additonal dependencies needed by the action-runner, move
# our startup script (Responsible for setting up and tearing down the runner)
# into the image, make the script executable and then finally set it as our
# entry point.

# install some additional dependencies
RUN chown -R docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh

# copy over the start.sh script
COPY start.sh /home/docker/start.sh

# make the script executable
RUN chmod +x /home/docker/start.sh

# since the config and run script for actions are not allowed to be run by root,
# set the user to "docker" so all subsequent commands are run as the docker user
USER docker

WORKDIR /home/docker

# set the entrypoint to the start.sh script
ENTRYPOINT ["./start.sh"]
