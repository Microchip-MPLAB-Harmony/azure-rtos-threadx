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
############### Cortex-A5 Architecture specific configuration ##############
############################################################################
def updateIncludePath(symbol, event):
    configName = Variables.get("__CONFIGURATION_NAME")
    coreArch = Database.getSymbolValue("core", "CoreArchitecture")
    coreName = coreArch.replace("-", "_")
    compiler = "/mplabx" if Database.getSymbolValue("core", "COMPILER_CHOICE") == 0 else "/iar"
    symbol.setValue("../src/config/" + configName + "/threadx_config;../src/third_party/rtos/threadx/common/inc;../src/third_party/rtos/threadx/ports/" + coreName.lower() + compiler + "/inc;")

#Default Byte Pool size
threadxSym_BytePoolSize.setDefaultValue(40960)

#CPU Clock Frequency
threadxSym_CpuClockHz.setDependencies(threadxCpuClockHz, ["core.CPU_CLOCK_FREQUENCY"])
threadxSym_CpuClockHz.setDefaultValue(int(Database.getSymbolValue("core", "CPU_CLOCK_FREQUENCY")))

Database.activateComponents(["pit"]);
Database.setSymbolValue("pit", "RTOS_INTERRUPT_HANDLER", "Threadx_Tick_Handler")
Database.setSymbolValue("core", "USE_THREADX_VECTORS", True)
Database.setSymbolValue("pit", "ENABLE_COUNTER", False)

# Update Include directories path
threadxLdPreprocessorMacroSym = thirdPartyThreadX.createSettingSymbol("THREADX_LINKER_PREPROC_MARCOS", None)
threadxLdPreprocessorMacroSym.setCategory("C32")
threadxLdPreprocessorMacroSym.setKey("preprocessor-macros")
threadxLdPreprocessorMacroSym.setValue("TX_INCLUDE_USER_DEFINE_FILE")
threadxLdPreprocessorMacroSym.setAppend(True, ";")

threadxLdPreprocessorMacroSym_xc32cpp = thirdPartyThreadX.createSettingSymbol("THREADX_LINKER_PREPROC_MACROS_XC32CPP", None)
threadxLdPreprocessorMacroSym_xc32cpp.setCategory("C32CPP")
threadxLdPreprocessorMacroSym_xc32cpp.setKey("preprocessor-macros")
threadxLdPreprocessorMacroSym_xc32cpp.setValue(threadxLdPreprocessorMacroSym.getValue())
threadxLdPreprocessorMacroSym_xc32cpp.setAppend(True, ";")
threadxLdPreprocessorMacroSym_xc32cpp.setEnabled(Database.getSymbolValue("core", "COMPILER_CHOICE") == 0)
threadxLdPreprocessorMacroSym_xc32cpp.setDependencies(lambda symbol, event: symbol.setEnabled(Database.getSymbolValue("core", "COMPILER_CHOICE") == 0), ['core.COMPILER_CHOICE'])

txIncPath = "../src/config/" + configName + "/threadx_config;../src/third_party/rtos/threadx/common/inc;../src/third_party/rtos/threadx/ports/" + coreName.lower() + "/iar/inc;" if compiler == 1 else "/mplabx/inc;"
threadxOsSettingSym = thirdPartyThreadX.createSettingSymbol("THREADX_OS_INCLUDE_DIRS", None)
threadxOsSettingSym.setCategory("C32")
threadxOsSettingSym.setKey("extra-include-directories")
threadxOsSettingSym.setValue(txIncPath)
threadxOsSettingSym.setAppend(True, ";")
threadxOsSettingSym.setDependencies(updateIncludePath, ['core.COMPILER_CHOICE'])

threadxOsSettingSym_xc32cpp = thirdPartyThreadX.createSettingSymbol("THREADX_OS_INCLUDE_DIRS_XC32CPP", None)
threadxOsSettingSym_xc32cpp.setCategory("C32CPP")
threadxOsSettingSym_xc32cpp.setKey("extra-include-directories")
threadxOsSettingSym_xc32cpp.setValue(threadxOsSettingSym.getValue())
threadxOsSettingSym_xc32cpp.setAppend(True, ";")
threadxOsSettingSym_xc32cpp.setEnabled(Database.getSymbolValue("core", "COMPILER_CHOICE") == 0)
threadxOsSettingSym_xc32cpp.setDependencies(lambda symbol, event: symbol.setEnabled(Database.getSymbolValue("core", "COMPILER_CHOICE") == 0), ['core.COMPILER_CHOICE'])

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

threadxxc32InitializeLowLevelAsm = thirdPartyThreadX.createFileSymbol("THREADX_TX_INITIALIZE_LOW_LEVEL_S", None)
threadxxc32InitializeLowLevelAsm.setSourcePath("config/arch/arm/devices_" + coreName.lower() + "/src/xc32/tx_initialize_low_level.S")
threadxxc32InitializeLowLevelAsm.setOutputName("tx_initialize_low_level.S")
threadxxc32InitializeLowLevelAsm.setDestPath("../../third_party/rtos/threadx/ports/" + coreName.lower() + "/mplabx/src/")
threadxxc32InitializeLowLevelAsm.setProjectPath("threadx/ports/" + coreName.lower() + "/mplabx/src/")
threadxxc32InitializeLowLevelAsm.setType("SOURCE")
threadxxc32InitializeLowLevelAsm.setEnabled(Database.getSymbolValue("core", "COMPILER_CHOICE") == 0)
threadxxc32InitializeLowLevelAsm.setDependencies(lambda symbol, event: symbol.setEnabled(Database.getSymbolValue("core", "COMPILER_CHOICE") == 0), ['core.COMPILER_CHOICE'])

threadxIarInitializeLowLevelAsm = thirdPartyThreadX.createFileSymbol("THREADX_TX_INITIALIZE_LOW_LEVEL_S_IAR", None)
threadxIarInitializeLowLevelAsm.setSourcePath("config/arch/arm/devices_" + coreName.lower() + "/src/iar/tx_initialize_low_level.s")
threadxIarInitializeLowLevelAsm.setOutputName("tx_initialize_low_level.s")
threadxIarInitializeLowLevelAsm.setDestPath("../../third_party/rtos/threadx/ports/" + coreName.lower() + "/iar/src/")
threadxIarInitializeLowLevelAsm.setProjectPath("threadx/ports/" + coreName.lower() + "/iar/src/")
threadxIarInitializeLowLevelAsm.setType("SOURCE")
threadxIarInitializeLowLevelAsm.setEnabled(Database.getSymbolValue("core", "COMPILER_CHOICE") == 1)
threadxIarInitializeLowLevelAsm.setDependencies(lambda symbol, event: symbol.setEnabled(Database.getSymbolValue("core", "COMPILER_CHOICE") == 1), ['core.COMPILER_CHOICE'])

threadxxc32TxPortHeader = thirdPartyThreadX.createFileSymbol("THREADX_TX_PORT_H", None)
threadxxc32TxPortHeader.setSourcePath("config/arch/arm/devices_" + coreName.lower() + "/src/xc32/tx_port.h")
threadxxc32TxPortHeader.setOutputName("tx_port.h")
threadxxc32TxPortHeader.setDestPath("../../third_party/rtos/threadx/ports/" + coreName.lower() + "/mplabx/inc/")
threadxxc32TxPortHeader.setProjectPath("threadx/ports/" + coreName.lower() + "/mplabx/inc/")
threadxxc32TxPortHeader.setType("HEADER")
threadxxc32TxPortHeader.setEnabled(Database.getSymbolValue("core", "COMPILER_CHOICE") == 0)
threadxxc32TxPortHeader.setDependencies(lambda symbol, event: symbol.setEnabled(Database.getSymbolValue("core", "COMPILER_CHOICE") == 0), ['core.COMPILER_CHOICE'])

threadxIarPortASMsource = thirdPartyThreadX.createFileSymbol("THREADX_IAR_PORT_S", None)
threadxIarPortASMsource.setSourcePath("config/arch/arm/devices_cortex_a5/src/iar/sama5d2_tx_port.s")
threadxIarPortASMsource.setOutputName("sama5d2_tx_port.s")
threadxIarPortASMsource.setDestPath("threadx_config/")
threadxIarPortASMsource.setProjectPath("config/" + configName + "/threadx_config/")
threadxIarPortASMsource.setType("SOURCE")
threadxIarPortASMsource.setDependencies(lambda symbol, event: symbol.setEnabled(Database.getSymbolValue("core", "COMPILER_CHOICE") == 1), ['core.COMPILER_CHOICE'])
threadxIarPortASMsource.setEnabled(Database.getSymbolValue("core", "COMPILER_CHOICE")  == 1)

threadxXc32PortASMsource = thirdPartyThreadX.createFileSymbol("THREADX_XC32_PORT_S", None)
threadxXc32PortASMsource.setSourcePath("config/arch/arm/devices_cortex_a5/src/xc32/sama5d2_tx_port.S")
threadxXc32PortASMsource.setOutputName("sama5d2_tx_port.S")
threadxXc32PortASMsource.setDestPath("threadx_config/")
threadxXc32PortASMsource.setProjectPath("config/" + configName + "/threadx_config/")
threadxXc32PortASMsource.setType("SOURCE")
threadxXc32PortASMsource.setDependencies(lambda symbol, event: symbol.setEnabled(Database.getSymbolValue("core", "COMPILER_CHOICE") == 0), ['core.COMPILER_CHOICE'])
threadxXc32PortASMsource.setEnabled(Database.getSymbolValue("core", "COMPILER_CHOICE") == 0)

threadxTimerSource = thirdPartyThreadX.createFileSymbol("THREADX_TX_TIMER", None)
threadxTimerSource.setSourcePath("config/arch/arm/devices_cortex_a5/src/sama5d2_tx_timer.c")
threadxTimerSource.setOutputName("sama5d2_tx_timer.c")
threadxTimerSource.setDestPath("threadx_config/")
threadxTimerSource.setProjectPath("config/" + configName + "/threadx_config/")
threadxTimerSource.setType("SOURCE")
threadxTimerSource.setMarkup(False)
