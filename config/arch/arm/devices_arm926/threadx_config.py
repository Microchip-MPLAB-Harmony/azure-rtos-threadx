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
############### ARM926EJS Architecture specific configuration ##############
############################################################################
def updateIncludePath(symbol, event):
    configName = Variables.get("__CONFIGURATION_NAME")
    coreArch = Database.getSymbolValue("core", "CoreArchitecture")
    coreName = coreArch.replace("-", "_").replace("PLUS", "").replace("EJS","").lower()
    compiler = "_mplabx" if Database.getSymbolValue("core", "COMPILER_CHOICE") == 0 else "_iar"
    symbol.setValue("../src/config/" + configName + "/threadx_config;../src/third_party/rtos/threadx/tx58" + coreName.lower() + compiler + "/threadx;")

def changeTimerTick(symbol, event):
    pit64Period = (long)(Database.getSymbolValue("core", "PIT64B_CLOCK_FREQUENCY") / 
                         event["source"].getSymbolValue("THREADX_TICK_RATE_HZ"))
    Database.setSymbolValue("pit64b", "PERIOD", pit64Period)

#Default Byte Pool size
threadxSym_BytePoolSize.setDefaultValue(40960)

# CPU Clock Frequency 
cpuclk = int(Database.getSymbolValue("core", "CPU_CLOCK_FREQUENCY"))
threadxSym_CpuClockHz.setDependencies(threadxCpuClockHz, ["core.CPU_CLOCK_FREQUENCY"])
threadxSym_CpuClockHz.setDefaultValue(cpuclk)

#Set timer to work with the configured tick rate (NOTE: will not work with prescaler)
Database.activateComponents(["pit64b"])
Database.setSymbolValue("core", "USE_THREADX_VECTORS", True)
Database.setSymbolValue("pit64b", "PERIOD_INT", True)
Database.setSymbolValue("pit64b", "CONT", True)
pit64Period = (long)(Database.getSymbolValue("core", "PIT64B_CLOCK_FREQUENCY") / threadxSym_TickRate.getValue())
Database.setSymbolValue("pit64b", "PERIOD", pit64Period)
tickChangeListenerSym = thirdPartyThreadX.createBooleanSymbol("TICK_CHANGE_LISTENER", None)
tickChangeListenerSym.setVisible(False)
tickChangeListenerSym.setDependencies(changeTimerTick, ["THREADX_TICK_RATE_HZ"])

############################################################################
#### Code Generation ####
############################################################################
configName  = Variables.get("__CONFIGURATION_NAME")

# Update Include directories path
threadxLdPreprocessroMacroSym = thirdPartyThreadX.createSettingSymbol("THREADX_LINKER_PREPROC_MACROS", None)
threadxLdPreprocessroMacroSym.setCategory("C32")
threadxLdPreprocessroMacroSym.setKey("preprocessor-macros")
threadxLdPreprocessroMacroSym.setValue("TX_INCLUDE_USER_DEFINE_FILE")
threadxLdPreprocessroMacroSym.setAppend(True, ";")

txIncPath = "../src/config/" + configName + "/threadx_config;../src/third_party/rtos/Threadx/tx58" + coreName.lower() + "_iar/threadx" if compiler == 1 else "_mplabx/threadx"
threadxIncludeSettingsSym = thirdPartyThreadX.createSettingSymbol("THREADX_OS_INCLUDE_DIRS", None)
threadxIncludeSettingsSym.setCategory("C32")
threadxIncludeSettingsSym.setKey("extra-include-directories")
threadxIncludeSettingsSym.setValue(txIncPath)
threadxIncludeSettingsSym.setAppend(True, ";")
threadxIncludeSettingsSym.setDependencies(updateIncludePath, ['core.COMPILER_CHOICE'])

threadxIncDirForAsm = thirdPartyThreadX.createSettingSymbol("THREADX_AS_INCLUDE_DIRS", None)
threadxIncDirForAsm.setCategory("C32-AS")
threadxIncDirForAsm.setKey("extra-include-directories-for-assembler")
threadxIncDirForAsm.setValue(txIncPath)
threadxIncDirForAsm.setAppend(True, ";")
threadxIncDirForAsm.setDependencies(updateIncludePath, ['core.COMPILER_CHOICE'])

threadxIncDirForPre = thirdPartyThreadX.createSettingSymbol("THREADX_AS_INCLUDE_PRE_PROC_DIRS", None)
threadxIncDirForPre.setCategory("C32-AS")
threadxIncDirForPre.setKey("extra-include-directories-for-preprocessor")
threadxIncDirForPre.setValue(txIncPath)
threadxIncDirForPre.setAppend(True, ";")
threadxIncDirForPre.setDependencies(updateIncludePath, ['core.COMPILER_CHOICE'])

threadxIarPortAsmFileSym = thirdPartyThreadX.createFileSymbol("SAM_9X6_TX_PORT_S", None)
threadxIarPortAsmFileSym.setSourcePath("config/arch/arm/devices_arm926/src/iar/sam9x6_tx_port.s")
threadxIarPortAsmFileSym.setOutputName("sam9x6_tx_port.s")
threadxIarPortAsmFileSym.setDestPath("threadx_config/")
threadxIarPortAsmFileSym.setProjectPath("config/" + configName + "/threadx_config/")
threadxIarPortAsmFileSym.setType("SOURCE")
threadxIarPortAsmFileSym.setMarkup(False)
threadxIarPortAsmFileSym.setDependencies(lambda symbol, event: symbol.setEnabled(Database.getSymbolValue("core", "COMPILER_CHOICE") == 1), ['core.COMPILER_CHOICE'])
threadxIarPortAsmFileSym.setEnabled(Database.getSymbolValue("core", "COMPILER_CHOICE") == 1)

threadxXc32PortAsmFileSym = thirdPartyThreadX.createFileSymbol("THREADX_XC32_PORT_S", None)
threadxXc32PortAsmFileSym.setSourcePath("config/arch/arm/devices_arm926/src/xc32/sam9x6_tx_port.S")
threadxXc32PortAsmFileSym.setOutputName("sam9x6_tx_port.S")
threadxXc32PortAsmFileSym.setDestPath("threadx_config/")
threadxXc32PortAsmFileSym.setProjectPath("config/" + configName + "/threadx_config/")
threadxXc32PortAsmFileSym.setType("SOURCE")
threadxXc32PortAsmFileSym.setMarkup(False)
threadxXc32PortAsmFileSym.setDependencies(lambda symbol, event: symbol.setEnabled(Database.getSymbolValue("core", "COMPILER_CHOICE") == 0), ['core.COMPILER_CHOICE'])
threadxXc32PortAsmFileSym.setEnabled(Database.getSymbolValue("core", "COMPILER_CHOICE") == 0)

threadxPortTimerSrcFileSym = thirdPartyThreadX.createFileSymbol("SAM_9X6_TX_TIMER_C", None)
threadxPortTimerSrcFileSym.setSourcePath("config/arch/arm/devices_arm926/src/sam9x6_tx_timer.c")
threadxPortTimerSrcFileSym.setOutputName("sam9x6_tx_timer.c")
threadxPortTimerSrcFileSym.setDestPath("threadx_config/")
threadxPortTimerSrcFileSym.setProjectPath("config/" + configName + "/threadx_config/")
threadxPortTimerSrcFileSym.setType("SOURCE")
threadxPortTimerSrcFileSym.setMarkup(False)

threadxPortTimerHdrFileSym = thirdPartyThreadX.createFileSymbol("SAM_9X6_TX_TIMER_H", None)
threadxPortTimerHdrFileSym.setSourcePath("config/arch/arm/devices_arm926/src/sam9x6_tx_timer.h")
threadxPortTimerHdrFileSym.setOutputName("sam9x6_tx_timer.h")
threadxPortTimerHdrFileSym.setDestPath("threadx_config/")
threadxPortTimerHdrFileSym.setProjectPath("config/" + configName + "/threadx_config/")
threadxPortTimerHdrFileSym.setType("HEADER")
threadxPortTimerHdrFileSym.setMarkup(False)