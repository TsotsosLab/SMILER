"""
Image operations such as color space conversion and histogram equalization
"""

import numpy as np
from scipy import misc

def convertRGB2YUV(img):
    """Converts RGB image to YUV"""
    iplImg = misc.toimage(img)
    imgYUV = iplImg.convert('YCbCr')
    # np.asarray(imgYUV) gives a HxWx4 array which is wrong
    # so we're decoding the image byte string ourselves
    # http://mail.python.org/pipermail/image-sig/2010-November/006565.html
    imgArr = np.ndarray((iplImg.size[1], iplImg.size[0], 3), 'u1',
                imgYUV.tobytes())
    return imgArr

def hist_equalize_maps(fixMap, salMap):
    """Equalizes the histogram of a saliency map 'salMap' whith that of the
reference empirical saliency map 'fixMap'"""
    num_bins = 256
    counts, bins = np.histogram(fixMap.flatten(), num_bins)
    res = hist_equalize(salMap, counts, bins, num_bins);
    return res

def hist_equalize(salMap, N, X, num_bins=256):
    salMapShape = salMap.shape
    oN, oX = np.histogram(salMap.flatten(), num_bins)

    oC = np.hstack((0.0, oN.cumsum().astype(np.float)))
    oC /= oC[-1]

    nC = np.hstack((0.0, N.cumsum().astype(np.float)))
    nC /= nC[-1]
    nStep = np.diff(X)[0]
    nX = X/nStep+0.5

    nnX = np.interp(oC, nC, nX)
    res = np.interp(salMap.flatten(), oX, nnX)
    res = res.reshape(salMapShape)
    return res
