/**************************************************************************/
/*                                                                        */
/*       Copyright (c) Microsoft Corporation. All rights reserved.        */
/*                                                                        */
/*       This software is licensed under the Microsoft Software License   */
/*       Terms for Microsoft Azure RTOS. Full text of the license can be  */
/*       found in the LICENSE file at https://aka.ms/AzureRTOS_EULA       */
/*       and in the root directory of this software.                      */
/*                                                                        */
/**************************************************************************/


/**************************************************************************/
/**************************************************************************/
/**                                                                       */ 
/** ThreadX Component                                                     */ 
/**                                                                       */
/**   Thread                                                              */
/**                                                                       */
/**************************************************************************/
/**************************************************************************/
/*
***************************************************************************/
/*             CONSTANTS USED TO ACCESS TASK CONTEXT STACK                */
/**************************************************************************/

#if defined (__mips_hard_float)
.equ    STACK_OFFSET_S0,     4
.equ    STACK_OFFSET_S1,    STACK_OFFSET_S0    + 4  /* 8 */
.equ    STACK_OFFSET_S2,    STACK_OFFSET_S1    + 4  /* 12 */
.equ    STACK_OFFSET_S3,    STACK_OFFSET_S2    + 4  /* 16 */
.equ    STACK_OFFSET_S4,    STACK_OFFSET_S3    + 4  /* 20 */
.equ    STACK_OFFSET_S5,    STACK_OFFSET_S4    + 4 /* 24 */
.equ    STACK_OFFSET_S6,    STACK_OFFSET_S5    + 4 /* 28 */
.equ    STACK_OFFSET_S7,    STACK_OFFSET_S6    + 4 /* 32 */
.equ    STACK_OFFSET_S8,    STACK_OFFSET_S7    + 4 /* 36 */
.equ    STACK_OFFSET_F20,   STACK_OFFSET_S8    + 4 /* 40 */
.equ    STACK_OFFSET_F21,   STACK_OFFSET_F20   + 8 /* 48 */
.equ    STACK_OFFSET_F22,   STACK_OFFSET_F21   + 8 /* 56 */
.equ    STACK_OFFSET_F23,   STACK_OFFSET_F22   + 8 /* 64 */
.equ    STACK_OFFSET_F24,   STACK_OFFSET_F23   + 8 /* 72 */
.equ    STACK_OFFSET_F25,   STACK_OFFSET_F24   + 8/* 80 */
.equ    STACK_OFFSET_F26,   STACK_OFFSET_F25   + 8/* 88 */
.equ    STACK_OFFSET_F27,   STACK_OFFSET_F26   + 8/* 96 */
.equ    STACK_OFFSET_F28,   STACK_OFFSET_F27   + 8/* 104 */
.equ    STACK_OFFSET_F29,   STACK_OFFSET_F28   + 8/* 112 */
.equ    STACK_OFFSET_F30,   STACK_OFFSET_F29   + 8/* 120 */
.equ    STACK_OFFSET_F31,   STACK_OFFSET_F30   + 8/* 128 */
.equ    STACK_OFFSET_Res0,  STACK_OFFSET_F31   + 8/* 136 */
.equ    STACK_OFFSET_Res1,  STACK_OFFSET_Res0  + 4/* 140 */
.equ    STACK_OFFSET_Res2,  STACK_OFFSET_Res1  + 4/* 144 */
.equ    STACK_OFFSET_Res3,  STACK_OFFSET_Res2  + 4/* 148 */
.equ    STACK_OFFSET_AT,    STACK_OFFSET_Res3  + 4/* 152 */
.equ    STACK_OFFSET_V0,    STACK_OFFSET_AT    + 4/* 156 */
.equ    STACK_OFFSET_V1,    STACK_OFFSET_V0    + 4/* 160 */
.equ    STACK_OFFSET_A0,    STACK_OFFSET_V1    + 4/* 164 */
.equ    STACK_OFFSET_A1,    STACK_OFFSET_A0    + 4/* 168 */
.equ    STACK_OFFSET_A2,    STACK_OFFSET_A1    + 4/* 172 */
.equ    STACK_OFFSET_A3,    STACK_OFFSET_A2    + 4/* 176 */
.equ    STACK_OFFSET_T0,    STACK_OFFSET_A3    + 4/* 180 */
.equ    STACK_OFFSET_T1,    STACK_OFFSET_T0    + 4/* 184 */
.equ    STACK_OFFSET_T2,    STACK_OFFSET_T1    + 4/* 188 */
.equ    STACK_OFFSET_T3,    STACK_OFFSET_T2    + 4/* 192 */
.equ    STACK_OFFSET_T4,    STACK_OFFSET_T3    + 4/* 196 */
.equ    STACK_OFFSET_T5,    STACK_OFFSET_T4    + 4/* 200 */
.equ    STACK_OFFSET_T6,    STACK_OFFSET_T5    + 4/* 204 */
.equ    STACK_OFFSET_T7,    STACK_OFFSET_T6    + 4/* 208 */
.equ    STACK_OFFSET_T8,    STACK_OFFSET_T7    + 4/* 212 */
.equ    STACK_OFFSET_T9,    STACK_OFFSET_T8    + 4/* 216 */

.equ    STACK_OFFSET_RA,    STACK_OFFSET_T9    + 4/* 220 */
.equ    STACK_OFFSET_F0,    STACK_OFFSET_RA    + 4/* 224 */
.equ    STACK_OFFSET_F1,    STACK_OFFSET_F0    + 8/* 232 */
.equ    STACK_OFFSET_F2,    STACK_OFFSET_F1    + 8/* 240 */
.equ    STACK_OFFSET_F3,    STACK_OFFSET_F2    + 8/* 248 */
.equ    STACK_OFFSET_F4,    STACK_OFFSET_F3    + 8/* 256 */
.equ    STACK_OFFSET_F5,    STACK_OFFSET_F4    + 8/* 264 */
.equ    STACK_OFFSET_F6,    STACK_OFFSET_F5    + 8/* 272 */
.equ    STACK_OFFSET_F7,    STACK_OFFSET_F6    + 8/* 280 */
.equ    STACK_OFFSET_F8,    STACK_OFFSET_F7    + 8/* 288 */
.equ    STACK_OFFSET_F9,    STACK_OFFSET_F8    + 8/* 296 */
.equ    STACK_OFFSET_F10,   STACK_OFFSET_F9    + 8/* 304 */
.equ    STACK_OFFSET_F11,   STACK_OFFSET_F10   + 8/* 312 */
.equ    STACK_OFFSET_F12,   STACK_OFFSET_F11   + 8/* 320 */
.equ    STACK_OFFSET_F13,   STACK_OFFSET_F12   + 8/* 328 */
.equ    STACK_OFFSET_F14,   STACK_OFFSET_F13   + 8/* 336 */
.equ    STACK_OFFSET_F15,   STACK_OFFSET_F14   + 8/* 344 */
.equ    STACK_OFFSET_F16,   STACK_OFFSET_F15   + 8/* 352 */
.equ    STACK_OFFSET_F17,   STACK_OFFSET_F16   + 8/* 360 */
.equ    STACK_OFFSET_F18,   STACK_OFFSET_F17   + 8/* 368 */
.equ    STACK_OFFSET_F19,   STACK_OFFSET_F18   + 8/* 376 */
.equ    STACK_OFFSET_Res4,  STACK_OFFSET_F19   + 8/* 384 */
.equ    STACK_OFFSET_FCSR,  STACK_OFFSET_Res4  + 4/* 388 */
.equ    STACK_OFFSET_HI3,   STACK_OFFSET_FCSR  + 4/* 392 */
.equ    STACK_OFFSET_LO3,   STACK_OFFSET_HI3   + 4/* 396 */
.equ    STACK_OFFSET_HI2,   STACK_OFFSET_LO3   + 4/* 400 */
.equ    STACK_OFFSET_LO2,   STACK_OFFSET_HI2   + 4/* 404 */
.equ    STACK_OFFSET_HI1,   STACK_OFFSET_LO2   + 4/* 408 */
.equ    STACK_OFFSET_LO1,   STACK_OFFSET_HI1   + 4/* 412 */
.equ    STACK_OFFSET_HI0,   STACK_OFFSET_LO1   + 4/* 416 */
.equ    STACK_OFFSET_LO0,   STACK_OFFSET_HI0   + 4/* 420 */
.equ    STACK_OFFSET_DSPC,  STACK_OFFSET_LO0   + 4/* 424 */
.equ    STACK_OFFSET_SRSC,  STACK_OFFSET_DSPC  + 4/* 428 */
.equ    STACK_OFFSET_SR,    STACK_OFFSET_SRSC  + 4/* 432 */
.equ    STACK_OFFSET_EPC,   STACK_OFFSET_SR    + 4/* 436 */
.equ    STACK_CTX_SIZE,     STACK_OFFSET_EPC   + 4/* 440 */ 
#else
.equ    STACK_OFFSET_S0,     4
.equ    STACK_OFFSET_S1,    STACK_OFFSET_S0    + 4  /* 8 */
.equ    STACK_OFFSET_S2,    STACK_OFFSET_S1    + 4  /* 12 */
.equ    STACK_OFFSET_S3,    STACK_OFFSET_S2    + 4  /* 16 */
.equ    STACK_OFFSET_S4,    STACK_OFFSET_S3    + 4  /* 20 */
.equ    STACK_OFFSET_S5,    STACK_OFFSET_S4    + 4  /* 24 */
.equ    STACK_OFFSET_S6,    STACK_OFFSET_S5    + 4  /* 28 */
.equ    STACK_OFFSET_S7,    STACK_OFFSET_S6    + 4  /* 32 */
.equ    STACK_OFFSET_S8,    STACK_OFFSET_S7    + 4  /* 36 */
.equ    STACK_OFFSET_Res0,  STACK_OFFSET_S8    + 4  /* 40 */
.equ    STACK_OFFSET_Res1,  STACK_OFFSET_Res0  + 4  /* 44 */
.equ    STACK_OFFSET_Res2,  STACK_OFFSET_Res1  + 4  /* 48 */
.equ    STACK_OFFSET_Res3,  STACK_OFFSET_Res2  + 4  /* 52 */
.equ    STACK_OFFSET_AT,    STACK_OFFSET_Res3  + 4  /* 56 */
.equ    STACK_OFFSET_V0,    STACK_OFFSET_AT    + 4  /* 60 */
.equ    STACK_OFFSET_V1,    STACK_OFFSET_V0    + 4  /* 64 */
.equ    STACK_OFFSET_A0,    STACK_OFFSET_V1    + 4  /* 68 */
.equ    STACK_OFFSET_A1,    STACK_OFFSET_A0    + 4  /* 72 */
.equ    STACK_OFFSET_A2,    STACK_OFFSET_A1    + 4  /* 76 */
.equ    STACK_OFFSET_A3,    STACK_OFFSET_A2    + 4  /* 80 */
.equ    STACK_OFFSET_T0,    STACK_OFFSET_A3    + 4  /* 84 */
.equ    STACK_OFFSET_T1,    STACK_OFFSET_T0    + 4  /* 88 */
.equ    STACK_OFFSET_T2,    STACK_OFFSET_T1    + 4  /* 92 */
.equ    STACK_OFFSET_T3,    STACK_OFFSET_T2    + 4  /* 96 */
.equ    STACK_OFFSET_T4,    STACK_OFFSET_T3    + 4  /* 100 */
.equ    STACK_OFFSET_T5,    STACK_OFFSET_T4    + 4  /* 104 */
.equ    STACK_OFFSET_T6,    STACK_OFFSET_T5    + 4  /* 108 */
.equ    STACK_OFFSET_T7,    STACK_OFFSET_T6    + 4  /* 112 */
.equ    STACK_OFFSET_T8,    STACK_OFFSET_T7    + 4  /* 116 */
.equ    STACK_OFFSET_T9,    STACK_OFFSET_T8    + 4  /* 120 */

.equ    STACK_OFFSET_RA,    STACK_OFFSET_T9    + 4  /* 124 */
.equ    STACK_OFFSET_HI3,   STACK_OFFSET_RA    + 4  /* 128 */
.equ    STACK_OFFSET_LO3,   STACK_OFFSET_HI3   + 4  /* 132 */
.equ    STACK_OFFSET_HI2,   STACK_OFFSET_LO3   + 4  /* 136 */
.equ    STACK_OFFSET_LO2,   STACK_OFFSET_HI2   + 4  /* 140 */
.equ    STACK_OFFSET_HI1,   STACK_OFFSET_LO2   + 4  /* 144 */
.equ    STACK_OFFSET_LO1,   STACK_OFFSET_HI1   + 4  /* 148 */
.equ    STACK_OFFSET_HI0,   STACK_OFFSET_LO1   + 4  /* 152 */
.equ    STACK_OFFSET_LO0,   STACK_OFFSET_HI0   + 4  /* 156 */
.equ    STACK_OFFSET_DSPC,   STACK_OFFSET_LO0  + 4  /* 160 */
.equ    STACK_OFFSET_SRSC,  STACK_OFFSET_DSPC  + 4  /* 164 */
.equ    STACK_OFFSET_SR,    STACK_OFFSET_SRSC  + 4  /* 168 */
.equ    STACK_OFFSET_EPC,   STACK_OFFSET_SR    + 4  /* 172 */
.equ    STACK_CTX_SIZE,     STACK_OFFSET_EPC   + 4  /* 176 */
#endif



#if defined (__mips_hard_float)
.equ    MINIMAL_STACK_OFFSET_DSPC,   20 			    /* 20 */
.equ    MINIMAL_STACK_OFFSET_S0,    MINIMAL_STACK_OFFSET_DSPC  + 4  /* 24 */
.equ    MINIMAL_STACK_OFFSET_S1,    MINIMAL_STACK_OFFSET_S0    + 4  /* 28 */
.equ    MINIMAL_STACK_OFFSET_S2,    MINIMAL_STACK_OFFSET_S1    + 4  /* 32 */
.equ    MINIMAL_STACK_OFFSET_S3,    MINIMAL_STACK_OFFSET_S2    + 4  /* 36 */
.equ    MINIMAL_STACK_OFFSET_S4,    MINIMAL_STACK_OFFSET_S3    + 4  /* 40 */
.equ    MINIMAL_STACK_OFFSET_S5,    MINIMAL_STACK_OFFSET_S4    + 4  /* 44 */
.equ    MINIMAL_STACK_OFFSET_S6,    MINIMAL_STACK_OFFSET_S5    + 4  /* 48 */
.equ    MINIMAL_STACK_OFFSET_S7,    MINIMAL_STACK_OFFSET_S6    + 4  /* 52 */
.equ    MINIMAL_STACK_OFFSET_S8,    MINIMAL_STACK_OFFSET_S7    + 4  /* 56 */
.equ    MINIMAL_STACK_OFFSET_RA,    MINIMAL_STACK_OFFSET_S8    + 4  /* 60 */
.equ    MINIMAL_STACK_OFFSET_HI3,   MINIMAL_STACK_OFFSET_RA    + 4  /* 64 */
.equ    MINIMAL_STACK_OFFSET_LO3,   MINIMAL_STACK_OFFSET_HI3   + 4  /* 68 */
.equ    MINIMAL_STACK_OFFSET_HI2,   MINIMAL_STACK_OFFSET_LO3   + 4  /* 72 */
.equ    MINIMAL_STACK_OFFSET_LO2,   MINIMAL_STACK_OFFSET_HI2   + 4  /* 76 */
.equ    MINIMAL_STACK_OFFSET_HI1,   MINIMAL_STACK_OFFSET_LO2   + 4  /* 80 */
.equ    MINIMAL_STACK_OFFSET_LO1,   MINIMAL_STACK_OFFSET_HI1   + 4  /* 84 */
.equ    MINIMAL_STACK_OFFSET_HI0,   MINIMAL_STACK_OFFSET_LO1   + 4  /* 88 */
.equ    MINIMAL_STACK_OFFSET_LO0,   MINIMAL_STACK_OFFSET_HI0   + 4  /* 92 */
.equ    MINIMAL_STACK_OFFSET_FCSR,  MINIMAL_STACK_OFFSET_LO0   + 4  /* 96 */
.equ    MINIMAL_STACK_OFFSET_SR,    MINIMAL_STACK_OFFSET_FCSR  + 4  /* 100 */
.equ    MINIMAL_STACK_OFFSET_F20,   MINIMAL_STACK_OFFSET_SR    + 4  /* 104 */
.equ    MINIMAL_STACK_OFFSET_F21,   MINIMAL_STACK_OFFSET_F20   + 8  /* 112 */
.equ    MINIMAL_STACK_OFFSET_F22,   MINIMAL_STACK_OFFSET_F21   + 8  /* 120 */
.equ    MINIMAL_STACK_OFFSET_F23,   MINIMAL_STACK_OFFSET_F22   + 8  /* 128 */
.equ    MINIMAL_STACK_OFFSET_F24,   MINIMAL_STACK_OFFSET_F23   + 8  /* 136 */
.equ    MINIMAL_STACK_OFFSET_F25,   MINIMAL_STACK_OFFSET_F24   + 8  /* 144 */
.equ    MINIMAL_STACK_OFFSET_F26,   MINIMAL_STACK_OFFSET_F25   + 8  /* 152 */
.equ    MINIMAL_STACK_OFFSET_F27,   MINIMAL_STACK_OFFSET_F26   + 8  /* 160 */
.equ    MINIMAL_STACK_OFFSET_F28,   MINIMAL_STACK_OFFSET_F27   + 8  /* 168 */
.equ    MINIMAL_STACK_OFFSET_F29,   MINIMAL_STACK_OFFSET_F28   + 8  /* 176 */
.equ    MINIMAL_STACK_OFFSET_F30,   MINIMAL_STACK_OFFSET_F29   + 8  /* 184 */
.equ    MINIMAL_STACK_OFFSET_F31,   MINIMAL_STACK_OFFSET_F30   + 8  /* 192 */
.equ    MINIMAL_STACK_CTX_SIZE,     MINIMAL_STACK_OFFSET_F31   + 8  /* 200 */

#else
.equ    MINIMAL_STACK_OFFSET_DSPC,   20 			    /* 20 */
.equ    MINIMAL_STACK_OFFSET_S0,    MINIMAL_STACK_OFFSET_DSPC  + 4  /* 24 */
.equ    MINIMAL_STACK_OFFSET_S1,    MINIMAL_STACK_OFFSET_S0    + 4  /* 28 */
.equ    MINIMAL_STACK_OFFSET_S2,    MINIMAL_STACK_OFFSET_S1    + 4  /* 32 */
.equ    MINIMAL_STACK_OFFSET_S3,    MINIMAL_STACK_OFFSET_S2    + 4  /* 36 */
.equ    MINIMAL_STACK_OFFSET_S4,    MINIMAL_STACK_OFFSET_S3    + 4  /* 40 */
.equ    MINIMAL_STACK_OFFSET_S5,    MINIMAL_STACK_OFFSET_S4    + 4  /* 44 */
.equ    MINIMAL_STACK_OFFSET_S6,    MINIMAL_STACK_OFFSET_S5    + 4  /* 48 */
.equ    MINIMAL_STACK_OFFSET_S7,    MINIMAL_STACK_OFFSET_S6    + 4  /* 52 */
.equ    MINIMAL_STACK_OFFSET_S8,    MINIMAL_STACK_OFFSET_S7    + 4  /* 56 */
.equ    MINIMAL_STACK_OFFSET_RA,    MINIMAL_STACK_OFFSET_S8    + 4  /* 60 */
.equ    MINIMAL_STACK_OFFSET_LO0,   MINIMAL_STACK_OFFSET_RA    + 4  /* 64 */
.equ    MINIMAL_STACK_OFFSET_HI0,   MINIMAL_STACK_OFFSET_LO0   + 4  /* 68 */
.equ    MINIMAL_STACK_OFFSET_LO1,   MINIMAL_STACK_OFFSET_HI0   + 4  /* 72 */
.equ    MINIMAL_STACK_OFFSET_HI1,   MINIMAL_STACK_OFFSET_LO1   + 4  /* 76 */
.equ    MINIMAL_STACK_OFFSET_LO2,   MINIMAL_STACK_OFFSET_HI1   + 4  /* 80 */
.equ    MINIMAL_STACK_OFFSET_HI2,   MINIMAL_STACK_OFFSET_LO2   + 4  /* 84 */
.equ    MINIMAL_STACK_OFFSET_LO3,   MINIMAL_STACK_OFFSET_HI2   + 4  /* 88 */
.equ    MINIMAL_STACK_OFFSET_HI3,   MINIMAL_STACK_OFFSET_LO3   + 4  /* 92 */
.equ    MINIMAL_STACK_OFFSET_Res0,  MINIMAL_STACK_OFFSET_HI3   + 4  /* 96 */
.equ    MINIMAL_STACK_OFFSET_SR,    MINIMAL_STACK_OFFSET_Res0  + 4  /* 100 */
.equ    MINIMAL_STACK_CTX_SIZE,     MINIMAL_STACK_OFFSET_SR    + 4  /* 104 */
#endif
