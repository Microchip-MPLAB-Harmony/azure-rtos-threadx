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
threadxTimer1SourceFile.setDestPath("../../third_party/rtos/ThreadX/tx58" + coreName.lower() + "_mplabx/threadx/")
threadxTimer1SourceFile.setProjectPath("ThreadX/" + coreName.upper())
threadxTimer1SourceFile.setType("SOURCE")
threadxTimer1SourceFile.setMarkup(True)

threadxTimer1Headerfile = thirdPartyThreadX.createFileSymbol("THREADX_TMR1_H", None)
threadxTimer1Headerfile.setSourcePath("config/arch/mips/templates/tmr1/tx_tmr1.h")
threadxTimer1Headerfile.setDestPath("../../third_party/rtos/ThreadX/tx58" + coreName.lower() + "_mplabx/threadx/")
threadxTimer1Headerfile.setProjectPath("ThreadX/" + coreName.upper())
threadxTimer1Headerfile.setType("HEADER")

threadxTaskContextStackHeaderFile = thirdPartyThreadX.createFileSymbol("THREADX_PIC32MZ_TX_CPU_INC", None)
threadxTaskContextStackHeaderFile.setSourcePath("../thirdparty_expresslogic/tx58pic32mz_mplabx/ThreadX/tx_cpu.inc")
threadxTaskContextStackHeaderFile.setDestPath("../../third_party/rtos/ThreadX/tx58" + coreName.lower() + "_mplabx/threadx/")
threadxTaskContextStackHeaderFile.setProjectPath("ThreadX/" + coreName.upper())
threadxTaskContextStackHeaderFile.setType("HEADER")

# Update C32 Include directories path
threadxxc32LdPreprocessroMacroSym = thirdPartyThreadX.createSettingSymbol("THREADX_XC32_LINKER_PREPROC_MARCOS", None)
threadxxc32LdPreprocessroMacroSym.setCategory("C32")
threadxxc32LdPreprocessroMacroSym.setKey("preprocessor-macros")
threadxxc32LdPreprocessroMacroSym.setValue("TX_INCLUDE_USER_DEFINE_FILE")

threadxOsXc32SettingSym = thirdPartyThreadX.createSettingSymbol("THREADX_OS_XC32_INCLUDE_DIRS", None)
threadxOsXc32SettingSym.setCategory("C32")
threadxOsXc32SettingSym.setKey("extra-include-directories")
threadxOsXc32SettingSym.setValue("../src/config/" + configName + "/threadx_config;../src/third_party/rtos/ThreadX/tx58" + coreName.lower() + "_mplabx/threadx;")
threadxOsXc32SettingSym.setAppend(True, ";")

threadxIncDirForAsm = thirdPartyThreadX.createSettingSymbol("THREADX_XC32_AS_INCLUDE_DIRS", None)
threadxIncDirForAsm.setCategory("C32-AS")
threadxIncDirForAsm.setKey("extra-include-directories-for-assembler")
threadxIncDirForAsm.setValue("../src/config/" + configName + "/threadx_config;../src/third_party/rtos/ThreadX/tx58" + coreName.lower() + "_mplabx/threadx;")
threadxIncDirForAsm.setAppend(True, ";")

threadxIncDirForPre = thirdPartyThreadX.createSettingSymbol("THREADX_XC32_AS_INCLUDE_PRE_PROC_DIRS", None)
threadxIncDirForPre.setCategory("C32-AS")
threadxIncDirForPre.setKey("extra-include-directories-for-preprocessor")
threadxIncDirForPre.setValue("../src/config/" + configName + "/threadx_config;../src/third_party/rtos/ThreadX/tx58" + coreName.lower() + "_mplabx/threadx;")
threadxIncDirForPre.setAppend(True, ";")
