# Quaternion-Based Spectral Saliency (QSS)

Quaternion-Based Spectral Saliency (QSS) is based on work in the following paper:

```
B. Schauerte, and R. Stiefelhagen, "Quaternion-based Spectral Saliency Detection for Eye Fixation Prediction," in European Conference on Computer Vision (ECCV), 2012
```

## Original README

```
1. GENERAL

  Not much to say at the moment. If you are interested in the topic, then
  please visit my website (http://cvhci.anthropomatik.kit.edu/~bschauer/).

  If you use any of this work in scientific research or as part of a larger
  software system, you are kindly requested to cite the use in any related 
  publications or technical documentation. The work is based upon:

  [1] B. Schauerte, and R. Stiefelhagen, "Quaternion-based Spectral Saliency
      Detection for Eye Fixation Prediction," in European Conference on 
      Computer Vision (ECCV), 2012

  [2] B. Schauerte, and R. Stiefelhagen, "Predicting Human Gaze using 
      Quaternion DCT Image Signature Saliency and Face Detection," in IEEE
      Workshop on the Applications of Computer Vision (WACV), 2012.

2. INSTALLATION

2.1. QUATERNION METHODS AND THE QTFM

  If you want to use the Quaternion spectral saliency methods, then you need
  the "Quaternion Toolbox for Matlab" (QTFM). Most importantly, for the 
  .m-file implementation of the quaternion dct spectral saliency you need to
  patch the implementation by adding the .m-files in qtfm/@quaternion to the
  corresponding folder of the QTFM.

  A patched version of the QTFM that already contains the QDCT/iQDCT routines
  can be downloaded at:
    http://cvhci.anthropomatik.kit.edu/~bschauer/code/qdct-qtfm/

  You can also use the get_additional_files.m to download the library.

2.2. OPTIMIZED C/C++ IMPLEMENTATION (.MEX)

  The necessary .mex files for the optimized implementations can be generated
  by running build.m. However, this should also be done automatically when
  calling spectral_saliency_multichannel, if needed.

2.3  OPTIMIZED C/C++ IMPLEMENTATION (PRE-COMPILED .MEX BINARIES)

  If you have trouble compiling, you can download pre-compiled .mex files for
  some platforms at:    
    http://cvhci.anthropomatik.kit.edu/~bschauer/code/qdct-mex-binaries/

  You can also use the get_additional_files.m to download the binaries.

2.4  LOCALLY DEBIASED REGION CONTRAST SALIENCY

  You can download, compile, and install the C/C++ code for locally debiased
  region contrast saliency [3]. To this end, simply execute
  get_additional_files.m, which should download the latest code version from
  the github repository at:
    https://github.com/bschauerte/region_contrast_saliency

  [3] B. Schauerte, R. Stiefelhagen, "How the Distribution of Salient Objects 
      in Images Influences Salient Object Detection". In Proceedings of the 
      20th International Conference on Image Processing (ICIP), 2013.

3. AUTHORS AND CONTACT INFORMATION

  Boris Schauerte <boris.schauerte@kit.edu>

4. ACKNOWLEDGEMENTS

4.1 INSTITUTIONS

  Part of this work was/is supported by the German Research Foundation (DFG)
  within the Collaborative Research Program SFB 588 "Humanoid Robots" and the
  Quaero Programme, funded by OSEO, French State agency for innovation.

4.2 PEOPLE

  Thanks for reporting bugs go to ...

   Lahouari Ghouti
   Hadi Hadizadeh
```
