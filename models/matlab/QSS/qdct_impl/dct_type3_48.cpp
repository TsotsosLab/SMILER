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
#include "dct_type2.hpp"

#include <cstddef>				 // for size_t

#ifndef DK
#define DK(name, value) const E name = K(value)
#endif

#ifndef WS
#define WS(stride, i)  (stride * i)
#endif

#ifndef MAKE_VOLATILE_STRIDE
#define MAKE_VOLATILE_STRIDE(x) x
#endif

template <typename R, typename stride, typename INT>
void
dct_type3_48(const R * I, R * O, stride is, stride os, INT v, INT ivs, INT ovs)
{
	typedef R E;
	typedef R K;
	DK(KP1_913880671, +1.913880671464417729871595773960539938965698411);
	DK(KP580569354, +0.580569354508924735272384751634790549382952557);
	DK(KP1_763842528, +1.763842528696710059425513727320776699016885241);
	DK(KP942793473, +0.942793473651995297112775251810508755314920638);
	DK(KP1_662939224, +1.662939224605090474157576755235811513477121624);
	DK(KP1_111140466, +1.111140466039204449485661627897065748749874382);
	DK(KP1_268786568, +1.268786568327290996430343226450986741351374190);
	DK(KP1_546020906, +1.546020906725473921621813219516939601942082586);
	DK(KP1_990369453, +1.990369453344393772489673906218959843150949737);
	DK(KP196034280, +0.196034280659121203988391127777283691722273346);
	DK(KP1_961570560, +1.961570560806460898252364472268478073947867462);
	DK(KP390180644, +0.390180644032256535696569736954044481855383236);
	DK(KP382683432, +0.382683432365089771728459984030398866761344562);
	DK(KP923879532, +0.923879532511286756128183189396788286822416626);
	DK(KP612372435, +0.612372435695794524549321018676472847991486870);
	DK(KP353553390, +0.353553390593273762200422181052424519642417969);
	DK(KP765366864, +0.765366864730179543456919968060797733522689125);
	DK(KP1_847759065, +1.847759065022573512256366378793576573644833252);
	DK(KP707106781, +0.707106781186547524400844362104849039284835938);
	DK(KP1_414213562, +1.414213562373095048801688724209698078569671875);
	DK(KP1_224744871, +1.224744871391589049098642037352945695982973740);
	DK(KP2_000000000, +2.000000000000000000000000000000000000000000000);
	DK(KP1_732050807, +1.732050807568877293527446341505872366942805254);
	DK(KP500000000, +0.500000000000000000000000000000000000000000000);
	DK(KP866025403, +0.866025403784438646763723170752936183471402627);
	INT i;
	for (i = v; i > 0; i = i - 1, I = I + ivs, O = O + ovs, MAKE_VOLATILE_STRIDE(is), MAKE_VOLATILE_STRIDE(os))
	{
		E T250;
		E T252;
		E T54;
		E T183;
		E T60;
		E T179;
		E T257;
		E T274;
		E T75;
		E T187;
		E T134;
		E T202;
		E T6;
		E T172;
		E T13;
		E T173;
		E T242;
		E T288;
		E T23;
		E T176;
		E T28;
		E T175;
		E T245;
		E T289;
		E T45;
		E T180;
		E T249;
		E T253;
		E T63;
		E T182;
		E T106;
		E T124;
		E T267;
		E T270;
		E T195;
		E T199;
		E T121;
		E T125;
		E T264;
		E T271;
		E T192;
		E T198;
		E T90;
		E T201;
		E T260;
		E T273;
		E T129;
		E T188;
		{
			E T52;
			E T56;
			E T48;
			E T57;
			E T51;
			E T59;
			E T53;
			E T58;
			T52 = I[WS(is, 42)];
			T56 = I[WS(is, 6)];
			{
				E T46;
				E T47;
				E T49;
				E T50;
				T46 = I[WS(is, 38)];
				T47 = I[WS(is, 26)];
				T48 = KP866025403 * (T46 - T47);
				T57 = T47 + T46;
				T49 = I[WS(is, 22)];
				T50 = I[WS(is, 10)];
				T51 = T49 - T50;
				T59 = KP866025403 * (T49 + T50);
			}
			T250 = T51 + T52;
			T252 = T56 - T57;
			T53 = FMS(KP500000000, T51, T52);
			T54 = T48 + T53;
			T183 = T53 - T48;
			T58 = FMA(KP500000000, T57, T56);
			T60 = T58 + T59;
			T179 = T58 - T59;
		}
		{
			E T67;
			E T132;
			E T70;
			E T130;
			E T74;
			E T131;
			E T71;
			E T133;
			T67 = I[WS(is, 3)];
			T132 = I[WS(is, 45)];
			{
				E T68;
				E T69;
				E T72;
				E T73;
				T68 = I[WS(is, 29)];
				T69 = I[WS(is, 35)];
				T70 = T68 + T69;
				T130 = KP866025403 * (T69 - T68);
				T72 = I[WS(is, 19)];
				T73 = I[WS(is, 13)];
				T74 = KP866025403 * (T72 + T73);
				T131 = T72 - T73;
			}
			T257 = T67 - T70;
			T274 = T131 + T132;
			T71 = FMA(KP500000000, T70, T67);
			T75 = T71 + T74;
			T187 = T71 - T74;
			T133 = FMS(KP500000000, T131, T132);
			T134 = T130 + T133;
			T202 = T133 - T130;
		}
		{
			E T7;
			E T5;
			E T3;
			E T240;
			E T10;
			E T12;
			E T4;
			E T11;
			E T241;
			T7 = I[WS(is, 24)];
			T4 = I[WS(is, 16)];
			T5 = KP1_732050807 * T4;
			{
				E T1;
				E T2;
				E T8;
				E T9;
				T1 = I[0];
				T2 = I[WS(is, 32)];
				T3 = T1 + T2;
				T240 = FNMS(KP2_000000000, T2, T1);
				T8 = I[WS(is, 8)];
				T9 = I[WS(is, 40)];
				T10 = T8 - T9;
				T12 = KP1_224744871 * (T8 + T9);
			}
			T6 = T3 + T5;
			T172 = T3 - T5;
			T11 = FMA(KP1_414213562, T7, KP707106781 * T10);
			T13 = T11 + T12;
			T173 = T12 - T11;
			T241 = KP1_414213562 * (T7 - T10);
			T242 = T240 + T241;
			T288 = T240 - T241;
		}
		{
			E T15;
			E T26;
			E T18;
			E T24;
			E T22;
			E T25;
			T15 = I[WS(is, 12)];
			T26 = I[WS(is, 36)];
			{
				E T16;
				E T17;
				E T20;
				E T21;
				T16 = I[WS(is, 20)];
				T17 = I[WS(is, 44)];
				T18 = T16 + T17;
				T24 = KP866025403 * (T17 - T16);
				T20 = I[WS(is, 28)];
				T21 = I[WS(is, 4)];
				T22 = KP866025403 * (T20 + T21);
				T25 = T20 - T21;
			}
			{
				E T19;
				E T27;
				E T243;
				E T244;
				T19 = FMA(KP500000000, T18, T15);
				T23 = T19 + T22;
				T176 = T19 - T22;
				T27 = FMS(KP500000000, T25, T26);
				T28 = T24 + T27;
				T175 = T27 - T24;
				T243 = T15 - T18;
				T244 = T25 + T26;
				T245 = FMA(KP1_847759065, T243, KP765366864 * T244);
				T289 = FNMS(KP1_847759065, T244, KP765366864 * T243);
			}
		}
		{
			E T31;
			E T34;
			E T35;
			E T36;
			E T41;
			E T42;
			E T40;
			E T43;
			E T37;
			E T44;
			{
				E T32;
				E T33;
				E T38;
				E T39;
				T31 = I[WS(is, 30)];
				T32 = I[WS(is, 2)];
				T33 = I[WS(is, 34)];
				T34 = T32 - T33;
				T35 = FMA(KP707106781, T31, KP353553390 * T34);
				T36 = KP612372435 * (T32 + T33);
				T41 = I[WS(is, 18)];
				T38 = I[WS(is, 14)];
				T39 = I[WS(is, 46)];
				T42 = T38 - T39;
				T40 = KP612372435 * (T38 + T39);
				T43 = FMA(KP707106781, T41, KP353553390 * T42);
			}
			T37 = T35 - T36;
			T44 = T40 - T43;
			T45 = T37 + T44;
			T180 = T44 - T37;
			{
				E T247;
				E T248;
				E T61;
				E T62;
				T247 = T31 - T34;
				T248 = T41 - T42;
				T249 = KP707106781 * (T247 - T248);
				T253 = KP707106781 * (T247 + T248);
				T61 = T35 + T36;
				T62 = T43 + T40;
				T63 = T61 + T62;
				T182 = T62 - T61;
			}
		}
		{
			E T101;
			E T102;
			E T94;
			E T103;
			E T98;
			E T97;
			E T99;
			E T104;
			E T100;
			E T105;
			{
				E T92;
				E T93;
				E T95;
				E T96;
				T101 = I[WS(is, 9)];
				T92 = I[WS(is, 23)];
				T93 = I[WS(is, 41)];
				T102 = T93 + T92;
				T94 = KP866025403 * (T92 - T93);
				T103 = FMA(KP500000000, T102, T101);
				T98 = I[WS(is, 39)];
				T95 = I[WS(is, 7)];
				T96 = I[WS(is, 25)];
				T97 = T95 - T96;
				T99 = FMA(KP500000000, T97, T98);
				T104 = KP866025403 * (T95 + T96);
			}
			T100 = T94 + T99;
			T105 = T103 + T104;
			T106 = FNMS(KP382683432, T105, KP923879532 * T100);
			T124 = FMA(KP923879532, T105, KP382683432 * T100);
			{
				E T265;
				E T266;
				E T193;
				E T194;
				T265 = T101 - T102;
				T266 = T98 - T97;
				T267 = FMA(KP923879532, T265, KP382683432 * T266);
				T270 = FNMS(KP923879532, T266, KP382683432 * T265);
				T193 = T103 - T104;
				T194 = T99 - T94;
				T195 = FMA(KP923879532, T193, KP382683432 * T194);
				T199 = FNMS(KP382683432, T193, KP923879532 * T194);
			}
		}
		{
			E T107;
			E T110;
			E T111;
			E T116;
			E T118;
			E T117;
			E T114;
			E T119;
			E T115;
			E T120;
			{
				E T108;
				E T109;
				E T112;
				E T113;
				T107 = I[WS(is, 15)];
				T108 = I[WS(is, 17)];
				T109 = I[WS(is, 47)];
				T110 = T108 + T109;
				T111 = FMA(KP500000000, T110, T107);
				T116 = KP866025403 * (T109 - T108);
				T118 = I[WS(is, 33)];
				T112 = I[WS(is, 31)];
				T113 = I[WS(is, 1)];
				T117 = T112 - T113;
				T114 = KP866025403 * (T112 + T113);
				T119 = FMS(KP500000000, T117, T118);
			}
			T115 = T111 + T114;
			T120 = T116 + T119;
			T121 = FMA(KP382683432, T115, KP923879532 * T120);
			T125 = FNMS(KP382683432, T120, KP923879532 * T115);
			{
				E T262;
				E T263;
				E T190;
				E T191;
				T262 = T107 - T110;
				T263 = T117 + T118;
				T264 = FMA(KP923879532, T262, KP382683432 * T263);
				T271 = FNMS(KP923879532, T263, KP382683432 * T262);
				T190 = T111 - T114;
				T191 = T119 - T116;
				T192 = FNMS(KP382683432, T191, KP923879532 * T190);
				T198 = FMA(KP382683432, T190, KP923879532 * T191);
			}
		}
		{
			E T76;
			E T79;
			E T80;
			E T81;
			E T83;
			E T86;
			E T87;
			E T88;
			E T82;
			E T89;
			{
				E T77;
				E T78;
				E T84;
				E T85;
				T76 = I[WS(is, 27)];
				T77 = I[WS(is, 5)];
				T78 = I[WS(is, 37)];
				T79 = T77 - T78;
				T80 = FMA(KP707106781, T76, KP353553390 * T79);
				T81 = KP612372435 * (T77 + T78);
				T83 = I[WS(is, 21)];
				T84 = I[WS(is, 11)];
				T85 = I[WS(is, 43)];
				T86 = T84 - T85;
				T87 = FMA(KP707106781, T83, KP353553390 * T86);
				T88 = KP612372435 * (T84 + T85);
			}
			T82 = T80 + T81;
			T89 = T87 + T88;
			T90 = T82 + T89;
			T201 = T89 - T82;
			{
				E T258;
				E T259;
				E T127;
				E T128;
				T258 = T76 - T79;
				T259 = T83 - T86;
				T260 = KP707106781 * (T258 + T259);
				T273 = KP707106781 * (T258 - T259);
				T127 = T80 - T81;
				T128 = T88 - T87;
				T129 = T127 + T128;
				T188 = T128 - T127;
			}
		}
		{
			E T246;
			E T280;
			E T255;
			E T281;
			E T269;
			E T283;
			E T276;
			E T284;
			E T251;
			E T254;
			T246 = T242 + T245;
			T280 = T242 - T245;
			T251 = T249 - T250;
			T254 = T252 + T253;
			T255 = FNMS(KP1_961570560, T254, KP390180644 * T251);
			T281 = FMA(KP390180644, T254, KP1_961570560 * T251);
			{
				E T261;
				E T268;
				E T272;
				E T275;
				T261 = T257 + T260;
				T268 = T264 + T267;
				T269 = T261 + T268;
				T283 = T261 - T268;
				T272 = T270 - T271;
				T275 = T273 - T274;
				T276 = T272 - T275;
				T284 = T272 + T275;
			}
			{
				E T256;
				E T277;
				E T286;
				E T287;
				T256 = T246 + T255;
				T277 = FNMS(KP1_990369453, T276, KP196034280 * T269);
				O[WS(os, 40)] = T256 - T277;
				O[WS(os, 7)] = T256 + T277;
				T286 = T280 + T281;
				T287 = FMA(KP1_546020906, T283, KP1_268786568 * T284);
				O[WS(os, 19)] = T286 - T287;
				O[WS(os, 28)] = T286 + T287;
			}
			{
				E T278;
				E T279;
				E T282;
				E T285;
				T278 = T246 - T255;
				T279 = FMA(KP1_990369453, T269, KP196034280 * T276);
				O[WS(os, 16)] = T278 - T279;
				O[WS(os, 31)] = T278 + T279;
				T282 = T280 - T281;
				T285 = FNMS(KP1_546020906, T284, KP1_268786568 * T283);
				O[WS(os, 43)] = T282 - T285;
				O[WS(os, 4)] = T282 + T285;
			}
		}
		{
			E T290;
			E T304;
			E T293;
			E T305;
			E T297;
			E T307;
			E T300;
			E T308;
			E T291;
			E T292;
			T290 = T288 - T289;
			T304 = T288 + T289;
			T291 = T252 - T253;
			T292 = T249 + T250;
			T293 = FMA(KP1_111140466, T291, KP1_662939224 * T292);
			T305 = FNMS(KP1_111140466, T292, KP1_662939224 * T291);
			{
				E T295;
				E T296;
				E T298;
				E T299;
				T295 = T257 - T260;
				T296 = T271 + T270;
				T297 = T295 - T296;
				T307 = T295 + T296;
				T298 = T264 - T267;
				T299 = T273 + T274;
				T300 = T298 - T299;
				T308 = T298 + T299;
			}
			{
				E T294;
				E T301;
				E T310;
				E T311;
				T294 = T290 - T293;
				T301 = FMA(KP942793473, T297, KP1_763842528 * T300);
				O[WS(os, 10)] = T294 - T301;
				O[WS(os, 37)] = T294 + T301;
				T310 = T304 - T305;
				T311 = FMA(KP580569354, T307, KP1_913880671 * T308);
				O[WS(os, 22)] = T310 - T311;
				O[WS(os, 25)] = T310 + T311;
			}
			{
				E T302;
				E T303;
				E T306;
				E T309;
				T302 = T290 + T293;
				T303 = FNMS(KP1_763842528, T297, KP942793473 * T300);
				O[WS(os, 34)] = T302 - T303;
				O[WS(os, 13)] = T302 + T303;
				T306 = T304 + T305;
				T309 = FNMS(KP580569354, T308, KP1_913880671 * T307);
				O[WS(os, 46)] = T306 - T309;
				O[WS(os, 1)] = T306 + T309;
			}
		}
		{
			E T30;
			E T140;
			E T136;
			E T144;
			E T65;
			E T141;
			E T123;
			E T143;
			{
				E T14;
				E T29;
				E T126;
				E T135;
				T14 = T6 - T13;
				T29 = FMA(KP765366864, T23, KP1_847759065 * T28);
				T30 = T14 + T29;
				T140 = T14 - T29;
				T126 = T124 - T125;
				T135 = T129 - T134;
				T136 = T126 - T135;
				T144 = T126 + T135;
			}
			{
				E T55;
				E T64;
				E T91;
				E T122;
				T55 = T45 - T54;
				T64 = T60 - T63;
				T65 = FNMS(KP1_662939224, T64, KP1_111140466 * T55);
				T141 = FMA(KP1_111140466, T64, KP1_662939224 * T55);
				T91 = T75 - T90;
				T122 = T106 - T121;
				T123 = T91 - T122;
				T143 = T91 + T122;
			}
			{
				E T66;
				E T137;
				E T146;
				E T147;
				T66 = T30 + T65;
				T137 = FNMS(KP1_913880671, T136, KP580569354 * T123);
				O[WS(os, 41)] = T66 - T137;
				O[WS(os, 6)] = T66 + T137;
				T146 = T140 + T141;
				T147 = FMA(KP1_763842528, T143, KP942793473 * T144);
				O[WS(os, 18)] = T146 - T147;
				O[WS(os, 29)] = T146 + T147;
			}
			{
				E T138;
				E T139;
				E T142;
				E T145;
				T138 = T30 - T65;
				T139 = FMA(KP1_913880671, T123, KP580569354 * T136);
				O[WS(os, 17)] = T138 - T139;
				O[WS(os, 30)] = T138 + T139;
				T142 = T140 - T141;
				T145 = FNMS(KP1_763842528, T144, KP942793473 * T143);
				O[WS(os, 42)] = T142 - T145;
				O[WS(os, 5)] = T142 + T145;
			}
		}
		{
			E T218;
			E T232;
			E T228;
			E T236;
			E T221;
			E T233;
			E T225;
			E T235;
			{
				E T216;
				E T217;
				E T226;
				E T227;
				T216 = T172 + T173;
				T217 = FMA(KP765366864, T176, KP1_847759065 * T175);
				T218 = T216 + T217;
				T232 = T216 - T217;
				T226 = T192 - T195;
				T227 = T201 + T202;
				T228 = T226 - T227;
				T236 = T226 + T227;
			}
			{
				E T219;
				E T220;
				E T223;
				E T224;
				T219 = T179 + T180;
				T220 = T182 + T183;
				T221 = FMA(KP1_662939224, T219, KP1_111140466 * T220);
				T233 = FNMS(KP1_662939224, T220, KP1_111140466 * T219);
				T223 = T187 + T188;
				T224 = T199 - T198;
				T225 = T223 - T224;
				T235 = T223 + T224;
			}
			{
				E T222;
				E T229;
				E T238;
				E T239;
				T222 = T218 - T221;
				T229 = FMA(KP580569354, T225, KP1_913880671 * T228);
				O[WS(os, 9)] = T222 - T229;
				O[WS(os, 38)] = T222 + T229;
				T238 = T232 - T233;
				T239 = FMA(KP942793473, T235, KP1_763842528 * T236);
				O[WS(os, 21)] = T238 - T239;
				O[WS(os, 26)] = T238 + T239;
			}
			{
				E T230;
				E T231;
				E T234;
				E T237;
				T230 = T218 + T221;
				T231 = FNMS(KP1_913880671, T225, KP580569354 * T228);
				O[WS(os, 33)] = T230 - T231;
				O[WS(os, 14)] = T230 + T231;
				T234 = T232 + T233;
				T237 = FNMS(KP942793473, T236, KP1_763842528 * T235);
				O[WS(os, 45)] = T234 - T237;
				O[WS(os, 2)] = T234 + T237;
			}
		}
		{
			E T178;
			E T208;
			E T204;
			E T212;
			E T185;
			E T209;
			E T197;
			E T211;
			{
				E T174;
				E T177;
				E T200;
				E T203;
				T174 = T172 - T173;
				T177 = FNMS(KP1_847759065, T176, KP765366864 * T175);
				T178 = T174 - T177;
				T208 = T174 + T177;
				T200 = T198 + T199;
				T203 = T201 - T202;
				T204 = T200 - T203;
				T212 = T200 + T203;
			}
			{
				E T181;
				E T184;
				E T189;
				E T196;
				T181 = T179 - T180;
				T184 = T182 - T183;
				T185 = FMA(KP1_961570560, T181, KP390180644 * T184);
				T209 = FNMS(KP1_961570560, T184, KP390180644 * T181);
				T189 = T187 - T188;
				T196 = T192 + T195;
				T197 = T189 + T196;
				T211 = T189 - T196;
			}
			{
				E T186;
				E T205;
				E T214;
				E T215;
				T186 = T178 - T185;
				T205 = FMA(KP196034280, T197, KP1_990369453 * T204);
				O[WS(os, 8)] = T186 - T205;
				O[WS(os, 39)] = T186 + T205;
				T214 = T208 - T209;
				T215 = FMA(KP1_268786568, T211, KP1_546020906 * T212);
				O[WS(os, 20)] = T214 - T215;
				O[WS(os, 27)] = T214 + T215;
			}
			{
				E T206;
				E T207;
				E T210;
				E T213;
				T206 = T178 + T185;
				T207 = FNMS(KP1_990369453, T197, KP196034280 * T204);
				O[WS(os, 32)] = T206 - T207;
				O[WS(os, 15)] = T206 + T207;
				T210 = T208 + T209;
				T213 = FNMS(KP1_268786568, T212, KP1_546020906 * T211);
				O[WS(os, 44)] = T210 - T213;
				O[WS(os, 3)] = T210 + T213;
			}
		}
		{
			E T150;
			E T164;
			E T160;
			E T168;
			E T153;
			E T165;
			E T157;
			E T167;
			{
				E T148;
				E T149;
				E T158;
				E T159;
				T148 = T6 + T13;
				T149 = FNMS(KP765366864, T28, KP1_847759065 * T23);
				T150 = T148 - T149;
				T164 = T148 + T149;
				T158 = T121 + T106;
				T159 = T129 + T134;
				T160 = T158 - T159;
				T168 = T158 + T159;
			}
			{
				E T151;
				E T152;
				E T155;
				E T156;
				T151 = T60 + T63;
				T152 = T45 + T54;
				T153 = FMA(KP390180644, T151, KP1_961570560 * T152);
				T165 = FNMS(KP390180644, T152, KP1_961570560 * T151);
				T155 = T75 + T90;
				T156 = T125 + T124;
				T157 = T155 - T156;
				T167 = T155 + T156;
			}
			{
				E T154;
				E T161;
				E T170;
				E T171;
				T154 = T150 - T153;
				T161 = FMA(KP1_268786568, T157, KP1_546020906 * T160);
				O[WS(os, 11)] = T154 - T161;
				O[WS(os, 36)] = T154 + T161;
				T170 = T164 - T165;
				T171 = FMA(KP196034280, T167, KP1_990369453 * T168);
				O[WS(os, 23)] = T170 - T171;
				O[WS(os, 24)] = T170 + T171;
			}
			{
				E T162;
				E T163;
				E T166;
				E T169;
				T162 = T150 + T153;
				T163 = FNMS(KP1_546020906, T157, KP1_268786568 * T160);
				O[WS(os, 35)] = T162 - T163;
				O[WS(os, 12)] = T162 + T163;
				T166 = T164 + T165;
				T169 = FNMS(KP196034280, T168, KP1_990369453 * T167);
				O[WS(os, 47)] = T166 - T169;
				O[0] = T166 + T169;
			}
		}
	}
}


template void dct_type3_48<>(const double*, double*, int, int, int, int, int);
template void dct_type3_48<>(const float*, float*, int, int, int, int, int);
template void dct_type3_48<>(const double*, double*, size_t, size_t, size_t, size_t, size_t);
template void dct_type3_48<>(const float*, float*, size_t, size_t, size_t, size_t, size_t);
