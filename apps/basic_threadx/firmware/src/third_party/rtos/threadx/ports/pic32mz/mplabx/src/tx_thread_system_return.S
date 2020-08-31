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
    #include "tx_cpu.inc"

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
/*    _tx_thread_system_return                         PIC32MZ/Microchip  */ 
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

    /* For a solicited context save, the threads stack without FPU will appear 
       as follows:

                                    (0)    Frame Type = 0
                                    (4)    Reserved
                                    (8)    Reserved
                                    (12)   Reserved
                                    (16)   Reserved
                       DSPControl   (20)   DSPControl 
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
                       ac3          (64)   Initial HI
                       ac3          (68)   Initial LO
                       ac2          (72)   Initial HI
                       ac2          (76)   Initial LO
                       ac1          (80)   Initial HI
                       ac1          (84)   Initial LO
                       ac0          (88)   Initial HI
                       ac0          (92)   Initial LO
                                    (96)   Reserved      
                       SR           (100)  Initial status  
    */    
    /* For a solicited context save, the threads stack with FPU will appear 
       as follows:

                                    (0)    Frame Type = 0
                                    (4)    Reserved
                                    (8)    Reserved
                                    (12)   Reserved
                                    (16)   Reserved
                       DSPControl   (20)   DSPControl 
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
                       ac3          (64)   Initial HI
                       ac3          (68)   Initial LO
                       ac2          (72)   Initial HI
                       ac2          (76)   Initial LO
                       ac1          (80)   Initial HI
                       ac1          (84)   Initial LO
                       ac0          (88)   Initial HI
                       ac0          (92)   Initial LO
                       FCSR         (96)   FCSR      
                       SR           (100)  Initial status
                       $f20         (104)    Initial f20  
                       $f21         (112)    Initial f21 
                       $f22         (120)    Initial f22  
                       $f23         (128)    Initial f23  
                       $f24         (136)    Initial f24    
                       $f25         (144)    Initial f25      
                       $f26         (152)    Initial f26 
                       $f27         (160)    Initial f27  
                       $f28         (168)   Initial f28 
                       $f29         (176)   Initial f29        
                       $f30         (184)   Initial f30 
                       $f31         (192)   Initial f31          
    */    

    /* Save minimal context on the stack.  */
#if defined (__mips_hard_float)
    
    addiu   $29, $29, -104                  # Allocate space on the stack
    
    la      $9, _tx_thread_current_ptr      # Pickup address of pointer
    lw      $8, ($9)                        # Set current thread pointer
    lw      $10, 144($8)                    # Check the status of FPU Enable Flag
    beq	    $10, $0, 1f   
    nop
    addiu   $29, $29, -96                   # Allocate additional space on the stack
    1:
#else
    addiu   $29, $29, -104                  # Allocate space on the stack
#endif    

#if ( __mips_micromips == 1)    
    
    sw      $0, ($29)                       # Solicited stack type
    rddsp   $8,  31                         # Pickup DSPControl
    swm32   $16-$23,$16,MINIMAL_STACK_OFFSET_S0($29)    # Store s0-s7
    sw      $8,  MINIMAL_STACK_OFFSET_DSPC($29)         # Save DSPControl
    sw      $30, MINIMAL_STACK_OFFSET_S8($29)           # Save s8, fp
    sw      $31, MINIMAL_STACK_OFFSET_RA($29)           # Save ra
    
    mfhi    $8,  $ac3                       		# Pickup ac3 hi
    mflo    $9,  $ac3                       		# Pickup ac3 lo
    swp      $8,  MINIMAL_STACK_OFFSET_HI3($29)         # Save hi, lo

    mfhi    $8,  $ac2                       		# Pickup ac2 hi
    mflo    $9,  $ac2                       		# Pickup ac2 lo
    swp      $8,  MINIMAL_STACK_OFFSET_HI2($29)         # Save hi, lo

    mfhi    $8,  $ac1                       		# Pickup ac1 hi
    mflo    $9,  $ac1                       		# Pickup ac1 lo
    swp      $8,  MINIMAL_STACK_OFFSET_HI1($29)         # Save hi, lo

    mfhi    $8,  $ac0                       		# Pickup ac0 hi
    mflo    $9,  $ac0                       		# Pickup ac0 lo
    swp      $8,  MINIMAL_STACK_OFFSET_HI0($29)         # Save hi, lo
    
    mfc0    $8, $12                         		# Pickup SR
    sw      $8, MINIMAL_STACK_OFFSET_SR($29)            # Save SR
    
#else
    sw      $0, ($29)                       		# Solicited stack type
    rddsp   $8,  31                         		# Pickup DSPControl
    sw      $16, MINIMAL_STACK_OFFSET_S0($29)           # Save s0
    sw      $8,  MINIMAL_STACK_OFFSET_DSPC($29)         # Save DSPControl
    sw      $17, MINIMAL_STACK_OFFSET_S1($29)           # Save s1
    sw      $18, MINIMAL_STACK_OFFSET_S2($29)           # Save s2
    sw      $19, MINIMAL_STACK_OFFSET_S3($29)           # Save s3
    sw      $20, MINIMAL_STACK_OFFSET_S4($29)           # Save s4
    sw      $21, MINIMAL_STACK_OFFSET_S5($29)           # Save s5
    sw      $22, MINIMAL_STACK_OFFSET_S6($29)           # Save s6
    sw      $23, MINIMAL_STACK_OFFSET_S7($29)           # Save s7
    sw      $30, MINIMAL_STACK_OFFSET_S8($29)           # Save s8, fp
    sw      $31, MINIMAL_STACK_OFFSET_RA($29)           # Save ra
    
    mfhi    $8,  $ac3                       		# Pickup ac3 hi
    mflo    $9,  $ac3                       		# Pickup ac3 lo
    sw      $8,  MINIMAL_STACK_OFFSET_HI3($29)          # Save hi
    sw      $9,  MINIMAL_STACK_OFFSET_LO3($29)          # Save lo

    mfhi    $8,  $ac2                       		# Pickup ac2 hi
    mflo    $9,  $ac2                       		# Pickup ac2 lo
    sw      $8,  MINIMAL_STACK_OFFSET_HI2($29)          # Save hi
    sw      $9,  MINIMAL_STACK_OFFSET_LO2($29)          # Save lo

    mfhi    $8,  $ac1                       		# Pickup ac1 hi
    mflo    $9,  $ac1                       		# Pickup ac1 lo
    sw      $8,  MINIMAL_STACK_OFFSET_HI1($29)          # Save hi
    sw      $9,  MINIMAL_STACK_OFFSET_LO1($29)          # Save lo

    mfhi    $8,  $ac0                       		# Pickup ac0 hi
    mflo    $9,  $ac0                       		# Pickup ac0 lo
    sw      $8,  MINIMAL_STACK_OFFSET_HI0($29)          # Save hi
    sw      $9,  MINIMAL_STACK_OFFSET_LO0($29)          # Save lo
    
    mfc0    $8, $12                         		# Pickup SR
    sw      $8, MINIMAL_STACK_OFFSET_SR($29)            # Save SR
    
#endif /* #if ( __mips_micromips == 1 ) */    
#if defined (__mips_hard_float)    
    la      $9, _tx_thread_current_ptr      # Pickup address of pointer
    lw      $8, ($9)                        # Set current thread pointer
    lw      $10, 144($8)                    # Set current thread pointer
    beq	    $10, $0, 1f
    nop

    CFC1    $8,$f31			    		# Save FCSR
    sw	    $8,MINIMAL_STACK_OFFSET_FCSR($29)
    
    SDC1    $f20, MINIMAL_STACK_OFFSET_F20($29)		# Save f20
    SDC1    $f21, MINIMAL_STACK_OFFSET_F21($29)		# Save f21
    SDC1    $f22, MINIMAL_STACK_OFFSET_F22($29)		# Save f22
    SDC1    $f23, MINIMAL_STACK_OFFSET_F23($29)		# Save f23
    SDC1    $f24, MINIMAL_STACK_OFFSET_F24($29)		# Save f24
    SDC1    $f25, MINIMAL_STACK_OFFSET_F25($29)		# Save f25
    SDC1    $f26, MINIMAL_STACK_OFFSET_F26($29)		# Save f26
    SDC1    $f27, MINIMAL_STACK_OFFSET_F27($29)		# Save f27
    SDC1    $f28, MINIMAL_STACK_OFFSET_F28($29)		# Save f28
    SDC1    $f29, MINIMAL_STACK_OFFSET_F29($29)		# Save f29
    SDC1    $f30, MINIMAL_STACK_OFFSET_F30($29)		# Save f30
    SDC1    $f31, MINIMAL_STACK_OFFSET_F31($29)		# Save f31
#endif    
1:
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

