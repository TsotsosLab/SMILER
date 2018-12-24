# SMILER Docker Model Skeleton

This directory is a template to aid in creation of new SMILER models. Copy these files over to `SMILER/models/docker`, and fill them in with details specific to your model.

SMILER's Docker models rely on the following being present:

## 1. `smiler.json`

Holds metadata about the model.

## 2. `models/run_model.py`

A file that serves as the entry point for SMILER. It should perform model initialization, and call `smiler_tools.runner.run_model` with a single argument: a function that takes in a path to a single image (not directory), and returns a saliency map as a numpy array. SMILER will handle pre- and post-processing of the image.

If you wish to bypass SMILER's `smiler_tools` functions, you can modify the `run_command` parameter in `smiler.json` to be something else, but this is not recommended.

## 3. A Docker Image

In `smiler.json`, you will specify a Docker image this model will be run within. Some great choices are:

- SMILER's pre-built containers for other models: https://hub.docker.com/u/tsotsoslab
- Base CUDA containers: https://hub.docker.com/r/nvidia/cuda
- The official TensorFlow container: https://hub.docker.com/r/tensorflow/tensorflow
- The official caffe container: https://hub.docker.com/r/bvlc/caffe

You can also write your own Dockerfile (see [dockerfiles](dockerfiles) for examples), and build an image locally, and write its name into the `docker_image` field in the `smiler.json`.
