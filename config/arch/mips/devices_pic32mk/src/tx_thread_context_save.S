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
#if ( __mips_micromips == 1 )    
	.set  micromips
#else
    .set  nomicromips
#endif
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
/*    _tx_thread_context_save                          PIC32MZ/Microchip  */ 
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
       out and the stack has the Microchip interrupt XC32 (compiler 1.4x):


                                    (0)    Reserved
                                    (4)    Reserved
                                    (8)    Reserved
                                    (12)   Reserved
                       DSPControl   (16)   Initial DSPControl 
                       $1           (20)   Initial at
                       $2           (24)   Initial v0
                       $3           (28)   Initial v1
                       $4           (32)   Initial a0    
                       $5           (36)   Initial a1    
                       $6           (40)   Initial a2    
                       $7           (44)   Initial a3    
                       $8           (48)   Initial t0    
                       $9           (52)   Initial t1    
                       $10          (56)   Initial t2    
                       $11          (60)   Initial t3    
                       $12          (64)   Initial t4    
                       $13          (68)   Initial t5    
                       $14          (72)   Initial t6    
                       $15          (76)   Initial t7    
                       $24          (80)   Initial t8    
                       $25          (84)   Initial t9    
                       $30          (88)   Initial s8    
                       $31          (92)   Initial ra    
                       ac3          (96)   Initial HI
                       ac3          (100)  Initial LO
                       ac2          (104)  Initial HI
                       ac2          (108)  Initial LO
                       ac1          (112)  Initial HI
                       ac1          (116)  Initial LO
                       ac0          (120)  Initial HI
                       ac0          (124)  Initial LO
                                    (128)  Reserved      
                       SR           (132)  Initial SRSCtl
                       SRSCtl       (136)  Initial status
                       EPC          (140)  Initial EPC        
       
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
 #if defined (__mips_hard_float)
     addiu    $29, $29, -136                  # Allocate additional space for a full stack frame
                                        /*  #   even though the whole thing might
                                            #   not be needed for awhile  */
 #else
     addiu    $29, $29, -40                  # Allocate additional space for a full stack frame
                                        /*  #   even though the whole thing might
                                            #   not be needed for awhile  */
 #endif

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

