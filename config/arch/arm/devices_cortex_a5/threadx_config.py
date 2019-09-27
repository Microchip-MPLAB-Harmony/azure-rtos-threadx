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
    compiler = "_mplabx" if Database.getSymbolValue("core", "COMPILER_CHOICE") == 0 else "_iar"
    symbol.setValue("../src/config/" + configName + "/threadx_config;../src/third_party/rtos/threadx/tx58" + coreName.lower() + compiler + "/threadx;")

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
threadxLdPreprocessroMacroSym = thirdPartyThreadX.createSettingSymbol("THREADX_LINKER_PREPROC_MARCOS", None)
threadxLdPreprocessroMacroSym.setCategory("C32")
threadxLdPreprocessroMacroSym.setKey("preprocessor-macros")
threadxLdPreprocessroMacroSym.setValue("TX_INCLUDE_USER_DEFINE_FILE")
threadxLdPreprocessroMacroSym.setAppend(True, ";")

compiler = "_mplabx" if Database.getSymbolValue("core", "COMPILER_CHOICE") == 0 else "_iar"

threadxOsSettingSym = thirdPartyThreadX.createSettingSymbol("THREADX_OS_INCLUDE_DIRS", None)
threadxOsSettingSym.setCategory("C32")
threadxOsSettingSym.setKey("extra-include-directories")
threadxOsSettingSym.setValue("../src/config/" + configName + "/threadx_config;../src/third_party/rtos/threadx/tx58" + coreName.lower() + compiler + "/threadx;")
threadxOsSettingSym.setAppend(True, ";")
threadxOsSettingSym.setDependencies(updateIncludePath, ['core.COMPILER_CHOICE'])

threadxIncDirForAsm = thirdPartyThreadX.createSettingSymbol("THREADX_AS_INCLUDE_DIRS", None)
threadxIncDirForAsm.setCategory("C32-AS")
threadxIncDirForAsm.setKey("extra-include-directories-for-assembler")
threadxIncDirForAsm.setValue("../src/config/" + configName + "/threadx_config;../src/third_party/rtos/threadx/tx58" + coreName.lower() + compiler + "/threadx;")
threadxIncDirForAsm.setAppend(True, ";")
threadxIncDirForAsm.setDependencies(updateIncludePath, ['core.COMPILER_CHOICE'])

threadxIncDirForPre = thirdPartyThreadX.createSettingSymbol("THREADX_AS_INCLUDE_PRE_PROC_DIRS", None)
threadxIncDirForPre.setCategory("C32-AS")
threadxIncDirForPre.setKey("extra-include-directories-for-preprocessor")
threadxIncDirForPre.setValue("../src/config/" + configName + "/threadx_config;../src/third_party/rtos/threadx/tx58" + coreName.lower() + compiler + "/threadx;")
threadxIncDirForPre.setAppend(True, ";")
threadxIncDirForPre.setDependencies(updateIncludePath, ['core.COMPILER_CHOICE'])

threadxIarPortASMsource = thirdPartyThreadX.createFileSymbol("THREADX_IAR_PORT_S", None)
threadxIarPortASMsource.setSourcePath("../expresslogic_threadx/config/arch/arm/devices_cortex_a5/src/iar/sama5d2_tx_port.s.ftl")
threadxIarPortASMsource.setOutputName("sama5d2_tx_port.s")
threadxIarPortASMsource.setDestPath("threadx_config/")
threadxIarPortASMsource.setProjectPath("config/" + configName + "/threadx_config/")
threadxIarPortASMsource.setType("SOURCE")
threadxIarPortASMsource.setMarkup(True)
threadxIarPortASMsource.setDependencies(lambda symbol, event: symbol.setEnabled(Database.getSymbolValue("core", "COMPILER_CHOICE") == 1), ['core.COMPILER_CHOICE'])
threadxIarPortASMsource.setEnabled(Database.getSymbolValue("core", "COMPILER_CHOICE")  == 1)

threadxXc32PortASMsource = thirdPartyThreadX.createFileSymbol("THREADX_XC32_PORT_S", None)
threadxXc32PortASMsource.setSourcePath("../expresslogic_threadx/config/arch/arm/devices_cortex_a5/src/xc32/sama5d2_tx_port.S.ftl")
threadxXc32PortASMsource.setOutputName("sama5d2_tx_port.S")
threadxXc32PortASMsource.setDestPath("threadx_config/")
threadxXc32PortASMsource.setProjectPath("config/" + configName + "/threadx_config/")
threadxXc32PortASMsource.setType("SOURCE")
threadxXc32PortASMsource.setMarkup(True)
threadxXc32PortASMsource.setDependencies(lambda symbol, event: symbol.setEnabled(Database.getSymbolValue("core", "COMPILER_CHOICE") == 0), ['core.COMPILER_CHOICE'])
threadxXc32PortASMsource.setEnabled(Database.getSymbolValue("core", "COMPILER_CHOICE") == 0)

threadxTimerSource = thirdPartyThreadX.createFileSymbol("THREADX_TX_TIMER", None)
threadxTimerSource.setSourcePath("../expresslogic_threadx/config/arch/arm/devices_cortex_a5/src/sama5d2_tx_timer.c")
threadxTimerSource.setOutputName("sama5d2_tx_timer.c")
threadxTimerSource.setDestPath("threadx_config/")
threadxTimerSource.setProjectPath("config/" + configName + "/threadx_config/")
threadxTimerSource.setType("SOURCE")
threadxTimerSource.setMarkup(False)
