FROM ubuntu:16.04

LABEL maintainer="Toni Kunic <tk@cse.yorku.ca>"

############################################################
# NOTE: This container is special: its working directory   #
# is /opt/model_static: it doesn't use the mounted model   #
# directory /opt/model.                                    #
############################################################

################################################################################
### Apt and pip dependencies

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    python-pip \
    python-setuptools \
    cmake \
    libopencv-dev && \
  rm -rf /var/lib/apt/lists/*

COPY ./smiler_tools /tmp/smiler_tools
RUN pip install /tmp/smiler_tools

################################################################################
### Volumes and directories

VOLUME ["/opt/model"]
VOLUME ["/opt/input_vol"]
VOLUME ["/opt/output_vol"]

WORKDIR /opt/model_static

################################################################################
### Set up working directory for build.

COPY models/docker/BMS/model /opt/model_static

RUN mkdir ./build && cd ./build && cmake ../ && make

CMD ["/bin/bash"]
