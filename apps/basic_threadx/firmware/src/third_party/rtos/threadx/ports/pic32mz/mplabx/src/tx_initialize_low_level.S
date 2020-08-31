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
/**   Initialize                                                          */
/**                                                                       */
/**************************************************************************/
/**************************************************************************/


/* #define TX_SOURCE_CODE  */


/* Include necessary system files.  */

/*  #include "tx_api.h"
    #include "tx_initialize.h"
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
    
    .extern _tx_build_options
    .extern _tx_version_id
    
/**************************************************************************/ 
/*                                                                        */ 
/*  FUNCTION                                               RELEASE        */ 
/*                                                                        */ 
/*    _tx_initialize_low_level                         PIC32MZ/Microchip  */ 
/*                                                           5.0          */ 
/*  AUTHOR                                                                */ 
/*                                                                        */ 
/*    William E. Lamie, Express Logic, Inc.                               */ 
/*                                                                        */ 
/*  DESCRIPTION                                                           */ 
/*                                                                        */ 
/*    This function is responsible for any low-level processor            */ 
/*    initialization, including setting up interrupt vectors, setting     */ 
/*    up a periodic timer interrupt source, saving the system stack       */ 
/*    pointer for use in ISR processing later, and finding the first      */ 
/*    available RAM memory address for tx_application_define.             */ 
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
/*    _tx_initialize_kernel_enter           ThreadX entry function        */ 
/*                                                                        */ 
/*  RELEASE HISTORY                                                       */ 
/*                                                                        */ 
/*    DATE              NAME                      DESCRIPTION             */ 
/*                                                                        */ 
/*  09-01-2014     William E. Lamie         Initial Version 5.0           */ 
/*                                                                        */ 
/**************************************************************************/ 
/* VOID   _tx_initialize_low_level(VOID)
{  */
    .globl  _tx_initialize_low_level
_tx_initialize_low_level:

    /* Make sure interrupts are disabled.  */
    di
    ehb

    /* Debug code to keep the count register from running at halt or BPs.  */
    
    mfc0    $8, $23, 0                          # Pickup CP0 23
    li      $9, 0xFDFFFFFF                      # Mask to clear bit 25 of CP0 23    
    and     $8, $8, $9                          # Clear bit 25
    mtc0    $8, $23, 0                          # Set the Debug Reg (CP0 23)  
    ehb
    
    /* Save the system stack pointer.  */
    /* _tx_thread_system_stack_ptr = (VOID_PTR) (SP);  */

    la      $8, _tx_thread_system_stack_ptr     # Pickup address of system  
                                                # stack pointer.
    la      $9, _stack                          # Pickup initial stack pointer
    sw      $9, ($8)                            # Save system stack pointer


    /* Save the first available memory address.  */
    /* _tx_initialize_unused_memory =  (VOID_PTR)__builtin_section_begin(".stack");  */

    la      $9, (.startof..stack)               # Pickup free memory address (assuming this is the last RAM section loaded!)  
    la      $10, _tx_initialize_unused_memory   # Pickup address of unused
                                                # memory  
    sw      $9, ($10)                           # Save unused memory address

    /* Done, return to caller.  */

    jr      $31                                 # Return to caller
    nop                                         # Delay slot
/* }  */


    /* Reference the build options and the version ID to ensure they are part of the image.  */
    la      $8, _tx_build_options
    la      $9, _tx_version_id


