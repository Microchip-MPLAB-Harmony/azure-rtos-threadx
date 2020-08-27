@/**************************************************************************/
@/*                                                                        */
@/*       Copyright (c) Microsoft Corporation. All rights reserved.        */
@/*                                                                        */
@/*       This software is licensed under the Microsoft Software License   */
@/*       Terms for Microsoft Azure RTOS. Full text of the license can be  */
@/*       found in the LICENSE file at https://aka.ms/AzureRTOS_EULA       */
@/*       and in the root directory of this software.                      */
@/*                                                                        */
@/**************************************************************************/
@
@
@/**************************************************************************/
@/**************************************************************************/
@/**                                                                       */ 
@/** ThreadX Component                                                     */ 
@/**                                                                       */
@/**   Initialize                                                          */
@/**                                                                       */
@/**************************************************************************/
@/**************************************************************************/
@
@
@#define TX_SOURCE_CODE
@
@
@/* Include necessary system files.  */
@
@#include "tx_api.h"
@#include "tx_initialize.h"
@#include "tx_thread.h"
@#include "tx_timer.h"

    .arm

@
@
    .global     _tx_initialize_unused_memory
    .global     _tx_thread_context_save
    .global     _tx_thread_context_restore
    .global     _tx_timer_interrupt
    .global     _end

@
@
@/* Define the 16-bit Thumb mode veneer for _tx_initialize_low_level for
@   applications calling this function from to 16-bit Thumb mode.  */
@
    .text
    .align 2
    .thumb
    .global $_tx_initialize_low_level
    .type   $_tx_initialize_low_level,function
$_tx_initialize_low_level:
     BX        pc                               @ Switch to 32-bit mode
     NOP                                        @ 
    .arm
     STMFD     sp!, {lr}                        @ Save return address
     BL        _tx_initialize_low_level         @ Call _tx_initialize_low_level function
     LDMFD     sp!, {lr}                        @ Recover saved return address
     BX        lr                               @ Return to 16-bit caller
@
@
    .text
    .align 2
@/**************************************************************************/ 
@/*                                                                        */ 
@/*  FUNCTION                                               RELEASE        */ 
@/*                                                                        */ 
@/*    _tx_initialize_low_level                             ARM9/GNU       */ 
@/*                                                           5.2          */ 
@/*  AUTHOR                                                                */ 
@/*                                                                        */ 
@/*    William E. Lamie, Express Logic, Inc.                               */ 
@/*                                                                        */ 
@/*  DESCRIPTION                                                           */ 
@/*                                                                        */ 
@/*    This function is responsible for any low-level processor            */ 
@/*    initialization, including setting up interrupt vectors, setting     */ 
@/*    up a periodic timer interrupt source, saving the system stack       */ 
@/*    pointer for use in ISR processing later, and finding the first      */ 
@/*    available RAM memory address for tx_application_define.             */ 
@/*                                                                        */ 
@/*  INPUT                                                                 */ 
@/*                                                                        */ 
@/*    None                                                                */ 
@/*                                                                        */ 
@/*  OUTPUT                                                                */ 
@/*                                                                        */ 
@/*    None                                                                */ 
@/*                                                                        */ 
@/*  CALLS                                                                 */ 
@/*                                                                        */ 
@/*    None                                                                */ 
@/*                                                                        */ 
@/*  CALLED BY                                                             */ 
@/*                                                                        */ 
@/*    _tx_initialize_kernel_enter           ThreadX entry function        */ 
@/*                                                                        */ 
@/*  RELEASE HISTORY                                                       */ 
@/*                                                                        */ 
@/*    DATE              NAME                      DESCRIPTION             */ 
@/*                                                                        */ 
@/*  12-12-2005     William E. Lamie         Initial Version 5.0           */ 
@/*  12-12-2008     William E. Lamie         Modified comment(s), added    */ 
@/*                                            logic for 8-byte stack      */ 
@/*                                            alignment, and removed      */ 
@/*                                            clearing of SL and FP       */ 
@/*                                            registers in SYS mode,      */ 
@/*                                            resulting in version 5.1    */ 
@/*  05-01-2010     William E. Lamie         Modified comment(s),          */ 
@/*                                            resulting in version 5.2    */ 
@/*                                                                        */ 
@/**************************************************************************/ 
@VOID   _tx_initialize_low_level(VOID)
@{
    .global _tx_initialize_low_level
    .type   _tx_initialize_low_level,function
_tx_initialize_low_level:
@
@    /* We must be in SVC mode at this point!  */
@
@    /* Save the system stack pointer.  */
@    _tx_thread_system_stack_ptr = (VOID_PTR) (sp);
@
    LDR     r2, =_tx_thread_system_stack_ptr    @ Pickup stack pointer
    STR     r1, [r2]                            @ Save the system stack
@
@    /* Save the first available memory address.  */
@    _tx_initialize_unused_memory =  (VOID_PTR) _end;
@
    LDR     r1, =_end                           @ Get end of non-initialized RAM area
    LDR     r2, =_tx_initialize_unused_memory   @ Pickup unused memory ptr address
    ADD     r1, r1, #8                          @ Increment to next free word
    STR     r1, [r2]                            @ Save first free memory address
@
@    /* Setup Timer for periodic interrupts.  */
@
@    /* Done, return to caller.  */
@
#ifdef __THUMB_INTERWORK
    BX      lr                                  @ Return to caller
#else
    MOV     pc, lr                              @ Return to caller
#endif
@}
@
@
@/* Define shells for each of the interrupt vectors.  */
@
    .global __tx_undefined
__tx_undefined:
    B       __tx_undefined                      @ Undefined handler
@
    .global __tx_swi_interrupt
__tx_swi_interrupt:
    B       __tx_swi_interrupt                  @ Software interrupt handler
@
    .global __tx_prefetch_handler
__tx_prefetch_handler:
    B       __tx_prefetch_handler               @ Prefetch exception handler
@
    .global __tx_abort_handler
__tx_abort_handler:
    B       __tx_abort_handler                  @ Abort exception handler
@
    .global __tx_reserved_handler
__tx_reserved_handler:
    B       __tx_reserved_handler               @ Reserved exception handler
@
    .global __tx_irq_handler
    .global __tx_irq_processing_return      
__tx_irq_handler:
@
@    /* Jump to context save to save system context.  */
    B       _tx_thread_context_save
__tx_irq_processing_return:
@
@    /* At this point execution is still in the IRQ mode.  The CPSR, point of
@       interrupt, and all C scratch registers are available for use.  In 
@       addition, IRQ interrupts may be re-enabled - with certain restrictions -
@       if nested IRQ interrupts are desired.  Interrupts may be re-enabled over
@       small code sequences where lr is saved before enabling interrupts and 
@       restored after interrupts are again disabled.  */
@
@    /* Interrupt nesting is allowed after calling _tx_thread_irq_nesting_start 
@       from IRQ mode with interrupts disabled.  This routine switches to the
@       system mode and returns with IRQ interrupts enabled.  
@       
@       NOTE:  It is very important to ensure all IRQ interrupts are cleared 
@       prior to enabling nested IRQ interrupts.  */
#ifdef TX_ENABLE_IRQ_NESTING
    BL      _tx_thread_irq_nesting_start
#endif
@
@    /* For debug purpose, execute the timer interrupt processing here.  In
@       a real system, some kind of status indication would have to be checked
@       before the timer interrupt handler could be called.  */
@
    BL     _tx_timer_interrupt                  @ Timer interrupt handler
@
@
@    /* If interrupt nesting was started earlier, the end of interrupt nesting
@       service must be called before returning to _tx_thread_context_restore.  
@       This routine returns in processing in IRQ mode with interrupts disabled.  */
#ifdef TX_ENABLE_IRQ_NESTING
    BL      _tx_thread_irq_nesting_end
#endif
@
@    /* Jump to context restore to restore system context.  */
    B       _tx_thread_context_restore
@
@
@    /* This is an example of a vectored IRQ handler.  */
@
@    .global __tx_example_vectored_irq_handler
@__tx_example_vectored_irq_handler:
@
@
@    /* Save initial context and call context save to prepare for 
@       vectored ISR execution.  */
@
@    STMDB   sp!, {r0-r3}                        @ Save some scratch registers
@    MRS     r0, SPSR                            @ Pickup saved SPSR
@    SUB     lr, lr, #4                          @ Adjust point of interrupt 
@    STMDB   sp!, {r0, r10, r12, lr}             @ Store other scratch registers
@    BL      _tx_thread_vectored_context_save    @ Vectored context save
@
@    /* At this point execution is still in the IRQ mode.  The CPSR, point of
@       interrupt, and all C scratch registers are available for use.  In 
@       addition, IRQ interrupts may be re-enabled - with certain restrictions -
@       if nested IRQ interrupts are desired.  Interrupts may be re-enabled over
@       small code sequences where lr is saved before enabling interrupts and 
@       restored after interrupts are again disabled.  */
@
@
@    /* Interrupt nesting is allowed after calling _tx_thread_irq_nesting_start 
@       from IRQ mode with interrupts disabled.  This routine switches to the
@       system mode and returns with IRQ interrupts enabled.  
@       
@       NOTE:  It is very important to ensure all IRQ interrupts are cleared 
@       prior to enabling nested IRQ interrupts.  */
@#ifdef TX_ENABLE_IRQ_NESTING
@    BL      _tx_thread_irq_nesting_start
@#endif
@
@    /* Application IRQ handlers can be called here!  */
@
@    /* If interrupt nesting was started earlier, the end of interrupt nesting
@       service must be called before returning to _tx_thread_context_restore.  
@       This routine returns in processing in IRQ mode with interrupts disabled.  */
@#ifdef TX_ENABLE_IRQ_NESTING
@    BL      _tx_thread_irq_nesting_end
@#endif
@
@    /* Jump to context restore to restore system context.  */
@    B       _tx_thread_context_restore
@
@
#ifdef TX_ENABLE_FIQ_SUPPORT
    .global  __tx_fiq_handler
    .global  __tx_fiq_processing_return
__tx_fiq_handler:
@
@    /* Jump to fiq context save to save system context.  */
    B       _tx_thread_fiq_context_save
__tx_fiq_processing_return:
@
@    /* At this point execution is still in the FIQ mode.  The CPSR, point of
@       interrupt, and all C scratch registers are available for use.  */
@
@    /* Interrupt nesting is allowed after calling _tx_thread_fiq_nesting_start 
@       from FIQ mode with interrupts disabled.  This routine switches to the
@       system mode and returns with FIQ interrupts enabled. 
@
@       NOTE:  It is very important to ensure all FIQ interrupts are cleared 
@       prior to enabling nested FIQ interrupts.  */
#ifdef TX_ENABLE_FIQ_NESTING
    BL      _tx_thread_fiq_nesting_start
#endif
@
@    /* Application FIQ handlers can be called here!  */
@
@    /* If interrupt nesting was started earlier, the end of interrupt nesting
@       service must be called before returning to _tx_thread_fiq_context_restore.  */
#ifdef TX_ENABLE_FIQ_NESTING
    BL      _tx_thread_fiq_nesting_end
#endif
@
@    /* Jump to fiq context restore to restore system context.  */
    B       _tx_thread_fiq_context_restore
@
@
#else
    .global  __tx_fiq_handler
__tx_fiq_handler:
    B       __tx_fiq_handler                    @ FIQ interrupt handler
#endif
@
@
BUILD_OPTIONS:
    .word  _tx_build_options                    @ Reference to bring in
VERSION_ID:
    .word  _tx_version_id                       @ Reference to bring in



