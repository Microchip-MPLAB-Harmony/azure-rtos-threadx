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
/**   Timer                                                               */
/**                                                                       */
/**************************************************************************/
/**************************************************************************/

/* #define TX_SOURCE_CODE  */


/* Include necessary system files.  */

/*  #include "tx_api.h"
    #include "tx_timer.h"
    #include "tx_thread.h"  */



    .section .text,code
    .set    noreorder
    .set    noat
#if ( __mips_micromips == 1 )    
	.set  micromips
#else
    .set  nomicromips
#endif
    .set    nomips16

    .extern _tx_timer_system_clock
    .extern _tx_timer_time_slice
    .extern _tx_timer_expired_time_slice
    .extern _tx_timer_current_ptr
    .extern _tx_timer_expired
    .extern _tx_timer_expiration_process
    .extern _tx_timer_list_end
    .extern _tx_timer_list_start
    .extern _tx_thread_time_slice

/**************************************************************************/ 
/*                                                                        */ 
/*  FUNCTION                                               RELEASE        */ 
/*                                                                        */ 
/*    _tx_timer_interrupt                              PIC32MZ/Microchip  */ 
/*                                                           5.0          */ 
/*  AUTHOR                                                                */ 
/*                                                                        */ 
/*    William E. Lamie, Express Logic, Inc.                               */ 
/*                                                                        */ 
/*  DESCRIPTION                                                           */ 
/*                                                                        */ 
/*    This function processes the hardware timer interrupt.  This         */ 
/*    processing includes incrementing the system clock and checking for  */ 
/*    time slice and/or timer expiration.  If either is found, the        */ 
/*    expiration functions are called.                                    */
/*                                                                        */ 
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
/*    _tx_timer_expiration_process          Timer expiration processing   */ 
/*    _tx_thread_time_slice                 Time slice interrupted thread */ 
/*                                                                        */ 
/*  CALLED BY                                                             */ 
/*                                                                        */ 
/*    interrupt vector                                                    */ 
/*                                                                        */ 
/*  RELEASE HISTORY                                                       */ 
/*                                                                        */ 
/*    DATE              NAME                      DESCRIPTION             */ 
/*                                                                        */ 
/*  09-01-2014     William E. Lamie         Initial Version 5.0           */ 
/*                                                                        */ 
/**************************************************************************/ 
/* VOID   _tx_timer_interrupt(VOID)
{  */
    .globl  _tx_timer_interrupt
_tx_timer_interrupt:


    /* Increment the system clock.  */
    /* _tx_timer_system_clock++;  */

    la      $9, _tx_timer_system_clock          # Pickup address of system clock
    lw      $8, ($9)                            # Pickup system clock
    la      $11, _tx_timer_time_slice           # Pickup address of time slice
    lw      $10, ($11)                          # Pickup time slice
    addiu    $8, $8, 1                          # Increment system clock
    sw      $8, ($9)                            # Store new system clock
    ori     $15, $0, 0                          # Clear local expired flag

    /* Test for time-slice expiration.  */
    /* if (_tx_timer_time_slice)
    {  */

    beqz    $10, _tx_timer_no_time_slice        # If 0, skip time slice processing
    addiu    $10, $10, -1                       # Decrement the time slice

       /* Decrement the time_slice.  */
       /* _tx_timer_time_slice--;  */

    sw      $10, ($11)                          # Store new time slice

       /* Check for expiration.  */
       /* if (__tx_timer_time_slice == 0)  */

    bgtz    $10, _tx_timer_no_time_slice        # If not 0, has not expired yet
    ori     $8, $0, 1                           # Build expired flag

       /* Set the time-slice expired flag.  */
       /* _tx_timer_expired_time_slice =  TX_TRUE;  */

    la      $14, _tx_timer_expired_time_slice   # Get address of expired flag
    sw      $8, ($14)                           # Set expired flag
    ori     $15, $15, 1                         # Set local expired flag

    /* }  */

_tx_timer_no_time_slice:

    /* Test for timer expiration.  */
    /* if (*_tx_timer_current_ptr)
    {  */

    la      $9, _tx_timer_current_ptr           # Pickup address of current ptr
    lw      $8, ($9)                            # Pickup current pointer
    la      $13, _tx_timer_expired              # Pickup address of timer expired flag
    lw      $10, ($8)                           # Pickup the current timer entry
    ori     $12, $0, 1                          # Build TX_TRUE flag
    beqz    $10, _tx_timer_no_timer             # If NULL, no timer has expired
    nop                                         # Delay slot

        /* Set expiration flag.  */
        /* _tx_timer_expired =  TX_TRUE;  */

    ori     $15, $15, 2                         # Set local expired flag
    b       _tx_timer_done                      # Finished timer processing
    sw      $12, ($13)                          # Set expired flag in memory


    /* }
    else
    {  */
_tx_timer_no_timer:

        /* No timer expired, increment the timer pointer.  */
        /* _tx_timer_current_ptr++;  */

        /* Check for wrap-around.  */
        /* if (_tx_timer_current_ptr == _tx_timer_list_end)  */

    la      $12, _tx_timer_list_end             # Pickup address of list end pointer
    lw      $11, ($12)                          # Pickup actual list end
    addu    $8, $8, 4                           # Point to next timer entry
    bne     $8, $11, _tx_timer_skip_wrap        # If not same, good pointer
    sw      $8, ($9)                            # Store new timer pointer

            /* Wrap to beginning of list.  */
            /* _tx_timer_current_ptr =  _tx_timer_list_start;  */

    la      $12, _tx_timer_list_start           # Pickup address of list start pointer
    lw      $10, ($12)                          # Pickup start of the list
    sw      $10, ($9)                           # Store new timer pointer


_tx_timer_skip_wrap:
    /* }  */

_tx_timer_done:


    /* See if anything has expired.  */
    /* if ((_tx_timer_expired_time_slice) || (_tx_timer_expired))
    {  */

    beqz    $15, _tx_timer_nothing_expired      # If nothing expired skip the rest
    and     $12, $15, 2                         # Isolate the timer expired bit
    addiu   $29, $29, -8                        # Allocate some storage on the stack
    sw      $15, ($29)                          # Save local expired flag
    sw      $31, 4($29)                         # Save ra

    /* Did a timer expire?  */
    /* if (_tx_timer_expired)
    {  */

    beqz    $12, _tx_timer_dont_activate        # No, timer not expired
    nop                                         # Delay slot

        /* Call the timer expiration processing.  */
        /* _tx_timer_expiration_process(void);  */

    la      $9, _tx_timer_expiration_process    # Build address of _tx_timer_expiratoin_process routine
    jal     $9                                  # Call _tx_timer_expiration_process
    nop
    lw      $15, ($29)                          # Recover local expired flag
    nop                                         #

    /* }  */
_tx_timer_dont_activate:

    /* Did time slice expire?  */
    /* if (_tx_timer_expired_time_slice)
    {  */

    and     $12, $15, 1                         # Is the timer expired bit set?
    beqz    $12, _tx_timer_not_ts_expiration    # If not, skip time slice processing
    nop                                         # Delay slot

        /* Time slice interrupted thread.  */
        /* _tx_thread_time_slice();  */

    la      $9, _tx_thread_time_slice           # Pickup address of time slice function
    jal     $9                                  # Call time slice
    nop                                         # Delay slot

     /* }  */

_tx_timer_not_ts_expiration:

    lw      $31, 4($29)                         # Recover ra
    addiu   $29, $29, 8                         # Recover stack space
    /* }  */

_tx_timer_nothing_expired:

    jr      $31                                 # Return to caller
    nop                                         # Delay slot

/* }  */

