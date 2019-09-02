/*******************************************************************************
  TMR1 Peripheral Library Interface Source File

  Company
    Microchip Technology Inc.

  File Name
    tmr1.c

  Summary
    TMR1 peripheral library source file.

  Description
    This file implements the interface to the TMR1 peripheral library.  This
    library provides access to and control of the associated peripheral
    instance.

*******************************************************************************/

// DOM-IGNORE-BEGIN
/*******************************************************************************
* Copyright (C) 2019 Microchip Technology Inc. and its subsidiaries.
*
* Subject to your compliance with these terms, you may use Microchip software
* and any derivatives exclusively with Microchip products. It is your
* responsibility to comply with third party license terms applicable to your
* use of third party software (including open source software) that may
* accompany Microchip software.
*
* THIS SOFTWARE IS SUPPLIED BY MICROCHIP "AS IS". NO WARRANTIES, WHETHER
* EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING ANY IMPLIED
* WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, AND FITNESS FOR A
* PARTICULAR PURPOSE.
*
* IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY INDIRECT, SPECIAL, PUNITIVE,
* INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST OR EXPENSE OF ANY KIND
* WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED, EVEN IF MICROCHIP HAS
* BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE FORESEEABLE. TO THE
* FULLEST EXTENT ALLOWED BY LAW, MICROCHIP'S TOTAL LIABILITY ON ALL CLAIMS IN
* ANY WAY RELATED TO THIS SOFTWARE WILL NOT EXCEED THE AMOUNT OF FEES, IF ANY,
* THAT YOU HAVE PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE.
*******************************************************************************/
// DOM-IGNORE-END

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************

#include "device.h"
#include "tx_tmr1.h"
#include "peripheral/evic/plib_evic.h"
#include "tx_api.h"

extern void _tx_timer_interrupt( void );

void __ISR(_TIMER_1_VECTOR, ipl1AUTO) TIMER_1_Handler (void)
{
    /* Clear Interrupt */
    IFS0CLR = _IFS0_T1IF_MASK;

    /* Call ThreadX context save. */
    _tx_thread_context_save();

    /* Call ThreadX timer interrupt processing. */
    _tx_timer_interrupt();

    /* Call ThreadX context restore. */
    _tx_thread_context_restore();
}

void TMR1_Initialize(void)
{
    const uint32_t timer1Period = ( (${THREADX_PERIPHERAL_CLOCK_HZ} / ${THREADX_TIMER_PRESCALE}) / ${THREADX_TICK_RATE_HZ} ) - 1UL;

    /* Disable Timer */
    T1CONCLR = _T1CON_ON_MASK;

    T1CONbits.TCKPS = ${THREADX_TIMER_PRESCALE_BITS};

    PR1 = timer1Period;

    /* Clear the interrupt as a starting condition. */
    IEC0CLR = _IEC0_T1IE_MASK;

    /* Enable the interrupt. */
    IEC0SET = _IEC0_T1IE_MASK;

    /* Start the timer. */
    T1CONSET = _T1CON_ON_MASK;

    /* Set up priority / subpriority of enabled interrupts */
    IPC1SET = 0x4 | 0x0;  /* TIMER_1:  Priority 1 / Subpriority 0 */
}

