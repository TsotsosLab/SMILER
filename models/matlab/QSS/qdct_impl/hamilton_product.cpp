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
 * Calculate the Hamilton Product for quaternion matrices/images and scalars.
 *
 * The Hamilton Product:
 * =====================
 *
 * x1 x2 =   (a1 +b1 i + c1 j + d1 k)(a2 + b2 i + c2 j + d2 k)
 *       =    a1 a2 − b1 b2 − c1 c2 − d1 d2
 *         + (a1 b2 + b1 a2 + c1 d2 − d1 c2 )i
 *         + (a1 c2 − b1 d2 + c1 a2 + d1 b2 )j
 *         + (a1 d2 + b1 c2 − c1 b2 + d1 a2 )k
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

#include "hamilton_product.hpp"

#ifdef __MEX
template <typename T>
void
_mexFunction(int nlhs, mxArray* plhs[],
             int nrhs, const mxArray* prhs[])
{
  __CONST__ mxArray *mindataA = prhs[0];
  __CONST__ mxArray *mindataB = prhs[1];

  if (mxIsComplex(mindataA))
    mexErrMsgTxt("only real data allowed");

  // create the output data
  mwSize outdims[3];
  const mwSize* indims=mxGetDimensions(mindataA);
  for (mwSize i = 0; i < 3; i++)
    outdims[i]=indims[i];
  outdims[2]=4; // we always need 4 output channels!
    
  mxArray *moutdata = mxCreateNumericArray(mxGetNumberOfDimensions(mindataA),
                                           outdims,
                                           mxGetClassID(mindataA),
                                          (mxIsComplex(mindataA) ? mxCOMPLEX: mxREAL));
  plhs[0] = moutdata; 

  __CONST__ T* indataA = (T*)mxGetData(mindataA);
  __CONST__ T* indataB = (T*)mxGetData(mindataB);
  T* outdata = (T*)mxGetData(moutdata);

  // run algorithm
  const mwSize *dims = mxGetDimensions(mindataA);

  if (dims[2] == 3)
  {
    HamiltonProductMatricesImaginary_3c(indataA,indataB,outdata,dims[0],dims[1]);
  }
  else if (dims[2] == 4)
  {
    HamiltonProductMatrices_4c(indataA,indataB,outdata,dims[0],dims[1]);
  }
}

void
mexFunction(int nlhs, mxArray* plhs[],
            int nrhs, const mxArray* prhs[])
{
  // check number of input parameters
  if (nrhs != 2)
    mexErrMsgTxt("input arguments: A B (A and B are MxNx3 or MxNx4 matrices)");

  // Check number of output parameters
  if (nlhs > 1) 
    mexErrMsgTxt("Wrong number of output arguments.");

  const mwSize* indims=mxGetDimensions(prhs[0]);
  if (mxGetNumberOfDimensions(prhs[0]) < 3 || indims[2] < 3 || indims[2] > 4 || mxGetM(prhs[0]) != mxGetM(prhs[1]) || mxGetN(prhs[0]) != mxGetN(prhs[1]))
    mexErrMsgTxt("A and B have to be MxNx3 or MxNx4 matrices");

  // only float and double are currently supported
  if (!mxIsDouble(prhs[0]) && !mxIsSingle(prhs[0])) 
  	mexErrMsgTxt("Only float and double input arguments are supported.");
  
  // @todo: check that A and B have the same data type
  
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
