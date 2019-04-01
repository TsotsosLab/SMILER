FROM nvidia/cuda:8.0-cudnn5-devel

LABEL maintainer="Toni Kunic <tk@cse.yorku.ca>"

################################################################################
### Apt and pip dependencies

RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential \
      python-pip \
      python-dev \
      python-numpy \
      python-scipy \
      python-opencv \
      python-skimage \
      python-protobuf \
      python-setuptools \
      libprotobuf-dev \
      libleveldb-dev \
      libsnappy-dev \
      libopencv-dev \
      libhdf5-serial-dev \
      protobuf-compiler \
      libboost-all-dev \
      libatlas-base-dev \
      libgflags-dev \
      libgoogle-glog-dev \
      liblmdb-dev \
      libxml2-dev \
      libxslt-dev \
      wget \
      unzip \
      cmake \
      git && \
    rm -rf /var/lib/apt/lists/*

################################################################################
### @wenguanwang's implementation depends on HED's caffe.

COPY models/docker/DVAP/model/Makefile.config /opt/Makefile.config

RUN git clone https://github.com/s9xie/hed.git /opt/caffe && \
    cd /opt/caffe && \
    protoc src/caffe/proto/caffe.proto --cpp_out=. && \
    mkdir include/caffe/proto && \
    mv src/caffe/proto/caffe.pb.h include/caffe/proto && \
    mv /opt/Makefile.config /opt/caffe/ && \
    make -j && \
    make tools && \
    make pycaffe

################################################################################
### smiler_tools

COPY ./smiler_tools /tmp/smiler_tools
RUN pip install /tmp/smiler_tools

################################################################################
### Run command on container start.

VOLUME ["/opt/model"]
VOLUME ["/opt/input_vol"]
VOLUME ["/opt/output_vol"]

WORKDIR /opt/model

CMD ["/bin/bash"]
