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
############### PIC32MZ Architecture specific configuration ##############
############################################################################

#Default Byte Pool size
threadxSym_BytePoolSize.setDefaultValue(28000)

#CPU Clock Frequency
cpuclk = Database.getSymbolValue("core", "SYS_CLK_FREQ")
cpuclk = int(cpuclk)

threadxSym_CpuClockHz.setDefaultValue(cpuclk)
threadxSym_CpuClockHz.setDependencies(threadxCpuClockHz, ["core.SYS_CLK_FREQ"])

perclk = Database.getSymbolValue("core", "CONFIG_SYS_CLK_PBCLK2_FREQ")
perclk = int(perclk)

threadxSym_PerClockHz.setDefaultValue(perclk)
threadxSym_PerClockHz.setDependencies(threadxCpuClockHz, ["core.CONFIG_SYS_CLK_PBCLK2_FREQ"])
threadxSym_PerClockHz.setReadOnly(True)

configName  = Variables.get("__CONFIGURATION_NAME")

threadxTaskContextStackHeaderFile = thirdPartyThreadX.createFileSymbol("THREADX_PIC32MZ_TX_CPU_INC", None)
threadxTaskContextStackHeaderFile.setSourcePath("../thirdparty_expresslogic/gcc/PIC32MZ/tx_cpu.inc")
threadxTaskContextStackHeaderFile.setDestPath("../../third_party/rtos/ThreadX/gcc/PIC32MZ/")
threadxTaskContextStackHeaderFile.setProjectPath("ThreadX/gcc/PIC32MZ")
threadxTaskContextStackHeaderFile.setType("HEADER")

threadxInitLowLevelAsmHeaderFile = thirdPartyThreadX.createFileSymbol("THREADX_PIC32MZ_TX_PORT_H", None)
threadxInitLowLevelAsmHeaderFile.setSourcePath("../thirdparty_expresslogic/gcc/PIC32MZ/tx_port.h")
threadxInitLowLevelAsmHeaderFile.setDestPath("../../third_party/rtos/ThreadX/gcc/PIC32MZ/")
threadxInitLowLevelAsmHeaderFile.setProjectPath("ThreadX/gcc/PIC32MZ")
threadxInitLowLevelAsmHeaderFile.setType("HEADER")

threadxInitLowLevelAsmSourceFile = thirdPartyThreadX.createFileSymbol("THREADX_PIC32MZ_TX_INITIALIZE_LOW_LEVEL_S", None)
threadxInitLowLevelAsmSourceFile.setSourcePath("../thirdparty_expresslogic/gcc/PIC32MZ/tx_initialize_low_level.S")
threadxInitLowLevelAsmSourceFile.setDestPath("../../third_party/rtos/ThreadX/gcc/PIC32MZ/")
threadxInitLowLevelAsmSourceFile.setProjectPath("ThreadX/gcc/PIC32MZ")
threadxInitLowLevelAsmSourceFile.setType("SOURCE")

threadxContextRestoreAsmSourceFile = thirdPartyThreadX.createFileSymbol("THREADX_PIC32MZ_TX_THREAD_CONTEXT_RESTORE_S", None)
threadxContextRestoreAsmSourceFile.setSourcePath("../thirdparty_expresslogic/gcc/PIC32MZ/tx_thread_context_restore.S")
threadxContextRestoreAsmSourceFile.setDestPath("../../third_party/rtos/ThreadX/gcc/PIC32MZ/")
threadxContextRestoreAsmSourceFile.setProjectPath("ThreadX/gcc/PIC32MZ")
threadxContextRestoreAsmSourceFile.setType("SOURCE")

threadxContextSaveAsmSourceFile = thirdPartyThreadX.createFileSymbol("THREADX_PIC32MZ_TX_THREAD_CONTEXT_SAVE_S", None)
threadxContextSaveAsmSourceFile.setSourcePath("../thirdparty_expresslogic/gcc/PIC32MZ/tx_thread_context_save.S")
threadxContextSaveAsmSourceFile.setDestPath("../../third_party/rtos/ThreadX/gcc/PIC32MZ/")
threadxContextSaveAsmSourceFile.setProjectPath("ThreadX/gcc/PIC32MZ")
threadxContextSaveAsmSourceFile.setType("SOURCE")

threadxInterruptControlAsmSourceFile = thirdPartyThreadX.createFileSymbol("THREADX_PIC32MZ_TX_THREAD_INTERRUPT_CONTROL_S", None)
threadxInterruptControlAsmSourceFile.setSourcePath("../thirdparty_expresslogic/gcc/PIC32MZ/tx_thread_interrupt_control.S")
threadxInterruptControlAsmSourceFile.setDestPath("../../third_party/rtos/ThreadX/gcc/PIC32MZ/")
threadxInterruptControlAsmSourceFile.setProjectPath("ThreadX/gcc/PIC32MZ")
threadxInterruptControlAsmSourceFile.setType("SOURCE")

threadxScheduleAsmSourceFile = thirdPartyThreadX.createFileSymbol("THREADX_PIC32MZ_TX_THREAD_SCHEDULE_S", None)
threadxScheduleAsmSourceFile.setSourcePath("../thirdparty_expresslogic/gcc/PIC32MZ/tx_thread_schedule.S")
threadxScheduleAsmSourceFile.setDestPath("../../third_party/rtos/ThreadX/gcc/PIC32MZ/")
threadxScheduleAsmSourceFile.setProjectPath("ThreadX/gcc/PIC32MZ")
threadxScheduleAsmSourceFile.setType("SOURCE")

threadxStackBuildAsmSourceFile = thirdPartyThreadX.createFileSymbol("THREADX_PIC32MZ_TX_THREAD_STACK_BUILD_S", None)
threadxStackBuildAsmSourceFile.setSourcePath("../thirdparty_expresslogic/gcc/PIC32MZ/tx_thread_stack_build.S")
threadxStackBuildAsmSourceFile.setDestPath("../../third_party/rtos/ThreadX/gcc/PIC32MZ/")
threadxStackBuildAsmSourceFile.setProjectPath("ThreadX/gcc/PIC32MZ")
threadxStackBuildAsmSourceFile.setType("SOURCE")

threadxSystemReturnAsmSourceFile = thirdPartyThreadX.createFileSymbol("THREADX_PIC32MZ_TX_THREAD_SYSTEM_RETURN_S", None)
threadxSystemReturnAsmSourceFile.setSourcePath("../thirdparty_expresslogic/gcc/PIC32MZ/tx_thread_system_return.S")
threadxSystemReturnAsmSourceFile.setDestPath("../../third_party/rtos/ThreadX/gcc/PIC32MZ/")
threadxSystemReturnAsmSourceFile.setProjectPath("ThreadX/gcc/PIC32MZ")
threadxSystemReturnAsmSourceFile.setType("SOURCE")

threadxTimerIntrAsmSourceFile = thirdPartyThreadX.createFileSymbol("THREADX_PIC32MZ_TX_TIMER_INTERRUPT_S", None)
threadxTimerIntrAsmSourceFile.setSourcePath("../thirdparty_expresslogic/gcc/PIC32MZ/tx_timer_interrupt.S")
threadxTimerIntrAsmSourceFile.setDestPath("../../third_party/rtos/ThreadX/gcc/PIC32MZ/")
threadxTimerIntrAsmSourceFile.setProjectPath("ThreadX/gcc/PIC32MZ")
threadxTimerIntrAsmSourceFile.setType("SOURCE")

# Update C32 Include directories path
threadxxc32LdPreprocessroMacroSym = thirdPartyThreadX.createSettingSymbol("THREADX_XC32_LINKER_PREPROC_MARCOS", None)
threadxxc32LdPreprocessroMacroSym.setCategory("C32")
threadxxc32LdPreprocessroMacroSym.setKey("preprocessor-macros")
threadxxc32LdPreprocessroMacroSym.setValue("TX_INCLUDE_USER_DEFINE_FILE")

threadxOsXc32SettingSym = thirdPartyThreadX.createSettingSymbol("THREADX_OS_XC32_INCLUDE_DIRS", None)
threadxOsXc32SettingSym.setCategory("C32")
threadxOsXc32SettingSym.setKey("extra-include-directories")
threadxOsXc32SettingSym.setValue("../src/config/" + configName + "/threadx_config;../src/third_party/rtos/ThreadX;../src/third_party/rtos/ThreadX/gcc/PIC32MZ/;")
threadxOsXc32SettingSym.setAppend(True, ";")

threadxIncDirForAsm = thirdPartyThreadX.createSettingSymbol("THREADX_XC32_AS_INCLUDE_DIRS", None)
threadxIncDirForAsm.setCategory("C32-AS")
threadxIncDirForAsm.setKey("extra-include-directories-for-assembler")
threadxIncDirForAsm.setValue("../src/third_party/rtos/ThreadX/gcc/PIC32MZ/;")
threadxIncDirForAsm.setAppend(True, ";")

threadxIncDirForPre = thirdPartyThreadX.createSettingSymbol("THREADX_XC32_AS_INCLUDE_PRE_PROC_DIRS", None)
threadxIncDirForPre.setCategory("C32-AS")
threadxIncDirForPre.setKey("extra-include-directories-for-preprocessor")
threadxIncDirForPre.setValue("../src/third_party/rtos/ThreadX/gcc/PIC32MZ/;")
threadxIncDirForPre.setAppend(True, ";")
