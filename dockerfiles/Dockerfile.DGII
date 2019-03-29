FROM tensorflow/tensorflow:1.12.0-gpu-py3

LABEL maintainer="Toni Kunic <tk@cse.yorku.ca>"

################################################################################
### Apt and pip dependencies

RUN apt-get update && apt-get install -y --no-install-recommends \
            python3-tk python-opencv && \
  rm -rf /var/lib/apt/lists/*

RUN pip3 install opencv-python

COPY ./smiler_tools /tmp/smiler_tools
RUN pip3 install /tmp/smiler_tools

################################################################################
### Volumes and directories

VOLUME ["/opt/model"]
VOLUME ["/opt/input_vol"]
VOLUME ["/opt/output_vol"]

WORKDIR /opt/model

CMD ["/bin/bash"]
