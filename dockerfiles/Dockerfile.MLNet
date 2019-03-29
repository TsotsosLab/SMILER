FROM nvidia/cuda:8.0-cudnn5-devel

LABEL maintainer="Toni Kunic <tk@cse.yorku.ca>"

################################################################################
### Apt and pip dependencies

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    python-dev \
    python-setuptools \
    python-pkg-resources \
    libglib2.0-0 \
    libsm-dev \
    libxrender-dev \
    libxext-dev && \
    rm -rf /var/lib/apt/lists/*

RUN cd /tmp && \
    wget https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py

RUN pip install \
    wheel \
    Theano==0.9.0 \
    h5py==2.7.1 \
    opencv_python==3.3.0.10 \
    Keras==1.1.0 \
    numpy==1.14.3

RUN mkdir /root/.keras && \
  echo '{ \
      "image_dim_ordering": "th", \
      "backend": "theano" \
  }' > /root/.keras/keras.json

RUN echo "[global]\ndevice=gpu\nfloatX=float32\n[nvcc]\nfastmath=True" > /root/.theanorc

COPY ./smiler_tools /tmp/smiler_tools
RUN pip install /tmp/smiler_tools

################################################################################
### Run command on container start.

VOLUME ["/opt/model"]
VOLUME ["/opt/input_vol"]
VOLUME ["/opt/output_vol"]

WORKDIR /opt/model

CMD ["/bin/bash"]
