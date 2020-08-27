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
/**   User Specific                                                       */
/**                                                                       */
/**************************************************************************/
/**************************************************************************/


/**************************************************************************/
/*                                                                        */
/*  PORT SPECIFIC C INFORMATION                            RELEASE        */
/*                                                                        */
/*    tx_user.h                                           PORTABLE C      */
/*                                                           6.0          */
/*                                                                        */
/*  AUTHOR                                                                */
/*                                                                        */
/*    William E. Lamie, Microsoft Corporation                             */
/*                                                                        */
/*  DESCRIPTION                                                           */
/*                                                                        */
/*    This file contains user defines for configuring ThreadX in specific */
/*    ways. This file will have an effect only if the application and     */
/*    ThreadX library are built with TX_INCLUDE_USER_DEFINE_FILE defined. */
/*    Note that all the defines in this file may also be made on the      */
/*    command line when building ThreadX library and application objects. */
/*                                                                        */
/*  RELEASE HISTORY                                                       */
/*                                                                        */
/*    DATE              NAME                      DESCRIPTION             */
/*                                                                        */
/*  05-19-2020     William E. Lamie         Initial Version 6.0           */
/*                                                                        */
/**************************************************************************/

#ifndef TX_USER_H
#define TX_USER_H


/* Define various build options for the ThreadX port.  The application should either make changes
   here by commenting or un-commenting the conditional compilation defined OR supply the defines
   though the compiler's equivalent of the -D option.

   For maximum speed, the following should be defined:

        TX_MAX_PRIORITIES                       32
        TX_DISABLE_PREEMPTION_THRESHOLD
        TX_DISABLE_REDUNDANT_CLEARING
        TX_DISABLE_NOTIFY_CALLBACKS
        TX_NOT_INTERRUPTABLE
        TX_TIMER_PROCESS_IN_ISR
        TX_REACTIVATE_INLINE
        TX_DISABLE_STACK_FILLING
        TX_INLINE_THREAD_RESUME_SUSPEND

   For minimum size, the following should be defined:

        TX_MAX_PRIORITIES                       32
        TX_DISABLE_PREEMPTION_THRESHOLD
        TX_DISABLE_REDUNDANT_CLEARING
        TX_DISABLE_NOTIFY_CALLBACKS
        TX_NOT_INTERRUPTABLE
        TX_TIMER_PROCESS_IN_ISR

   Of course, many of these defines reduce functionality and/or change the behavior of the
   system in ways that may not be worth the trade-off. For example, the TX_TIMER_PROCESS_IN_ISR
   results in faster and smaller code, however, it increases the amount of processing in the ISR.
   In addition, some services that are available in timers are not available from ISRs and will
   therefore return an error if this option is used. This may or may not be desirable for a
   given application.  */


/* Override various options with default values already assigned in tx_port.h. Please also refer
   to tx_port.h for descriptions on each of these options.  */

#define TX_MAX_PRIORITIES                       ${THREADX_TX_MAX_PRIORITIES}
#define TX_MINIMUM_STACK                        ${THREADX_TX_MINIMUM_STACK}
/*
#define TX_THREAD_USER_EXTENSION                ????
*/

#define TX_CPU_CLOCK_HZ                         ${THREADX_CPU_CLOCK_HZ}
#define TX_TICK_RATE_HZ                         ${THREADX_TICK_RATE_HZ}
#define TX_TICK_PERIOD_MS                       (1000 / TX_TICK_RATE_HZ)
<#if core.CoreArchitecture != "MIPS" && core.CoreArchitecture != "CORTEX-A" && core.CoreArchitecture != "ARM926EJS">
#define TX_SYSTICK_CYCLES                       ((TX_CPU_CLOCK_HZ / TX_TICK_RATE_HZ) -1)
</#if>

<#if THREADX_TX_DISABLE_ERROR_CHECKING == true>
#define TX_DISABLE_ERROR_CHECKING
<#else>
/*
#define TX_DISABLE_ERROR_CHECKING
*/
</#if>


/* Determine if timer expirations (application timers, timeouts, and tx_thread_sleep calls
   should be processed within the a system timer thread or directly in the timer ISR.
   By default, the timer thread is used. When the following is defined, the timer expiration
   processing is done directly from the timer ISR, thereby eliminating the timer thread control
   block, stack, and context switching to activate it.  */

<#if THREADX_TX_TIMER_PROCESS_IN_ISR == true>
#define TX_TIMER_PROCESS_IN_ISR
/*
#define TX_TIMER_THREAD_STACK_SIZE              ????
#define TX_TIMER_THREAD_PRIORITY                ????
*/
<#else>
/*
#define TX_TIMER_PROCESS_IN_ISR
*/
#define TX_TIMER_THREAD_STACK_SIZE              ${THREADX_TX_TIMER_THREAD_STACK_SIZE}
#define TX_TIMER_THREAD_PRIORITY                ${THREADX_TX_TIMER_THREAD_PRIORITY}
</#if>


/* Determine if in-line timer reactivation should be used within the timer expiration processing.
   By default, this is disabled and a function call is used. When the following is defined,
   reactivating is performed in-line resulting in faster timer processing but slightly larger
   code size.  */

<#if THREADX_TX_REACTIVATE_INLINE == true>
#define TX_REACTIVATE_INLINE
<#else>
/*
#define TX_REACTIVATE_INLINE
*/
</#if>


/* Determine is stack filling is enabled. By default, ThreadX stack filling is enabled,
   which places an 0xEF pattern in each byte of each thread's stack.  This is used by
   debuggers with ThreadX-awareness and by the ThreadX run-time stack checking feature.  */

<#if THREADX_TX_DISABLE_STACK_FILLING == true>
#define TX_DISABLE_STACK_FILLING
<#else>
/*
#define TX_DISABLE_STACK_FILLING
*/
</#if>

/* Determine whether or not stack checking is enabled. By default, ThreadX stack checking is
   disabled. When the following is defined, ThreadX thread stack checking is enabled.  If stack
   checking is enabled (TX_ENABLE_STACK_CHECKING is defined), the TX_DISABLE_STACK_FILLING
   define is negated, thereby forcing the stack fill which is necessary for the stack checking
   logic.  */

<#if THREADX_TX_ENABLE_STACK_CHECKING == true>
#define TX_ENABLE_STACK_CHECKING
<#else>
/*
#define TX_ENABLE_STACK_CHECKING
*/
</#if>

/* Determine if preemption-threshold should be disabled. By default, preemption-threshold is
   enabled. If the application does not use preemption-threshold, it may be disabled to reduce
   code size and improve performance.  */

<#if THREADX_TX_DISABLE_PREEMPTION_THRESHOLD == true>
#define TX_DISABLE_PREEMPTION_THRESHOLD
<#else>
/*
#define TX_DISABLE_PREEMPTION_THRESHOLD
*/
</#if>

/* Determine if global ThreadX variables should be cleared. If the compiler startup code clears
   the .bss section prior to ThreadX running, the define can be used to eliminate unnecessary
   clearing of ThreadX global variables.  */

<#if THREADX_TX_DISABLE_REDUNDANT_CLEARING == true>
#define TX_DISABLE_REDUNDANT_CLEARING
<#else>
/*
#define TX_DISABLE_REDUNDANT_CLEARING
*/
</#if>

/* Determine if no timer processing is required. This option will help eliminate the timer
   processing when not needed. The user will also have to comment out the call to
   tx_timer_interrupt, which is typically made from assembly language in
   tx_initialize_low_level. Note: if TX_NO_TIMER is used, the define TX_TIMER_PROCESS_IN_ISR
   must also be used.  */

/*
#define TX_NO_TIMER
#ifndef TX_TIMER_PROCESS_IN_ISR
#define TX_TIMER_PROCESS_IN_ISR
#endif
*/

/* Determine if the notify callback option should be disabled. By default, notify callbacks are
   enabled. If the application does not use notify callbacks, they may be disabled to reduce
   code size and improve performance.  */

<#if THREADX_TX_DISABLE_NOTIFY_CALLBACKS == true>
#define TX_DISABLE_NOTIFY_CALLBACKS
<#else>
/*
#define TX_DISABLE_NOTIFY_CALLBACKS
*/
</#if>

/* Determine if the tx_thread_resume and tx_thread_suspend services should have their internal
   code in-line. This results in a larger image, but improves the performance of the thread
   resume and suspend services.  */

<#if THREADX_TX_INLINE_THREAD_RESUME_SUSPEND == true>
#define TX_INLINE_THREAD_RESUME_SUSPEND
<#else>
/*
#define TX_INLINE_THREAD_RESUME_SUSPEND
*/
</#if>


/* Determine if the internal ThreadX code is non-interruptable. This results in smaller code
   size and less processing overhead, but increases the interrupt lockout time.  */

<#if THREADX_TX_NOT_INTERRUPTABLE == true>
#define TX_NOT_INTERRUPTABLE
<#else>
/*
#define TX_NOT_INTERRUPTABLE
*/
</#if>


/* Determine if the trace event logging code should be enabled. This causes slight increases in
   code size and overhead, but provides the ability to generate system trace information which
   is available for viewing in TraceX.  */

<#if THREADX_TX_ENABLE_EVENT_TRACE == true>
#define TX_ENABLE_EVENT_TRACE
<#else>
/*
#define TX_ENABLE_EVENT_TRACE
*/
</#if>


/* Determine if block pool performance gathering is required by the application. When the following is
   defined, ThreadX gathers various block pool performance information. */

<#if THREADX_TX_BLOCK_POOL_ENABLE_PERFORMANCE_INFO == true>
#define TX_BLOCK_POOL_ENABLE_PERFORMANCE_INFO
<#else>
/*
#define TX_BLOCK_POOL_ENABLE_PERFORMANCE_INFO
*/
</#if>

/* Determine if byte pool performance gathering is required by the application. When the following is
   defined, ThreadX gathers various byte pool performance information. */

<#if THREADX_TX_BYTE_POOL_ENABLE_PERFORMANCE_INFO == true>
#define TX_BYTE_POOL_ENABLE_PERFORMANCE_INFO
<#else>
/*
#define TX_BYTE_POOL_ENABLE_PERFORMANCE_INFO
*/
</#if>

/* Determine if event flags performance gathering is required by the application. When the following is
   defined, ThreadX gathers various event flags performance information. */

<#if THREADX_TX_EVENT_FLAGS_ENABLE_PERFORMANCE_INFO == true>
#define TX_EVENT_FLAGS_ENABLE_PERFORMANCE_INFO
<#else>
/*
#define TX_EVENT_FLAGS_ENABLE_PERFORMANCE_INFO
*/
</#if>

/* Determine if mutex performance gathering is required by the application. When the following is
   defined, ThreadX gathers various mutex performance information. */

<#if THREADX_TX_MUTEX_ENABLE_PERFORMANCE_INFO == true>
#define TX_MUTEX_ENABLE_PERFORMANCE_INFO
<#else>
/*
#define TX_MUTEX_ENABLE_PERFORMANCE_INFO
*/
</#if>

/* Determine if queue performance gathering is required by the application. When the following is
   defined, ThreadX gathers various queue performance information. */

<#if THREADX_TX_QUEUE_ENABLE_PERFORMANCE_INFO == true>
#define TX_QUEUE_ENABLE_PERFORMANCE_INFO
<#else>
/*
#define TX_QUEUE_ENABLE_PERFORMANCE_INFO
*/
</#if>

/* Determine if semaphore performance gathering is required by the application. When the following is
   defined, ThreadX gathers various semaphore performance information. */

<#if THREADX_TX_SEMAPHORE_ENABLE_PERFORMANCE_INFO == true>
#define TX_SEMAPHORE_ENABLE_PERFORMANCE_INFO
<#else>
/*
#define TX_SEMAPHORE_ENABLE_PERFORMANCE_INFO
*/
</#if>

/* Determine if thread performance gathering is required by the application. When the following is
   defined, ThreadX gathers various thread performance information. */

<#if THREADX_TX_THREAD_ENABLE_PERFORMANCE_INFO == true>
#define TX_THREAD_ENABLE_PERFORMANCE_INFO
<#else>
/*
#define TX_THREAD_ENABLE_PERFORMANCE_INFO
*/
</#if>

/* Determine if timer performance gathering is required by the application. When the following is
   defined, ThreadX gathers various timer performance information. */

<#if THREADX_TX_THREAD_ENABLE_PERFORMANCE_INFO == true>
#define TX_TIMER_ENABLE_PERFORMANCE_INFO
<#else>
/*
#define TX_TIMER_ENABLE_PERFORMANCE_INFO
*/
</#if>

#endif
