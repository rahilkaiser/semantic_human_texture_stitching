ARG CUDA_BASE_VERSION=10.0

# use CUDA + OpenGL
FROM nvidia/cudagl:${CUDA_BASE_VERSION}-devel-ubuntu18.04
MAINTAINER Domhnall Boyle (domhnallboyle@gmail.com)

# install apt dependencies
RUN apt-get update && apt-get install -y \
	git \
	vim \
	wget \
	software-properties-common \
	curl \
	libglu1-mesa-dev freeglut3-dev mesa-common-dev libosmesa6-dev libxrender1 libfontconfig1

# install newest cmake version
RUN apt-get purge cmake && cd ~ && wget https://github.com/Kitware/CMake/releases/download/v3.14.5/cmake-3.14.5.tar.gz && tar -xvf cmake-3.14.5.tar.gz
RUN cd ~/cmake-3.14.5 && ./bootstrap && make -j6 && make install

# install python2.7 and pip
RUN apt-add-repository -y ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y python2.7 python2.7-dev && \
    ln -s /usr/bin/python2.7 /usr/bin/python && \
    curl https://bootstrap.pypa.io/pip/2.7/get-pip.py | python

# arguments from command line
ARG CUDA_BASE_VERSION=10.0
ARG CUDNN_VERSION=7.6.0.64

# set environment variables
ENV CUDA_BASE_VERSION=${CUDA_BASE_VERSION}
ENV CUDNN_VERSION=${CUDNN_VERSION}

# setting up cudnn
RUN apt-get install -y --no-install-recommends \             
	libcudnn7=$(echo $CUDNN_VERSION)-1+cuda$(echo $CUDA_BASE_VERSION) \             
	libcudnn7-dev=$(echo $CUDNN_VERSION)-1+cuda$(echo $CUDA_BASE_VERSION) 
RUN apt-mark hold libcudnn7 && rm -rf /var/lib/apt/lists/*

ARG TENSORFLOW_VERSION=1.14.0
ENV TENSORFLOW_VERSION=${TENSORFLOW_VERSION}

WORKDIR /usr/src/app
COPY . .
RUN python -m pip install tensorflow-gpu==$(echo $TENSORFLOW_VERSION)
RUN python -m pip install -r requirements.txt
# install dirt
ENV CUDAFLAGS='-DNDEBUG=1'

RUN chmod u+x ./run_sample.sh