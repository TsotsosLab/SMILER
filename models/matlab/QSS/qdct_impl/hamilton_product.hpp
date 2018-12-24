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
#pragma once

/**
 * Imlementation notes:
 * --------------------
 * - all matrices are supposed to be given non-interleaved (i.e. each channel is a compact matrix for itself)
 * - default memory order is column-major (Matlab); however, this is irrelevant for all element-wise operations
 */

/** 
 * Calculate the Hamilton product elements (A,B,C,D) of (a1 + b1 i + c1 j + d1 k)*(a2 + b2 i + c2 j + d2 k) 
 */
#define HAMILTON_PRODUCT_A(a1,b1,c1,d1,a2,b2,c2,d2) ((a1 * a2) - (b1 * b2) - (c1 * c2) - (d1 * d2))
#define HAMILTON_PRODUCT_B(a1,b1,c1,d1,a2,b2,c2,d2) ((a1 * b2) + (b1 * a2) + (c1 * d2) - (d1 * c2))
#define HAMILTON_PRODUCT_C(a1,b1,c1,d1,a2,b2,c2,d2) ((a1 * c2) - (b1 * d2) + (c1 * a2) + (d1 * b2))
#define HAMILTON_PRODUCT_D(a1,b1,c1,d1,a2,b2,c2,d2) ((a1 * d2) + (b1 * c2) - (c1 * b2) + (d1 * a2))

/** 
 * Calculate the Hamilton product (a,b,c,d) of (a1 + b1 i + c1 j + d1 k)*(a2 + b2 i + c2 j + d2 k) 
 */
template <typename T>
inline void
HamiltonProduct(const T a1, const T b1, const T c1, const T d1,
                const T a2, const T b2, const T c2, const T d2,
                T& a, T& b, T& c, T& d)
{
    a = HAMILTON_PRODUCT_A(a1,b1,c1,d1,a2,b2,c2,d2);
    b = HAMILTON_PRODUCT_B(a1,b1,c1,d1,a2,b2,c2,d2);
    c = HAMILTON_PRODUCT_C(a1,b1,c1,d1,a2,b2,c2,d2);
    d = HAMILTON_PRODUCT_D(a1,b1,c1,d1,a2,b2,c2,d2);
}

/** 
 * Calculate the Hamilton product elements for two (pure) imaginary quaternions (A,B,C,D) of (a1 + b1 i + c1 j + d1 k)*(a2 + b2 i + c2 j + d2 k), where a1 = a2 = 0 
 */
#define HAMILTON_PRODUCT_IMAGINARY_A(a1,b1,c1,d1,a2,b2,c2,d2) (-(b1 * b2) - (c1 * c2) - (d1 * d2))
#define HAMILTON_PRODUCT_IMAGINARY_B(a1,b1,c1,d1,a2,b2,c2,d2) (             (c1 * d2) - (d1 * c2))
#define HAMILTON_PRODUCT_IMAGINARY_C(a1,b1,c1,d1,a2,b2,c2,d2) (-(b1 * d2)             + (d1 * b2))
#define HAMILTON_PRODUCT_IMAGINARY_D(a1,b1,c1,d1,a2,b2,c2,d2) ( (b1 * c2) - (c1 * b2)            )

/** 
 * Calculate the Hamilton product for two (pure) imaginary quaternions (a,b,c,d) of (a1 + b1 i + c1 j + d1 k)*(a2 + b2 i + c2 j + d2 k), where a1 = a2 = 0 
 */
template <typename T>
inline void
HamiltonProductImaginary(const T b1, const T c1, const T d1,
                         const T b2, const T c2, const T d2,
                         T& a, T& b, T& c, T& d)
{
    a = HAMILTON_PRODUCT_IMAGINARY_A(0,b1,c1,d1,0,b2,c2,d2);
    b = HAMILTON_PRODUCT_IMAGINARY_B(0,b1,c1,d1,0,b2,c2,d2);
    c = HAMILTON_PRODUCT_IMAGINARY_C(0,b1,c1,d1,0,b2,c2,d2);
    d = HAMILTON_PRODUCT_IMAGINARY_D(0,b1,c1,d1,0,b2,c2,d2);
}

/** 
 * Calculate the Hamilton product C=A*B for two (full) quaternion matrices/images with 4 channels each. 
 * Output quaternion image C has/requires 4 channels.
 */
template <typename T, typename S>
inline void 
HamiltonProductMatrices_4c(const T* A, const T* B, T* C, const S M, const S N)
{
    const S MN = M*N;
    const T* Aa = A + 0*MN;
    const T* Ab = A + 1*MN;
    const T* Ac = A + 2*MN;
    const T* Ad = A + 3*MN;
    const T* Ba = B + 0*MN;
    const T* Bb = B + 1*MN;
    const T* Bc = B + 2*MN;
    const T* Bd = B + 3*MN;
    T* Ca       = C + 0*MN;
    T* Cb       = C + 1*MN;
    T* Cc       = C + 2*MN;
    T* Cd       = C + 3*MN;
    for (S i = 0; i < MN; i++)
    {
        /*HamiltonProduct(*Aa++,*Ab++,*Ac++,*Ad++,
                        *Ba++,*Bb++,*Bc++,*Bd++,
                        *Ca++,*Cb++,*Cc++,*Cd++);*/
        HamiltonProduct(Aa[i],Ab[i],Ac[i],Ad[i],
                        Ba[i],Bb[i],Bc[i],Bd[i],
                        Ca[i],Cb[i],Cc[i],Cd[i]);
    }
}

/** 
 * Calculate the Hamilton product C=A*x for a (full) 4 channel quaternion matrix A and a (scalar) quaternion x. 
 * Output quaternion image C has/requires 4 channels.
 */
template <typename T, typename S>
inline void 
HamiltonProductMatrixScalar_4c(const T* A, const T* x, T* C, const S M, const S N)
{
    // multiplication: scalar quaternion x and quaternion matrix A: C=A*x
    const S MN = M*N;
    const T* Aa = A + 0*MN;
    const T* Ab = A + 1*MN;
    const T* Ac = A + 2*MN;
    const T* Ad = A + 3*MN;
    T* Ca       = C + 0*MN;
    T* Cb       = C + 1*MN;
    T* Cc       = C + 2*MN;
    T* Cd       = C + 3*MN;
    for (S i = 0; i < MN; i++)
    {
        /*HamiltonProduct(*Aa++,*Ab++,*Ac++,*Ad++,
                        *Ba++,*Bb++,*Bc++,*Bd++,
                        *Ca++,*Cb++,*Cc++,*Cd++);*/
        HamiltonProduct(Aa[i],Ab[i],Ac[i],Ad[i],
                         x[0], x[1], x[2], x[3],
                        Ca[i],Cb[i],Cc[i],Cd[i]);
    }
}

/** 
 * Calculate the Hamilton product C=x*A for a (scalar) quaternion x and a (full) 4 channel quaternion matrix A. 
 * Output quaternion image C has/requires 4 channels.
 */
template <typename T, typename S>
inline void 
HamiltonProductScalarMatrix_4c(const T* x, const T* A, T* C, const S M, const S N)
{
    // multiplication: scalar quaternion x and quaternion matrix A: C=x*A
    const S MN = M*N;
    const T* Aa = A + 0*MN;
    const T* Ab = A + 1*MN;
    const T* Ac = A + 2*MN;
    const T* Ad = A + 3*MN;
    T* Ca       = C + 0*MN;
    T* Cb       = C + 1*MN;
    T* Cc       = C + 2*MN;
    T* Cd       = C + 3*MN;
    for (S i = 0; i < MN; i++)
    {
        /*HamiltonProduct(*Aa++,*Ab++,*Ac++,*Ad++,
                        *Ba++,*Bb++,*Bc++,*Bd++,
                        *Ca++,*Cb++,*Cc++,*Cd++);*/
        HamiltonProduct( x[0], x[1], x[2], x[3],
                        Aa[i],Ab[i],Ac[i],Ad[i],
                        Ca[i],Cb[i],Cc[i],Cd[i]);
    }
}

/** 
 * Calculate the Hamilton product C=x*A for a (scalar) quaternion x and a (pure imaginary) 3 channel quaternion matrix A. 
 * Output quaternion image C has/requires 4 channels.
 */
template <typename T, typename S>
inline void 
HamiltonProductScalarMatrixImaginary_3c(const T* x, const T* A, T* C, const S M, const S N)
{
    // multiplication: scalar quaternion x and quaternion matrix A: C=x*A (here, A and x are pure imaginary)
    const S MN  = M*N;
    const T* Aa = A + 0*MN;
    const T* Ab = A + 1*MN;
    const T* Ac = A + 2*MN;
    T* Ca       = C + 0*MN;
    T* Cb       = C + 1*MN;
    T* Cc       = C + 2*MN;
    T* Cd       = C + 3*MN;
    for (S i = 0; i < MN; i++)
    {
        /*HamiltonProductImaginary(*Aa++,*Ab++,*Ac++,
                                 *Ba++,*Bb++,*Bc++,
                                 *Ca++,*Cb++,*Cc++);*/
        HamiltonProductImaginary( x[0], x[1], x[2],
                                 Aa[i],Ab[i],Ac[i],
                                 Ca[i],Cb[i],Cc[i],Cd[i]);
    }
}

/** 
 * Calculate the Hamilton product C=A*x for a (pure imaginary) 3 channel quaternion matrix A and a (scalar) quaternion x. 
 * Output quaternion image C has/requires 4 channels.
 */
template <typename T, typename S>
inline void 
HamiltonProductMatrixScalarImaginary_3c(const T* A, const T* x, T* C, const S M, const S N)
{
    // multiplication: scalar quaternion x and quaternion matrix A: C=A*x (here, A and x are pure imaginary)
    const S MN  = M*N;
    const T* Aa = A + 0*MN;
    const T* Ab = A + 1*MN;
    const T* Ac = A + 2*MN;
    T* Ca       = C + 0*MN;
    T* Cb       = C + 1*MN;
    T* Cc       = C + 2*MN;
    T* Cd       = C + 3*MN;
    for (S i = 0; i < MN; i++)
    {
        /*HamiltonProductImaginary(*Aa++,*Ab++,*Ac++,
                                 *Ba++,*Bb++,*Bc++,
                                 *Ca++,*Cb++,*Cc++);*/
        HamiltonProductImaginary(Aa[i],Ab[i],Ac[i],
                                  x[0], x[1], x[2],
                                 Ca[i],Cb[i],Cc[i],Cd[i]);
    }
}

/** 
 * Calculate the Hamilton product C=A*B of two (pure imaginary) 3 channel quaternion matrices A and B. 
 * Output quaternion image C has/requires 4 channels.
 */
template <typename T, typename S>
inline void 
HamiltonProductMatricesImaginary_3c(const T* A, const T* B, T* C, const S M, const S N)
{
    const S MN  = M*N;
    const T* Aa = A + 0*MN;
    const T* Ab = A + 1*MN;
    const T* Ac = A + 2*MN;
    const T* Ba = B + 0*MN;
    const T* Bb = B + 1*MN;
    const T* Bc = B + 2*MN;
    T* Ca       = C + 0*MN;
    T* Cb       = C + 1*MN;
    T* Cc       = C + 2*MN;
    T* Cd       = C + 3*MN;
    for (S i = 0; i < MN; i++)
    {
        /*HamiltonProductImaginary(*Aa++,*Ab++,*Ac++,
                                 *Ba++,*Bb++,*Bc++,
                                 *Ca++,*Cb++,*Cc++);*/
        HamiltonProductImaginary(Aa[i],Ab[i],Ac[i],
                                 Ba[i],Bb[i],Bc[i],
                                 Ca[i],Cb[i],Cc[i],Cd[i]);
    }
}
