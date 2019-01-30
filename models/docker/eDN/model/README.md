eDN-saliency
============
This repository contains reference code for computing Ensembles of Deep Networks (eDN) saliency maps based on the CVPR'2014 paper "Large-Scale Optimization of Hierarchical Features for Saliency Prediction in Natural Images".

Usage
-----

```
./eDNsaliency [--opts] <image> <output_saliency_map>

Options:
  -h, --help         show this help message and exit
  --descs DESCPATH   path to eDN model(s) (default: ./slmBestDescrCombi.pkl)
  --svm SVMPATH      path to SVM file (default: ./svm-slm-cntr)
  --white WHITEPATH  path to whitening parameters (default: ./whiten-slm-cntr)
  --fixMap FIXMAP    fixation map / empirical saliency map, if available
  --histeq           histogram equalization with given empirical saliency map
                     (default: False); requires empirical saliency map
  --auc              computes AUC for given fixation map; requires fixation map
  --no-blur          disable the default smoothing of the final map

```

Input format:
  + fixation map: black image with fixated pixels (one per fixation) set to 255 (see ./img_fixPts.jpg)
  + empirical saliency map: superposition of Gaussians centered at fixations (see ./img_fixMap.jpg)

These images should have the same size as the input image.

Examples
--------

```
./eDNsaliency img.jpg salMap.jpg 
    Computes raw (non-histogram-equalized) saliency map (in salMap.jpg) for given image 

./eDNsaliency --histeq --fixMap img_fixMap.jpg img.jpg salMap-histeq.jpg
    Computes histogram-equalized saliency map with given empirical saliency map (img_fixMap.jpg)

./eDNsaliency --auc --fixMap img_fixPts.jpg img.jpg salMap.jpg
    Computes Area Under the Curve (AUC) for fixation map (img_fixPts.jpg)
    
./eDNsaliency --svm ./svm-slm --white ./whiten-slm  img.jpg  salMap-noCntr.jpg
    Computes non-centered saliency maps
```


Requirements
------------

```
sthor
liblinear
```


Installation
------------

(Tested under Ubuntu 14.04)

1. Install dependencies 
  ```
  sudo apt-get install python-matplotlib python-setuptools curl python-dev libxml2-dev libxslt-dev
  ```
  
2. Install liblinear
  
  Download toolbox from http://www.csie.ntu.edu.tw/~cjlin/liblinear/
  
  ```
  # extract the zip
  make
  cd python
  make
  ```
  
3. Install sthor dependencies

  ```
  curl -O http://python-distribute.org/distribute_setup.py
  sudo python distribute_setup.py
  sudo easy_install pip
  sudo easy_install -U scikit-image
  sudo easy_install -U cython
  sudo easy_install -U numexpr
  sudo easy_install -U scipy
  ```
  
  For speedup, numpy and numexpr should be built against e.g. Intel MKL libraries.
  
4. Install sthor
  
  ```
  git clone https://github.com/nsf-ri-ubicv/sthor.git
  cd sthor/sthor/operation
  sudo make
  cd ../..
  python setup.py install
  ```
  add the sthor directory and the liblinear/python directory to your PYTHONPATH

5. Test sthor installation
  
  ```
  python
  import sthor  # should import without errors
  ```

Precomputed Saliency Maps
-------------------------

We provide precomputed saliency maps for three standard benchmarks:
  + MIT data set: MIT1003_eDN.zip 
  + Toronto data set: Toronto_eDN.zip 
  + NUSEF data set: NUSEF_eDN.zip 


Citing this Code
----------------

If you use this code in your own work, please cite the following paper:

Eleonora Vig, Michael Dorr, David Cox, "Large-Scale Optimization of Hierarchical Features for Saliency Prediction in Natural Images", IEEE Computer Vision and Pattern Recognition (CVPR), 2014. 

Link to the paper: http://coxlab.org/pdfs/cvpr2014_vig_saliency.pdf 

For questions and feedback please contact me at eleonora.vig@dlr.de
