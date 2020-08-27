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

    .extern      _tx_thread_vectored_context_save
    .extern      _tx_thread_context_restore

    .global      ThreadX_IRQ_Handler

//------------------------------------------------------------------------------
//         Definitions
//------------------------------------------------------------------------------

#define AIC           0xFC020000
#define AIC_SMR       0x04
#define AIC_IVR       0x10
#define AIC_EOICR     0x38

#define ARM_MODE_IRQ  0x12
#define ARM_MODE_SVC  0x13

#define I_BIT         0x80
#define F_BIT         0x40

//------------------------------------------------------------------------------
//         ThreadX IRQ handler routine
//------------------------------------------------------------------------------
	.TEXT
    .ARM
ThreadX_IRQ_Handler:
	/* Jump to context save to save system context.  */
	STMDB   sp!, {r0-r3}                    /* Save some scratch registers */
	MRS     r0, SPSR                        /* Pickup saved SPSR */
	SUB     lr, lr, #4                      /* Adjust point of interrupt */
	STMDB   sp!, {r0, r10, r12, lr}         /* Store other registers */
	LDR     r0, =_tx_thread_vectored_context_save
	BLX     r0                              /* Call vectored context save */

	/* Write in the IVR to support Protect Mode */
	LDR     lr, =AIC
	LDR     r0, [r14, #AIC_IVR]
	STR     lr, [r14, #AIC_IVR]
	/* Dummy read to force AIC_IVR write completion */
	LDR     lr, [r14, #AIC_SMR]

	/* Branch to interrupt handler in Supervisor mode */
	MSR     CPSR_c, #ARM_MODE_SVC
	STMFD   sp!, {r1-r3, r4, r12, lr}

	/* Check for 8-byte alignment and save lr plus a */
	/* word to indicate the stack adjustment used (0 or 4) */
	AND     r1, sp, #4
	SUB     sp, sp, r1
	STMFD   sp!, {r1, lr}

	BLX     r0

	LDMIA   sp!, {r1, lr}
	ADD     sp, sp, r1

	LDMIA   sp!, {r1-r3, r4, r12, lr}
	MSR     CPSR_c, #ARM_MODE_IRQ | I_BIT | F_BIT

	/* Acknowledge interrupt */
	LDR     lr, =AIC
	STR     lr, [r14, #AIC_EOICR]

	/* Jump to context restore to restore system context.  */
	LDR     r0,=_tx_thread_context_restore
	BX      r0                              /* Jump to context restore */

	.END
