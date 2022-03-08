# SMILER on Windows

Welcome to SMILER for Windows!

While SMILER is designed to be run on Linux, there are some handy tips and tricks one can use to access SMILER functionality on a Windows machine. The process is not as seamless or as easy to set up as on a Linux machine, so if you have access to a Linux machine that would be a better option. If not, it is still possible to run all of the SMILER integrated models on a Windows machine, it just takes a little more playing around and setup.

SMILER has two main types of models, Docker-based models and MATLAB models. On a Linux machine both of these model categories can be run via the CLI, however, on Windows running these two categories of models has to be approached separately.

## Running Docker models on Windows

In order to run the SMILER Docker models on Windows SMILER needs to be run through a WSL 2 (Windows subsystem for Linux 2) distribution. Here is a guide for installing WSL 2: https://docs.docker.com/desktop/windows/wsl/. Using the WSL 2 terminal for your chosen distro will allow you to follow the SMILER CLI running procedure as explained in the README. Note: this only works for the non-MATLAB models. Running MATLAB models on Windows is explained in the following section.

## Running MATLAB models on Windows

To run the SMILER MATLAB models, unfortunately, there is no CLI integration due to compatibility issues with MATLAB Engine API for Python and WSL. Thus, to run the SMILER MATLAB models it is necessary to use the MATLAB interface as described in the README.

## Troubleshooting running SMILER on WSL 2

### Line endings
One possible error one might encounter when trying to run SMILER in WSL is an issue with the line endings of the files when trying to run Windows files in Linux.

If you encounter the following error when trying to run SMILER you likely have a line ending issue: 
```
/usr/bin/env: ‘python\r’: No such file or directory
```

To fix this, sudo install dos2unix using
```
sudo apt install dos2unix
```
Then run the following command to convert your file endings to Linux endings
```
dos2unix **
```

### Quotation mark errors
When running SMILER from the CLI, it seems that it is picky about what type of quotation marks you use. So if your computer defaults to using “”, make sure to use "" to wrap your model names instead.
