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
#pragma once

#define QUATERNION_ABS_SQR(a,b,c,d) (SQR(a) + SQR(b) + SQR(c) + SQR(d))
#define QUATERNION_ABS(a,b,c,d) sqrt(SQR(a) + SQR(b) + SQR(c) + SQR(d))

#ifndef SQR
#define SQR(x) ((x)*(x))
#endif

/**
 * Imlementation notes:
 * --------------------
 * - all matrices are supposed to be given non-interleaved (i.e. each channel is a compact matrix for itself)
 * - default memory order is column-major (Matlab); however, this is irrelevant for all element-wise operations
 */

/** 
 * Calculate the squared absolute value for each element of a quaternion matrix. 
 * 4 input channels, 1 output channels
 */
template <typename T, typename S>
inline void 
AbsSqr_4c(const T* A, T* B, const S M, const S N) // 4 input channels, 1 output channels
{
    const S MN = M*N;
    const T* Aa = A + 0*MN;
    const T* Ab = A + 1*MN;
    const T* Ac = A + 2*MN;
    const T* Ad = A + 3*MN;
    for (S i = 0; i < MN; i++)
    {
      const T abs_sqr = QUATERNION_ABS_SQR(Aa[i],Ab[i],Ac[i],Ad[i]);
      if (abs_sqr > 0)
      {
        B[i] = abs_sqr;
      }
      else
      {
        B[i] = 0;
      }
    }
}

/** 
 * Calculate the squared absolute value for each element of a quaternion matrix. 
 * 3 input channels, 1 output channels
 */
template <typename T, typename S>
inline void 
AbsSqr_3c(const T* A, T* B, const S M, const S N) // 3 input channels, 1 output channels
{
    const S MN = M*N;
    const T* Aa = A + 0*MN;
    const T* Ab = A + 1*MN;
    const T* Ac = A + 2*MN;
    for (S i = 0; i < MN; i++)
    {
      const T abs_sqr = QUATERNION_ABS_SQR(Aa[i],Ab[i],Ac[i],0);
      if (abs_sqr > 0)
      {
        B[i] = abs_sqr;
      }
      else
      {
        B[i] = 0;
      }
    }
}

/** 
 * Calculate the absolute value for each element of a quaternion matrix. 
 * 4 input channels, 1 output channels
 */
template <typename T, typename S>
inline void 
Abs_4c(const T* A, T* B, const S M, const S N)
{
    const S MN = M*N;
    const T* Aa = A + 0*MN;
    const T* Ab = A + 1*MN;
    const T* Ac = A + 2*MN;
    const T* Ad = A + 3*MN;
    for (S i = 0; i < MN; i++)
    {
      const T abs = QUATERNION_ABS(Aa[i],Ab[i],Ac[i],Ad[i]);
      if (abs > 0)
      {
        B[i] = abs;
      }
      else
      {
        B[i] = 0;
      }
    }
}

/** 
 * Calculate the absolute value for each element of a quaternion matrix. 
 * 3 input channels, 1 output channels
 */
template <typename T, typename S>
inline void 
Abs_3c(const T* A, T* B, const S M, const S N)
{
    const S MN = M*N;
    const T* Aa = A + 0*MN;
    const T* Ab = A + 1*MN;
    const T* Ac = A + 2*MN;
    for (S i = 0; i < MN; i++)
    {
      const T abs = QUATERNION_ABS(Aa[i],Ab[i],Ac[i],0);
      if (abs > 0)
      {
        B[i] = abs;
      }
      else
      {
        B[i] = 0;
      }
    }
}

/** 
 * Calculate the signum function for each element of a quaternion matrix. 
 * 4 input channels, 4 output channels
 */
template <typename T, typename S>
inline void 
Signum_4c(const T* A, T* B, const S M, const S N)
{
    const S MN = M*N;
    const T* Aa = A + 0*MN;
    const T* Ab = A + 1*MN;
    const T* Ac = A + 2*MN;
    const T* Ad = A + 3*MN;
    T* Ba = B + 0*MN;
    T* Bb = B + 1*MN;
    T* Bc = B + 2*MN;
    T* Bd = B + 3*MN;
    for (S i = 0; i < MN; i++)
    {
      const T abs = QUATERNION_ABS(Aa[i],Ab[i],Ac[i],Ad[i]);
      if (abs > 0)
      {
        Ba[i] = Aa[i] / abs;
        Bb[i] = Ab[i] / abs;
        Bc[i] = Ac[i] / abs;
        Bd[i] = Ad[i] / abs;
      }
      else
      {
        Ba[i] = 0;
        Bb[i] = 0;
        Bc[i] = 0;
        Bd[i] = 0;
      }
    }
}

/** 
 * Calculate the signum function for each element of a quaternion matrix. 
 * 3 input channels, 3 output channels
 */
template <typename T, typename S>
inline void 
Signum_3c(const T* A, T* B, const S M, const S N)
{
    const S MN = M*N;
    const T* Aa = A + 0*MN;
    const T* Ab = A + 1*MN;
    const T* Ac = A + 2*MN;
    T* Ba = B + 0*MN;
    T* Bb = B + 1*MN;
    T* Bc = B + 2*MN;
    for (S i = 0; i < MN; i++)
    {
      const T abs = QUATERNION_ABS(Aa[i],Ab[i],Ac[i],0);
      if (abs > 0)
      {
        Ba[i] = Aa[i] / abs;
        Bb[i] = Ab[i] / abs;
        Bc[i] = Ac[i] / abs;
      }
      else
      {
        Ba[i] = 0;
        Bb[i] = 0;
        Bc[i] = 0;
      }
    }
}
