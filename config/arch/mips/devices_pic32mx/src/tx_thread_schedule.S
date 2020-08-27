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

   .extern _tx_thread_current_ptr
   .extern _tx_thread_execute_ptr
   .extern _tx_timer_time_slice
   #ifdef TX_ENABLE_EXECUTION_CHANGE_NOTIFY
   .extern _tx_execution_thread_enter
   #endif

/**************************************************************************/ 
/*                                                                        */ 
/*  FUNCTION                                               RELEASE        */ 
/*                                                                        */ 
/*    _tx_thread_schedule                              PIC32MX/Microchip  */ 
/*                                                           5.0          */ 
/*  AUTHOR                                                                */ 
/*                                                                        */ 
/*    William E. Lamie, Express Logic, Inc.                               */ 
/*                                                                        */ 
/*  DESCRIPTION                                                           */ 
/*                                                                        */ 
/*    This function waits for a thread control block pointer to appear in */ 
/*    the _tx_thread_execute_ptr variable.  Once a thread pointer appears */ 
/*    in the variable, the corresponding thread is resumed.               */ 
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
/*    _tx_initialize_kernel_enter          ThreadX entry function         */ 
/*    _tx_thread_system_return             Return to system from thread   */ 
/*    _tx_thread_context_restore           Restore thread's context       */ 
/*                                                                        */ 
/*  RELEASE HISTORY                                                       */ 
/*                                                                        */ 
/*    DATE              NAME                      DESCRIPTION             */ 
/*                                                                        */ 
/*  09-01-2014     William E. Lamie         Initial Version 5.0           */ 
/*                                                                        */ 
/**************************************************************************/ 
/* VOID   _tx_thread_schedule(VOID)
{  */
   .globl  _tx_thread_schedule
_tx_thread_schedule:
    
    /* Clear IPL bits.  */

    di                                      # Disable interrupts
    ehb
    
    mfc0    $10, $12, 0                     # Pickup current IPL value
    ins     $10, $0, 10, 6                  # Clear IPL bits IPL15:10
    mtc0    $10, $12, 0                     # Setup IPL bits
    ehb 
    
    ei 

    /* Wait for a thread to execute.  */
    /* do
    {  */

    la      $9, _tx_thread_execute_ptr      # Pickup address of execute ptr
_tx_thread_schedule_loop:

    lw      $8, ($9)                        # Pickup next thread to execute
    nop                                     # Delay slot
    beqz    $8, _tx_thread_schedule_loop    # If NULL, wait for thread to execute
    nop                                     # Delay slot

    /* }
    while(_tx_thread_execute_ptr == TX_NULL);  */
    
    /* Yes! We have a thread to execute.  Lockout interrupts and
       transfer control to it.  */

    di                                      # Disable interrupts
    ehb

    /* Setup the current thread pointer.  */
    /* _tx_thread_current_ptr =  _tx_thread_execute_ptr;  */

    la      $9, _tx_thread_current_ptr      # Pickup current thread pointer address
    sw      $8, ($9)                        # Set current thread pointer

    /* Increment the run count for this thread.  */
    /* _tx_thread_current_ptr -> tx_thread_run_count++;  */

    lw      $10, 4($8)                      # Pickup run count
    lw      $11, 24($8)                     # Pickup time slice value
    addiu   $10, $10, 1                     # Increment run count
    sw      $10, 4($8)                      # Store new run count

    /* Setup time-slice, if present.  */
    /* _tx_timer_time_slice =  _tx_thread_current_ptr -> tx_thread_time_slice;  */

    la      $10, _tx_timer_time_slice       # Pickup time-slice variable address

    /* Switch to the thread's stack.  */
    /* SP =  _tx_thread_execute_ptr -> tx_thread_stack_ptr;  */

    lw      $29, 8($8)                      # Switch to thread's stack
    sw      $11, ($10)                      # Store new time-slice

#ifdef TX_ENABLE_EXECUTION_CHANGE_NOTIFY

    la      $9, _tx_execution_thread_enter  # Build address 
    jal     $9                              # Call the thread execution enter function
    nop                                     # Delay slot
#endif

    /* Determine if an interrupt frame or a synchronous task suspension frame
       is present.  */

    lw      $10, ($29)                      # Pickup stack type
    beqz    $10, _tx_thread_synch_return    # If 0, solicited thread return
    nop                                     # Delay slot

    /* Recover interrupt frame registers.  */

    lw      $8,  152($29)                   # Recover EPC
    lw      $9,  144($29)                   # Recover SR
    mtc0    $8,  $14                        # Setup EPC
    lw      $30, 124($29)                   # Recover s0
    mtc0    $9,  $12                        # Restore SR
    lw      $16, 4($29)                     # Recover s1
    lw      $17, 8($29)                     # Recover s2
    lw      $18, 12($29)                    # Recover s3
    lw      $19, 16($29)                    # Recover s4
    lw      $20, 20($29)                    # Recover s5
    lw      $21, 24($29)                    # Recover s6
    lw      $22, 28($29)                    # Recover s7
    lw      $23, 32($29)                    # Recover s8, fp

    lw      $8,  132($29)                   # Recover hi
    lw      $9,  136($29)                   # Recover low
    mthi    $8                              # Setup hi
    mtlo    $9                              # Setup lo

    lw      $1,  56($29)                    # Recover at
    lw      $2,  60($29)                    # Recover v0
    lw      $3,  64($29)                    # Recover v1
    lw      $4,  68($29)                    # Recover a0
    lw      $5,  72($29)                    # Recover a1
    lw      $6,  76($29)                    # Recover a2
    lw      $7,  80($29)                    # Recover a3
    lw      $8,  84($29)                    # Recover t0
    lw      $9,  88($29)                    # Recover t1
    lw      $10, 92($29)                    # Recover t2
    lw      $11, 96($29)                    # Recover t3
    lw      $12, 100($29)                   # Recover t4
    lw      $13, 104($29)                   # Recover t5
    lw      $14, 108($29)                   # Recover t6
    lw      $15, 112($29)                   # Recover t7
    lw      $24, 116($29)                   # Recover t8
    lw      $25, 120($29)                   # Recover t9
    lw      $31, 128($29)                   # Recover ra
    addiu   $29, $29, 156                   # Recover stack frame
    eret                                    # Return to point of interrupt

_tx_thread_synch_return:

   /* Recover standard preserved registers.  */

    lw      $30, 56($29)                    # Recover s8, fp
    lw      $23, 52($29)                    # Recover s7
    lw      $22, 48($29)                    # Recover s6
    lw      $21, 44($29)                    # Recover s5
    lw      $20, 40($29)                    # Recover s4
    lw      $19, 36($29)                    # Recover s3
    lw      $18, 32($29)                    # Recover s2
    lw      $17, 28($29)                    # Recover s1
    lw      $16, 24($29)                    # Recover s0
    
    lw      $8,  64($29)                    # Recover hi
    lw      $9,  68($29)                    # Recover low
    mthi    $8                              # Setup hi
    mtlo    $9                              # Setup lo
    
    lw      $8,  76($29)                    # Recover SR
    lw      $31, 60($29)                    # Recover ra
    addiu   $29, $29, 80                    # Recover stack space
    
    mtc0    $8, $12                         # Restore SR
    jr.hb   $31                             # Return to thread
    nop                                     # Delay slot

/* }  */

