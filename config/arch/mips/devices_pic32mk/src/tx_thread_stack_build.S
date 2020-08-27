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


/* #define TX_SOURCE_CODE  */

    #include "tx_cpu.inc"
/* Include necessary system files.  */

/*  #include "tx_api.h"
    #include "tx_thread.h"  */


    INITIAL_SR  =   0x0003                  # Interrupt enable previous

    .section .text,code
    .set    noreorder
    .set    noat
#if ( __mips_micromips == 1 )    
	.set  micromips
#else
    .set  nomicromips
#endif
    .set    nomips16


/**************************************************************************/ 
/*                                                                        */ 
/*  FUNCTION                                               RELEASE        */ 
/*                                                                        */ 
/*    _tx_thread_stack_build                           PIC32MZ/Microchip  */ 
/*                                                           5.0          */ 
/*  AUTHOR                                                                */ 
/*                                                                        */ 
/*    William E. Lamie, Express Logic, Inc.                               */ 
/*                                                                        */ 
/*  DESCRIPTION                                                           */ 
/*                                                                        */ 
/*    This function builds a stack frame on the supplied thread's stack.  */
/*    The stack frame results in a fake interrupt return to the supplied  */
/*    function pointer.                                                   */ 
/*                                                                        */ 
/*  INPUT                                                                 */ 
/*                                                                        */ 
/*    thread_ptr                            Pointer to thread control blk */
/*    function_ptr                          Pointer to return function    */
/*                                                                        */ 
/*  OUTPUT                                                                */ 
/*                                                                        */ 
/*    None                                                                */
/*                                                                        */ 
/*  CALLS                                                                 */ 
/*                                                                        */ 
/*    None                                                                */
/*                                                                        */ 
/*  CALLED BY                                                             */ 
/*                                                                        */ 
/*    _tx_thread_create                     Create thread service         */
/*                                                                        */ 
/*  RELEASE HISTORY                                                       */ 
/*                                                                        */ 
/*    DATE              NAME                      DESCRIPTION             */ 
/*                                                                        */ 
/*  09-01-2014     William E. Lamie         Initial Version 5.0           */ 
/*                                                                        */ 
/*NOTE: Each register position on the stack is loaded with a fill value,  */
/*      this makes it easy to see Task stack and CPU registers are getting*/
/*      setup correctly the first time.                                   */
/**************************************************************************/ 
/* VOID   _tx_thread_stack_build(TX_THREAD *thread_ptr, VOID (*function_ptr)(VOID))
{  */
    .globl  _tx_thread_stack_build
_tx_thread_stack_build:

       
    /* Build a fake interrupt frame.  The form of the fake interrupt stack
       on the PIC32MZ without FPU should look like the following after it is  
       built for interrupts declared with the IPLnSOFT function __attribute__:
       
       Stack Top:      1            (00)    Interrupt stack frame type
                       $16          (04)    Initial S0
                       $17          (08)    Initial S1
                       $18          (12)    Initial S2
                       $19          (16)    Initial S3
                       $20          (20)    Initial S4
                       $21          (24)    Initial S5
                       $22          (28)    Initial S6
                       $23          (32)    Initial S7
                                    (36)    Reserved
                                    (40)    Reserved
                                    (44)    Reserved
                                    (48)    Reserved
                       DSPControl   (52)    Initial DSPControl 
                       $1           (56)    Initial at
                       $2           (60)    Initial v0
                       $3           (64)    Initial v1
                       $4           (68)    Initial a0    
                       $5           (72)    Initial a1    
                       $6           (76)    Initial a2    
                       $7           (80)    Initial a3    
                       $8           (84)    Initial t0    
                       $9           (88)    Initial t1    
                       $10          (92)    Initial t2    
                       $11          (96)    Initial t3    
                       $12          (100)   Initial t4    
                       $13          (104)   Initial t5    
                       $14          (108)   Initial t6    
                       $15          (112)   Initial t7    
                       $24          (116)   Initial t8    
                       $25          (120)   Initial t9    
                       $30          (124)   Initial s8    
                       $31          (128)   Initial ra    
                       ac3          (132)   Initial HI
                       ac3          (136)   Initial LO
                       ac2          (140)   Initial HI
                       ac2          (144)   Initial LO
                       ac1          (148)   Initial HI
                       ac1          (152)   Initial LO
                       ac0          (156)   Initial HI
                       ac0          (160)   Initial LO
                                    (164)   Reserved      
                       SR           (168)   Initial SRSCtl  
                       SRSCtl       (172)   Initial status
                       EPC          (176)   Initial EPC         

    Stack Bottom: (higher memory address)  */

        /* Build a fake interrupt frame.  The form of the fake interrupt stack
       on the PIC32MZ with FPU should look like the following after it is  
       built for interrupts declared with the IPLnSOFT function __attribute__:
       
       Stack Top:      1            (00)    Interrupt stack frame type
                       $16          (04)    Initial S0
                       $17          (08)    Initial S1
                       $18          (12)    Initial S2
                       $19          (16)    Initial S3
                       $20          (20)    Initial S4
                       $21          (24)    Initial S5
                       $22          (28)    Initial S6
                       $23          (32)    Initial S7
		       Reserved	    (36)    Reserved		    
                       $f20         (40)    Initial f20  
                       $f21         (48)    Initial f21 
                       $f22         (56)    Initial f22  
                       $f23         (64)    Initial f23  
                       $f24         (72)    Initial f24    
                       $f25         (80)    Initial f25      
                       $f26         (88)    Initial f26 
                       $f27         (96)    Initial f27  
                       $f28         (104)   Initial f28 
                       $f29         (112)   Initial f29        
                       $f30         (120)   Initial f30 
                       $f31         (128)   Initial f31       
                                    (136)   Reserved
                                    (140)   Reserved
                                    (144)   Reserved
                       $1           (148)   Initial at
                       $2           (152)   Initial v0
                       $3           (156)   Initial v1
                       $4           (160)   Initial a0    
                       $5           (164)   Initial a1    
                       $6           (168)   Initial a2    
                       $7           (172)   Initial a3    
                       $8           (176)   Initial t0    
                       $9           (180)   Initial t1    
                       $10          (184)   Initial t2    
                       $11          (188)   Initial t3    
                       $12          (192)   Initial t4    
                       $13          (196)   Initial t5    
                       $14          (200)   Initial t6    
                       $15          (204)   Initial t7    
                       $24          (208)   Initial t8    
                       $25          (212)   Initial t9    
                       $30          (216)   Initial s8    
                       $31          (220)   Initial ra
                       $f0          (224)   Initial f0  
                       $f1          (232)   Initial f1 
                       $f2          (240)   Initial f2  
                       $f3          (248)   Initial f3  
                       $f4          (256)   Initial f4    
                       $f5          (264)   Initial f5      
                       $f6          (272)   Initial f6 
                       $f7          (280)   Initial f7  
                       $f8          (288)   Initial f8 
                       $f9          (296)   Initial f9  
                       $f10         (304)   Initial f10  
                       $f11         (312)   Initial f11    
                       $f12         (320)   Initial f12      
                       $f13         (328)   Initial f13 
                       $f14         (336)   Initial f14  
                       $f15         (344)   Initial f15 
                       $f16         (352)   Initial f16  
                       $f17         (360)   Initial f17  
                       $f18         (368)   Initial f18    
                       $f19         (376)   Initial f19       
		       reserved	    (384)   reserved
		       FCSR	    (388)   Initial FCSR
                       ac3          (392)   Initial HI
                       ac3          (396)   Initial LO
                       ac2          (400)   Initial HI
                       ac2          (404)   Initial LO
                       ac1          (408)   Initial HI
                       ac1          (412)   Initial LO
                       ac0          (416)   Initial HI
                       ac0          (420)   Initial LO
                       DSPControl   (424)   Initial DSPControl      
                       SR           (428)   Initial SRSCtl  
                       SRSCtl       (432)   Initial status
                       EPC          (436)   Initial EPC         

    Stack Bottom: (higher memory address)  */
	
    lw      $8, 16($4)                      # Pickup end of stack area
    ins     $8, $0, 0, 3                    # Make sure double word alignment

    /* Actually build the stack frame.  */

    addiu   $8, $8, -STACK_CTX_SIZE         # Allocate space for the stack frame

    ori     $9, $0, 1                       # Build stack type
    sw      $9, ($8)                        # Place stack type on the top
    
    li      $9, 0x16161616                  # Build fill value for $16
    sw      $9, STACK_OFFSET_S0($8)         # Initial s0
    
    li      $9, 0x17171717                  # Build fill value for $17
    sw      $9, STACK_OFFSET_S1($8)         # Initial s1

    li      $9, 0x18181818                  # Build fill value for $18
    sw      $9, STACK_OFFSET_S2($8)         # Initial s2

    li      $9, 0x19191919                  # Build fill value for $19
    sw      $9, STACK_OFFSET_S3($8)         # Initial s3
    
    li      $9, 0x20202020                  # Build fill value for $20
    sw      $9, STACK_OFFSET_S4($8)         # Initial s4

    li      $9, 0x21212121                  # Build fill value for $21
    sw      $9, STACK_OFFSET_S5($8)         # Initial s5

    li      $9, 0x22222222                  # Build fill value for $22
    sw      $9, STACK_OFFSET_S6($8)         # Initial s6

    li      $9, 0x23232323                  # Build fill value for $23
    sw      $9, STACK_OFFSET_S7($8)         # Initial s7
 
    li      $9, 0x30303030                  # Build fill value for $30
    sw      $9, STACK_OFFSET_S8($8)         # Initial s8
    
    #if defined (__mips_hard_float)
    li      $9, 0x51515151                  # Build fill value for $f20
    sw      $9, STACK_OFFSET_F20($8)        # Initial f20
    sw      $9, (STACK_OFFSET_F20+4)($8)    # Initial f20
    li      $9, 0x52525252                  # Build fill value for $f21
    sw      $9, STACK_OFFSET_F21($8)        # Initial f21
    sw      $9, (STACK_OFFSET_F21+4)($8)    # Initial f21
    li      $9, 0x53535353                  # Build fill value for $f22
    sw      $9, STACK_OFFSET_F22($8)        # Initial f22
    sw      $9, (STACK_OFFSET_F22+4)($8)    # Initial f22
    li      $9, 0x54545454                  # Build fill value for $f23
    sw      $9, STACK_OFFSET_F23($8)        # Initial f23
    sw      $9, (STACK_OFFSET_F23+4)($8)    # Initial f23
    li      $9, 0x55555555                  # Build fill value for $f24
    sw      $9, STACK_OFFSET_F24($8)        # Initial f24
    sw      $9, (STACK_OFFSET_F24+4)($8)    # Initial f24
    li      $9, 0x56565656                  # Build fill value for $f25
    sw      $9, STACK_OFFSET_F25($8)        # Initial f25
    sw      $9, (STACK_OFFSET_F25+4)($8)    # Initial f25
    li      $9, 0x57575757                  # Build fill value for $f26
    sw      $9, STACK_OFFSET_F26($8)        # Initial f26
    sw      $9, (STACK_OFFSET_F26+4)($8)    # Initial f26
    li      $9, 0x58585858                  # Build fill value for $f27
    sw      $9, STACK_OFFSET_F27($8)        # Initial f27
    sw      $9, (STACK_OFFSET_F27+4)($8)    # Initial f27
    li      $9, 0x59595959                  # Build fill value for $f28
    sw      $9, STACK_OFFSET_F28($8)        # Initial f28
    sw      $9, (STACK_OFFSET_F28+4)($8)    # Initial f28
    li      $9, 0x60606060                  # Build fill value for $f29
    sw      $9, STACK_OFFSET_F29($8)        # Initial f29
    sw      $9, (STACK_OFFSET_F29+4)($8)    # Initial f29
    li      $9, 0x61616161                  # Build fill value for $f30
    sw      $9, STACK_OFFSET_F30($8)        # Initial f30
    sw      $9, (STACK_OFFSET_F30+4)($8)    # Initial f30
    li      $9, 0x62626262                  # Build fill value for $f31
    sw      $9, STACK_OFFSET_F31($8)        # Initial f31
    sw      $9, (STACK_OFFSET_F31+4)($8)    # Initial f31    
    #endif

    sw      $0, STACK_OFFSET_Res0($8)       # reserved
    sw      $0, STACK_OFFSET_Res1($8)       # reserved
    sw      $0, STACK_OFFSET_Res2($8)       # reserved
    sw      $0, STACK_OFFSET_Res3($8)       # reserved
    
    li      $9, 0x01010101                  # Build fill value for $1
    sw      $9, STACK_OFFSET_AT($8)         # Initial at
    li      $9, 0x02020202                  # Build fill value for $2
    sw      $9, STACK_OFFSET_V0($8)         # Initial v0   
    li      $9, 0x03030303                  # Build fill value for $3
    sw      $9, STACK_OFFSET_V1($8)         # Initial v1
    li      $9, 0x04040404                  # Build fill value for $4
    sw      $9, STACK_OFFSET_A0($8)         # Initial a0
    li      $9, 0x05050505                  # Build fill value for $5
    sw      $9, STACK_OFFSET_A1($8)         # Initial a1
    li      $9, 0x06060606                  # Build fill value for $6
    sw      $9, STACK_OFFSET_A2($8)         # Initial a2
    li      $9, 0x07070707                  # Build fill value for $7
    sw      $9, STACK_OFFSET_A3($8)         # Initial a3
    li      $9, 0x08080808                  # Build fill value for $8
    sw      $9, STACK_OFFSET_T0($8)         # Initial t0
    li      $9, 0x09090909                  # Build fill value for $9
    sw      $9, STACK_OFFSET_T1($8)         # Initial t1
    li      $9, 0x10101010                  # Build fill value for $10
    sw      $9, STACK_OFFSET_T2($8)         # Initial t2
    li      $9, 0x11111111                  # Build fill value for $11
    sw      $9, STACK_OFFSET_T3($8)         # Initial t3
    li      $9, 0x12121212                  # Build fill value for $12
    sw      $9, STACK_OFFSET_T4($8)         # Initial t4
    li      $9, 0x13131313                  # Build fill value for $13
    sw      $9, STACK_OFFSET_T5($8)         # Initial t5
    li      $9, 0x14141414                  # Build fill value for $14
    sw      $9, STACK_OFFSET_T6($8)         # Initial t6
    li      $9, 0x15151515                  # Build fill value for $15
    sw      $9, STACK_OFFSET_T7($8)         # Initial t7
    li      $9, 0x24242424                  # Build fill value for $24
    sw      $9, STACK_OFFSET_T8($8)         # Initial t8
    li      $9, 0x25252525                  # Build fill value for $25
    sw      $9, STACK_OFFSET_T9($8)         # Initial t9

    sw      $0, STACK_OFFSET_RA($8)         # Initial ra
#if defined (__mips_hard_float)
    li      $9, 0x31313131                  # Build fill value for $f0
    sw      $9, STACK_OFFSET_F0($8)         # Initial f0
    sw      $9, (STACK_OFFSET_F0+4)($8)                     # Initial f0
    li      $9, 0x32323232                  # Build fill value for $f1
    sw      $9, STACK_OFFSET_F1($8)         # Initial f1
    sw      $9, (STACK_OFFSET_F1+4)($8)     # Initial f1
    li      $9, 0x33333333                  # Build fill value for $f2
    sw      $9, STACK_OFFSET_F2($8)         # Initial f2
    sw      $9, (STACK_OFFSET_F2+4)($8)     # Initial f2
    li      $9, 0x34343434                  # Build fill value for $f3
    sw      $9, STACK_OFFSET_F3($8)         # Initial f3
    sw      $9, (STACK_OFFSET_F3+4)($8)     # Initial f3
    li      $9, 0x35353535                  # Build fill value for $f4
    sw      $9, STACK_OFFSET_F4($8)         # Initial f4
    sw      $9, (STACK_OFFSET_F4+4)($8)     # Initial f4
    li      $9, 0x36363636                  # Build fill value for $f5
    sw      $9, STACK_OFFSET_F5($8)         # Initial f5
    sw      $9, (STACK_OFFSET_F5+4)($8)     # Initial f5
    li      $9, 0x37373737                  # Build fill value for $f6
    sw      $9, STACK_OFFSET_F6($8)         # Initial f6
    sw      $9, (STACK_OFFSET_F6+4)($8)     # Initial f6
    li      $9, 0x38383838                  # Build fill value for $f7
    sw      $9, STACK_OFFSET_F7($8)         # Initial f7
    sw      $9, (STACK_OFFSET_F7+4)($8)     # Initial f7
    li      $9, 0x39393939                  # Build fill value for $f8
    sw      $9, STACK_OFFSET_F8($8)         # Initial f8
    sw      $9, (STACK_OFFSET_F8+4)($8)     # Initial f8
    li      $9, 0x40404040                  # Build fill value for $f9
    sw      $9, STACK_OFFSET_F9($8)         # Initial f9
    sw      $9, (STACK_OFFSET_F9+4)($8)     # Initial f9
    li      $9, 0x41414141                  # Build fill value for $f10
    sw      $9, STACK_OFFSET_F10($8)        # Initial f10
    sw      $9, (STACK_OFFSET_F10+4)($8)    # Initial f10
    li      $9, 0x42424242                  # Build fill value for $f11
    sw      $9, STACK_OFFSET_F11($8)        # Initial f11
    sw      $9, (STACK_OFFSET_F11+4)($8)    # Initial f11
    li      $9, 0x43434343                  # Build fill value for $f12
    sw      $9, STACK_OFFSET_F12($8)        # Initial f12
    sw      $9, (STACK_OFFSET_F12+4)($8)    # Initial f12
    li      $9, 0x44444444                  # Build fill value for $f13
    sw      $9, STACK_OFFSET_F13($8)        # Initial f13
    sw      $9, (STACK_OFFSET_F13+4)($8)    # Initial f13
    li      $9, 0x45454545                  # Build fill value for $f14
    sw      $9, STACK_OFFSET_F14($8)        # Initial f14
    sw      $9, (STACK_OFFSET_F14+4)($8)    # Initial f14
    li      $9, 0x46464646                  # Build fill value for $f15
    sw      $9, STACK_OFFSET_F15($8)        # Initial f15
    sw      $9, (STACK_OFFSET_F15+4)($8)    # Initial f15
    li      $9, 0x47474747                  # Build fill value for $f16
    sw      $9, STACK_OFFSET_F16($8)        # Initial f16
    sw      $9, (STACK_OFFSET_F16+4)($8)    # Initial f16
    li      $9, 0x48484848                  # Build fill value for $f17
    sw      $9, STACK_OFFSET_F17($8)        # Initial f17
    sw      $9, (STACK_OFFSET_F17+4)($8)    # Initial f17
    li      $9, 0x49494949                  # Build fill value for $f18
    sw      $9, STACK_OFFSET_F18($8)        # Initial f18
    sw      $9, (STACK_OFFSET_F18+4)($8)    # Initial f18
    li      $9, 0x50505050                  # Build fill value for $f19
    sw      $9, STACK_OFFSET_F19($8)        # Initial f19
    sw      $9, (STACK_OFFSET_F19+4)($8)    # Initial f19
    
    CFC1    $9, $f31			    # Build fill value for $FCSR                
    sw      $9, STACK_OFFSET_FCSR($8)                     # Initial FCSR
 #endif
    sw      $0, STACK_OFFSET_HI3($8)        # Initial ac3 hi
    sw      $0, STACK_OFFSET_LO3($8)        # Initial ac3 lo
    sw      $0, STACK_OFFSET_HI2($8)        # Initial ac2 hi
    sw      $0, STACK_OFFSET_LO2($8)        # Initial ac2 lo
    sw      $0, STACK_OFFSET_HI1($8)        # Initial ac1 hi
    sw      $0, STACK_OFFSET_LO1($8)        # Initial ac1 lo
    sw      $0, STACK_OFFSET_HI0($8)        # Initial ac0 hi
    sw      $0, STACK_OFFSET_LO0($8)        # Initial ac0 lo

    rddsp   $9, 0x1F                        # Pickup current DSPControl
    sw      $9, STACK_OFFSET_DSPC($8)       # Initial DSPControl 
    mfc0    $9, $12,2                       # Pickup SRSCtl
    sw      $9, STACK_OFFSET_SRSC($8)       # Initial SRSCtl
    mfc0    $9, $12                         # Pickup current SR
    ori     $9, $9, INITIAL_SR              # Build initial SR
    sw      $9, STACK_OFFSET_SR($8)         # Initial SR
    sw      $5, STACK_OFFSET_EPC($8)        # Initial EPC


    /* Setup stack pointer.  */
    /* thread_ptr -> tx_thread_stack_ptr =  t0;  */

    jr      $31                             # Return to caller
    sw      $8, 8($4)                       # Save stack pointer in thread's 
                                        /*  #   control block  */
/* }  */

