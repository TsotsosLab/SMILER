import numpy as np

def evaluate_sal_map(salMap, fixMap):
    """Computes AUC for given saliency map 'salMap' and given  
    fixation map 'fixMap'""" 
    fixMap = (fixMap>200).astype(int)
    salShape = salMap.shape
    fixShape = fixMap.shape

    predicted = salMap.reshape(salShape[0]*salShape[1], -1, 
                               order='F').flatten()
    actual = fixMap.reshape(fixShape[0]*fixShape[1], -1, 
                            order='F').flatten()
    labelset = np.arange(2) 

    auc = area_under_curve(predicted, actual, labelset) 
    return auc

def area_under_curve(predicted, actual, labelset):
    tp, fp = roc_curve(predicted, actual, np.max(labelset))
    auc = auc_from_roc(tp, fp)
    return auc

def auc_from_roc(tp, fp):
    h = np.diff(fp)
    auc = np.sum(h*(tp[1:]+tp[:-1]))/2.0
    return auc

def roc_curve(predicted, actual, cls):
    si = np.argsort(-predicted)
    tp = np.cumsum(np.single(actual[si]==cls))
    fp = np.cumsum(np.single(actual[si]!=cls))
    tp = tp/np.sum(actual==cls)
    fp = fp/np.sum(actual!=cls)
    tp = np.hstack((0.0, tp, 1.0))
    fp = np.hstack((0.0, fp, 1.0))
    return tp, fp
