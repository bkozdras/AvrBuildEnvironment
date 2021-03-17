#*************************************************************************************************#
# Copyright by @bkozdras <b.kozdras@gmail.com>                                                    #
# Purpose: To run and exec /bin/bash in docker container bkozdras/bkozdras/avr-build-environment. #
# Version: 1.0                                                                                    #
# Licence: MIT                                                                                    #
#*************************************************************************************************#

#!/bin/bash

if ! docker -v &> /dev/null
then
    echo "Docker is not found!"
    echo "WSL: Install Docker Desktop from https://www.docker.com/products/docker-desktop"
    echo "Ubuntu standalone: use sudo apt-get install docker"
    exit -1
fi

IMAGE_TAG_NAME="bkozdras/avr-build-environment"

if [[ "$(! docker images -q $IMAGE_TAG_NAME:latest 2> /dev/null)" == "" ]]; then
    echo "Docker image $IMAGE_TAG_NAME does not exist! Run buildImage.sh first!"
    exit -1
fi

(set -x; docker run --rm -ti -e "TERM=xterm-256color" $IMAGE_TAG_NAME:latest /bin/bash -l)

exit 0
