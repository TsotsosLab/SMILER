/**
 * Copyright 2011 B. Schauerte. All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without 
 * modification, are permitted provided that the following conditions are 
 * met:
 * 
 *    1. Redistributions of source code must retain the above copyright 
 *       notice, this list of conditions and the following disclaimer.
 * 
 *    2. Redistributions in binary form must reproduce the above copyright 
 *       notice, this list of conditions and the following disclaimer in 
 *       the documentation and/or other materials provided with the 
 *       distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY B. SCHAUERTE ''AS IS'' AND ANY EXPRESS OR 
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
 * DISCLAIMED. IN NO EVENT SHALL B. SCHAUERTE OR CONTRIBUTORS BE LIABLE 
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR 
 * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *  
 * The views and conclusions contained in the software and documentation
 * are those of the authors and should not be interpreted as representing 
 * official policies, either expressed or implied, of B. Schauerte.
 */

/**
 * If you use any of this work in scientific research or as part of a larger
 * software system, you are kindly requested to cite the use in any related 
 * publications or technical documentation. The work is based upon:
 *
 * [1] B. Schauerte, and R. Stiefelhagen, "Predicting Human Gaze using 
 *     Quaternion DCT Image Signature Saliency and Face Detection," in IEEE 
 *     Workshop on the Applications of Computer Vision (WACV), 2012.
 * [2] B. Schauerte, and R. Stiefelhagen, "Quaternion-based Spectral 
 *     Saliency Detection for Eye Fixation Prediction," in European 
 *     Conference on Computer Vision (ECCV), 2012
 */

/** 
 * Calculate the quaterion DCT-II saliency for 48x64 matrices.
 *
 * \author B. Schauerte
 * \email  <schauerte@kit.edu>
 * \date   2011
 */
#include "dct_type2.hpp"

#include <cmath>

#ifdef __MEX
#define __CONST__ const
#include "mex.h"
#include "matrix.h"
#endif

#include "signum.hpp"           // the quaternion signum function
#include "hamilton_product.hpp" // the quaternion Hamilton product
#include "dct_48_64.hpp"        // the type-II DCT and inverse DCT (optimized for 48x64 matrices, i.e. 64x48 images)

template <typename T>
void
qdct_saliency_48_64(const T* axis, const T* indata, T* outdata, int num_image_channels)
{
  const int M=48;
  const int N=64;
  
  // temporary data
  T tmp_first_axis_transform[M*N*4];  // output of 1.1
  T tmp_dct[M*N*4];                   // output of 1.2
  T tmp_signum[M*N*4];                // output of 2
  T tmp_second_axis_transform[M*N*4]; // output of 3.1
  T tmp_idct[M*N*4];                  // output of 3.2
    
  ////
  // Processing
  // ==========
  // 1   QDCT
  // 1.1 multiply image with axis (after that we definitely have 4 channels)
  if (num_image_channels == 3)
  {
    HamiltonProductScalarMatrixImaginary_3c(axis,indata,tmp_first_axis_transform, M, N); // left-sided
  }
  else
  {
    HamiltonProductScalarMatrix_4c(axis,indata,tmp_first_axis_transform, M, N); // left-sided
  }
  // 1.2 dct for each of the 4 channels
  for (int c = 0; c < 4; c++)
  {
    dct2_type2_48_64(&tmp_first_axis_transform[c*M*N], &tmp_dct[c*M*N], false);
  }
  // 2.  SIGNUM
  Signum_4c(tmp_dct,tmp_signum,M,N);
  // 3   IQDCT
  // 3.1 multiply result with axis
  HamiltonProductScalarMatrix_4c(axis,tmp_signum,tmp_second_axis_transform, M, N); // left-sided
  // 3.2 idct
  for (int c = 0; c < 4; c++)
  {
    idct2_type2_48_64(&tmp_second_axis_transform[c*M*N], &tmp_idct[c*M*N], false); // left-sided
  }
  // 4.  ABS
  AbsSqr_4c(tmp_idct,outdata,M,N);
}

template <typename T>
inline void
qdct_saliency_48_64(const T* indata, T* outdata, int num_image_channels)
{
  T default_axis[4] = {0, T(-1)/sqrt(T(3)), T(-1)/sqrt(T(3)), T(-1)/sqrt(T(3))}; // unit pure quaterion (i.e. unit(quaternion(-1,-1,-1)))
  
  qdct_saliency_48_64(default_axis,indata,outdata,num_image_channels);
}
        
template void qdct_saliency_48_64<>(const float*, float*, int);
template void qdct_saliency_48_64<>(const double*, double*, int);

#ifdef __MEX
template <typename T>
void
_mexFunction(int nlhs, mxArray* plhs[],
             int nrhs, const mxArray* prhs[])
{
  const int M=48;
  const int N=64;
  
  __CONST__ mxArray *mindata = prhs[0];
  
  T default_axis[4] = {0, T(-1)/sqrt(T(3)), T(-1)/sqrt(T(3)), T(-1)/sqrt(T(3))}; // unit pure quaterion (i.e. unit(quaternion(-1,-1,-1)))
  if (nrhs > 1) // check for bad axis definitions
  {
    if (mxGetNumberOfElements(prhs[1])  != 4)
      mexErrMsgTxt("The axis needs to be defined as full quaternion, i.e. 4 elements (however, zero elements are allowed).");
    
    // @todo: check whether or not it's a unit quaternion
  }
  const T* axis = (nrhs > 1 ? (T*)mxGetData(prhs[1]) : default_axis);

  // create the output data
  mwSize outdims[3];
  const mwSize* indims=mxGetDimensions(mindata);
  for (mwSize i = 0; i < 3; i++)
    outdims[i]=indims[i];
  outdims[2]=1;
  
  if (indims[0] != M) 
    mexErrMsgTxt("mxGetM(in) != M=48");
  if (indims[1] != N) 
    mexErrMsgTxt("mxGetN(in) != N=64");

  if (mxIsComplex(mindata))
    mexErrMsgTxt("only real data allowed");

  // create the output data
  mxArray *moutdata = mxCreateNumericArray(mxGetNumberOfDimensions(mindata),
                                           outdims,
                                           mxGetClassID(mindata),
                                          (mxIsComplex(mindata) ? mxCOMPLEX: mxREAL));
  plhs[0] = moutdata; 

  // get the real data pointers
  __CONST__ T* indata=(T*)mxGetData(mindata);
  T* outdata=(T*)mxGetData(moutdata);
  
  mwSize nchannels = indims[2];
  qdct_saliency_48_64(axis,indata,outdata,nchannels);
}

void
mexFunction(int nlhs, mxArray* plhs[],
            int nrhs, const mxArray* prhs[])
{
  // check number of input parameters
  if (nrhs < 1 || nrhs > 2)
    mexErrMsgTxt("input arguments: image [axis]");

  // Check number of output parameters
  if (nlhs > 1) 
    mexErrMsgTxt("Wrong number of output arguments.");
  
  const mwSize* indims=mxGetDimensions(prhs[0]);
  if (mxGetNumberOfDimensions(prhs[0]) < 3 || indims[2] < 3 || indims[2] > 4)
    mexErrMsgTxt("The input image has to be MxNx3 or MxNx4");
  
  if (nrhs >= 2)
  {
    // @todo: check that the image and the axis have the same data type (float,double)
  }

  // only float and double are currently supported
  if (!mxIsDouble(prhs[0]) && !mxIsSingle(prhs[0])) 
  	mexErrMsgTxt("Only float and double input arguments are supported.");
  
  switch (mxGetClassID(prhs[0]))
  {
    case mxDOUBLE_CLASS:
      _mexFunction<double>(nlhs,plhs,nrhs,prhs);
      break;
    case mxSINGLE_CLASS:
      _mexFunction<float>(nlhs,plhs,nrhs,prhs);
      break;
    default:
      // this should never happen
      break;
  }
}
#endif
