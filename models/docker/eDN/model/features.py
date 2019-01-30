"""
Image features and operations on them
"""

import numpy as np
import scipy as sp

import numexpr
numexpr.set_num_threads(1)
numexpr.set_vml_num_threads(1)

import sthor
from sthor.model.slm import SequentialLayeredModel

from imageOps import convertRGB2YUV

def eDN_features(img, desc, outSize=None):
    """ Computes eDN features for given image or image sequence 'img' based
on the given descriptor(s) 'desc'"""

    # iterates through individual DN models (Deep Networks) in the blend
    for i in xrange(len(desc)):
        imgC = img.copy()

        if desc[i]['colorSp'] == 'yuv':
            # either a single image or an image sequence
            for j in xrange(imgC.shape[2]/3):
                imgC[:,:,j*3:j*3+3] = convertRGB2YUV(imgC[:,:,j*3:j*3+3])

        imgC = imgC.astype('f')

        model = SequentialLayeredModel((imgC.shape[0],
                    imgC.shape[1]), desc[i]['desc'])
        fm = model.transform(imgC, pad_apron=True,
                interleave_stride=False)
        print('FM shape', fm.shape)
        if outSize:
            # zoom seems to round down when non-integer shapes are requested
            # and zoom does not accept an `output_shape` parameter
            fMap = sp.ndimage.interpolation.zoom(fm,
                (outSize[0]*(1+1e-5)/fm.shape[0],
                 outSize[1]*(1+1e-5)/fm.shape[1],
                 1.0))
        else:
            if i == 0:
                fmShape = fm.shape[:2]
                fMap = fm
            else:
                if fm.shape[:2] == fmShape:
                    fMap = fm
                else:
                    # models with different number of layers have different
                    # output sizes, so resizing is necessary
                    fMap = sp.ndimage.interpolation.zoom(fm,
                        (fmShape[0]*(1+1e-5)/fm.shape[0],
                         fmShape[1]*(1+1e-5)/fm.shape[1],
                         1.0))

        fMap = fMap.reshape(fMap.shape[0]*fMap.shape[1], -1, order='F')

        if i == 0:
            fMaps = fMap
        else:
            fMaps = np.hstack((fMaps, fMap))
    return fMaps, fmShape

def dist_to_cntr_features(img, outSize=None):
    """ Distance to image center feature; simulates the center bias """
    imgSize = img.shape[:2]
    midpointx = int(np.floor(imgSize[0]/2.0))
    midpointy = int(np.floor(imgSize[1]/2.0))
    distMat = np.zeros(imgSize)

    for x in xrange(imgSize[0]):
        for y in xrange(imgSize[1]):
            distMat[x, y] = np.floor(np.sqrt((x-midpointx)**2 + \
                                             (y-midpointy)**2))
    distMat = distMat/distMat.max()
    if outSize:
        fMap = sp.ndimage.interpolation.zoom(distMat,
            (outSize[0]*(1+1e-5)/distMat.shape[0],
             outSize[1]*(1+1e-5)/distMat.shape[1]))
    else:
        fMap = distMat
    fMap = fMap.reshape(fMap.shape[0]*fMap.shape[1], -1, order='F')
    return fMap

def whiten_features(X, whitenParams=None):
    """ Feature whitening """
    if whitenParams is None:
        Xmean = X.mean(axis=0)
        Xstd = np.maximum(X.std(axis=0), 1e-8)
    else:
        Xmean, Xstd = whitenParams
    X = (X - Xmean) / Xstd
    return X, [Xmean, Xstd]
