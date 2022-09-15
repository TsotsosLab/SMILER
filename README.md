# SMILER

Welcome to SMILER!

The Saliency Model Implementation Library for Experimental Research (SMILER) is a software package which provides an open, standardized, and extensible framework for maintaining and executing computational saliency models. This work drastically reduces the human effort required to apply saliency algorithms to new tasks and datasets, while also ensuring consistency and procedural correctness for results and conclusions produced by different parties. At its launch SMILER already includes twenty three saliency models (fourteen models based in MATLAB and nine supported through containerization), and the open design of SMILER encourages this number to grow with future contributions from the community.

SMILER v2 is now in progress! The contributors are:

- Calden Wloka (Manager)
- Toni Kunic (Advisor)

Fall 2022:
- Jade Kessinger
- Emily Lee

Spring 2022:
- Andy Liu
- Anirudh Satish
- Clara McIntyre
- Francine Wright
- Richard Chang

The bundle code for SMILER v1 was written by:

- Calden Wloka (Current maintainer)
- Toni Kunic
- Iuliia Kotseruba
- Ramin Fahimi
- Nicholas Frosst

If you use this code in your work, please cite the paper on which this work was based:

- https://arxiv.org/abs/1812.08848

Much of the code base and datasets utilized in this bundle are not written by the bundle developers, and are instead owned by the individual researchers who originally developed and released the code. For each algorithm, dataset, or evaluation metric you use from the bundle, you should also cite the original work for which that particular component was developed. This bibliographic information can be accessed via the command `smiler info [model name]`.

## Installation

1. To install SMILER's prerequisites, run:

```
pip install -r requirements.txt
```

2. To be able to run MATLAB models, ensure the [MATLAB Python API](https://www.mathworks.com/help/matlab/matlab-engine-for-python.html) is installed. Here is a link to the wiki with [further information](https://github.com/TsotsosLab/SMILER/wiki/Tips-and-Tricks#installing-matlab-and-matlabengine) on how to get MATLAB and MATLAB.engine up and running and a link to the [Troubleshooting MATLAB Engine API for Python Installation guide](https://github.com/TsotsosLab/SMILER/wiki/Troubleshooting#troubleshooting-matlab-engine-api-for-python-installation)
3. To be able to run Docker models, ensure [nvidia-docker2](https://github.com/NVIDIA/nvidia-docker) is installed.

If you want to include `smiler` in your environment (so you can call `smiler` from any directory, instead of having to use `./smiler`), just add this to the end of your `.bashrc`:

```
export PATH=$PATH:[PATH TO SMILER]
```

Another thing you might want to do is add your user to the `docker` group, so you do not have to type in the sudo password when running SMILER (run `sudo usermod -a -G docker [your username]`, and log out and back in again).

## Running SMILER

There are two main ways to run SMILER: The CLI (Command Line Interface), and the MATLAB interface. The CLI is the preferred method of running models, since it can run all SMILER models, whereas the MATLAB interface can only run MATLAB models.

### <a name="cli">Using the CLI</a>

If you just want to run models with their default parameters, use:

```matlab
./smiler run -m "aim,dgii" [PATH TO INPUT DIRECTORY] [PATH TO OUTPUT DIRECTORY]
```

The argument to `-m` can be the short names of models (e.g. `aim,dgii`) of a model collection (e.g. `docker`, `matlab`, `all`) or any combination of models and collections. Run `./smiler info` for a list of available models.

For more interesting use cases, we recommend writing a YAML experiment file (examples are available [here](examples/yaml)):

```yaml
experiment:
  name: Simple Example
  description: An illustrative example of how to set up SMILER YAML experiments.
  input_path: /tmp/test_in
  base_output_path: /tmp/test_out
  parameters:
    do_smoothing: none

runs:
  - algorithm: AIM
    output_path: /tmp/AIM_smoothing
    parameters:
      do_smoothing: default

  - algorithm: AIM
    output_path: /tmp/AIM_no_smoothing

  - algorithm: DGII

  - algorithm: oSALICON
    parameters:
      color_space: LAB
```

And running it like so:

```
./smiler run -e experiment.yaml
```

For additional information on SMILER CLI usage, append `--help` to any SMILER command.


### <a name="matlab">Using the MATLAB Interface</a>

If you only wish to run the MATLAB models without using the CLI, and don't care about containerized models, navigate to the `smiler_matlab_tools` directory in MATLAB, and run `iSMILER.m`. After that, you can invoke models in the following way:

``` matlab
img_path = 'path/to/example.png';

AIM_map = AIM_wrap(img_path);
AWS_map = AWS_wrap(img_path);
IKN_map = IKN_wrap(img_path);
QSS_map = QSS_wrap(img_path);
...
```

To specify parameters, you can do the following:

``` matlab
img_path = 'path/to/example.png';
params = struct("color_space", "hsv")

AIM_map = AIM_wrap(img_path, params);
```

For more examples, see the [MATLAB examples directory](examples/MATLAB).

To get information about models from MATLAB (the equivalent of the CLI's `./smiler info` command), use the `smiler_info.m` function.

```
>> [model_name]_wrap(image, [parameters])
```

## SMILER for Windows
While SMILER is designed to be run on Linux, it is possible to run SMILER on a Windows machine. On Windows running MATLAB vs. Docker models must be approached separately. If experiencing difficulties getting SMILER up and running on Windows the [wiki troubleshooting guide](https://github.com/TsotsosLab/SMILER/wiki/Troubleshooting#troubleshooting-smiler-for-windows) might contain a solution.

### Running Docker models on Windows

In order to run the SMILER Docker models on Windows, SMILER needs to be run through a WSL 2 (Windows subsystem for Linux 2) distribution. Here is a guide for installing WSL 2: https://docs.docker.com/desktop/windows/wsl/. Using the WSL 2 terminal for your chosen distro will allow you to follow the Linux [SMILER CLI running procedure](#cli).

### Running MATLAB models on Windows

To run the SMILER MATLAB models, unfortunately, there is no CLI integration due to compatibility issues with MATLAB Engine API for Python and WSL. Thus, to run the SMILER MATLAB models it is necessary to use the [MATLAB interface](#matlab).

## Contributing New Models

To add additional models to SMILER, the easiest thing to do is to head over to the [model skeletons in the examples directory](examples/model_skeletons), copy one of the templates available there and fill it out following the instructions.

## Found a bug? Have a model request?

Please don't hesitate to [open an issue](https://github.com/TsotsosLab/SMILER/issues), and include as much information as you can.
