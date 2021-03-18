#**********************************************************************************#
# Copyright by @bkozdras <b.kozdras@gmail.com>                                     #
# Purpose: To build docker image from provided Dockerfile in the current repo.     #
# Version: 1.0                                                                     #
# Licence: MIT                                                                     #
#**********************************************************************************#

#!/bin/bash

echo "Checking docker availability..."

if ! docker -v &> /dev/null
then
    echo "Docker is not found!"
    echo "WSL: Install and/or run Docker Desktop from https://www.docker.com/products/docker-desktop"
    echo "Ubuntu standalone: use sudo apt-get install docker"
    exit -1
fi

echo "docker is available!"

DOCKER_BUILDKIT=1
CURRENT_DIR=$(pwd)
NUMBER_OF_CPUS=$(grep -c ^processor /proc/cpuinfo)
IMAGE_TAG_NAME="bkozdras/avr-build-environment"

echo "CURRENT_DIR=$CURRENT_DIR"
echo "NUMBER_OF_CPUS=$NUMBER_OF_CPUS"
echo "IMAGE_TAG_NAME=$IMAGE_TAG_NAME"

$(set -x && docker \
    --log-level debug \
    build \
    --cpu-shares=$NUMBER_OF_CPUS \
    --file Dockerfile \
    --tag $IMAGE_TAG_NAME:latest \
    .)

echo "Docker building is finished. See log output to check if succeeded!"

exit 0
