#**********************************************************************************#
# Copyright by @bkozdras <b.kozdras@gmail.com>                                     #
# Purpose: To build docker image with build system for AVR MCUs (cross-compiling). #
# Version: 1.0                                                                     #
# Licence: MIT                                                                     #
#**********************************************************************************#

FROM ubuntu:20.04
MAINTAINER Bartlomiej Kozdras <b.kozdras@gmail.com>
LABEL version="1.0"

#********************************************#
# You can modify your custom versions here.  #
# BEGIN: VERSION SETUP                       #
# BINUTILS VERSION FORMAT: X.Y               #
# BINUTILS_VERSION=X.Y                       #
ENV BINUTILS_VERSION 2.36
# CMAKE VERSION FORMAT: X.Y.Z                #
# CMAKE_MAJOR_VERSION=X.Y                    #
ENV CMAKE_MAJOR_VERSION 3.20
# CMAKE_MINOR_VERSION=Z                      #
ENV CMAKE_MINOR_VERSION 0-rc5
# GCC VERSION FORMAT: X.Y.Z                  #
# GCC_MAJOR_VERSION=X                        #
ENV GCC_MAJOR_VERSION 10
# GCC_MINOR_VERSION=Y.Z                      #
ENV GCC_MINOR_VERSION 2.0
# LIBC VERSION FORMAT=X.Y.Z                  #
# LIBC_VERSION=X.Y.Z                         #
ENV LIBC_VERSION 2.0.0
# END: VERSION SETUP                         #
#********************************************#

ENV CMAKE_VERSION $CMAKE_MAJOR_VERSION.$CMAKE_MINOR_VERSION
ENV GCC_VERSION $GCC_MAJOR_VERSION.$GCC_MINOR_VERSION

USER root
WORKDIR /

#***************************************************#
# Updating and installing initial librariers.       #
# BEGIN: INSTALL PREREQUISITES                      #
RUN \
    apt-get update -y                             \
    && apt-get upgrade -y                         \
    && apt-get dist-upgrade -y                    \
    && apt-get install -y                         \
    && apt-get install -y --no-install-recommends \
        libmpc-dev                                \
        libmpfr-dev                               \
        libgmp3-dev                               \
        libssl-dev                                \
        gcc-$GCC_MAJOR_VERSION                    \
        g++-$GCC_MAJOR_VERSION                    \
        make                                      \
        ninja-build                               \
        wget                                      \
        pod2pdf                                   \
    && apt-get autoremove -y
# END: INSTALL PREREQUISITES                        #
#***************************************************#

#*******************************************#
# Naming directories used in build process. #
# BEGIN: SET ENV VARIABLES                  #
ENV BUILD_DIR avr_gcc_build

ENV BINUTILS_SUBDIR binutils_dir
ENV CMAKE_SUBDIR cmake_dir
ENV GCC_SUBDIR gcc_dir
ENV LIBC_SUBDIR libc_dir

ENV AVR_INSTALL_DIR /usr/local/avr
ENV AVR_BIN_PATH $AVR_INSTALL_DIR/bin
ENV PATH=$PATH:$AVR_BIN_PATH
# END: SET ENV VARIABLES                    #
#*******************************************#

ENV CC gcc-$GCC_MAJOR_VERSION
ENV CXX g++-$GCC_MAJOR_VERSION

WORKDIR /

RUN \
    mkdir $AVR_INSTALL_DIR \
    && mkdir $BUILD_DIR

#******************************************************************************#
# Building and installing requested binutils                                   #
# BEGIN: BUILD AND INSTALL BINUTILS                                            #
RUN \
    echo "Building binutils..."                                              \
    && cd $BUILD_DIR                                                         \
    && mkdir $BINUTILS_SUBDIR                                                \
    && cd $BINUTILS_SUBDIR                                                   \
    && wget ftp://ftp.gnu.org/gnu/binutils/binutils-$BINUTILS_VERSION.tar.gz \
        --no-check-certificate                                               \
    && tar -xzvf binutils-$BINUTILS_VERSION.tar.gz                           \
    && cd binutils-$BINUTILS_VERSION                                         \
    && mkdir build                                                           \
    && cd build                                                              \
    && ../configure --target=avr --prefix=$AVR_INSTALL_DIR --disable-nsl     \
    && make -j$(nproc --all)                                                 \
    && make install                                                          \
    && avr-as --help                                                         \
    && cd ../../..
# END: BUILD AND INSTALL BINUTILS                                              #
#******************************************************************************#

#******************************************************************************#
# BEGIN: REPLACING ORIGINAL AVR-SIZE WITH CUSTOM ATMEL VERSION                 #
RUN \
    apt-get install binutils-avr -y --no-install-recommends \
    && rm $AVR_BIN_PATH/avr-size                            \
    && cp /usr/bin/avr-size $AVR_BIN_PATH/                  \
    && apt remove binutils-avr -y
# END: REPLACING ORIGINAL AVR-SIZE WITH CUSTOM ATMEL VERSION                   #
#******************************************************************************#

#*********************************************************************************#
# Building and installing requested cmake                                         #
# BEGIN: BUILD AND INSTALL CMAKE                                                  #
RUN \
    echo "Building cmake..."                                                      \
    && cd $BUILD_DIR                                                              \
    && mkdir $CMAKE_SUBDIR                                                        \
    && cd $CMAKE_SUBDIR                                                           \
    && wget                                                                       \
        https://cmake.org/files/v$CMAKE_MAJOR_VERSION/cmake-$CMAKE_VERSION.tar.gz \
        --no-check-certificate                                                    \
    && tar -xzvf cmake-$CMAKE_VERSION.tar.gz                                      \
    && cd cmake-$CMAKE_VERSION                                                    \
    && ./bootstrap                                                                \
    && make -j$(nproc --all)                                                      \
    && make install                                                               \
    && cmake --version                                                            \
    && cd ../..
# END: BUILD AND INSTALL CMAKE                                                    #
#*********************************************************************************#

#*************************************************************************************#
# Building and installing requested gcc                                               #
# BEGIN: BUILD AND INSTALL GCC                                                        #
RUN \
    echo "Building avr-gcc and avr-g++..."                                          \
    && cd $BUILD_DIR                                                                \
    && mkdir $GCC_SUBDIR                                                            \
    && cd $GCC_SUBDIR                                                               \
    && wget ftp://ftp.gnu.org/gnu/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.gz      \
        --no-check-certificate                                                      \
    && tar -xzvf gcc-$GCC_VERSION.tar.gz                                            \
    && cd gcc-$GCC_VERSION                                                          \
    && ./contrib/download_prerequisites                                             \
    && mkdir build                                                                  \
    && cd build                                                                     \
    && ../configure --target=avr --prefix=$AVR_INSTALL_DIR --enable-languages=c,c++ \
        --disable-nls --disable-libssp --with-dwarf2 \
    && make -j$(nproc --all)                                                        \
    && make install                                                                 \
    && avr-gcc --version                                                            \
    && cd ../../..
# END: BUILD AND INSTALL GCC                                                          #
#*************************************************************************************#

#***********************************************************************************************#
# Building and installing requested libc                                                        #
# BEGIN: BUILD AND INSTALL LIBC                                                                 #
ENV CC avr-gcc
ENV CXX avr-g++
RUN \
    echo "Building AVR libraries (libc)..."                                                   \
    && cd $BUILD_DIR                                                                          \
    && mkdir $LIBC_SUBDIR                                                                     \
    && cd $LIBC_SUBDIR                                                                        \
    && wget http://download.savannah.gnu.org/releases/avr-libc/avr-libc-$LIBC_VERSION.tar.bz2 \
        --no-check-certificate                                                                \
    && tar -xf avr-libc-$LIBC_VERSION.tar.bz2                                                 \
    && cd avr-libc-$LIBC_VERSION                                                              \
    && mkdir build                                                                            \
    && cd build                                                                               \
    && ../configure --prefix=$AVR_INSTALL_DIR --build=`../config.guess` --host=avr            \
    && make -j$(nproc --all)                                                                  \
    && make install                                                                           \
    && cd ../../..
ENV CC gcc-$GCC_MAJOR_VERSION
ENV CXX g++-$GCC_MAJOR_VERSION
# END: BUILD AND INSTALL LIBC                                                                   #
#***********************************************************************************************#

#***************************************#
# Removing build artifacts              #
# BEGIN: REMOVE BUILD ARTIFACTS         #
RUN \
    echo "Cleaning up temporary files" \
    && rm -r -f $BUILD_DIR             \
    && apt remove -y                   \
        libmpc-dev                     \
        libmpfr-dev                    \
        libgmp3-dev                    \
        libssl-dev                     \
        wget                           \
        pod2pdf
# END: REMOVE BUILD ARTIFACTS           #
#***************************************#

#***************************************************#
# Install utilities used inside container           #
# BEGIN: INSTALL UTILITIES                          #
RUN \
    apt-get install -y --no-install-recommends    \
        git                                       \
        doxygen                                   \
        vim                                       \
        lcov                                      \
    && apt-get autoremove -y
# END: INSTALL UTILITIES                            #
#***************************************************#
