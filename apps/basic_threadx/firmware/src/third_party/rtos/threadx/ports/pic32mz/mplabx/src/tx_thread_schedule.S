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
#include "tx_cpu.inc"
#include <xc.h>
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
/*    _tx_thread_schedule                              PIC32MZ/Microchip  */ 
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
    
    mfc0    $10, $12, 4                     # Pickup current IPL value
    ins     $10, $0, 2, 8                   # Clear IPL bits IPL9:2
    mtc0    $10, $12, 4                     # Setup IPL bits
    ehb 
    
    ei                                      # Enable interrupts 
    
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

    lw      $8,  STACK_OFFSET_EPC($29)      # Recover EPC
    lw      $9,  STACK_OFFSET_SR($29)       # Recover SR
    mtc0    $8,  $14                        # Recover fp, s8
    mtc0    $9,  $12                        # Setup EPC
    lw      $30, STACK_OFFSET_S8($29)       # Restore SR

#if ( __mips_micromips == 1 )    
    lwm32   $16-$23,$16,STACK_OFFSET_S0($29)  # Recover s0-s7

    lw      $8,  STACK_OFFSET_DSPC($29)     # Recover DSPControl
    wrdsp   $8,  31                         # Setup DSPControl 
        
    lwp     $8,  STACK_OFFSET_HI0($29)      # Recover ac0 low,hi
    mthi    $8,  $ac0                       # Setup ac0 lo
    mtlo    $9,  $ac0                       # Setup ac0 hi
   
    lwp     $8,  STACK_OFFSET_HI1($29)      # Recover ac1 low,hi
    mthi    $8,  $ac1                       # Setup ac1 lo
    mtlo    $9,  $ac1                       # Setup ac1 hi
    
    lwp     $8,  STACK_OFFSET_HI2($29)      # Recover ac2 low,hi
    mthi    $8,  $ac2                       # Setup ac2 lo
    mtlo    $9,  $ac2                       # Setup ac2 hi
   
    
    lwp     $8,  STACK_OFFSET_HI3($29)      # Recover ac3 hi,low
    mthi    $8,  $ac3                       # Setup ac3 lo
    mtlo    $9,  $ac3                       # Setup ac3 hi
    
    #if defined (__mips_hard_float)
    lw	    $8,  STACK_OFFSET_FCSR($29)	    # Setup FCSR
    CTC1    $8,$f31
    #endif
    
    lwp      $1,  STACK_OFFSET_AT($29)      # Recover at,v0
    lwp      $3,  STACK_OFFSET_V1($29)      # Recover v1,a0
    lwp      $5,  STACK_OFFSET_A1($29)      # Recover a1,a2
    lwp      $7,  STACK_OFFSET_A3($29)      # Recover a3,t0
    lwp      $9,  STACK_OFFSET_T1($29)      # Recover t1,t2
    lwp      $11, STACK_OFFSET_T3($29)      # Recover t3,t4
    lwp      $13, STACK_OFFSET_T5($29)      # Recover t5,t6
    lw       $15, STACK_OFFSET_T7($29)      # Recover t7
    lwp      $24, STACK_OFFSET_T8($29)      # Recover t8,t9
    lw       $31, STACK_OFFSET_RA($29)      # Recover ra
#else
    lw      $16, STACK_OFFSET_S0($29)       # Recover s0
    lw      $17, STACK_OFFSET_S1($29)       # Recover s1
    lw      $18, STACK_OFFSET_S2($29)       # Recover s2
    lw      $19, STACK_OFFSET_S3($29)       # Recover s3
    lw      $20, STACK_OFFSET_S4($29)       # Recover s4
    lw      $21, STACK_OFFSET_S5($29)       # Recover s5
    lw      $22, STACK_OFFSET_S6($29)       # Recover s6
    lw      $23, STACK_OFFSET_S7($29)       # Recover s7

    lw      $8,  STACK_OFFSET_DSPC($29)     # Recover DSPControl
    wrdsp   $8,  31                         # Setup DSPControl 
        
    lw      $8,  STACK_OFFSET_HI0($29)      # Recover ac0 hi
    lw      $9,  STACK_OFFSET_LO0($29)      # Recover ac0 low
    mthi    $8,  $ac0                       # Setup ac0 hi
    mtlo    $9,  $ac0                       # Setup ac0 lo
    lw      $8,  STACK_OFFSET_HI1($29)      # Recover ac1 hi
    lw      $9,  STACK_OFFSET_LO1($29)      # Recover ac1 low
    mthi    $8,  $ac1                       # Setup ac1 hi
    mtlo    $9,  $ac1                       # Setup ac1 lo
    lw      $8,  STACK_OFFSET_HI2($29)      # Recover ac2 hi
    lw      $9,  STACK_OFFSET_LO2($29)      # Recover ac2 low
    mthi    $8,  $ac2                       # Setup ac2 hi
    mtlo    $9,  $ac2                       # Setup ac2 lo
    lw      $8,  STACK_OFFSET_HI3($29)      # Recover ac3 hi
    lw      $9,  STACK_OFFSET_LO3($29)      # Recover ac3 low
    mthi    $8,  $ac3                       # Setup ac3 hi
    mtlo    $9,  $ac3                       # Setup ac3 lo
    #if defined (__mips_hard_float)
    lw	    $8,  STACK_OFFSET_FCSR($29)     # Setup FCSR
    CTC1    $8,$f31
    #endif
    lw      $1,  STACK_OFFSET_AT($29)       # Recover at
    lw      $2,  STACK_OFFSET_V0($29)       # Recover v0
    lw      $3,  STACK_OFFSET_V1($29)       # Recover v1
    lw      $4,  STACK_OFFSET_A0($29)       # Recover a0
    lw      $5,  STACK_OFFSET_A1($29)       # Recover a1
    lw      $6,  STACK_OFFSET_A2($29)       # Recover a2
    lw      $7,  STACK_OFFSET_A3($29)       # Recover a3
    lw      $8,  STACK_OFFSET_T0($29)       # Recover t0
    lw      $9,  STACK_OFFSET_T1($29)       # Recover t1
    lw      $10, STACK_OFFSET_T2($29)       # Recover t2
    lw      $11, STACK_OFFSET_T3($29)       # Recover t3
    lw      $12, STACK_OFFSET_T4($29)       # Recover t4
    lw      $13, STACK_OFFSET_T5($29)       # Recover t5
    lw      $14, STACK_OFFSET_T6($29)       # Recover t6
    lw      $15, STACK_OFFSET_T7($29)       # Recover t7
    lw      $24, STACK_OFFSET_T8($29)       # Recover t8
    lw      $25, STACK_OFFSET_T9($29)       # Recover t9
    lw      $31, STACK_OFFSET_RA($29)       # Recover ra
#endif    /* ( __mips_micromips == 1 )  */   
    #if defined (__mips_hard_float)
    LDC1    $f0,  STACK_OFFSET_F0($29)      # Recover f0
    LDC1    $f1,  STACK_OFFSET_F1($29)      # Recover f1
    LDC1    $f2,  STACK_OFFSET_F2($29)	    # Recover f2
    LDC1    $f3,  STACK_OFFSET_F3($29)	    # Recover f3
    LDC1    $f4,  STACK_OFFSET_F4($29)	    # Recover f4
    LDC1    $f5,  STACK_OFFSET_F5($29)      # Recover f5
    LDC1    $f6,  STACK_OFFSET_F6($29)	    # Recover f6
    LDC1    $f7,  STACK_OFFSET_F7($29)	    # Recover f7
    LDC1    $f8,  STACK_OFFSET_F8($29)	    # Recover f8
    LDC1    $f9,  STACK_OFFSET_F9($29)	    # Recover f9
    LDC1    $f10, STACK_OFFSET_F10($29)	    # Recover f10
    LDC1    $f11, STACK_OFFSET_F11($29)	    # Recover f11
    LDC1    $f12, STACK_OFFSET_F12($29)	    # Recover f12
    LDC1    $f13, STACK_OFFSET_F13($29)	    # Recover f13
    LDC1    $f14, STACK_OFFSET_F14($29)	    # Recover f14
    LDC1    $f15, STACK_OFFSET_F15($29)	    # Recover f15
    LDC1    $f16, STACK_OFFSET_F16($29)	    # Recover f16
    LDC1    $f17, STACK_OFFSET_F17($29)	    # Recover f17
    LDC1    $f18, STACK_OFFSET_F18($29)	    # Recover f18	
    LDC1    $f19, STACK_OFFSET_F19($29)	    # Recover f19
    
    LDC1    $f20, STACK_OFFSET_F20($29)	    # Recover f20
    LDC1    $f21, STACK_OFFSET_F21($29)	    # Recover f21
    LDC1    $f22, STACK_OFFSET_F22($29)	    # Recover f22
    LDC1    $f23, STACK_OFFSET_F23($29)	    # Recover f23
    LDC1    $f24, STACK_OFFSET_F24($29)	    # Recover f24
    LDC1    $f25, STACK_OFFSET_F25($29)	    # Recover f25
    LDC1    $f26, STACK_OFFSET_F26($29)	    # Recover f26
    LDC1    $f27, STACK_OFFSET_F27($29)	    # Recover f27
    LDC1    $f28, STACK_OFFSET_F28($29)	    # Recover f28
    LDC1    $f29, STACK_OFFSET_F29($29)	    # Recover f29
    LDC1    $f30, STACK_OFFSET_F30($29)	    # Recover f30
    LDC1    $f31, STACK_OFFSET_F31($29)	    # Recover f31
    #endif
    addiu   $29, $29, STACK_CTX_SIZE        # Recover stack frame
    
    eret                                    # Return to point of interrupt

_tx_thread_synch_return:

   /* Recover standard preserved registers.  */
    lw      $8,  MINIMAL_STACK_OFFSET_DSPC($29)     # Recover DSPControl
    lw      $30, MINIMAL_STACK_OFFSET_S8($29)       # Recover s8, fp
    wrdsp   $8,  31                                 # Restore DSPControl
#if ( __mips_micromips == 1 )
    
    lwm32   $16-$23,$16,MINIMAL_STACK_OFFSET_S0($29)  # Recover s0-s7
    
    lwp      $8,  MINIMAL_STACK_OFFSET_HI0($29) # Recover ac0 hi,low
    mthi    $8,  $ac0                       	# Setup ac0 hi
    mtlo    $9,  $ac0                       	# Setup ac0 lo
    
    lwp      $8,  MINIMAL_STACK_OFFSET_HI1($29) # Recover ac1 hi,low
    mthi    $8,  $ac1                       	# Setup ac1 hi
    mtlo    $9,  $ac1                       	# Setup ac1 lo

    lwp      $8,  MINIMAL_STACK_OFFSET_HI2($29) # Recover ac2 hi,low
    mthi    $8,  $ac2                       	# Setup ac2 hi
    mtlo    $9,  $ac2                       	# Setup ac2 lo
    
    lwp      $8,  MINIMAL_STACK_OFFSET_HI3($29) # Recover ac3 hi,low
    mthi    $8,  $ac3                       	# Setup ac3 hi
    mtlo    $9,  $ac3                       	# Setup ac3 lo
    
    lw      $8,  MINIMAL_STACK_OFFSET_SR($29)   # Recover SR
    lw      $31, MINIMAL_STACK_OFFSET_RA($29)   # Recover ra
#else
    lw      $23, MINIMAL_STACK_OFFSET_S7($29)   # Recover s7
    lw      $22, MINIMAL_STACK_OFFSET_S6($29)   # Recover s6
    lw      $21, MINIMAL_STACK_OFFSET_S5($29)   # Recover s5
    lw      $20, MINIMAL_STACK_OFFSET_S4($29)   # Recover s4
    lw      $19, MINIMAL_STACK_OFFSET_S3($29)   # Recover s3
    lw      $18, MINIMAL_STACK_OFFSET_S2($29)   # Recover s2
    lw      $17, MINIMAL_STACK_OFFSET_S1($29)   # Recover s1
    lw      $16, MINIMAL_STACK_OFFSET_S0($29)   # Recover s0
    
    lw      $8,  MINIMAL_STACK_OFFSET_HI0($29)  # Recover ac0 hi
    lw      $9,  MINIMAL_STACK_OFFSET_LO0($29)  # Recover ac0 low
    mthi    $8,  $ac0                           # Setup ac0 hi
    mtlo    $9,  $ac0                           # Setup ac0 lo
    
    lw      $8,  MINIMAL_STACK_OFFSET_HI1($29)  # Recover ac1 hi
    lw      $9,  MINIMAL_STACK_OFFSET_LO1($29)  # Recover ac1 low
    mthi    $8,  $ac1                           # Setup ac1 hi
    mtlo    $9,  $ac1                           # Setup ac1 lo

    lw      $8,  MINIMAL_STACK_OFFSET_HI2($29)  # Recover ac2 hi
    lw      $9,  MINIMAL_STACK_OFFSET_LO2($29)  # Recover ac2 low
    mthi    $8,  $ac2                           # Setup ac2 hi
    mtlo    $9,  $ac2                           # Setup ac2 lo
    
    lw      $8,  MINIMAL_STACK_OFFSET_HI3($29)  # Recover ac3 hi
    lw      $9,  MINIMAL_STACK_OFFSET_LO3($29)  # Recover ac3 low
    mthi    $8,  $ac3                           # Setup ac3 hi
    mtlo    $9,  $ac3                           # Setup ac3 lo
    
    lw      $8,  MINIMAL_STACK_OFFSET_SR($29)   # Recover SR
    lw      $31, MINIMAL_STACK_OFFSET_RA($29)   # Recover ra
#endif /* #if ( __mips_micromips == 1 ) */
#if defined (__mips_hard_float)   
    la      $9, _tx_thread_current_ptr          # Pickup address of pointer
    lw      $10, ($9)                           # Set current thread pointer
    lw      $9, 144($10)                        # Set current thread pointer
    beq	    $9, $0, 1f   
    nop
    lw	    $9,MINIMAL_STACK_OFFSET_FCSR($29)
    CTC1    $9,$f31			        # Recover FCSR
    
    LDC1  $f20, MINIMAL_STACK_OFFSET_F20($29)	# Recover f20
    LDC1  $f21, MINIMAL_STACK_OFFSET_F21($29)	# Recover f21
    LDC1  $f22, MINIMAL_STACK_OFFSET_F22($29)	# Recover f22
    LDC1  $f23, MINIMAL_STACK_OFFSET_F23($29)	# Recover f23
    LDC1  $f24, MINIMAL_STACK_OFFSET_F24($29)	# Recover f24
    LDC1  $f25, MINIMAL_STACK_OFFSET_F25($29)	# Recover f25
    LDC1  $f26, MINIMAL_STACK_OFFSET_F26($29)	# Recover f26
    LDC1  $f27, MINIMAL_STACK_OFFSET_F27($29)	# Recover f27		
    LDC1  $f28, MINIMAL_STACK_OFFSET_F28($29)	# Recover f28
    LDC1  $f29, MINIMAL_STACK_OFFSET_F29($29)	# Recover f29	
    LDC1  $f30, MINIMAL_STACK_OFFSET_F30($29)	# Recover f30
    LDC1  $f31, MINIMAL_STACK_OFFSET_F31($29)	# Recover f31
    addiu   $29, $29, 96                    	# Recover stack space
#endif
1:    
    addiu   $29, $29, 104                   	# Recover stack space

    
    /* This may re-enable interrupts, make sure to clear exe hazard.  */
    
    mtc0    $8, $12                         # Restore SR
    jr.hb   $31                             # Return to thread
    nop                                     # Delay slot

/* }  */


    .section .text,code
    .set    noreorder
    .set    noat
#if ( __mips_micromips == 1 )    
	.set  micromips
#else
    .set  nomicromips
#endif
    .set    nomips16
   .extern _tx_thread_current_ptr

/**************************************************************************/ 
/*                                                                        */ 
/*  FUNCTION                                               RELEASE        */ 
/*                                                                        */ 
/*   tx_thread_fpu_enable                              PIC32MZ/Microchip  */ 
/*                                                           5.0          */ 
/*  AUTHOR                                                                */ 
/*                                                                        */ 
/*    William E. Lamie, Express Logic, Inc.                               */ 
/*                                                                        */ 
/*  DESCRIPTION                                                           */ 
/*                                                                        */ 
/*    This function  sets the FPU Enable flag for the corresponding       */ 
/*    thread.                                                             */ 
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
/*     Applicaiton                                                        */ 
/*                                                                        */ 
/*  RELEASE HISTORY                                                       */ 
/*                                                                        */ 
/*    DATE              NAME                      DESCRIPTION             */ 
/*                                                                        */ 
/*  09-01-2014     William E. Lamie         Initial Version 5.0           */ 
/*                                                                        */ 
/**************************************************************************/ 
/* VOID   tx_thread_fpu_enable(VOID)
{  */
       .globl  tx_thread_fpu_enable
tx_thread_fpu_enable:
    /* Lockout interrupts  */
    mfc0	k1, _CP0_STATUS
    di
    ehb

    /* Setup the current thread pointer.  */
    /* _tx_thread_current_ptr =  _tx_thread_execute_ptr;  */

    la      $9, _tx_thread_current_ptr      # Pickup current thread pointer address
    lw      $8, ($9)                        # Set current thread pointer
    
    /* Set the FPU Enable Flag for this thread.  */
    /* _tx_thread_current_ptr -> tx_thread_fpu_enable = 1;  */

    addiu   $10, $0, 1    
    sw      $10, 144($8)                    # set fpu enable flag   
    
    /* Restore the interrupts */
    mtc0	k1, _CP0_STATUS
    ehb
    
    jr.hb   $31                             # Return to thread
    nop                                     # Delay slot
/* }  */
