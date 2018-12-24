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

/** DCT-II optimized for 48x64 matrices. 
 *
 * \author B. Schauerte
 * \email  <schauerte@kit.edu>
 * \date   2011
 */

// @TODO:
// - The normalization is broken at the moment. Needs to be fixed!
// 

#include "dct_type2.hpp"

#include "dct_48_64.hpp"

#include <cmath>
#include <cassert>

#ifdef __MEX
#define __CONST__ const
#include "mex.h"
#include "matrix.h"
#endif

#define _DEFAULT_DO_INVERSE (false)
#define _DEFAULT_DO_NORMALIATION (true)
#define _DEFAULT_DO_ONE_DIMENSIONAL (false)

/** 
 * 1-D type-II DCT; processes each column separately.
 */
template <typename T>
void
dct1_type2_48_64(const T* indata, T* outdata, bool do_normalization)
{
    const int M = 48;
    const int N = 64;
    const T T_M1 = sqrt(1/T(M)) / T(2);
    const T T_M2 = sqrt(T(2)/T(M)) / T(2);
    
   // 1-D debug code (compare with matlab dct function)
    dct_type2_48(indata,outdata,1,1,(int)N,(int)M,(int)M);
    // normalization
    if (do_normalization)
    {
      for (int x = 0; x < N; x++)
      {
          outdata[x*M] *= T_M1;
          for (int y = 1; y < M; y++)
          {
            outdata[x*M + y] *= T_M2;
          }
      }
    }
}

/** 
 * 2-D type-II DCT. 
 */
template <typename T>
void
dct2_type2_48_64(const T* indata, T* outdata, bool do_normalization)
{
    const int M = 48;
    const int N = 64;
    const T T_N1 = sqrt(1/T(N)) / T(2);
    const T T_N2 = sqrt(T(2)/T(N)) / T(2);
    const T T_M1 = sqrt(1/T(M)) / T(2);
    const T T_M2 = sqrt(T(2)/T(M)) / T(2);
    T tmpdata[M*N];

    // real code    
    dct_type2_64(indata,tmpdata,(int)M,(int)M,(int)M,1,1);
    // 1st normalization (normalize each row)
    if (do_normalization)
    {
        for (int y = 0; y < M; y++)    
        {
            tmpdata[y] *= T_N1;
            for (int x = 1; x < N; x++)
            {
              tmpdata[x*M + y] *= T_N2;
            }
        }
    }  
    dct_type2_48(tmpdata,outdata,1,1,(int)N,(int)M,(int)M);
    // 2nd normalization (normalize each column)
    if (do_normalization)
    {
        for (int x = 0; x < N; x++)
        {
            outdata[x*M] *= T_M1;
            for (int y = 1; y < M; y++)
            {
              outdata[x*M + y] *= T_M2;
            }
        }  
    }
}

/** 
 * Inverse of the 1-D type-II DCT; processes each column separately. 
 */
template <typename T>
void
idct1_type2_48_64(const T* indata, T* outdata, bool do_normalization) // actually the inverse DCT of the type-II DCT uses a type-III DCT to calculate the result
{
    const int M = 48;
    const int N = 64;
    const T T_M(M);
    const T T_N(N);
    
    T tmpdata[M*N];
    
    // pre-normalization, i.e. multiply X_0 with sqrt(2)
    if (do_normalization)
    {
      for (int x = 0; x < N; x++)
      {
          tmpdata[x*M] = indata[x*M] * sqrt(T(2));
          for (int y = 1; y < M; y++)
          {
            tmpdata[x*M + y] = indata[x*M];
          }
        
          //tmpdata[x*M] = indata[x*M] * sqrt(1/T(M)) / T(2);
          //for (int y = 1; y < M; y++)
          //{
          //  tmpdata[x*M + y] = indata[x*M] * sqrt(T(2)/T(M)) / T(2);
          //}
      }
    }
    
    // calculate the dct-III
    if (do_normalization)
      dct_type3_48(tmpdata,outdata,1,1,(int)N,(int)M,(int)M);
    else
      dct_type3_48(indata,outdata,1,1,(int)N,(int)M,(int)M);
    
    // post-normalization, i.e. multiply by sqrt(2/M)
    if (do_normalization)
    {
      for (int x = 0; x < N; x++)
      {
        for (int y = 0; y < M; y++)
        {
          outdata[x*M + y] /= sqrt(T(M*2)); //*= sqrt(2 / M);
        }
      }
    }
}

/**
 * Inverse of the 2-D type-II DCT; processes each column separately. 
 */
template <typename T>
void
idct2_type2_48_64(const T* indata, T* outdata, bool do_normalization) // actually the inverse DCT of the type-II DCT uses a type-III DCT to calculate the result
{
    // pre-normalization:  multiply X_0 with sqrt(2) BEFORE the transform (this is important)
    // post-normalization: multiply all X_k with sqrt(2/M) and sqrt(2/N), respectively AFTER the transform; this is just scaling and not very important!
    bool do_pre_normalization = do_normalization;
    bool do_post_normalization = do_normalization;
  
    const int M = 48;
    const int N = 64;
    
    T tmpdata_a[M*N];
    T tmpdata_b[M*N];
    
    ////
    // 1st dimension
    ////
    
    // pre-normalization, i.e. multiply X_0 with sqrt(2)
    if (do_pre_normalization)
    {
      for (int x = 0; x < N; x++)
      {
          tmpdata_a[x*M] = indata[x*M] * sqrt(T(2));
          for (int y = 1; y < M; y++)
          {
            tmpdata_a[x*M + y] = indata[x*M];
          }
      }
    }
    
    // calculate the dct-III
    if (do_pre_normalization)
      dct_type3_48(tmpdata_a,tmpdata_b,1,1,(int)N,(int)M,(int)M);
    else
      dct_type3_48(indata,tmpdata_b,1,1,(int)N,(int)M,(int)M);
    
    // post-normalization, i.e. multiply by sqrt(2/M)
    if (do_post_normalization)
    {
      for (int x = 0; x < N; x++)
      {
        for (int y = 0; y < M; y++)
        {
          tmpdata_b[x*M + y] /= sqrt(T(M*2)); //*= sqrt(2 / M);
        }
      }
    }
    
    ////
    // 2nd dimension
    ////
    
    // pre-normalization, i.e. multiply X_0 with sqrt(2)
    if (do_pre_normalization)
    {
      for (int y = 0; y < M; y++)
      {
          tmpdata_b[y] *= sqrt(T(2));
      }
    }
    
    // calculate the dct-III
    dct_type3_64(tmpdata_b,outdata,(int)M,(int)M,(int)M,1,1);
    
    // post-normalization, i.e. multiply by sqrt(2/M)
    if (do_post_normalization)
    {
      for (int x = 0; x < N; x++)
      {
        for (int y = 0; y < M; y++)
        {
          outdata[x*M + y] /= sqrt(T(N*2)); //*= sqrt(2 / M);
        }
      }
    }
}

#ifndef __MEX
// 1-D DCT type-II
template void dct1_type2_48_64<>(const float*, float*, bool);
template void dct1_type2_48_64<>(const double*, double*, bool);
// 2-D DCT type-II
template void dct2_type2_48_64<>(const float*, float*, bool);
template void dct2_type2_48_64<>(const double*, double*, bool);
// 1-D invserse DCT of the type-II DCT
template void idct1_type2_48_64<>(const float*, float*, bool);
template void idct1_type2_48_64<>(const double*, double*, bool);
// 2-D invserse DCT of the type-II DCT
template void idct2_type2_48_64<>(const float*, float*, bool);
template void idct2_type2_48_64<>(const double*, double*, bool);
#endif

#ifdef __MEX
template <typename T>
void
_mexFunction(int nlhs, mxArray* plhs[],
             int nrhs, const mxArray* prhs[])
{
  ////
  // @note: this is an unsecure implementation/interface, but we want it fast!
  ////
  __CONST__ mxArray *mindata = prhs[0];
  if (mxGetM(mindata) != 48) 
    mexErrMsgTxt("mxGetM(in) != 48");
  if (mxGetN(mindata) != 64) 
    mexErrMsgTxt("mxGetN(in) != 48");

  if (mxIsComplex(mindata))
    mexErrMsgTxt("only real data allowed");

  // create the output data
  mxArray *moutdata = mxCreateNumericArray(mxGetNumberOfDimensions(mindata),
                                           mxGetDimensions(mindata),
                                           mxGetClassID(mindata),
                                          (mxIsComplex(mindata) ? mxCOMPLEX: mxREAL));
  plhs[0] = moutdata; 

  __CONST__ T* indata=(T*)mxGetData(mindata);
  T* outdata=(T*)mxGetData(moutdata);

  // run algorithm
  size_t M = mxGetM(mindata);
  size_t N = mxGetN(mindata);
  
  // are we supposed to calculate the inverse DCT?
  bool do_inverse = _DEFAULT_DO_INVERSE;
  if (nrhs >= 2)
    do_inverse = (mxGetScalar(prhs[1]) > 0 ? true : false);

  // shall we normalize the output?
  bool do_normalization = _DEFAULT_DO_NORMALIATION;
  if (nrhs >= 3)
    do_normalization = (mxGetScalar(prhs[2]) > 0 ? true : false);
  
  // should we do a one-dimensional DCT (each column separately)?
  bool do_one_dimensional = _DEFAULT_DO_ONE_DIMENSIONAL;
  if (nrhs >= 4)
    do_one_dimensional = (mxGetScalar(prhs[3]) > 0 ? true : false);

  if (!do_inverse)
  {
    mexPrintf("Calculating the DCT\n");
    if (!do_one_dimensional)
    {
      dct2_type2_48_64(indata, outdata, do_normalization);
    }
    else
    {
      dct1_type2_48_64(indata, outdata, do_normalization);
    }
  }
  else
  {
    mexPrintf("Calculating the IDCT\n");
    if (!do_one_dimensional)
    {
      idct2_type2_48_64(indata, outdata, do_normalization);
    }
    else
    {
      idct1_type2_48_64(indata, outdata, do_normalization);
    }
  }
}

void
mexFunction(int nlhs, mxArray* plhs[],
            int nrhs, const mxArray* prhs[])
{
  // check number of input parameters
  if (nrhs < 1 || nrhs > 4)
    mexErrMsgTxt("input arguments: image do_inverse[=false] do_normalization[=true] do_one_dimensional[=false] (with [=default value])");

  // Check number of output parameters
  if (nlhs > 1) 
    mexErrMsgTxt("Wrong number of output arguments.");

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
