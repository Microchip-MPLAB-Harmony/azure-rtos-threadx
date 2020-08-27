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
    #include "tx_thread.h"
    #include "tx_timer.h"  */


    .section .text,code
    .set    noreorder
    .set    noat
    .set    nomicromips
    .set    nomips16

   #ifdef TX_ENABLE_EXECUTION_CHANGE_NOTIFY
   .extern _tx_execution_thread_exit
   #endif
   .extern _tx_thread_current_ptr
   .extern _tx_thread_schedule
   .extern _tx_timer_time_slice
   .extern _tx_thread_system_stack_ptr    

/**************************************************************************/ 
/*                                                                        */ 
/*  FUNCTION                                               RELEASE        */ 
/*                                                                        */ 
/*    _tx_thread_system_return                         PIC32MX/Microchip  */ 
/*                                                           5.0          */ 
/*  AUTHOR                                                                */ 
/*                                                                        */ 
/*    William E. Lamie, Express Logic, Inc.                               */ 
/*                                                                        */ 
/*  DESCRIPTION                                                           */ 
/*                                                                        */ 
/*    This function is target processor specific.  It is used to transfer */ 
/*    control from a thread back to the system.  Only a minimal context   */ 
/*    is saved since the compiler assumes temp registers are going to get */ 
/*    slicked by a function call anyway.                                  */ 
/*                                                                        */ 
/*  INPUT                                                                 */ 
/*                                                                        */ 
/*    None                                                                */ 
/*                                                                        */ 
/*  OUTPUT                                                                */ 
/*                                                                        */ 
/*    None                                                                */ 
/*                                                                        */ 
/*  CALLS                                                                 */ 
/*                                                                        */ 
/*    _tx_thread_schedule                   Thread scheduling loop        */ 
/*                                                                        */ 
/*  CALLED BY                                                             */ 
/*                                                                        */ 
/*    ThreadX components                                                  */ 
/*                                                                        */ 
/*  RELEASE HISTORY                                                       */ 
/*                                                                        */ 
/*    DATE              NAME                      DESCRIPTION             */ 
/*                                                                        */ 
/*  09-01-2014     William E. Lamie         Initial Version 5.0           */ 
/*                                                                        */ 
/**************************************************************************/ 
/* VOID   _tx_thread_system_return(VOID)
{  */
   .globl  _tx_thread_system_return
_tx_thread_system_return:

    /* For a solicited context save, the threads stack will appear as follows:

                                    (0)    Frame Type = 0
                                    (4)    Reserved
                                    (8)    Reserved
                                    (12)   Reserved
                                    (16)   Reserved
                                    (20)   Reserved 
                       $16          (24)   Saved s0
                       $27          (28)   Saved s1
                       $18          (32)   Saved s2 
                       $19          (36)   Saved s3    
                       $20          (40)   Saved s4    
                       $21          (44)   Saved s5    
                       $22          (48)   Saved s6    
                       $23          (52)   Saved s7    
                       $30          (56)   Saved s8, fp
                       $31          (60)   Saved ra    
                       ac0          (64)   Initial HI
                       ac0          (68)   Initial LO
                                    (72)   Reserved      
                       SR           (76)   Initial status  
    */    

    /* Save minimal context on the stack.  */
    
    addiu   $29, $29, -80                   # Allocate space on the stack
    sw      $0, ($29)                       # Solicited stack type

    sw      $16, 24($29)                    # Save s0
    sw      $17, 28($29)                    # Save s1
    sw      $18, 32($29)                    # Save s2
    sw      $19, 36($29)                    # Save s3
    sw      $20, 40($29)                    # Save s4
    sw      $21, 44($29)                    # Save s5
    sw      $22, 48($29)                    # Save s6
    sw      $23, 52($29)                    # Save s7
    sw      $30, 56($29)                    # Save s8, fp
    sw      $31, 60($29)                    # Save ra
    
    mfhi    $8,  $ac0                       # Pickup ac0 hi
    mflo    $9,  $ac0                       # Pickup ac0 lo
    sw      $8,  64($29)                    # Save hi
    sw      $9,  68($29)                    # Save lo

    mfc0    $8, $12                         # Pickup SR    
    sw      $8, 76($29)                     # Save SR

   /* Lockout interrupts.  */

    di                                      # Disable interrupts
    ehb

#ifdef TX_ENABLE_EXECUTION_CHANGE_NOTIFY

    la      $9, _tx_execution_thread_exit   # Build address 
    jal     $9                              # Call the thread execution exit function
    nop                                     # Delay slot
#endif

    la      $9, _tx_thread_current_ptr      # Pickup address of pointer
    lw      $8, ($9)                        # Pickup current thread pointer
    la      $10,_tx_thread_system_stack_ptr # Pickup stack pointer address

    /* Save current stack and switch to system stack.  */
    /* _tx_thread_current_ptr -> tx_thread_stack_ptr =  SP;
    SP = _tx_thread_system_stack_ptr;  */

    sw      $29, 8($8)                      # Save stack pointer
    lw      $29, ($10)                      # Switch to system stack

    /* Determine if the time-slice is active.  */
    /* if (_tx_timer_time_slice)
    {  */

    la      $13, _tx_timer_time_slice       # Pickup time slice variable addr
    lw      $11, ($13)                      # Pickup time slice value
    la      $12, _tx_thread_schedule        # Pickup address of scheduling loop
    beqz    $11, _tx_thread_dont_save_ts    # If no time-slice, don't save it
    nop                                     # Delay slot

    /* Save time-slice for the thread and clear the current time-slice.  */
    /* _tx_thread_current_ptr -> tx_thread_time_slice =  _tx_timer_time_slice;
    _tx_timer_time_slice =  0;  */

    sw      $11, 24($8)                     # Save current time-slice for thread
    sw      $0, ($13)                       # Clear time-slice variable

    /* }  */
_tx_thread_dont_save_ts:

    /* Clear the current thread pointer.  */
    /* _tx_thread_current_ptr =  TX_NULL;  */

    jr      $12                             # Return to thread scheduler
    sw      $0, ($9)                        # Clear current thread pointer

/* }  */

