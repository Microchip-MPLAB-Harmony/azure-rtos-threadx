/*******************************************************************************
  Threadx timer configuration file for SAM9X6
  Company:
    Microchip Technology Inc.

  File Name:
    sam9x6_tx_timer.c

  Summary:
    Provide tick timer initialization routines for Threadx on SAM9X6.

  Description:
    This file contains functional implementations of tick timer initialization 
    routines for Threadx on SAM9X6.

*******************************************************************************/

// DOM-IGNORE-BEGIN
/*******************************************************************************
* Copyright (C) 2018 Microchip Technology Inc. and its subsidiaries.
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

/*********************************************************************
*
*       Include files
*
**********************************************************************
*/

#include "definitions.h"

// *****************************************************************************
// *****************************************************************************
// Section: Timer routine implemenation
// *****************************************************************************
// *****************************************************************************
extern void _tx_timer_interrupt(void);

static void threadx_tick_handler(uintptr_t context)
{
    /* Call ThreadX timer interrupt processing.  */
    _tx_timer_interrupt();
}

void threadx_timer_intialize()
{
    PIT64B_TimerCallbackSet(threadx_tick_handler, 0);
    PIT64B_TimerStart();
}

