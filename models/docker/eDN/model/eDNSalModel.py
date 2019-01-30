import numpy as np
import scipy as sp
from scipy import misc
import time
import logging

from liblinearutil import predict

from features import eDN_features, dist_to_cntr_features, whiten_features

EDN_INSIZE = (512, 384)


class EDNSaliencyModel(object):
    def __init__(self, descriptions, svmModel, biasToCntr=False):
        self.descriptions = descriptions
        self.svm = svmModel['svm']
        self.whitenParams = svmModel['whitenParams']
        self.biasToCntr = biasToCntr
        nFeatures = np.sum([
            d['desc'][-1][0][1]['initialize']['n_filters']
            for d in self.descriptions if d != None
        ])
        diff = self.svm.get_nr_feature() - nFeatures
        if diff != 0:
            if diff == 1 and not biasToCntr:
                raise ValueError("The number of features in eDN and svm "
                                 "models does not match! Is the center bias "
                                 "correctly set?")

    def saliency(self, img, normalize=True):
        """Computes eDN saliency map for single image or image sequence"""

        descs = self.descriptions

        # rescale image to typical input size
        imgSize = img.shape[:2]
        rescale_factor = 0.5*EDN_INSIZE[0]/max(imgSize) + \
                         0.5*EDN_INSIZE[1]/min(imgSize)
        # single image:
        # img = misc.imresize(image, rescale_factor, 'bicubic')

        # image sequence (or single image)
        scaledImg = np.zeros([a * rescale_factor
                              for a in imgSize] + [img.shape[2]])
        for j in xrange(img.shape[2] / 3):
            scaledImg[:, :, j * 3:j * 3 + 3] = misc.imresize(
                img[:, :, j * 3:j * 3 + 3], rescale_factor, 'bicubic')
        img = scaledImg
        # compute eDN features for description(s)
        t1 = time.time()
        fMapEDN, fMapSize = eDN_features(img, descs)
        t2 = time.time()
        logging.info("Feature computation took %0.3fs" % (t2 - t1))
        print('fMapSize', fMapSize)
        if self.biasToCntr:
            fMapCntr = dist_to_cntr_features(img, fMapSize)
            fMap = np.hstack((fMapCntr, fMapEDN))
        else:
            fMap = fMapEDN

        fMapW, fwParams = whiten_features(fMap, self.whitenParams)

        # SVM prediction
        t1 = time.time()
        bs, pAcc, pred = predict([], fMapW.tolist(), self.svm, options="-q")
        t2 = time.time()
        logging.info("Prediction took %0.3fs" % (t2 - t1))
        pred = np.array(pred)

        # reshaping and upscaling
        pred = pred.reshape(fMapSize, order='F')
        predLarge = sp.ndimage.interpolation.zoom(
            pred, (imgSize[0] / float(pred.shape[0]),
                   imgSize[1] / float(pred.shape[1])))

        # normalization
        if normalize:
            rescaled = (255.0 / (predLarge.max() - predLarge.min()) *
                        (predLarge - predLarge.min())).astype(np.uint8)
            return rescaled
        else:
            return predLarge
