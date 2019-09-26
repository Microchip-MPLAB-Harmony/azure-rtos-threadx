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

#Default Byte Pool size
threadxSym_BytePoolSize.setDefaultValue(40960)

#CPU Clock Frequency
cpuclk = int(Database.getSymbolValue("core", "CPU_CLOCK_FREQUENCY"))

threadxSym_CpuClockHz.setDependencies(threadxCpuClockHz, ["core.CPU_CLOCK_FREQUENCY"])
threadxSym_CpuClockHz.setDefaultValue(cpuclk)

Database.activateComponents(["pit64b"])
Database.setSymbolValue("core", "USE_THREADX_VECTORS", True)
Database.setSymbolValue("pit64b", "PERIOD_INT", True)
Database.setSymbolValue("pit64b", "CONT", True)

pit64Period = (long)(Database.getSymbolValue("core", "PIT64B_CLOCK_FREQUENCY") / threadxSym_TickRate.getValue())
Database.setSymbolValue("pit64b", "PERIOD", pit64Period)

############################################################################
#### Code Generation ####
############################################################################
configName  = Variables.get("__CONFIGURATION_NAME")


txIncPath = "../src/config/" + configName + "/threadx_config;../src/third_party/rtos/Threadx/tx58" + coreName.lower() + "_iar/threadx" if compiler == 1 else "_mplabx/threadx"
threadxIncludeSettingsSym = thirdPartyThreadX.createSettingSymbol("THREADX_OS_INCLUDE_DIRS", None)
threadxIncludeSettingsSym.setCategory("C32")
threadxIncludeSettingsSym.setKey("extra-include-directories")
threadxIncludeSettingsSym.setValue(txIncPath)
threadxIncludeSettingsSym.setAppend(True, ";")

threadxPortAsmFileSym = thirdPartyThreadX.createFileSymbol("SAM_9X6_TX_PORT_S", None)
threadxPortAsmFileSym.setSourcePath("config/arch/arm/devices_arm926/src/iar/sam9x6_tx_port.s")
threadxPortAsmFileSym.setOutputName("sam9x6_tx_port.s")
threadxPortAsmFileSym.setDestPath("threadx_config/")
threadxPortAsmFileSym.setProjectPath("config/" + configName + "/threadx_config/")
threadxPortAsmFileSym.setType("SOURCE")
threadxPortAsmFileSym.setMarkup(False)

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