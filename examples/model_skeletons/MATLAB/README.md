# SMILER MATLAB Model skeleton

This folder contains the skeleton of a SMILER-wrapped saliency model written in MATLAB.

`skeleton_wrap.m` provides a template for wrapping a saliency model, and `smiler.json` provides a template for the information specification file for a saliency model.

Note that for SMILER to know where to look for a wrapped MATLAB model, the model folder containing the wrapper function, `smiler.json` file, and any required saliency processing code must be placed in `[SMILER root]/models/matlab`.
