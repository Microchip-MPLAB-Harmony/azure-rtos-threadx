;/*******************************************************************************
;Copyright (c) 2019 released Microchip Technology Inc.  All rights reserved.

;Microchip licenses to you the right to use, modify, copy and distribute
;Software only when embedded on a Microchip microcontroller or digital signal
;controller that is integrated into your product or third party product
;(pursuant to the sublicense terms in the accompanying license agreement).

;You should refer to the license agreement accompanying this Software for
;additional information regarding your rights and obligations.

;SOFTWARE AND DOCUMENTATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
;EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF
;MERCHANTABILITY, TITLE, NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR PURPOSE.
;IN NO EVENT SHALL MICROCHIP OR ITS LICENSORS BE LIABLE OR OBLIGATED UNDER
;CONTRACT, NEGLIGENCE, STRICT LIABILITY, CONTRIBUTION, BREACH OF WARRANTY, OR
;OTHER LEGAL EQUITABLE THEORY ANY DIRECT OR INDIRECT DAMAGES OR EXPENSES
;INCLUDING BUT NOT LIMITED TO ANY INCIDENTAL, SPECIAL, INDIRECT, PUNITIVE OR
;CONSEQUENTIAL DAMAGES, LOST PROFITS OR LOST DATA, COST OF PROCUREMENT OF
;SUBSTITUTE GOODS, TECHNOLOGY, SERVICES, OR ANY CLAIMS BY THIRD PARTIES
;(INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF), OR OTHER SIMILAR COSTS.
;*******************************************************************************/

        MODULE  sam9x6_tx_port

AIC_BASE_ADDRESS  DEFINE 0xFFFFF100
AIC_SMR           DEFINE 0x04
AIC_IVR           DEFINE 0x10
AIC_EOICR         DEFINE 0x38
ARM_MODE_IRQ      DEFINE 0x12
ARM_MODE_SVC      DEFINE 0x13
I_BIT             DEFINE 0x80
F_BIT             DEFINE 0x40

        EXTERN      _tx_thread_vectored_context_save
        EXTERN      _tx_thread_context_restore


        SECTION .text:CODE:NOROOT(2)
        PUBLIC Threadx_IRQ_Handler
        ARM
Threadx_IRQ_Handler:
        ; Jump to context save to save system context.
        STMDB   sp!, {r0-r3}                    ; Save some scratch registers
        MRS     r0, SPSR                        ; Pickup saved SPSR
        SUB     lr, lr, #4                      ; Adjust point of interrupt 
        STMDB   sp!, {r0, r10, r12, lr}         ; Store other registers
        LDR     r0, =_tx_thread_vectored_context_save
        BLX     r0                              ; Call vectored context save      

        ; Write in the IVR to support Protect Mode.

        LDR     lr, =AIC_BASE_ADDRESS
        LDR     r0, [r14, #AIC_IVR]
        STR     lr, [r14, #AIC_IVR]
    	; Dummy read to force AIC_IVR write completion
    	LDR     lr, [r14, #AIC_SMR]

	    ; Branch to interrupt handler in Supervisor mode

	    MSR     CPSR_c, #ARM_MODE_SVC
	    STMFD   sp!, { r1-r3, r4, r12, lr}

	    ; Check for 8-byte alignment and save lr plus a
	    ; word to indicate the stack adjustment used (0 or 4)

	    AND     r1, sp, #4
	    SUB     sp, sp, r1
	    STMFD   sp!, {r1, lr}

        ; Call IRQ processing function.
        BLX         r0

	    LDMIA   sp!, {r1, lr}
	    ADD     sp, sp, r1

	    LDMIA   sp!, { r1-r3, r4, r12, lr}
	    MSR     CPSR_c, #ARM_MODE_IRQ | I_BIT | F_BIT

        ; Acknowledge interrupt
        LDR         lr, =AIC_BASE_ADDRESS
        STR         lr, [r14, #AIC_EOICR]

        ; Jump to context restore to restore system context.
        LDR     r0,=_tx_thread_context_restore
        BX      r0                              ; Jump to context restore

        END