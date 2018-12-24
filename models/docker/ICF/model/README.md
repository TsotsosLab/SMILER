# DeepGazeII Model

This model is run inside a docker container using `nvidia-docker2` (installation instructions [here](https://github.com/NVIDIA/nvidia-docker)). This is to enable easier use of multiple models on the same machine at the same time.

## Running

First, build the docker image:

```
sudo script/build
```

Then, to process a directory of images:

```
sudo script/batch -i INPUT_DIR -o OUTPUT_DIR"
```

If you wish to experiment with the directory, you can always run `script/shell` to get a bash shell within the container, `script/ipython` to get ipython, or `script/jupyter` to get an jupyter notebook.

## Keep in mind

- The DGII folder, input directory, and output directory are mounted inside the container as volumes. This means they can be edited on the host with your usual editor, and the changes will take effect inside the container.
- The container is deleted when you exit: the only persistent files are the above mounted volumes, everything else will be deleted.
