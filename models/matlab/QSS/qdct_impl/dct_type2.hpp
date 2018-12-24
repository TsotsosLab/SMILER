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
 * Optimized Type-II and Type-III DCT implementations for arrays with 48, and
 * 64 elements.
 * 
 * \author B. Schauerte
 * \email  <schauerte@kit.edu>
 * \date   2011
 */
#pragma once

#ifndef FNMS
#define FMA(a, b, c) (((a) * (b)) + (c))
#define FMS(a, b, c) (((a) * (b)) - (c))
#define FNMA(a, b, c) (- (((a) * (b)) + (c)))
#define FNMS(a, b, c) ((c) - ((a) * (b)))
#endif

/** 1-D DCT type-II for 64 element array */
template <typename R, typename stride, typename INT>
void 
dct_type2_64(const R * I, R * O, stride is, stride os, INT v, INT ivs, INT ovs);

/** 1-D DCT type-II for 48 element array */
template <typename R, typename stride, typename INT>
void 
dct_type2_48(const R * I, R * O, stride is, stride os, INT v, INT ivs, INT ovs);

/** 1-D DCT type-III for 64 element array (serves as inverse for the DCT type-II). */
template <typename R, typename stride, typename INT>
void 
dct_type3_64(const R * I, R * O, stride is, stride os, INT v, INT ivs, INT ovs);

/** 1-D DCT type-III for 48 element array (serves as inverse for the DCT type-II). */
template <typename R, typename stride, typename INT>
void 
dct_type3_48(const R * I, R * O, stride is, stride os, INT v, INT ivs, INT ovs);
