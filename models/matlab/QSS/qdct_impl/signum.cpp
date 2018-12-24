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
 * Calculate the Signum, Abs, and Squared-Abs for quaternion matrices/images.
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

#include "signum.hpp"

#ifdef __MEX
template <typename T>
void
_mexFunction(int nlhs, mxArray* plhs[],
             int nrhs, const mxArray* prhs[])
{
  __CONST__ mxArray *mindata = prhs[0];

  if (mxIsComplex(mindata))
    mexErrMsgTxt("only real data allowed");

  mxArray *moutdata = mxCreateNumericArray(mxGetNumberOfDimensions(mindata),
                                           mxGetDimensions(mindata),
                                           mxGetClassID(mindata),
                                          (mxIsComplex(mindata) ? mxCOMPLEX: mxREAL));
  plhs[0] = moutdata; 

  __CONST__ T* indata = (T*)mxGetData(mindata);
  T* outdata = (T*)mxGetData(moutdata);

  // run algorithm
  const mwSize *dims = mxGetDimensions(mindata);

  if (dims[2] == 3)
  {
    Signum_3c(indata,outdata,dims[0],dims[1]);
  }
  else if (dims[2] == 4)
  {
    Signum_4c(indata,outdata,dims[0],dims[1]);
  }
}

void
mexFunction(int nlhs, mxArray* plhs[],
            int nrhs, const mxArray* prhs[])
{
  // check number of input parameters
  if (nrhs != 1)
    mexErrMsgTxt("input arguments: A");

  // Check number of output parameters
  if (nlhs > 1) 
    mexErrMsgTxt("Wrong number of output arguments.");

  if (mxGetNumberOfDimensions(prhs[0]) < 3 || mxGetNumberOfDimensions(prhs[0]) > 4)
    mexErrMsgTxt("A and B have to be MxNx3 or MxNx4 matrices");

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
