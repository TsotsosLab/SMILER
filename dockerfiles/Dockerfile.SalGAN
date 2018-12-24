FROM nvidia/cuda:8.0-cudnn5-devel

LABEL maintainer="Toni Kunic <tk@cse.yorku.ca>"

################################################################################
### Apt and pip dependencies

RUN apt-get update && apt-get install -y --no-install-recommends \
      python-dev \
      python-pip \
      python-setuptools \
      python-pkg-resources \
      libtiff5-dev \
      libjpeg8-dev \
      python-opencv \
      libblas-dev && \
    rm -rf /var/lib/apt/lists/*

RUN pip install \
      tqdm==4.5.0 \
      numpy==1.11.0 \
      Theano==0.8.2 \
      https://github.com/Lasagne/Lasagne/archive/master.zip

COPY ./smiler_tools /tmp/smiler_tools
RUN pip install /tmp/smiler_tools

################################################################################
### Run command on container start.

VOLUME ["/opt/model"]
VOLUME ["/opt/input_vol"]
VOLUME ["/opt/output_vol"]

WORKDIR /opt/model

CMD ["/bin/bash"]