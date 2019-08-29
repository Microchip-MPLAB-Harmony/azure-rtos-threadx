# coding: utf-8
"""*****************************************************************************
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
*****************************************************************************"""

############################################################################
############### Cortex-M7 Architecture specific configuration ##############
############################################################################

#Default Byte Pool size
threadxSym_BytePoolSize.setDefaultValue(40960)

#CPU Clock Frequency
cpuclk = Database.getSymbolValue("core", "CPU_CLOCK_FREQUENCY")
cpuclk = int(cpuclk)

threadxSym_CpuClockHz.setDependencies(threadxCpuClockHz, ["core.CPU_CLOCK_FREQUENCY"])
threadxSym_CpuClockHz.setDefaultValue(cpuclk)

#Setup SysTick, PendSV and SVCall Interrupt Priorities.
#SysTick must be highest priority
SysTickInterruptHandlerIndex    = Interrupt.getInterruptIndex("SysTick")

SysTickInterruptPri             = "NVIC_"+ str(SysTickInterruptHandlerIndex) +"_0_PRIORITY"
SysTickInterruptPriLock         = "NVIC_"+ str(SysTickInterruptHandlerIndex) +"_0_PRIORITY_LOCK"

if (Database.getSymbolValue("core", SysTickInterruptPri) != "1"):
    Database.clearSymbolValue("core", SysTickInterruptPri)
    Database.setSymbolValue("core", SysTickInterruptPri, "1")

if (Database.getSymbolValue("core", SysTickInterruptPriLock) == False):
    Database.clearSymbolValue("core", SysTickInterruptPriLock)
    Database.setSymbolValue("core", SysTickInterruptPriLock, True)

#SVCall must be lowest priority
SVCallInterruptHandlerIndex    = Interrupt.getInterruptIndex("SVCall")

SVCallInterruptPri             = "NVIC_"+ str(SVCallInterruptHandlerIndex) +"_0_PRIORITY"
SVCallInterruptPriLock         = "NVIC_"+ str(SVCallInterruptHandlerIndex) +"_0_PRIORITY_LOCK"

if (Database.getSymbolValue("core", SVCallInterruptPri) != "7"):
    Database.clearSymbolValue("core", SVCallInterruptPri)
    Database.setSymbolValue("core", SVCallInterruptPri, "7")

if (Database.getSymbolValue("core", SVCallInterruptPriLock) == False):
    Database.clearSymbolValue("core", SVCallInterruptPriLock)
    Database.setSymbolValue("core", SVCallInterruptPriLock, True)

#PndSV must be lowest priority
PendSVInterruptHandlerIndex    = Interrupt.getInterruptIndex("PendSV")

PendSVInterruptPri          = "NVIC_"+ str(PendSVInterruptHandlerIndex) +"_0_PRIORITY"
PendSVInterruptPriLock      = "NVIC_"+ str(PendSVInterruptHandlerIndex) +"_0_PRIORITY_LOCK"

if (Database.getSymbolValue("core", PendSVInterruptPri) != "7"):
    Database.clearSymbolValue("core", PendSVInterruptPri)
    Database.setSymbolValue("core", PendSVInterruptPri, "7")

if (Database.getSymbolValue("core", PendSVInterruptPriLock) == False):
    Database.clearSymbolValue("core", PendSVInterruptPriLock)
    Database.setSymbolValue("core", PendSVInterruptPriLock, True)

configName  = Variables.get("__CONFIGURATION_NAME")

threadxInitLowLevelAsmHeaderFile = thirdPartyThreadX.createFileSymbol("THREADX_CORTEX_M7_TX_PORT_H", None)
threadxInitLowLevelAsmHeaderFile.setSourcePath("../thirdparty_expresslogic/gcc/Cortex-M7/tx_port.h")
threadxInitLowLevelAsmHeaderFile.setDestPath("../../third_party/rtos/ThreadX/gcc/Cortex-M7/")
threadxInitLowLevelAsmHeaderFile.setProjectPath("ThreadX/gcc/Cortex-M7")
threadxInitLowLevelAsmHeaderFile.setType("HEADER")

threadxInitLowLevelAsmSourceFile = thirdPartyThreadX.createFileSymbol("THREADX_CORTEX_M7_TX_INITIALIZE_LOW_LEVEL_S", None)
threadxInitLowLevelAsmSourceFile.setSourcePath("../thirdparty_expresslogic/gcc/Cortex-M7/tx_initialize_low_level.S.ftl")
threadxInitLowLevelAsmSourceFile.setOutputName("tx_initialize_low_level.S")
threadxInitLowLevelAsmSourceFile.setDestPath("../../third_party/rtos/ThreadX/gcc/Cortex-M7/")
threadxInitLowLevelAsmSourceFile.setProjectPath("ThreadX/gcc/Cortex-M7")
threadxInitLowLevelAsmSourceFile.setType("SOURCE")
threadxInitLowLevelAsmSourceFile.setMarkup(True)

threadxContextRestoreAsmSourceFile = thirdPartyThreadX.createFileSymbol("THREADX_CORTEX_M7_TX_THREAD_CONTEXT_RESTORE_S", None)
threadxContextRestoreAsmSourceFile.setSourcePath("../thirdparty_expresslogic/gcc/Cortex-M7/tx_thread_context_restore.S")
threadxContextRestoreAsmSourceFile.setDestPath("../../third_party/rtos/ThreadX/gcc/Cortex-M7/")
threadxContextRestoreAsmSourceFile.setProjectPath("ThreadX/gcc/Cortex-M7")
threadxContextRestoreAsmSourceFile.setType("SOURCE")

threadxContextSaveAsmSourceFile = thirdPartyThreadX.createFileSymbol("THREADX_CORTEX_M7_TX_THREAD_CONTEXT_SAVE_S", None)
threadxContextSaveAsmSourceFile.setSourcePath("../thirdparty_expresslogic/gcc/Cortex-M7/tx_thread_context_save.S")
threadxContextSaveAsmSourceFile.setDestPath("../../third_party/rtos/ThreadX/gcc/Cortex-M7/")
threadxContextSaveAsmSourceFile.setProjectPath("ThreadX/gcc/Cortex-M7")
threadxContextSaveAsmSourceFile.setType("SOURCE")

threadxInterruptControlAsmSourceFile = thirdPartyThreadX.createFileSymbol("THREADX_CORTEX_M7_TX_THREAD_INTERRUPT_CONTROL_S", None)
threadxInterruptControlAsmSourceFile.setSourcePath("../thirdparty_expresslogic/gcc/Cortex-M7/tx_thread_interrupt_control.S")
threadxInterruptControlAsmSourceFile.setDestPath("../../third_party/rtos/ThreadX/gcc/Cortex-M7/")
threadxInterruptControlAsmSourceFile.setProjectPath("ThreadX/gcc/Cortex-M7")
threadxInterruptControlAsmSourceFile.setType("SOURCE")

threadxScheduleAsmSourceFile = thirdPartyThreadX.createFileSymbol("THREADX_CORTEX_M7_TX_THREAD_SCHEDULE_S", None)
threadxScheduleAsmSourceFile.setSourcePath("../thirdparty_expresslogic/gcc/Cortex-M7/tx_thread_schedule.S")
threadxScheduleAsmSourceFile.setDestPath("../../third_party/rtos/ThreadX/gcc/Cortex-M7/")
threadxScheduleAsmSourceFile.setProjectPath("ThreadX/gcc/Cortex-M7")
threadxScheduleAsmSourceFile.setType("SOURCE")

threadxStackBuildAsmSourceFile = thirdPartyThreadX.createFileSymbol("THREADX_CORTEX_M7_TX_THREAD_STACK_BUILD_S", None)
threadxStackBuildAsmSourceFile.setSourcePath("../thirdparty_expresslogic/gcc/Cortex-M7/tx_thread_stack_build.S")
threadxStackBuildAsmSourceFile.setDestPath("../../third_party/rtos/ThreadX/gcc/Cortex-M7/")
threadxStackBuildAsmSourceFile.setProjectPath("ThreadX/gcc/Cortex-M7")
threadxStackBuildAsmSourceFile.setType("SOURCE")

threadxSystemReturnAsmSourceFile = thirdPartyThreadX.createFileSymbol("THREADX_CORTEX_M7_TX_THREAD_SYSTEM_RETURN_S", None)
threadxSystemReturnAsmSourceFile.setSourcePath("../thirdparty_expresslogic/gcc/Cortex-M7/tx_thread_system_return.S")
threadxSystemReturnAsmSourceFile.setDestPath("../../third_party/rtos/ThreadX/gcc/Cortex-M7/")
threadxSystemReturnAsmSourceFile.setProjectPath("ThreadX/gcc/Cortex-M7")
threadxSystemReturnAsmSourceFile.setType("SOURCE")

threadxTimerIntrAsmSourceFile = thirdPartyThreadX.createFileSymbol("THREADX_CORTEX_M7_TX_TIMER_INTERRUPT_S", None)
threadxTimerIntrAsmSourceFile.setSourcePath("../thirdparty_expresslogic/gcc/Cortex-M7/tx_timer_interrupt.S")
threadxTimerIntrAsmSourceFile.setDestPath("../../third_party/rtos/ThreadX/gcc/Cortex-M7/")
threadxTimerIntrAsmSourceFile.setProjectPath("ThreadX/gcc/Cortex-M7")
threadxTimerIntrAsmSourceFile.setType("SOURCE")

# Update C32 Include directories path
threadxxc32LdPreprocessroMacroSym = thirdPartyThreadX.createSettingSymbol("THREADX_XC32_LINKER_PREPROC_MARCOS", None)
threadxxc32LdPreprocessroMacroSym.setCategory("C32")
threadxxc32LdPreprocessroMacroSym.setKey("preprocessor-macros")
threadxxc32LdPreprocessroMacroSym.setValue("TX_INCLUDE_USER_DEFINE_FILE")

threadxOsXc32SettingSym = thirdPartyThreadX.createSettingSymbol("THREADX_OS_XC32_INCLUDE_DIRS", None)
threadxOsXc32SettingSym.setCategory("C32")
threadxOsXc32SettingSym.setKey("extra-include-directories")
threadxOsXc32SettingSym.setValue("../src/config/" + configName + "/threadx_config;../src/third_party/rtos/ThreadX;../src/third_party/rtos/ThreadX/gcc/Cortex-M7/;")
threadxOsXc32SettingSym.setAppend(True, ";")

threadxIncDirForAsm = thirdPartyThreadX.createSettingSymbol("THREADX_XC32_AS_INCLUDE_DIRS", None)
threadxIncDirForAsm.setCategory("C32-AS")
threadxIncDirForAsm.setKey("extra-include-directories-for-assembler")
threadxIncDirForAsm.setValue("../src/third_party/rtos/ThreadX/gcc/Cortex-M7/;")
threadxIncDirForAsm.setAppend(True, ";")

threadxIncDirForPre = thirdPartyThreadX.createSettingSymbol("THREADX_XC32_AS_INCLUDE_PRE_PROC_DIRS", None)
threadxIncDirForPre.setCategory("C32-AS")
threadxIncDirForPre.setKey("extra-include-directories-for-preprocessor")
threadxIncDirForPre.setValue("../src/third_party/rtos/ThreadX/gcc/Cortex-M7/;")
threadxIncDirForPre.setAppend(True, ";")
