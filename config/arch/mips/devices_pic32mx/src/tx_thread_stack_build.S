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


/* Include necessary system files.  */

/*  #include "tx_api.h"
    #include "tx_thread.h"  */


    INITIAL_SR  =   0x0003                  # Interrupt enable previous

    .section .text,code
    .set    noreorder
    .set    noat
    .set    nomicromips
    .set    nomips16
    
/**************************************************************************/ 
/*                                                                        */ 
/*  FUNCTION                                               RELEASE        */ 
/*                                                                        */ 
/*    _tx_thread_stack_build                           PIC32MX/Microchip  */ 
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
/**************************************************************************/ 
/* VOID   _tx_thread_stack_build(TX_THREAD *thread_ptr, VOID (*function_ptr)(VOID))
{  */
    .globl  _tx_thread_stack_build
_tx_thread_stack_build:

       
    /* Build a fake interrupt frame.  The form of the fake interrupt stack
       on the PIC32MZ should look like the following after it is built for 
       interrupts declared with the IPLnSOFT function __attribute__:
       
       Stack Top:      1       (00)    Interrupt stack frame type
                       $16     (04)    Initial S0
                       $17     (08)    Initial S1
                       $18     (12)    Initial S2
                       $19     (16)    Initial S3
                       $20     (20)    Initial S4
                       $21     (24)    Initial S5
                       $22     (28)    Initial S6
                       $23     (32)    Initial S6
                               (36)    Reserved
                               (40)    Reserved
                               (44)    Reserved
                               (48)    Reserved
                               (52)    Reserved
                       $1      (56)    Initial at
                       $2      (60)    Initial v0
                       $3      (64)    Initial v1
                       $4      (68)    Initial a0    
                       $5      (72)    Initial a1    
                       $6      (76)    Initial a2    
                       $7      (80)    Initial a3    
                       $8      (84)    Initial t0    
                       $9      (88)    Initial t1    
                       $10     (92)    Initial t2    
                       $11     (96)    Initial t3    
                       $12     (100)   Initial t4    
                       $13     (104)   Initial t5    
                       $14     (108)   Initial t6    
                       $15     (112)   Initial t7    
                       $24     (116)   Initial t8    
                       $25     (120)   Initial t9    
                       $30     (124)   Initial s8    
                       $31     (128)   Initial ra    
                       hi      (132)   Initial HI    
                       lo      (136)   Initial LO    
                               (140)   Reserved      
                       SR      (144)   Initial status  
                       SRSCtl  (148)   Initial SRSCtl
                       EPC     (152)   Initial EPC         

    Stack Bottom: (higher memory address)  
    
    NOTE: Each register position on the stack is loaded with a fill value,  
          this makes it easy to see Task stack and CPU registers are getting
          setup correctly the first time.  
    */


    lw      $8, 16($4)                      # Pickup end of stack area
    ins     $8, $0, 0, 3                    # Make sure double word alignment

    /* Actually build the stack frame.  */

    addiu   $8, $8, -156                    # Allocate space for the stack frame  
    ori     $9, $0, 1                       # Build stack type
    sw      $9, ($8)                        # Place stack type on the top
    
    li      $9, 0x16161616                  # Build fill value for $16
    sw      $9, 4($8)                       # Initial s0
    
    li      $9, 0x17171717                  # Build fill value for $17
    sw      $9, 8($8)                       # Initial s1

    li      $9, 0x18181818                  # Build fill value for $18
    sw      $9, 12($8)                      # Initial s2

    li      $9, 0x19191919                  # Build fill value for $19
    sw      $9, 16($8)                      # Initial s3
    
    li      $9, 0x20202020                  # Build fill value for $20
    sw      $9, 20($8)                      # Initial s4

    li      $9, 0x21212121                  # Build fill value for $21
    sw      $9, 24($8)                      # Initial s5

    li      $9, 0x22222222                  # Build fill value for $22
    sw      $9, 28($8)                      # Initial s6

    li      $9, 0x23232323                  # Build fill value for $23
    sw      $9, 32($8)                      # Initial s7

    sw      $0, 36($8)                      # reserved
    sw      $0, 40($8)                      # reserved
    sw      $0, 44($8)                      # reserved
    sw      $0, 48($8)                      # reserved
    sw      $0, 52($8)                      # reserved

    li      $9, 0x01010101                  # Build fill value for $1
    sw      $9, 56($8)                      # Initial at

    li      $9, 0x02020202                  # Build fill value for $2
    sw      $9, 60($8)                      # Initial v0
    
    li      $9, 0x03030303                  # Build fill value for $3
    sw      $9, 64($8)                      # Initial v1

    li      $9, 0x04040404                  # Build fill value for $4
    sw      $9, 68($8)                      # Initial a0

    li      $9, 0x05050505                  # Build fill value for $5
    sw      $9, 72($8)                      # Initial a1
    
    li      $9, 0x06060606                  # Build fill value for $6
    sw      $9, 76($8)                      # Initial a2

    li      $9, 0x07070707                  # Build fill value for $7
    sw      $9, 80($8)                      # Initial a3

    li      $9, 0x08080808                  # Build fill value for $8
    sw      $9, 84($8)                      # Initial t0

    li      $9, 0x09090909                  # Build fill value for $9
    sw      $9, 88($8)                      # Initial t1
    
    li      $9, 0x10101010                  # Build fill value for $10
    sw      $9, 92($8)                      # Initial t2

    li      $9, 0x11111111                  # Build fill value for $11
    sw      $9, 96($8)                      # Initial t3
    
    li      $9, 0x12121212                  # Build fill value for $12
    sw      $9, 100($8)                     # Initial t4

    li      $9, 0x13131313                  # Build fill value for $13
    sw      $9, 104($8)                     # Initial t5
    
    li      $9, 0x14141414                  # Build fill value for $14
    sw      $9, 108($8)                     # Initial t6

    li      $9, 0x15151515                  # Build fill value for $15
    sw      $9, 112($8)                     # Initial t7
    
    li      $9, 0x24242424                  # Build fill value for $24
    sw      $9, 116($8)                     # Initial t8
    
    li      $9, 0x25252525                  # Build fill value for $25
    sw      $9, 120($8)                     # Initial t9
    
    li      $9, 0x30303030                  # Build fill value for $30
    sw      $9, 124($8)                     # Initial fp, s8
    
    sw      $0, 128($8)                     # Initial ra
    sw      $0, 132($8)                     # Initial ac0 hi
    sw      $0, 136($8)                     # Initial ac0 lo

    sw      $0, 140($8)                     # Reserved
    mfc0    $9, $12, 2                      # Pickup SRSCtl
    sw      $9, 148($8)                     # Initial SRSCtl
    mfc0    $9, $12                         # Pickup current SR
    ori     $9, $9, INITIAL_SR              # Build initial SR
    sw      $9, 144($8)                     # Initial SR
    sw      $5, 152($8)                     # Initial EPC

    /* Setup stack pointer.  */
    /* thread_ptr -> tx_thread_stack_ptr =  t0;  */

    jr      $31                             # Return to caller
    sw      $8, 8($4)                       # Save stack pointer in thread's 
                                        /*  #   control block  */
/* }  */

