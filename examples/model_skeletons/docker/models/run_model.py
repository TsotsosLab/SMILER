#!/usr/bin/env python

import os
import sys

from smiler_tools.runner import run_model

from your_model import your_model

if __name__ == "__main__":
    model = your_model()

    def compute_saliency(image_path):
        return model.compute_saliency(image_path)

    run_model(compute_saliency)
