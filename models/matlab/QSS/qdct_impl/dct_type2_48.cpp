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
dct_type2_48(const R * I, R * O, stride is, stride os, INT v, INT ivs, INT ovs)
{
	typedef R E;
	typedef R K;
	DK(KP1_546020906, +1.546020906725473921621813219516939601942082586);
	DK(KP1_268786568, +1.268786568327290996430343226450986741351374190);
	DK(KP1_763842528, +1.763842528696710059425513727320776699016885241);
	DK(KP942793473, +0.942793473651995297112775251810508755314920638);
	DK(KP1_990369453, +1.990369453344393772489673906218959843150949737);
	DK(KP196034280, +0.196034280659121203988391127777283691722273346);
	DK(KP580569354, +0.580569354508924735272384751634790549382952557);
	DK(KP1_913880671, +1.913880671464417729871595773960539938965698411);
	DK(KP923879532, +0.923879532511286756128183189396788286822416626);
	DK(KP382683432, +0.382683432365089771728459984030398866761344562);
	DK(KP1_732050807, +1.732050807568877293527446341505872366942805254);
	DK(KP1_224744871, +1.224744871391589049098642037352945695982973740);
	DK(KP1_961570560, +1.961570560806460898252364472268478073947867462);
	DK(KP390180644, +0.390180644032256535696569736954044481855383236);
	DK(KP1_111140466, +1.111140466039204449485661627897065748749874382);
	DK(KP1_662939224, +1.662939224605090474157576755235811513477121624);
	DK(KP2_000000000, +2.000000000000000000000000000000000000000000000);
	DK(KP1_414213562, +1.414213562373095048801688724209698078569671875);
	DK(KP1_847759065, +1.847759065022573512256366378793576573644833252);
	DK(KP765366864, +0.765366864730179543456919968060797733522689125);
	DK(KP707106781, +0.707106781186547524400844362104849039284835938);
	DK(KP612372435, +0.612372435695794524549321018676472847991486870);
	DK(KP500000000, +0.500000000000000000000000000000000000000000000);
	DK(KP866025403, +0.866025403784438646763723170752936183471402627);
	INT i;
	for (i = v; i > 0; i = i - 1, I = I + ivs, O = O + ovs, MAKE_VOLATILE_STRIDE(is), MAKE_VOLATILE_STRIDE(os))
	{
		E T170;
		E T208;
		E T46;
		E T279;
		E T211;
		E T260;
		E T124;
		E T142;
		E T69;
		E T141;
		E T169;
		E T259;
		E T280;
		E T281;
		E T61;
		E T262;
		E T181;
		E T214;
		E T83;
		E T145;
		E T76;
		E T144;
		E T176;
		E T213;
		E T270;
		E T271;
		E T272;
		E T15;
		E T269;
		E T193;
		E T235;
		E T188;
		E T234;
		E T99;
		E T149;
		E T92;
		E T148;
		E T265;
		E T266;
		E T267;
		E T30;
		E T264;
		E T204;
		E T238;
		E T199;
		E T237;
		E T114;
		E T152;
		E T107;
		E T151;
		{
			E T63;
			E T118;
			E T121;
			E T66;
			E T34;
			E T64;
			E T41;
			E T119;
			E T44;
			E T122;
			E T37;
			E T67;
			E T38;
			E T45;
			T63 = I[WS(is, 1)];
			T118 = I[WS(is, 25)];
			T121 = I[WS(is, 22)];
			T66 = I[WS(is, 46)];
			{
				E T32;
				E T33;
				E T39;
				E T40;
				T32 = I[WS(is, 33)];
				T33 = I[WS(is, 30)];
				T34 = T32 - T33;
				T64 = T32 + T33;
				T39 = I[WS(is, 38)];
				T40 = I[WS(is, 6)];
				T41 = T39 - T40;
				T119 = T39 + T40;
			}
			{
				E T42;
				E T43;
				E T35;
				E T36;
				T42 = I[WS(is, 9)];
				T43 = I[WS(is, 41)];
				T44 = T42 - T43;
				T122 = T42 + T43;
				T35 = I[WS(is, 14)];
				T36 = I[WS(is, 17)];
				T37 = T35 - T36;
				T67 = T35 + T36;
			}
			T170 = KP866025403 * (T41 - T44);
			T208 = KP866025403 * (T37 - T34);
			T38 = T34 + T37;
			T45 = T41 + T44;
			T46 = T38 + T45;
			T279 = KP866025403 * (T38 - T45);
			{
				E T209;
				E T210;
				E T120;
				E T123;
				T209 = FNMS(KP500000000, T119, T118);
				T210 = FNMS(KP500000000, T122, T121);
				T211 = T209 - T210;
				T260 = T209 + T210;
				T120 = T118 + T119;
				T123 = T121 + T122;
				T124 = T120 - T123;
				T142 = T120 + T123;
			}
			{
				E T65;
				E T68;
				E T167;
				E T168;
				T65 = T63 + T64;
				T68 = T66 + T67;
				T69 = T65 - T68;
				T141 = T65 + T68;
				T167 = FNMS(KP500000000, T64, T63);
				T168 = FNMS(KP500000000, T67, T66);
				T169 = T167 - T168;
				T259 = T167 + T168;
			}
		}
		{
			E T70;
			E T71;
			E T49;
			E T172;
			E T80;
			E T81;
			E T59;
			E T179;
			E T73;
			E T74;
			E T52;
			E T173;
			E T77;
			E T78;
			E T56;
			E T178;
			E T53;
			E T60;
			{
				E T47;
				E T48;
				E T57;
				E T58;
				T70 = I[WS(is, 13)];
				T47 = I[WS(is, 45)];
				T48 = I[WS(is, 18)];
				T71 = T47 + T48;
				T49 = T47 - T48;
				T172 = FNMS(KP500000000, T71, T70);
				T80 = I[WS(is, 37)];
				T57 = I[WS(is, 26)];
				T58 = I[WS(is, 5)];
				T81 = T57 + T58;
				T59 = T57 - T58;
				T179 = FNMS(KP500000000, T81, T80);
			}
			{
				E T50;
				E T51;
				E T54;
				E T55;
				T73 = I[WS(is, 34)];
				T50 = I[WS(is, 2)];
				T51 = I[WS(is, 29)];
				T74 = T50 + T51;
				T52 = T50 - T51;
				T173 = FNMS(KP500000000, T74, T73);
				T77 = I[WS(is, 10)];
				T54 = I[WS(is, 21)];
				T55 = I[WS(is, 42)];
				T78 = T54 + T55;
				T56 = T54 - T55;
				T178 = FNMS(KP500000000, T78, T77);
			}
			T280 = T172 + T173;
			T281 = T178 + T179;
			T53 = T49 + T52;
			T60 = T56 + T59;
			T61 = T53 + T60;
			T262 = KP866025403 * (T53 - T60);
			{
				E T177;
				E T180;
				E T79;
				E T82;
				T177 = KP612372435 * (T56 - T59);
				T180 = KP707106781 * (T178 - T179);
				T181 = T177 + T180;
				T214 = T177 - T180;
				T79 = T77 + T78;
				T82 = T80 + T81;
				T83 = T79 - T82;
				T145 = T79 + T82;
			}
			{
				E T72;
				E T75;
				E T174;
				E T175;
				T72 = T70 + T71;
				T75 = T73 + T74;
				T76 = T72 - T75;
				T144 = T72 + T75;
				T174 = KP707106781 * (T172 - T173);
				T175 = KP612372435 * (T49 - T52);
				T176 = T174 - T175;
				T213 = T175 + T174;
			}
		}
		{
			E T89;
			E T90;
			E T3;
			E T185;
			E T96;
			E T97;
			E T13;
			E T191;
			E T86;
			E T87;
			E T6;
			E T184;
			E T93;
			E T94;
			E T10;
			E T190;
			E T186;
			E T187;
			{
				E T1;
				E T2;
				E T11;
				E T12;
				T89 = I[WS(is, 40)];
				T1 = I[WS(is, 23)];
				T2 = I[WS(is, 8)];
				T90 = T2 + T1;
				T3 = T1 - T2;
				T185 = FNMS(KP500000000, T90, T89);
				T96 = I[WS(is, 16)];
				T11 = I[WS(is, 15)];
				T12 = I[WS(is, 47)];
				T97 = T11 + T12;
				T13 = T11 - T12;
				T191 = FNMS(KP500000000, T97, T96);
			}
			{
				E T4;
				E T5;
				E T8;
				E T9;
				T86 = I[WS(is, 7)];
				T4 = I[WS(is, 39)];
				T5 = I[WS(is, 24)];
				T87 = T4 + T5;
				T6 = T4 - T5;
				T184 = FNMS(KP500000000, T87, T86);
				T93 = I[WS(is, 31)];
				T8 = I[WS(is, 32)];
				T9 = I[0];
				T94 = T8 + T9;
				T10 = T8 - T9;
				T190 = FNMS(KP500000000, T94, T93);
			}
			T270 = T184 + T185;
			T271 = T190 + T191;
			T272 = KP707106781 * (T270 - T271);
			{
				E T7;
				E T14;
				E T189;
				E T192;
				T7 = T3 - T6;
				T14 = T10 + T13;
				T15 = T7 - T14;
				T269 = KP612372435 * (T7 + T14);
				T189 = KP866025403 * (T6 + T3);
				T192 = T190 - T191;
				T193 = T189 + T192;
				T235 = T192 - T189;
			}
			T186 = T184 - T185;
			T187 = KP866025403 * (T10 - T13);
			T188 = T186 - T187;
			T234 = T186 + T187;
			{
				E T95;
				E T98;
				E T88;
				E T91;
				T95 = T93 + T94;
				T98 = T96 + T97;
				T99 = T95 - T98;
				T149 = T95 + T98;
				T88 = T86 + T87;
				T91 = T89 + T90;
				T92 = T88 - T91;
				T148 = T88 + T91;
			}
		}
		{
			E T101;
			E T102;
			E T18;
			E T195;
			E T111;
			E T112;
			E T28;
			E T202;
			E T104;
			E T105;
			E T21;
			E T196;
			E T108;
			E T109;
			E T25;
			E T201;
			E T197;
			E T198;
			{
				E T16;
				E T17;
				E T26;
				E T27;
				T101 = I[WS(is, 4)];
				T16 = I[WS(is, 27)];
				T17 = I[WS(is, 36)];
				T102 = T16 + T17;
				T18 = T16 - T17;
				T195 = FNMS(KP500000000, T102, T101);
				T111 = I[WS(is, 28)];
				T26 = I[WS(is, 3)];
				T27 = I[WS(is, 35)];
				T112 = T26 + T27;
				T28 = T26 - T27;
				T202 = FMS(KP500000000, T112, T111);
			}
			{
				E T19;
				E T20;
				E T23;
				E T24;
				T104 = I[WS(is, 43)];
				T19 = I[WS(is, 20)];
				T20 = I[WS(is, 11)];
				T105 = T19 + T20;
				T21 = T19 - T20;
				T196 = FNMS(KP500000000, T105, T104);
				T108 = I[WS(is, 19)];
				T23 = I[WS(is, 44)];
				T24 = I[WS(is, 12)];
				T109 = T23 + T24;
				T25 = T23 - T24;
				T201 = FNMS(KP500000000, T109, T108);
			}
			T265 = T195 + T196;
			T266 = T202 - T201;
			T267 = KP707106781 * (T265 + T266);
			{
				E T22;
				E T29;
				E T200;
				E T203;
				T22 = T18 + T21;
				T29 = T25 + T28;
				T30 = T22 + T29;
				T264 = KP612372435 * (T29 - T22);
				T200 = KP866025403 * (T18 - T21);
				T203 = T201 + T202;
				T204 = T200 + T203;
				T238 = T203 - T200;
			}
			T197 = T195 - T196;
			T198 = KP866025403 * (T28 - T25);
			T199 = T197 + T198;
			T237 = T198 - T197;
			{
				E T110;
				E T113;
				E T103;
				E T106;
				T110 = T108 + T109;
				T113 = T111 + T112;
				T114 = T110 - T113;
				T152 = T110 + T113;
				T103 = T101 + T102;
				T106 = T104 + T105;
				T107 = T103 - T106;
				T151 = T103 + T106;
			}
		}
		{
			E T147;
			E T155;
			E T154;
			E T156;
			{
				E T143;
				E T146;
				E T150;
				E T153;
				T143 = T141 + T142;
				T146 = T144 + T145;
				T147 = T143 - T146;
				T155 = T143 + T146;
				T150 = T148 + T149;
				T153 = T151 + T152;
				T154 = T150 - T153;
				T156 = T150 + T153;
			}
			O[WS(os, 12)] = FMA(KP765366864, T147, KP1_847759065 * T154);
			O[WS(os, 24)] = KP1_414213562 * (T156 - T155);
			O[WS(os, 36)] = FNMS(KP1_847759065, T147, KP765366864 * T154);
			O[0] = KP2_000000000 * (T155 + T156);
		}
		{
			E T157;
			E T162;
			E T160;
			E T163;
			E T158;
			E T159;
			T157 = T141 - T142;
			T162 = T144 - T145;
			T158 = T152 - T151;
			T159 = T148 - T149;
			T160 = KP707106781 * (T158 - T159);
			T163 = KP707106781 * (T159 + T158);
			{
				E T161;
				E T164;
				E T165;
				E T166;
				T161 = T157 + T160;
				T164 = T162 - T163;
				O[WS(os, 6)] = FMA(KP1_662939224, T161, KP1_111140466 * T164);
				O[WS(os, 42)] = FNMS(KP1_111140466, T161, KP1_662939224 * T164);
				T165 = T160 - T157;
				T166 = T162 + T163;
				O[WS(os, 18)] = FNMS(KP1_961570560, T166, KP390180644 * T165);
				O[WS(os, 30)] = FMA(KP1_961570560, T165, KP390180644 * T166);
			}
		}
		{
			E T298;
			E T300;
			E T31;
			E T62;
			E T307;
			E T297;
			E T308;
			E T303;
			E T309;
			E T310;
			T298 = KP866025403 * (T15 + T30);
			T300 = KP866025403 * (T61 - T46);
			T31 = T15 - T30;
			T62 = T46 + T61;
			T307 = KP1_224744871 * (T62 + T31);
			{
				E T295;
				E T296;
				E T301;
				E T302;
				T295 = T259 + T260;
				T296 = T280 + T281;
				T297 = T295 - T296;
				T308 = T295 + T296;
				T301 = T270 + T271;
				T302 = T266 - T265;
				T303 = T301 + T302;
				T309 = T302 - T301;
			}
			O[WS(os, 16)] = KP1_732050807 * (T31 - T62);
			O[WS(os, 32)] = KP2_000000000 * (T309 - T308);
			T310 = KP1_414213562 * (T308 + T309);
			O[WS(os, 40)] = T307 - T310;
			O[WS(os, 8)] = T307 + T310;
			{
				E T299;
				E T304;
				E T305;
				E T306;
				T299 = T297 + T298;
				T304 = T300 - T303;
				O[WS(os, 4)] = FMA(KP1_847759065, T299, KP765366864 * T304);
				O[WS(os, 44)] = FNMS(KP765366864, T299, KP1_847759065 * T304);
				T305 = T298 - T297;
				T306 = T300 + T303;
				O[WS(os, 20)] = FNMS(KP1_847759065, T306, KP765366864 * T305);
				O[WS(os, 28)] = FMA(KP1_847759065, T305, KP765366864 * T306);
			}
		}
		{
			E T85;
			E T136;
			E T126;
			E T134;
			E T116;
			E T133;
			E T129;
			E T137;
			E T84;
			E T125;
			T84 = KP707106781 * (T76 + T83);
			T85 = T69 - T84;
			T136 = T69 + T84;
			T125 = KP707106781 * (T76 - T83);
			T126 = T124 - T125;
			T134 = T124 + T125;
			{
				E T100;
				E T115;
				E T127;
				E T128;
				T100 = FMA(KP382683432, T92, KP923879532 * T99);
				T115 = FNMS(KP923879532, T114, KP382683432 * T107);
				T116 = T100 + T115;
				T133 = T100 - T115;
				T127 = FNMS(KP382683432, T99, KP923879532 * T92);
				T128 = FMA(KP923879532, T107, KP382683432 * T114);
				T129 = T127 - T128;
				T137 = T127 + T128;
			}
			{
				E T117;
				E T130;
				E T139;
				E T140;
				T117 = T85 + T116;
				T130 = T126 - T129;
				O[WS(os, 3)] = FMA(KP1_913880671, T117, KP580569354 * T130);
				O[WS(os, 45)] = FNMS(KP580569354, T117, KP1_913880671 * T130);
				T139 = T134 + T133;
				T140 = T136 + T137;
				O[WS(os, 33)] = FNMS(KP1_990369453, T140, KP196034280 * T139);
				O[WS(os, 15)] = FMA(KP1_990369453, T139, KP196034280 * T140);
			}
			{
				E T131;
				E T132;
				E T135;
				E T138;
				T131 = T116 - T85;
				T132 = T126 + T129;
				O[WS(os, 21)] = FNMS(KP1_763842528, T132, KP942793473 * T131);
				O[WS(os, 27)] = FMA(KP1_763842528, T131, KP942793473 * T132);
				T135 = T133 - T134;
				T138 = T136 - T137;
				O[WS(os, 39)] = FNMS(KP1_546020906, T138, KP1_268786568 * T135);
				O[WS(os, 9)] = FMA(KP1_546020906, T135, KP1_268786568 * T138);
			}
		}
		{
			E T263;
			E T290;
			E T283;
			E T287;
			E T274;
			E T288;
			E T278;
			E T291;
			E T261;
			E T282;
			T261 = T259 - T260;
			T263 = T261 - T262;
			T290 = T261 + T262;
			T282 = T280 - T281;
			T283 = T279 + T282;
			T287 = T279 - T282;
			{
				E T268;
				E T273;
				E T276;
				E T277;
				T268 = T264 - T267;
				T273 = T269 + T272;
				T274 = T268 - T273;
				T288 = T273 + T268;
				T276 = T272 - T269;
				T277 = T264 + T267;
				T278 = T276 - T277;
				T291 = T276 + T277;
			}
			{
				E T275;
				E T284;
				E T293;
				E T294;
				T275 = T263 + T274;
				T284 = T278 - T283;
				O[WS(os, 10)] = FMA(KP1_111140466, T275, KP1_662939224 * T284);
				O[WS(os, 38)] = FNMS(KP1_662939224, T275, KP1_111140466 * T284);
				T293 = T291 - T290;
				T294 = T287 + T288;
				O[WS(os, 22)] = FNMS(KP1_662939224, T294, KP1_111140466 * T293);
				O[WS(os, 26)] = FMA(KP1_111140466, T294, KP1_662939224 * T293);
			}
			{
				E T285;
				E T286;
				E T289;
				E T292;
				T285 = T263 - T274;
				T286 = T283 + T278;
				O[WS(os, 14)] = FMA(KP390180644, T285, KP1_961570560 * T286);
				O[WS(os, 34)] = FNMS(KP1_961570560, T285, KP390180644 * T286);
				T289 = T287 - T288;
				T292 = T290 + T291;
				O[WS(os, 46)] = FNMS(KP390180644, T292, KP1_961570560 * T289);
				O[WS(os, 2)] = FMA(KP390180644, T289, KP1_961570560 * T292);
			}
		}
		{
			E T233;
			E T254;
			E T247;
			E T255;
			E T240;
			E T252;
			E T244;
			E T251;
			{
				E T231;
				E T232;
				E T245;
				E T246;
				T231 = T176 - T181;
				T232 = T208 + T211;
				T233 = T231 - T232;
				T254 = T232 + T231;
				T245 = FMA(KP382683432, T237, KP923879532 * T238);
				T246 = FMA(KP382683432, T234, KP923879532 * T235);
				T247 = T245 - T246;
				T255 = T246 + T245;
			}
			{
				E T236;
				E T239;
				E T242;
				E T243;
				T236 = FNMS(KP382683432, T235, KP923879532 * T234);
				T239 = FNMS(KP382683432, T238, KP923879532 * T237);
				T240 = T236 + T239;
				T252 = T239 - T236;
				T242 = T169 + T170;
				T243 = T214 - T213;
				T244 = T242 + T243;
				T251 = T242 - T243;
			}
			{
				E T241;
				E T248;
				E T257;
				E T258;
				T241 = T233 - T240;
				T248 = T244 + T247;
				O[WS(os, 43)] = FNMS(KP942793473, T248, KP1_763842528 * T241);
				O[WS(os, 5)] = FMA(KP942793473, T241, KP1_763842528 * T248);
				T257 = T252 - T251;
				T258 = T254 + T255;
				O[WS(os, 17)] = FNMS(KP1_990369453, T258, KP196034280 * T257);
				O[WS(os, 31)] = FMA(KP1_990369453, T257, KP196034280 * T258);
			}
			{
				E T249;
				E T250;
				E T253;
				E T256;
				T249 = T247 - T244;
				T250 = T233 + T240;
				O[WS(os, 19)] = FNMS(KP1_913880671, T250, KP580569354 * T249);
				O[WS(os, 29)] = FMA(KP580569354, T250, KP1_913880671 * T249);
				T253 = T251 + T252;
				T256 = T254 - T255;
				O[WS(os, 7)] = FMA(KP1_546020906, T253, KP1_268786568 * T256);
				O[WS(os, 41)] = FNMS(KP1_268786568, T253, KP1_546020906 * T256);
			}
		}
		{
			E T183;
			E T226;
			E T219;
			E T227;
			E T206;
			E T224;
			E T216;
			E T223;
			{
				E T171;
				E T182;
				E T217;
				E T218;
				T171 = T169 - T170;
				T182 = T176 + T181;
				T183 = T171 + T182;
				T226 = T171 - T182;
				T217 = FMA(KP382683432, T188, KP923879532 * T193);
				T218 = FNMS(KP382683432, T199, KP923879532 * T204);
				T219 = T217 + T218;
				T227 = T218 - T217;
			}
			{
				E T194;
				E T205;
				E T212;
				E T215;
				T194 = FNMS(KP382683432, T193, KP923879532 * T188);
				T205 = FMA(KP923879532, T199, KP382683432 * T204);
				T206 = T194 + T205;
				T224 = T194 - T205;
				T212 = T208 - T211;
				T215 = T213 + T214;
				T216 = T212 - T215;
				T223 = T212 + T215;
			}
			{
				E T207;
				E T220;
				E T229;
				E T230;
				T207 = T183 + T206;
				T220 = T216 - T219;
				O[WS(os, 1)] = FMA(KP1_990369453, T207, KP196034280 * T220);
				O[WS(os, 47)] = FNMS(KP196034280, T207, KP1_990369453 * T220);
				T229 = T224 - T223;
				T230 = T226 + T227;
				O[WS(os, 37)] = FNMS(KP1_763842528, T230, KP942793473 * T229);
				O[WS(os, 11)] = FMA(KP1_763842528, T229, KP942793473 * T230);
			}
			{
				E T221;
				E T222;
				E T225;
				E T228;
				T221 = T206 - T183;
				T222 = T216 + T219;
				O[WS(os, 23)] = FNMS(KP1_546020906, T222, KP1_268786568 * T221);
				O[WS(os, 25)] = FMA(KP1_546020906, T221, KP1_268786568 * T222);
				T225 = T223 + T224;
				T228 = T226 - T227;
				O[WS(os, 35)] = FNMS(KP1_913880671, T228, KP580569354 * T225);
				O[WS(os, 13)] = FMA(KP1_913880671, T225, KP580569354 * T228);
			}
		}
	}
}


template void dct_type2_48<>(const double*, double*, int, int, int, int, int);
template void dct_type2_48<>(const float*, float*, int, int, int, int, int);
template void dct_type2_48<>(const double*, double*, size_t, size_t, size_t, size_t, size_t);
template void dct_type2_48<>(const float*, float*, size_t, size_t, size_t, size_t, size_t);
