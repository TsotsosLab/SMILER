FROM ubuntu:16.04

LABEL maintainer="Toni Kunic <tk@cse.yorku.ca>"

################################################################################
### Apt and pip dependencies

RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential \
      python-pip \
      python-setuptools \
      python-matplotlib \
      python-dev \
      python-tk \
      libxml2-dev \
      libxslt-dev \
      git && \
    rm -rf /var/lib/apt/lists/*

COPY ./smiler_tools /tmp/smiler_tools
RUN pip install /tmp/smiler_tools

################################################################################
### Run command on container start.

VOLUME ["/opt/model"]
VOLUME ["/opt/input_vol"]
VOLUME ["/opt/output_vol"]

WORKDIR /opt/model

CMD ["/bin/bash"]

################################################################################
### Set up liblinear and sthor.

RUN pip install --upgrade pip setuptools
RUN pip install setuptools cython numpy scipy numexpr scikit-image liblinear hyperopt

RUN mkdir /opt/dependencies && \
    cd /opt/dependencies && \
    git clone https://github.com/tkunic/sthor.git && \
    cd /opt/dependencies/sthor/sthor/operation && \
    make && \
    pip install /opt/dependencies/sthor

RUN cd /opt/dependencies && \
    git clone https://github.com/cjlin1/liblinear && \
    cd liblinear && \
    git checkout tags/v201 && \
    make && \
    cd python && \
    make

ENV PYTHONPATH "${PYTONPATH}:/opt/dependencies/liblinear/python:/opt/dependencies/sthor/:/opt/dependencies/sthor/build/lib.linux-x86_64-2.7/sthor/sthor/:/opt/dependencies/sthor/build/lib.linux-x86_64-2.7/sthor/sthor/resample/"