FROM nvidia/cuda:8.0-cudnn5-devel

LABEL maintainer="Toni Kunic <tk@cse.yorku.ca>"

################################################################################
### Apt and pip dependencies

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    python3-dev \
    python3-setuptools \
    python-pkg-resources \
    libglib2.0-0 \
    libsm-dev \
    libxrender-dev \
    libxext-dev && \
    rm -rf /var/lib/apt/lists/*

RUN cd /tmp && \
    wget https://bootstrap.pypa.io/get-pip.py && \
    python3 get-pip.py

RUN pip3 install \
    Theano==0.9.0 \
    h5py==2.8.0rc1 \
    opencv_python==3.3.0.10 \
    Keras==1.1.0 \
    numpy==1.14.3

RUN mkdir /root/.keras && \
  echo '{ \
      "image_data_format": "channels_last", \
      "image_dim_ordering": "th", \
      "epsilon": 1e-07, \
      "floatx": "float32", \
      "backend": "theano" \
  }' > /root/.keras/keras.json

RUN echo "[global]\ndevice=gpu\nfloatX=float32\n" > /root/.theanorc

COPY ./smiler_tools /tmp/smiler_tools
RUN pip3 install /tmp/smiler_tools

################################################################################
### Run command on container start.

VOLUME ["/opt/model"]
VOLUME ["/opt/input_vol"]
VOLUME ["/opt/output_vol"]

WORKDIR /opt/model

CMD ["/bin/bash"]