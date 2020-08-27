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
   .extern _tx_execution_isr_exit
   #endif
   .extern _tx_thread_system_state
   .extern _tx_thread_current_ptr
   .extern _tx_thread_preempt_disable
   .extern _tx_thread_execute_ptr
   .extern _tx_thread_schedule
   .extern _tx_timer_time_slice

/**************************************************************************/ 
/*                                                                        */ 
/*  FUNCTION                                               RELEASE        */ 
/*                                                                        */ 
/*    _tx_thread_context_restore                       PIC32MX/Microchip  */ 
/*                                                           5.0          */ 
/*  AUTHOR                                                                */ 
/*                                                                        */ 
/*    William E. Lamie, Express Logic, Inc.                               */ 
/*                                                                        */ 
/*  DESCRIPTION                                                           */ 
/*                                                                        */ 
/*    This function restores the interrupt context if it is processing a  */ 
/*    nested interrupt.  If not, it returns to the interrupt thread if no */ 
/*    preemption is necessary.  Otherwise, if preemption is necessary or  */ 
/*    if no thread was running, the function returns to the scheduler.    */ 
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
/*    _tx_thread_schedule                   Thread scheduling routine     */ 
/*                                                                        */ 
/*  CALLED BY                                                             */ 
/*                                                                        */ 
/*    ISRs                                  Interrupt Service Routines    */ 
/*                                                                        */ 
/*  RELEASE HISTORY                                                       */ 
/*                                                                        */ 
/*    DATE              NAME                      DESCRIPTION             */ 
/*                                                                        */ 
/*  09-01-2014     William E. Lamie         Initial Version 5.0           */ 
/*                                                                        */ 
/**************************************************************************/ 
/* VOID   _tx_thread_context_restore(VOID)
{  */
   .globl  _tx_thread_context_restore
_tx_thread_context_restore:

    /* Lockout interrupts.  */

    di                                          # Disable interrupts
    ehb

#ifdef TX_ENABLE_EXECUTION_CHANGE_NOTIFY
    addu    $26, $31, $0                        # Save return address
    la      $8, _tx_execution_isr_exit          # Build address 
    jal     $8                                  # Call the ISR execution exit function
    nop                                         # Delay slot
    addu    $31, $26, $0                        # Recover return address    
#endif

    /* Determine if interrupts are nested.  */
    /* if (--_tx_thread_system_state != 0 )
    {  */

    la      $9, _tx_thread_system_state         # Pickup addr of nested interrupt count
    lw      $8, ($9)                            # Pickup nested interrupt count
    addiu   $8, $8, -1                          # Decrement the nested interrupt counter
    beq     $8, $0, _tx_thread_not_nested_restore  # If 0, not nested restore
    sw      $8, ($9)                            # Store new nested count
    
_tx_thread_nested_restore:

    /* Interrupts are nested.  */

    /* return to the point of interrupt.  Let code inserted by XC32 compiler 
    restore registers from interrupt frame. In this case we did not make room
    for the extra 36 bytes on the stack frame.  So the offsets used by the 
    compiler are valid.*/
    jr      $31
    nop
    
    /* }  */
_tx_thread_not_nested_restore:

    /* Determine if a thread was interrupted and no preemption is required.  */
    /* else if (((_tx_thread_current_ptr) && (_tx_thread_current_ptr == _tx_thread_execute_ptr) 
               || (_tx_thread_preempt_disable))
    {  */

    la      $9, _tx_thread_current_ptr          # Pickup address of current thread pointer
    lw      $8, ($9)                            # Pickup current thread pointer
    beqz    $8, _tx_thread_idle_system_restore  # If NULL, idle system restore
    nop

    /* Must do a secondary check, to make sure we are not really nested because
       of the following: 
        1. An interrupt occurs right after the compiler's inserted ISR prologue, but 
           before _tx_thread_context_save() is actually called. 
        2. An OS aware interrupt, interrupts or nests on an OS unaware interrupt.
    */

    lw      $10, 8($8)                          # Pickup the current thread SP
    lw      $10, 144($10)                       # Pickup saved SR value    
    andi    $11, $10, 0xFC00                    # Inspect IPL value
    bgtz    $11, _tx_thread_no_preempt_restore  # If not zero, must be nested
    nop
   
    la      $13, _tx_thread_preempt_disable     # Pickup address of preempt disable flag    
    lw      $12, ($13)                          # Pickup preempt disable flag
    la      $11, _tx_thread_execute_ptr         # Pickup address of execute thread pointer
    lw      $10, ($11)                          # Pickup thread execute pointer
    bgtz    $12, _tx_thread_no_preempt_restore  # If set, restore interrupted thread
    nop                                         # Delay slot
    bne     $8, $10, _tx_thread_preempt_restore # If higher-priority thread is ready, preempt
    nop                                         # Delay slot



_tx_thread_no_preempt_restore:

    /* Restore interrupted thread */

    /* Pickup the saved stack pointer.  */
    /* SP =  _tx_thread_current_ptr -> tx_thread_stack_ptr;  */

    lw      $29, 8($8)                          # Switch back to thread's stack

    /* Recover the saved context and return to the point of interrupt.  */

    /* Recover standard registers.  */

    lw      $8,  152($29)                       # Recover EPC
    lw      $9,  144($29)                       # Recover SR
    mtc0    $8,  $14                            # Setup EPC
    lw      $30, 124($29)                       # Recover s8
    mtc0    $9,  $12                            # Restore SR

    lw      $8,  132($29)                       # Recover hi
    lw      $9,  136($29)                       # Recover low
    mthi    $8                                  # Setup hi
    mtlo    $9                                  # Setup lo

    lw      $1,  56($29)                        # Recover at
    lw      $2,  60($29)                        # Recover v0
    lw      $3,  64($29)                        # Recover v1
    lw      $4,  68($29)                        # Recover a0
    lw      $5,  72($29)                        # Recover a1
    lw      $6,  76($29)                        # Recover a2
    lw      $7,  80($29)                        # Recover a3
    lw      $8,  84($29)                        # Recover t0
    lw      $9,  88($29)                        # Recover t1
    lw      $10, 92($29)                        # Recover t2
    lw      $11, 96($29)                        # Recover t3
    lw      $12, 100($29)                       # Recover t4
    lw      $13, 104($29)                       # Recover t5
    lw      $14, 108($29)                       # Recover t6
    lw      $15, 112($29)                       # Recover t7
    lw      $24, 116($29)                       # Recover t8
    lw      $25, 120($29)                       # Recover t9
    lw      $31, 128($29)                       # Recover ra 
    addiu   $29, $29, 156                       # Recover stack frame
    eret                                        # Return to point of interrupt

    /* }
    else
    {  */
_tx_thread_preempt_restore:

    /* Save remaining context on the thread's stack.  */
    /* $9 = _tx_thread_current_ptr -> tx_thread_stack_ptr;  */
    lw      $9, 8($8)                           # Pickup thread's stack pointer
    ori     $12, $0, 1                          # Build interrupt stack type
    sw      $12, ($9)                           # Store stack type

    /* Store standard preserved registers.  */

    sw      $16, 4($9)                          # Store s0
    sw      $17, 8($9)                          # Store s1
    sw      $18, 12($9)                         # Store s2
    sw      $19, 16($9)                         # Store s3
    sw      $20, 20($9)                         # Store s4
    sw      $21, 24($9)                         # Store s5
    sw      $22, 28($9)                         # Store s6
    sw      $23, 32($9)                         # Store s7

    /* Save the remaining time-slice and disable it.  */
    /* if (_tx_timer_time_slice)
    {  */

    la      $10, _tx_timer_time_slice           # Pickup time slice variable address
    lw      $9, ($10)                           # Pickup time slice
    la      $12, _tx_thread_current_ptr         # Pickup current thread pointer address
    beqz    $9, _tx_thread_dont_save_ts         # If 0, skip time slice processing
    nop                                         # Delay slot

        /* _tx_thread_current_ptr -> tx_thread_time_slice =  _tx_timer_time_slice
        _tx_timer_time_slice =  0;  */

    sw      $9, 24($8)                          # Save current time slice
    sw      $0, ($10)                           # Clear global time slice


    /* }  */
_tx_thread_dont_save_ts:


    /* Clear the current task pointer.  */
    /* _tx_thread_current_ptr =  TX_NULL;  */

    sw      $0, ($12)                           # Clear current thread pointer

    /* Return to the scheduler.  */
    /* _tx_thread_schedule();  */

    la      $8, _tx_thread_schedule             # Build address of scheduling loop
    mtc0    $8, $14                             # Setup EPC
    ehb
    eret                                        # Interrupt return to scheduling loop

    /* }  */

_tx_thread_idle_system_restore:

    lw      $10, 108($29)                       # Recover SR

    /* Must do a secondary check, to make sure we are not really nested because
       of the following: 
        1. An interrupt occurs right after the compiler's inserted ISR prologue, but 
           before _tx_thread_context_save() is actually called. 
        2. An OS aware interrupt, interrupts or nests on an OS unaware interrupt.
    */
    
    andi    $11, $10, 0xFC00                    # Inspect IPL value
    bgtz    $11, _tx_thread_nested_restore      # If not zero, must be nested
    nop    
    
    /*Not nested, just return back to the scheduler! */
    mtc0    $10, $12                            # Setup SR
    ehb
    la      $8, _tx_thread_schedule             # Build address of scheduling loop
    mtc0    $8, $14                             # Setup EPC
    ehb
    addiu   $29, $29, 120                       # Recover stack frame
    eret                                        # Interrupt return to scheduling loop

/* }  */

