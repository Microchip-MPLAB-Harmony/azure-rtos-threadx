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
   .extern _tx_execution_isr_enter
#endif
   .extern _tx_thread_system_state
   .extern _tx_thread_current_ptr
   .extern _tx_thread_system_stack_ptr

/**************************************************************************/ 
/*                                                                        */ 
/*  FUNCTION                                               RELEASE        */ 
/*                                                                        */ 
/*    _tx_thread_context_save                          PIC32MX/Microchip  */ 
/*                                                           5.0          */ 
/*  AUTHOR                                                                */ 
/*                                                                        */ 
/*    William E. Lamie, Express Logic, Inc.                               */ 
/*                                                                        */ 
/*  DESCRIPTION                                                           */ 
/*                                                                        */ 
/*    This function saves the context of an executing thread in the       */ 
/*    beginning of interrupt processing.  The function also ensures that  */ 
/*    the system stack is used upon return to the calling ISR.            */ 
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
/*    None                                                                */ 
/*                                                                        */ 
/*  CALLED BY                                                             */ 
/*                                                                        */ 
/*    ISRs                                                                */ 
/*                                                                        */ 
/*  RELEASE HISTORY                                                       */ 
/*                                                                        */ 
/*    DATE              NAME                      DESCRIPTION             */ 
/*                                                                        */ 
/*  09-01-2014     William E. Lamie         Initial Version 5.0           */ 
/*                                                                        */ 
/**************************************************************************/ 
/* VOID   _tx_thread_context_save(VOID)
{  */
   .globl _tx_thread_context_save
_tx_thread_context_save:

    di                                      # Lockout interrupts
    ehb

    /* Upon entry to this routine, it is assumed that interrupts are locked
       out and the stack has the Microchip interrupt XC32 (compiler 1.3x):


                               (0)    Reserved
                               (4)    Reserved
                               (8)    Reserved
                               (12)   Reserved
                               (16)   Reserved
                       $1      (20)   Interrupted at
                       $2      (24)   Interrupted v0
                       $3      (28)   Interrupted v1
                       $4      (32)   Interrupted a0    
                       $5      (36)   Interrupted a1    
                       $6      (40)   Interrupted a2    
                       $7      (44)   Interrupted a3    
                       $8      (48)   Interrupted t0    
                       $9      (52)   Interrupted t1    
                       $10     (56)   Interrupted t2    
                       $11     (60)   Interrupted t3    
                       $12     (64)   Interrupted t4    
                       $13     (68)   Interrupted t5    
                       $14     (72)   Interrupted t6    
                       $15     (76)   Interrupted t7    
                       $24     (80)   Interrupted t8    
                       $25     (84)   Interrupted t9    
                       $30     (88)   Interrupted s8    
                       $31     (92)   Interrupted ra    
                       hi      (96)   Interrupted HI    
                       lo      (100)  Interrupted LO    
                               (104)  Reserved     
                       SR      (108)  Interrupt status                                 
                       SRSCtl  (112)  Interrupted SRSCtl
                       EPC     (116)  Interrupt EPC         
       
         */

    la      $26, _tx_thread_system_state    # Pickup address of system state
    lw      $8, ($26)                       # Pickup system state

    /* Check for a nested interrupt condition.  */
    /* if (_tx_thread_system_state++)
    {  */

    beqz    $8, _tx_thread_not_nested_save  # If 0, first interrupt condition
    addiu   $8, $8, 1                       # Increment the nested interrupt counter


    /* Nested interrupt condition.  */

    sw      $8, ($26)                       # Store the interrupt counter

#ifdef TX_ENABLE_EXECUTION_CHANGE_NOTIFY

    addu    $26, $31, $0                    # Save return address
    la      $8, _tx_execution_isr_enter     # Build address 
    jal     $8                              # Call the ISR execution enter function
    nop                                     # Delay slot
    addu    $31, $26, $0                    # Recover return address
#endif

    /* Return to the ISR.  */

    jr      $31                             # Return to ISR
    nop

_tx_thread_not_nested_save:
    /* }  */

    /* Otherwise, not nested, check to see if a thread was running.  */
    /* else if (_tx_thread_current_ptr)
    {  */
    sw      $8, ($26)                       # Store the interrupt counter
    la      $26, _tx_thread_current_ptr     # Pickup address of current ptr
    lw      $8, ($26)                       # Pickup current thread pointer
    beqz    $8, _tx_thread_idle_system_save # If NULL, idle system was interrupted
    nop                                     # Delay slot
    
    /*only allocate extra bytes on stack frame if first time through and 
    _tx_thread_schedule_loop was not interrupted*/
    addiu    $29, $29, -36                  # Allocate additional space for a full stack frame
                                        /*  #   even though the whole thing might
                                            #   not be needed for awhile  */
    /* Save the current stack pointer in the thread's control block.  */
    /* _tx_thread_current_ptr -> tx_thread_stack_ptr =  sp;  */
    sw      $29, 8($8)                      # Save stack pointer

#ifdef TX_ENABLE_EXECUTION_CHANGE_NOTIFY

    addu    $26, $31, $0                    # Save return address
    la      $8, _tx_execution_isr_enter     # Build address 
    jal     $8                              # Call the ISR execution enter function
    nop                                     # Delay slot
    addu    $31, $26, $0                    # Recover return address
#endif

    /* Switch to the system stack and return*/
    /* sp =  _tx_thread_system_stack_ptr;  */
    la      $10,_tx_thread_system_stack_ptr # Pickup the stack pointer address    
    jr      $31                             # Return to caller
    lw      $29, ($10)                      # Switch to system stack
    /* }
    else
    {  */

_tx_thread_idle_system_save:


#ifdef TX_ENABLE_EXECUTION_CHANGE_NOTIFY

    addu    $26, $31, $0                    # Save return address
    la      $8, _tx_execution_isr_enter     # Build address 
    jal     $8                              # Call the ISR execution enter function
    nop                                     # Delay slot
    addu    $31, $26, $0                    # Recover return address
#endif

    /* Interrupt occurred in the scheduling loop.  */

    jr      $31                             # Return to ISR processing
    nop                                     # Delay slot

    /* }
}  */

