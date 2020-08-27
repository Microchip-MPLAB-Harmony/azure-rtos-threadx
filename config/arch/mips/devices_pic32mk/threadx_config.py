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
############### PIC32MX Architecture specific configuration ##############
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

#Update Timer1 Interrupt Handler name
timer1Irq                   = "TIMER_1"
timer1InterruptVector       = timer1Irq + "_INTERRUPT_ENABLE"
timer1InterruptHandler      = timer1Irq + "_INTERRUPT_HANDLER"
timer1InterruptHandlerLock  = timer1Irq + "_INTERRUPT_HANDLER_LOCK"

if (Database.getSymbolValue("core", timer1InterruptVector) == False):
    Database.setSymbolValue("core", timer1InterruptVector, True, 1)

if (Database.getSymbolValue("core", timer1InterruptHandlerLock) == False):
    Database.setSymbolValue("core", timer1InterruptHandlerLock, True, 1)

interruptName = timer1InterruptHandler.split("_INTERRUPT_HANDLER")[0]

if (Database.getSymbolValue("core", timer1InterruptHandler) != str (interruptName) + "_InterruptHandler"):
    Database.setSymbolValue("core", timer1InterruptHandler, interruptName + "_InterruptHandler", 1)

#Enable TMR1 Peripheral Clock for FreeRTOS Tick Interrupt Generation
if (Database.getSymbolValue("core", "TMR1_CLOCK_ENABLE") == False):
    Database.clearSymbolValue("core", "TMR1_CLOCK_ENABLE")
    Database.setSymbolValue("core", "TMR1_CLOCK_ENABLE", True)

configName  = Variables.get("__CONFIGURATION_NAME")

threadxTimer1SourceFile = thirdPartyThreadX.createFileSymbol("THREADX_TMR1_C", None)
threadxTimer1SourceFile.setSourcePath("config/arch/mips/templates/tmr1/tx_tmr1.c.ftl")
threadxTimer1SourceFile.setOutputName("tx_tmr1.c")
threadxTimer1SourceFile.setDestPath("threadx_config/")
threadxTimer1SourceFile.setProjectPath("config/" + configName + "/threadx_config/")
threadxTimer1SourceFile.setType("SOURCE")
threadxTimer1SourceFile.setMarkup(True)

threadxTimer1Headerfile = thirdPartyThreadX.createFileSymbol("THREADX_TMR1_H", None)
threadxTimer1Headerfile.setSourcePath("config/arch/mips/templates/tmr1/tx_tmr1.h")
threadxTimer1Headerfile.setOutputName("tx_tmr1.h")
threadxTimer1Headerfile.setDestPath("threadx_config/")
threadxTimer1Headerfile.setProjectPath("config/" + configName + "/threadx_config/")
threadxTimer1Headerfile.setType("HEADER")

threadxPortHeaderfile = thirdPartyThreadX.createFileSymbol("THREADX_TX_PORT_H", None)
threadxPortHeaderfile.setSourcePath("config/arch/mips/devices_" + coreName.lower() + "/src/inc/tx_port.h")
threadxPortHeaderfile.setOutputName("tx_port.h")
threadxPortHeaderfile.setDestPath("../../third_party/rtos/threadx/ports/" + coreName.lower() + "/mplabx/inc/")
threadxPortHeaderfile.setProjectPath("threadx/ports/" + coreName.lower() + "/mplabx/inc/")
threadxPortHeaderfile.setType("HEADER")

threadxTaskContextStackHeaderFile = thirdPartyThreadX.createFileSymbol("THREADX_PIC32MK_TX_CPU_INC", None)
threadxTaskContextStackHeaderFile.setSourcePath("config/arch/mips/devices_" + coreName.lower() + "/src/inc/tx_cpu.inc")
threadxTaskContextStackHeaderFile.setDestPath("../../third_party/rtos/threadx/ports/" + coreName.lower() + "/mplabx/inc/")
threadxTaskContextStackHeaderFile.setProjectPath("threadx/ports/" + coreName.lower() + "/mplabx/inc/")
threadxTaskContextStackHeaderFile.setType("HEADER")

AddThreadXFiles(thirdPartyThreadX, "config/arch/mips/devices_" + coreName.lower() + "/src/", "../../third_party/rtos/threadx/ports/" + coreName.lower() + "/mplabx/src/", True, compilers["XC32"])

# Update C32 Include directories path
threadxxc32LdPreprocessorMacroSym = thirdPartyThreadX.createSettingSymbol("THREADX_XC32_LINKER_PREPROC_MARCOS", None)
threadxxc32LdPreprocessorMacroSym.setCategory("C32")
threadxxc32LdPreprocessorMacroSym.setKey("preprocessor-macros")
threadxxc32LdPreprocessorMacroSym.setValue("TX_INCLUDE_USER_DEFINE_FILE")
threadxxc32LdPreprocessorMacroSym.setAppend(True, ";")

threadxxc32cppLdPreprocessorMacroSym = thirdPartyThreadX.createSettingSymbol("THREADX_XC32CPP_LINKER_PREPROC_MARCOS", None)
threadxxc32cppLdPreprocessorMacroSym.setCategory("C32CPP")
threadxxc32cppLdPreprocessorMacroSym.setKey("preprocessor-macros")
threadxxc32cppLdPreprocessorMacroSym.setValue(threadxxc32LdPreprocessorMacroSym.getValue())
threadxxc32cppLdPreprocessorMacroSym.setAppend(True, ";")

txIncPath = "../src/config/" + configName + "/threadx_config;../src/third_party/rtos/threadx/common/inc;../src/third_party/rtos/threadx/ports/" + coreName.lower() + "/mplabx/inc;"
threadxOsXc32SettingSym = thirdPartyThreadX.createSettingSymbol("THREADX_OS_XC32_INCLUDE_DIRS", None)
threadxOsXc32SettingSym.setCategory("C32")
threadxOsXc32SettingSym.setKey("extra-include-directories")
threadxOsXc32SettingSym.setValue(txIncPath)
threadxOsXc32SettingSym.setAppend(True, ";")

threadxOsXc32cppSettingSym = thirdPartyThreadX.createSettingSymbol("THREADX_OS_XC32CPP_INCLUDE_DIRS", None)
threadxOsXc32cppSettingSym.setCategory("C32CPP")
threadxOsXc32cppSettingSym.setKey("extra-include-directories")
threadxOsXc32cppSettingSym.setValue(threadxOsXc32SettingSym.getValue())
threadxOsXc32cppSettingSym.setAppend(True, ";")

threadxIncDirForAsm = thirdPartyThreadX.createSettingSymbol("THREADX_XC32_AS_INCLUDE_DIRS", None)
threadxIncDirForAsm.setCategory("C32-AS")
threadxIncDirForAsm.setKey("extra-include-directories-for-assembler")
threadxIncDirForAsm.setValue(txIncPath)
threadxIncDirForAsm.setAppend(True, ";")

threadxIncDirForPre = thirdPartyThreadX.createSettingSymbol("THREADX_XC32_AS_INCLUDE_PRE_PROC_DIRS", None)
threadxIncDirForPre.setCategory("C32-AS")
threadxIncDirForPre.setKey("extra-include-directories-for-preprocessor")
threadxIncDirForPre.setValue(txIncPath)
threadxIncDirForPre.setAppend(True, ";")
