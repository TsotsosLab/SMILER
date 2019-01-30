#!/usr/bin/env python

import os
import pickle

import numpy as np
from scipy import misc, ndimage

from eDNSalModel import EDNSaliencyModel
from liblinearutil import load_model

from smiler_tools.runner import run_model

os.environ['GLOG_minloglevel'] = '3'  # Suppress logging.

if __name__ == "__main__":
    desc_file_path = 'slmBestDescrCombi.pkl'
    with open(desc_file_path) as fp:
        desc = pickle.load(fp)

    nFeatures = np.sum([
        d['desc'][-1][0][1]['initialize']['n_filters'] for d in desc
        if d != None
    ])

    # load SVM model and whitening parameters
    svm_path = 'svm-slm-cntr'
    svm = load_model(svm_path)

    whiten_path = 'whiten-slm-cntr'
    with open(whiten_path) as fp:
        whitenParams = np.asarray(
            [map(float, line.split(' ')) for line in fp]).T

    # assemble svm model
    svmModel = {'svm': svm, 'whitenParams': whitenParams}

    biasToCntr = (svm.get_nr_feature() - nFeatures) == 1

    def eDNsaliency(image_path):
        img = misc.imread(image_path, mode='RGB')

        # compute saliency map
        model = EDNSaliencyModel(desc, svmModel, biasToCntr)

        salMap = model.saliency(img, normalize=False)

        salMap = salMap.astype('f')

        # normalize and save the saliency map to disk
        normSalMap = (255.0 / (salMap.max() - salMap.min()) *
                      (salMap - salMap.min())).astype(np.uint8)

        return normSalMap

    run_model(eDNsaliency)
