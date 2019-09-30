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
###############################################################################
########################## ThreadX Configurations ########################
###############################################################################
import os
global coreArch

fileSymbolName = "THREADX_"

def AddThreadXFile(component, src_path, dest_path, proj_path, filename, file_type, isMarkup = False):
    global fileSymbolName
    srcFile = component.createFileSymbol(fileSymbolName + str(filename.replace(".", "_").upper()), None)
    srcFile.setSourcePath(src_path)
    srcFile.setDestPath(dest_path)
    srcFile.setProjectPath(proj_path)
    srcFile.setType(file_type)
    srcFile.setMarkup(isMarkup)
    srcFile.setDependencies(lambda symbol, event: symbol.setEnabled(Database.getSymbolValue("core", "COMPILER_CHOICE") == 0), ['core.COMPILER_CHOICE'])
    srcFile.setEnabled(Database.getSymbolValue("core", "COMPILER_CHOICE") == 0)

# Traverse through Thirdparty RTOS ThreadX folder and create File Symbols for ThreadX Source files.
def AddThreadXFilesDir(component, configName, dirPath, coreName):
    modulePath = Module.getPath()
    dirPath = str(modulePath + dirPath)
    gccPath = dirPath + "gcc"
    docsPath = dirPath + "docs"
    gitPath = dirPath + ".git"
    for (root, dirs, files) in os.walk(dirPath):
        for filename in files:
            # Include all files under all folders other than gcc/ and docs/ folder
            if (gccPath not in root) and (docsPath not in root) and (gitPath not in root):
                filepath = str(root + os.sep + filename)
                source_path = filepath[len(modulePath):]
                destination_path = "../../third_party/rtos/ThreadX/tx58" + coreName.lower() + "_mplabx/threadx"
                project_path = "ThreadX"
                if (".c" in filename):
                    AddThreadXFile(component, source_path , destination_path , project_path, filename, "SOURCE")
                elif (".S" in filename):
                    project_path = "ThreadX/" + coreName
                    AddThreadXFile(component, source_path , destination_path , project_path, filename, "SOURCE")
                elif ("tx_port.h" in filename):
                    project_path = "ThreadX/" + coreName
                    AddThreadXFile(component, source_path , destination_path , project_path, filename, "HEADER")
                elif ("tx_user.h" not in filename) and (".h" in filename):
                    AddThreadXFile(component, source_path , destination_path , project_path, filename, "HEADER")

def AddIARThreadXFiles(component, dirPath, coreName):
    dirPath = str(Module.getPath() + dirPath)
    destPath = "../../third_party/rtos/ThreadX/tx58" + coreName.lower() + "_iar/threadx"
    projectPath = "Threadx"
    fileNames = os.listdir(dirPath)
    exclusionList = ["tx_user.h"]
    for fileName in fileNames:
        # Find threadx source/header/assembler files
        if fileName.lower().startswith("tx") and fileName.lower().endswith(('.c', '.s', '.h')):
            # Dont process files in the exclusion list
            if fileName in exclusionList:
                continue
            # Get the relative path of the file w.r.t to the module path
            sourcePath = os.path.relpath(os.path.join(dirPath, fileName), Module.getPath())
            #create a file symbol
            fileSymbolName =  "THREADX_IAR_" + fileName.replace(".", "_").upper()
            txFile = component.createFileSymbol(fileSymbolName, None)
            txFile.setSourcePath(sourcePath)
            txFile.setDestPath(destPath)
            txFile.setProjectPath(projectPath)
            txFile.setMarkup(False)
            # if it is a source
            if fileName.lower().endswith(('.c','.s')):
                txFile.setType("SOURCE")
            else:
                txFile.setType("HEADER")
            txFile.setDependencies(lambda symbol, event: symbol.setEnabled(Database.getSymbolValue("core", "COMPILER_CHOICE") == 1), ['core.COMPILER_CHOICE'])
            txFile.setEnabled(Database.getSymbolValue("core", "COMPILER_CHOICE")  == 1)


def threadxTimerStackSizeVisibility(symbol, event):

    if(event["value"] == False):
        symbol.setVisible(True)
    else :
        symbol.setVisible(False)

def threadxThreadPrioVisSetting(symbol, event):

    component = symbol.getComponent()

    threadxTmrProInIsr  = component.getSymbolValue("THREADX_TX_TIMER_PROCESS_IN_ISR")
    threadxMaxPrio  = component.getSymbolValue("THREADX_TX_MAX_PRIORITIES")

    if(threadxTmrProInIsr == False):
        symbol.setVisible(True)
    else :
        symbol.setVisible(False)

    symbol.setMin(0)
    symbol.setMax((threadxMaxPrio - 1))

def deactivateActiveRtos():
    activeComponents = Database.getActiveComponentIDs()

    for i in range(0, len(activeComponents)):
        if (activeComponents[i] == "FreeRTOS"):
            res = Database.deactivateComponents(["FreeRTOS"])
        elif (activeComponents[i] == "MicriumOSIII"):
            res = Database.deactivateComponents(["MicriumOSIII"])

def threadxIntConfig():
    global coreArch

    if (coreArch != "MIPS"):
        SysTickInterruptEnable      = "SysTick_INTERRUPT_ENABLE"
        SysTickInterruptHandler     = "SysTick_INTERRUPT_HANDLER"
        SysTickInterruptHandlerLock = "SysTick_INTERRUPT_HANDLER_LOCK"

        if (Database.getSymbolValue("core", SysTickInterruptEnable) == False):
            Database.clearSymbolValue("core", SysTickInterruptEnable)
            Database.setSymbolValue("core", SysTickInterruptEnable, True)

        if (Database.getSymbolValue("core", SysTickInterruptHandler) != "__tx_SysTickHandler"):
            Database.clearSymbolValue("core", SysTickInterruptHandler)
            Database.setSymbolValue("core", SysTickInterruptHandler, "__tx_SysTickHandler")

        if (Database.getSymbolValue("core", SysTickInterruptHandlerLock) == False):
            Database.clearSymbolValue("core", SysTickInterruptHandlerLock)
            Database.setSymbolValue("core", SysTickInterruptHandlerLock, True)

        PendSVInterruptEnable       = "PendSV_INTERRUPT_ENABLE"
        PendSVInterruptHandler      = "PendSV_INTERRUPT_HANDLER"
        PendSVInterruptHandlerLock  = "PendSV_INTERRUPT_HANDLER_LOCK"

        if (Database.getSymbolValue("core", PendSVInterruptEnable) == False):
            Database.clearSymbolValue("core", PendSVInterruptEnable)
            Database.setSymbolValue("core", PendSVInterruptEnable, True)

        if (Database.getSymbolValue("core", PendSVInterruptHandler) != "__tx_PendSVHandler"):
            Database.clearSymbolValue("core", PendSVInterruptHandler)
            Database.setSymbolValue("core", PendSVInterruptHandler, "__tx_PendSVHandler")

        if (Database.getSymbolValue("core", PendSVInterruptHandlerLock) == False):
            Database.clearSymbolValue("core", PendSVInterruptHandlerLock)
            Database.setSymbolValue("core", PendSVInterruptHandlerLock, True)

        SVCallInterruptEnable       = "SVCall_INTERRUPT_ENABLE"
        SVCallInterruptHandler      = "SVCall_INTERRUPT_HANDLER"
        SVCallInterruptHandlerLock  = "SVCall_INTERRUPT_HANDLER_LOCK"

        if (Database.getSymbolValue("core", SVCallInterruptEnable) == False):
            Database.clearSymbolValue("core", SVCallInterruptEnable)
            Database.setSymbolValue("core", SVCallInterruptEnable, True)

        if (Database.getSymbolValue("core", SVCallInterruptHandler) != "__tx_SVCallHandler"):
            Database.clearSymbolValue("core", SVCallInterruptHandler)
            Database.setSymbolValue("core", SVCallInterruptHandler, "__tx_SVCallHandler")

        if (Database.getSymbolValue("core", SVCallInterruptHandlerLock) == False):
            Database.clearSymbolValue("core", SVCallInterruptHandlerLock)
            Database.setSymbolValue("core", SVCallInterruptHandlerLock, True)

def threadxCpuClockHz(symbol, event):
    clock = int(event["value"])
    symbol.setValue(clock)

def threadxCalcTickRate(symbol, event):
    if (event["value"] != 0):
        symbol.setValue(long((1000 / event["value"])), 2)
    else:
        symbol.setValue(0, 2)

def threadxCheckTickRate(symbol, event):
    symbol.setVisible(False)

    if (event["value"] == 0):
        symbol.setVisible(True)

# Instatntiate ThreadX Component
def instantiateComponent(thirdPartyThreadX):
    Log.writeInfoMessage("Running ThreadX")

    global coreArch

    # Fetch Core Architecture and Family details
    coreArch     = Database.getSymbolValue("core", "CoreArchitecture")
    coreFamily   = ATDF.getNode( "/avr-tools-device-file/devices/device" ).getAttribute( "family" )
    compiler     = Database.getSymbolValue("core", "COMPILER_CHOICE")

    # Deactivate the active RTOS if any.
    deactivateActiveRtos()

    #ThreadX Interrupt Handlers configurations
    threadxIntConfig()

    #ThreadX Configuration Menu
    threadxSym_DisableErrorCheckDesc = "ThreadX - Disable error checking. \
    Bypasses basic service call error checking by disabling parameter \
    error checking. This may improve performance by as much as 30% and \
    may also reduce the image size. Of course, this option should only be \
    used after the application is thoroughly debugged. ThreadX API return \
    values not affected by disabling error checking are listed in bold in \
    the \"Return Values\" section of each API description in ThreadX User \
    Guide, Chapter 4. The non-bold return values are void if error checking \
    is disabled by using the TX_DISABLE_ERROR_CHECKING option. When error \
    checking is disabled, MHC defines the ThreadX preprocessor variable \
    TX_DISABLE_ERROR_CHECKING"
    threadxSym_DisableErrorCheck = thirdPartyThreadX.createBooleanSymbol("THREADX_TX_DISABLE_ERROR_CHECKING", None)
    threadxSym_DisableErrorCheck.setLabel("Disable error checking")
    threadxSym_DisableErrorCheck.setDefaultValue(False)
    threadxSym_DisableErrorCheck.setDescription(threadxSym_DisableErrorCheckDesc)

    threadxSym_CpuClockHz = thirdPartyThreadX.createIntegerSymbol("THREADX_CPU_CLOCK_HZ", None)
    threadxSym_CpuClockHz.setLabel("CPU Clock Speed (Hz)")
    threadxSym_CpuClockHz.setDescription("This is the CPU clock speed obtained from the Clock System Service configuration.")
    threadxSym_CpuClockHz.setReadOnly(True)

    if (coreArch == "MIPS"):
        threadxSym_PerClockHz = thirdPartyThreadX.createIntegerSymbol("THREADX_PERIPHERAL_CLOCK_HZ", None)
        threadxSym_PerClockHz.setLabel("Peripheral Clock Speed (Hz)")
        threadxSym_PerClockHz.setDescription("This is the frequency in Hz at which the Timer peripherals are clocked (PBCLK), obtained from the Clock System Service configuration.")

    threadxSym_TickIntrEnDesc = "ThreadX - Tick Interrupt Enables \
    (when set to 1) or disables (when set to 0) the code generation of the \
    system interrupt services MHC sets the system service preprocessor \
    variable SYS_INT to TRUE."
    threadxSym_TickIntrEn = thirdPartyThreadX.createBooleanSymbol("THREADX_TICK_INTERRUPT", None)
    threadxSym_TickIntrEn.setLabel("Tick interrupt")
    threadxSym_TickIntrEn.setDefaultValue(True)
    threadxSym_TickIntrEn.setReadOnly(True)
    threadxSym_TickIntrEn.setDescription(threadxSym_TickIntrEnDesc)

    threadxSym_TickRate = thirdPartyThreadX.createIntegerSymbol("THREADX_TICK_RATE_HZ", None)
    threadxSym_TickRate.setLabel("Tick Rate (Hz)")
    threadxSym_TickRate.setDescription("ThreadX - Tick rate (Hz)")
    threadxSym_TickRate.setDefaultValue(1000)
    threadxSym_TickRate.setMin(250)
    threadxSym_TickRate.setMax(1000)

    if (coreArch == "MIPS"):
        threadxSym_TimerPrescale = thirdPartyThreadX.createIntegerSymbol("THREADX_TIMER_PRESCALE", None)
        threadxSym_TimerPrescale.setLabel("Timer Prescale")
        threadxSym_TimerPrescale.setDescription("ThreadX - Timer Prescale")
        threadxSym_TimerPrescale.setDefaultValue(8)
        threadxSym_TimerPrescale.setReadOnly(True)

        threadxSym_TimerPrescaleBits = thirdPartyThreadX.createIntegerSymbol("THREADX_TIMER_PRESCALE_BITS", None)
        threadxSym_TimerPrescaleBits.setLabel("Timer Prescale Bits")
        threadxSym_TimerPrescaleBits.setDescription("ThreadX - Timer Prescale Bits")
        threadxSym_TimerPrescaleBits.setDefaultValue(1)
        threadxSym_TimerPrescaleBits.setReadOnly(True)

    threadxSym_TickRateComment = thirdPartyThreadX.createCommentSymbol("THREADX_TICK_RATE_COMMENT", None)
    threadxSym_TickRateComment.setLabel("Warning!!! Tick Rate cannot be \"0\" !!!")
    threadxSym_TickRateComment.setVisible(False)
    threadxSym_TickRateComment.setDependencies(threadxCheckTickRate, ["THREADX_TICK_RATE_HZ"])

    threadxSym_MaxPrioDesc = "ThreadX - Maximum number of priority levels \
    Defines the priority levels for ThreadX. Legal values range from 32 \
    through 1024 (inclusive) and must be evenly divisible by 32. Increasing \
    the number of priority levels supported increases the RAM usage by 128 \
    bytes for every group of 32 priorities. However, there is only a \
    negligible effect on performance. MHC defines the ThreadX preprocessor \
    variable TX_MAX_PRIORITIES."
    threadxSym_MaxPrio = thirdPartyThreadX.createIntegerSymbol("THREADX_TX_MAX_PRIORITIES", None)
    threadxSym_MaxPrio.setLabel("The maximum number of task priorities")
    threadxSym_MaxPrio.setDefaultValue(32)
    threadxSym_MaxPrio.setMin(32)
    threadxSym_MaxPrio.setMax(1024)
    threadxSym_MaxPrio.setDescription(threadxSym_MaxPrioDesc)

    threadxSym_MaxPrioComment = thirdPartyThreadX.createCommentSymbol("THREADX_TX_MAX_PRIORITIES_COMMENT", None)
    threadxSym_MaxPrioComment.setLabel("**** Priority levels range from 32 through 1024 and must be evenly divisible by 32. ****")

    threadxSym_MinStackDesc = "ThreadX - Minimum stack size (in bytes) Defines \
    the minimum stack size (in bytes). It is used for error checking when \
    threads are created. MHC defines the ThreadX preprocessor variable \
    TX_MINIMUM_STACK."
    threadxSym_MinStack = thirdPartyThreadX.createIntegerSymbol("THREADX_TX_MINIMUM_STACK", None)
    threadxSym_MinStack.setLabel("Minimum stack size (in bytes)")
    if (coreArch == "MIPS"):
        threadxSym_MinStack.setDefaultValue(1024)
    else:
        threadxSym_MinStack.setDefaultValue(512)
    threadxSym_MinStack.setDescription(threadxSym_MinStackDesc)

    threadxSym_BytePoolSizeDesc = "ThreadX - Create a byte memory pool from \
    which to allocate the thread stacks. The task or thread stack size uses \
    this memory. Hence this value must be sufficient enough to allocate all \
    the created thread stacks."
    threadxSym_BytePoolSize = thirdPartyThreadX.createIntegerSymbol("THREADX_TX_BYTE_POOL_SIZE", None)
    threadxSym_BytePoolSize.setLabel("Total Byte memory pool size")
    threadxSym_BytePoolSize.setDescription(threadxSym_BytePoolSizeDesc)

    threadxSym_BytePollComment = thirdPartyThreadX.createCommentSymbol("THREADX_TX_BYTE_POOL_SIZE_COMMENT", None)
    threadxSym_BytePollComment.setLabel("**** Byte memory pool size should atleast be equal to sum of stack sizes of all the threads. ****")

    threadxSym_TimerProInIsrDesc = "ThreadX - Process timer in ISR When enabled\
    eliminates the internal system timer thread for ThreadX. This results in \
    improved performance on timer events and smaller RAM requirements because \
    the timer stack and control block are no longer needed. However, using \
    this option moves all the timer expiration processing to the timer ISR \
    level. When enabled, MHC defines the ThreadX preprocessor variable TX_TIMER_PROCESS_IN_ISR."
    threadxSym_TimerProInIsr = thirdPartyThreadX.createBooleanSymbol("THREADX_TX_TIMER_PROCESS_IN_ISR", None)
    threadxSym_TimerProInIsr.setLabel("Process timer in ISR")
    threadxSym_TimerProInIsr.setDefaultValue(True)
    threadxSym_TimerProInIsr.setDescription(threadxSym_TimerProInIsrDesc)

    threadxSym_TimerStackSizeDesc = "ThreadX - Timer thread stack size \
    Defines the stack size (in bytes) of the internal ThreadX system timer \
    thread. This thread processes all thread sleep requests as well as all \
    service call timeouts. In addition, all application timer callback \
    routines are invoked from this context. MHC defines the ThreadX \
    preprocessor variable TX_TIMER_THREAD_STACK_SIZE."
    threadxSym_TimerStackSize = thirdPartyThreadX.createIntegerSymbol("THREADX_TX_TIMER_THREAD_STACK_SIZE", None)
    threadxSym_TimerStackSize.setLabel("Timer thread stack size")
    threadxSym_TimerStackSize.setDefaultValue(2048)
    threadxSym_TimerStackSize.setVisible(False)
    threadxSym_TimerStackSize.setDescription(threadxSym_TimerStackSizeDesc)
    threadxSym_TimerStackSize.setDependencies(threadxTimerStackSizeVisibility, ["THREADX_TX_TIMER_PROCESS_IN_ISR"])

    threadxSym_TimerThreadPrioDesc = "ThreadX - Timer thread priority \
    Defines the priority of the internal ThreadX system timer thread. \
    The default value is priority 0 - maximum priority level in ThreadX \
    TX_MAX_PRIORITIES - 1). MHC defines the ThreadX preprocessor variable \
    TX_TIMER_THREAD_PRIORITY."
    threadxSym_TimerThreadPrio = thirdPartyThreadX.createIntegerSymbol("THREADX_TX_TIMER_THREAD_PRIORITY", None)
    threadxSym_TimerThreadPrio.setLabel("Timer thread priority")
    threadxSym_TimerThreadPrio.setDefaultValue(0)
    threadxSym_TimerThreadPrio.setMin(0)
    threadxSym_TimerThreadPrio.setMax(1024)
    threadxSym_TimerThreadPrio.setVisible(False)
    threadxSym_TimerThreadPrio.setDescription(threadxSym_TimerThreadPrioDesc)
    threadxSym_TimerThreadPrio.setDependencies(threadxThreadPrioVisSetting, ["THREADX_TX_TIMER_PROCESS_IN_ISR", "THREADX_TX_MAX_PRIORITIES"])

    threadxSym_ReactiveInlineDesc = "ThreadX - Reactivate timers in-line \
    When enabled, performs reactivation of ThreadX timers in-line instead \
    of using a function call. This improves performance but slightly \
    increases code size. When enabled, MHC defines the ThreadX preprocessor \
    variable TX_REACTIVATE_INLINE."
    threadxSym_ReactiveInline = thirdPartyThreadX.createBooleanSymbol("THREADX_TX_REACTIVATE_INLINE", None)
    threadxSym_ReactiveInline.setLabel("Reactivate timers in-line")
    threadxSym_ReactiveInline.setDefaultValue(False)
    threadxSym_ReactiveInline.setDescription(threadxSym_ReactiveInlineDesc)

    threadxSym_DisStackFillDesc = "ThreadX - Disable stack filling \
    Disables placing the 0xEF value in each byte of each thread's stack when \
    created. By default, each thread's stack is filled with 0xEF. When stack \
    filling is disabled, MHC defines the ThreadX preprocessor variable \
    TX_DISABLE_STACK_FILLING."
    threadxSym_DisStackFill = thirdPartyThreadX.createBooleanSymbol("THREADX_TX_DISABLE_STACK_FILLING", None)
    threadxSym_DisStackFill.setLabel(" Disable stack filling")
    threadxSym_DisStackFill.setDefaultValue(False)
    threadxSym_DisStackFill.setDescription(threadxSym_DisStackFillDesc)

    threadxSym_EnStackCheckingDesc = "ThreadX - Enable stack checking \
    Enables ThreadX run-time stack checking, which includes analysis of how \
    much stack has been used and examination of data pattern \"fences\" \
    before and after the stack area. If a stack error is detected, the \
    registered application stack error handler is called. This option does \
    result in slightly increased overhead and code size. Review the \
    tx_thread_stack_error_notify API for more information. When stack \
    checking is enabled, MHC defines the ThreadX preprocessor variable \
    TX_ENABLE_STACK_CHECKING."
    threadxSym_EnStackChecking = thirdPartyThreadX.createBooleanSymbol("THREADX_TX_ENABLE_STACK_CHECKING", None)
    threadxSym_EnStackChecking.setLabel("Enable stack checking")
    threadxSym_EnStackChecking.setDefaultValue(False)
    threadxSym_EnStackChecking.setDescription(threadxSym_EnStackCheckingDesc)

    threadxSym_DisPrempThrDesc = "ThreadX - Disables the preemption-threshold \
    Disables the preemption-threshold feature and slightly reduces code size \
    and improves performance. Of course, the preemption-threshold capabilities \
    are no longer available. When the preemption-threshold is disabled, MHC \
    defines the ThreadX preprocessor variable TX_DISABLE_PREEMPTION_THRESHOLD."
    threadxSym_DisPrempThr = thirdPartyThreadX.createBooleanSymbol("THREADX_TX_DISABLE_PREEMPTION_THRESHOLD", None)
    threadxSym_DisPrempThr.setLabel("Disables the preemption-threshold")
    threadxSym_DisPrempThr.setDefaultValue(False)
    threadxSym_DisPrempThr.setDescription(threadxSym_DisPrempThrDesc)

    threadxSym_DisRedundantClearDesc = "ThreadX - Remove logic to initialize all \
    global C data structures to zero Removes the logic for initializing \
    ThreadX global C data structures to zero. This should only be used if \
    the compiler's initialization code sets all un-initialized C global \
    data to zero. Using this option slightly reduces code size and improves \
    performance during initialization. When this option is selected, MHC \
    defines the ThreadX preprocessor variable TX_DISABLE_REDUNDANT_CLEARING."
    threadxSym_DisRedundantClear = thirdPartyThreadX.createBooleanSymbol("THREADX_TX_DISABLE_REDUNDANT_CLEARING", None)
    threadxSym_DisRedundantClear.setLabel("Remove logic to initialize all global C data structures to zero")
    threadxSym_DisRedundantClear.setDefaultValue(False)
    threadxSym_DisRedundantClear.setDescription(threadxSym_DisRedundantClearDesc)

    threadxSym_DisNotifyCallbackDesc = "ThreadX - Disable notify callbacks \
    Disables the notify callbacks for various ThreadX objects. Using this \
    option slightly reduces code size and improves performance. When notify \
    callbacks are disabled, MHC defines the ThreadX preprocessor variable \
    TX_DISABLE_NOTIFY_CALLBACKS."
    threadxSym_DisNotifyCallback = thirdPartyThreadX.createBooleanSymbol("THREADX_TX_DISABLE_NOTIFY_CALLBACKS", None)
    threadxSym_DisNotifyCallback.setLabel("Disable notify callbacks")
    threadxSym_DisNotifyCallback.setDefaultValue(False)
    threadxSym_DisNotifyCallback.setDescription(threadxSym_DisNotifyCallbackDesc)

    threadxSym_InlineThreadResSusDesc = "ThreadX - Disable notify callbacks \
    Disables the notify callbacks for various ThreadX objects. Using this \
    option slightly reduces code size and improves performance. When notify \
    callbacks are disabled, MHC defines the ThreadX preprocessor variable \
    TX_DISABLE_NOTIFY_CALLBACKS."
    threadxSym_InlineThreadResSus = thirdPartyThreadX.createBooleanSymbol("THREADX_TX_INLINE_THREAD_RESUME_SUSPEND", None)
    threadxSym_InlineThreadResSus.setLabel("Inline thread resume and suspend")
    threadxSym_InlineThreadResSus.setDefaultValue(False)
    threadxSym_InlineThreadResSus.setDescription(threadxSym_InlineThreadResSusDesc)

    threadxSym_NotInterruptableDesc = "ThreadX - Internal ThreadX code is \
    non-interruptable Specifies that the internal ThreadX code is \
    non-interruptable. This results in smaller code size and less processing \
    overhead, but increases the interrupt lockout time. When the internal \
    ThreadX code is specified as non-interruptable, MHC defines the ThreadX \
    preprocessor variable THREADX_TX_NOT_INTERRUPTABLE."
    threadxSym_NotInterruptable = thirdPartyThreadX.createBooleanSymbol("THREADX_TX_NOT_INTERRUPTABLE", None)
    threadxSym_NotInterruptable.setLabel("Internal ThreadX code is non-interruptable")
    threadxSym_NotInterruptable.setDefaultValue(False)
    threadxSym_NotInterruptable.setDescription(threadxSym_NotInterruptableDesc)

    threadxSym_EnEventTraceDesc = "ThreadX - Enable the trace event logging \
    code Enable the trace event logging code. This causes slight increases \
    in code size and overhead, but provides the ability to generate system \
    trace information which is available for viewing in TraceX."
    threadxSym_EnEventTrace = thirdPartyThreadX.createBooleanSymbol("THREADX_TX_ENABLE_EVENT_TRACE", None)
    threadxSym_EnEventTrace.setLabel("Enable the trace event logging code")
    threadxSym_EnEventTrace.setDefaultValue(False)
    threadxSym_EnEventTrace.setDescription(threadxSym_EnEventTraceDesc)

    threadxSym_BlockPoolEnPerfInfoDesc = "ThreadX - Gather performance information \
    on block pools Gather performance information on block pools.When enabled,\
    MHC defines the ThreadX preprocessor variable TX_BLOCK_POOL_ENABLE_PERFORMANCE_INFO."
    threadxSym_BlockPoolEnPerfInfo = thirdPartyThreadX.createBooleanSymbol("THREADX_TX_BLOCK_POOL_ENABLE_PERFORMANCE_INFO", None)
    threadxSym_BlockPoolEnPerfInfo.setLabel("Gather performance information on block pools")
    threadxSym_BlockPoolEnPerfInfo.setDefaultValue(False)
    threadxSym_BlockPoolEnPerfInfo.setDescription(threadxSym_BlockPoolEnPerfInfoDesc)

    threadxSym_BytePoolEnPerfInfoDesc = "ThreadX - Gather performance information \
    on byte pools Gather performance information on byte pools. When enabled, MHC \
    defines the ThreadX preprocessor variable TX_BYTE_POOL_ENABLE_PERFORMANCE_INFO."
    threadxSym_BytePoolEnPerfInfo = thirdPartyThreadX.createBooleanSymbol("THREADX_TX_BYTE_POOL_ENABLE_PERFORMANCE_INFO", None)
    threadxSym_BytePoolEnPerfInfo.setLabel("Gather performance information on byte pools")
    threadxSym_BytePoolEnPerfInfo.setDefaultValue(False)
    threadxSym_BytePoolEnPerfInfo.setDescription(threadxSym_BytePoolEnPerfInfoDesc)

    threadxSym_EventFlagEnPerfInfoDesc = "ThreadX - Gather performance \
    information on event flags groups Gather performance information on event \
    flags groups.When enabled, MHC defines the ThreadX preprocessor variable \
    TX_EVENT_FLAGS_ENABLE_PERFORMANCE_INFO."
    threadxSym_EventFlagEnPerfInfo = thirdPartyThreadX.createBooleanSymbol("THREADX_TX_EVENT_FLAGS_ENABLE_PERFORMANCE_INFO", None)
    threadxSym_EventFlagEnPerfInfo.setLabel("Gather performance information on event flags groups")
    threadxSym_EventFlagEnPerfInfo.setDefaultValue(False)
    threadxSym_EventFlagEnPerfInfo.setDescription(threadxSym_EventFlagEnPerfInfoDesc)

    threadxSym_MutexEnPerfInfoDesc = "ThreadX - Gather performance information\
    on mutexes Gather performance information on mutexes.When enabled, MHC \
    defines the ThreadX preprocessor variable TX_MUTEX_ENABLE_PERFORMANCE_INFO."
    threadxSym_MutexEnPerfInfo = thirdPartyThreadX.createBooleanSymbol("THREADX_TX_MUTEX_ENABLE_PERFORMANCE_INFO", None)
    threadxSym_MutexEnPerfInfo.setLabel("Gather performance information on mutexes")
    threadxSym_MutexEnPerfInfo.setDefaultValue(False)
    threadxSym_MutexEnPerfInfo.setDescription(threadxSym_MutexEnPerfInfoDesc)

    threadxSym_QueueEnPerfInfoDesc = "ThreadX - Gather performance information\
    on queues Gather performance information on queues.When enabled, MHC \
    defines the ThreadX preprocessor variable TX_QUEUE_ENABLE_PERFORMANCE_INFO."
    threadxSym_QueueEnPerfInfo = thirdPartyThreadX.createBooleanSymbol("THREADX_TX_QUEUE_ENABLE_PERFORMANCE_INFO", None)
    threadxSym_QueueEnPerfInfo.setLabel("Gather performance information on queues")
    threadxSym_QueueEnPerfInfo.setDefaultValue(False)
    threadxSym_QueueEnPerfInfo.setDescription(threadxSym_QueueEnPerfInfoDesc)

    threadxSym_SemEnPerfInfoDesc = "ThreadX - Gather performance information\
    on semaphores Gather performance information on semaphores When enabled,\
    MHC defines the ThreadX preprocessor variable\
    TX_SEMAPHORE_ENABLE_PERFORMANCE_INFO."
    threadxSym_SemEnPerfInfo = thirdPartyThreadX.createBooleanSymbol("THREADX_TX_SEMAPHORE_ENABLE_PERFORMANCE_INFO", None)
    threadxSym_SemEnPerfInfo.setLabel("Gather performance information on semaphores")
    threadxSym_SemEnPerfInfo.setDefaultValue(False)
    threadxSym_SemEnPerfInfo.setDescription(threadxSym_SemEnPerfInfoDesc)

    threadxSym_ThreadEnPerfInfoDesc = "ThreadX - Gather performance information\
    on threads Gather performance information on threads when enabled, MHC \
    defines the ThreadX preprocessor variable TX_THREAD_ENABLE_PERFORMANCE_INFO."
    threadxSym_ThreadEnPerfInfo = thirdPartyThreadX.createBooleanSymbol("THREADX_TX_THREAD_ENABLE_PERFORMANCE_INFO", None)
    threadxSym_ThreadEnPerfInfo.setLabel("Gather performance information on threads")
    threadxSym_ThreadEnPerfInfo.setDefaultValue(False)
    threadxSym_ThreadEnPerfInfo.setDescription(threadxSym_ThreadEnPerfInfoDesc)

    threadxSym_TimerEnPerfInfoDesc = "ThreadX - Gather performance information\
    on timers Gather performance information on timersWhen enabled, MHC \
    defines the ThreadX preprocessor variable TX_TIMER_ENABLE_PERFORMANCE_INFO."
    threadxSym_TimerEnPerfInfo = thirdPartyThreadX.createBooleanSymbol("THREADX_TX_TIMER_ENABLE_PERFORMANCE_INFO", None)
    threadxSym_TimerEnPerfInfo.setLabel("Gather performance information on timers")
    threadxSym_TimerEnPerfInfo.setDefaultValue(False)
    threadxSym_TimerEnPerfInfo.setDescription(threadxSym_TimerEnPerfInfoDesc)

    # ThreadX Generic Source Files
    configName = Variables.get("__CONFIGURATION_NAME")

    threadxUserConfig = thirdPartyThreadX.createFileSymbol("THREADX_TX_USER_H", None)
    threadxUserConfig.setSourcePath("templates/tx_user.h.ftl")
    threadxUserConfig.setOutputName("tx_user.h")
    threadxUserConfig.setDestPath("threadx_config/")
    threadxUserConfig.setProjectPath("config/" + configName + "/threadx_config/")
    threadxUserConfig.setType("HEADER")
    threadxUserConfig.setMarkup(True)

    threadxSystemDefFile = thirdPartyThreadX.createFileSymbol("THREADX_SYS_DEF", None)
    threadxSystemDefFile.setType("STRING")
    threadxSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    threadxSystemDefFile.setSourcePath("templates/system/definitions.h.ftl")
    threadxSystemDefFile.setMarkup(True)

    threadxSystemInit = thirdPartyThreadX.createFileSymbol("THREADX_INIT", None)
    threadxSystemInit.setType("STRING")
    threadxSystemInit.setOutputName("core.LIST_SYSTEM_INIT_C_SYS_INITIALIZE_PERIPHERALS")
    threadxSystemInit.setSourcePath("templates/system/initialization.c.ftl")
    threadxSystemInit.setMarkup(True)

    threadxSystemTasksFile = thirdPartyThreadX.createFileSymbol("THREADX_SYS_START_SCHED", None)
    threadxSystemTasksFile.setType("STRING")
    threadxSystemTasksFile.setOutputName("core.LIST_SYSTEM_RTOS_TASKS_C_CALL_SCHEDULAR")
    threadxSystemTasksFile.setSourcePath("templates/system/start_rtos.c.ftl")
    threadxSystemTasksFile.setMarkup(True)

    threadxSystemTasks = thirdPartyThreadX.createFileSymbol("THREADX_SYS_TASKS", None)
    threadxSystemTasks.setType("STRING")
    threadxSystemTasks.setOutputName("core.LIST_SYSTEM_RTOS_TASKS_C_GEN_APP")
    threadxSystemTasks.setSourcePath("templates/system/create_tasks.c.ftl")
    threadxSystemTasks.setMarkup(True)

    threadxSystemTasksDef = thirdPartyThreadX.createFileSymbol("THREADX_SYS_TASKS_DEF", None)
    threadxSystemTasksDef.setType("STRING")
    threadxSystemTasksDef.setOutputName("core.LIST_SYSTEM_RTOS_TASKS_C_DEFINITIONS")
    threadxSystemTasksDef.setSourcePath("templates/system/tasks_macros.c.ftl")
    threadxSystemTasksDef.setMarkup(True)

    threadxFileSymbolConfig = 0
    # If compiler is XC32
    if compiler == 0:
        # load family specific configuration and port files
        if (coreArch == "MIPS"):
            coreName = coreFamily[:7].upper()
            if (coreName == "PIC32MK"):
                threadxSrcPath = "../thirdparty_expresslogic/" + "tx58pic32mz_mplabx/threadx/"
            else:
                threadxSrcPath = "../thirdparty_expresslogic/" + "tx58" + coreFamily[:7].lower() + "_mplabx/threadx/"

            execfile(Module.getPath() + "config/arch/mips/devices_" + coreFamily[:7].lower() + "/threadx_config.py")

        else:
            threadxSrcPath = "../thirdparty_expresslogic/" + "tx58" + coreArch.replace("PLUS", "").lower() + "_mplabx/threadx/"
            coreName = coreArch.replace("-", "_").replace("PLUS", "").replace("EJS","").upper()
            execfile(Module.getPath() + "config/arch/arm/devices_" + coreArch.replace("-", "_").replace("PLUS", "").replace("EJS","").lower() + "/threadx_config.py")

        threadxFileSymbolConfig += 1
        # BL to add Thirdparty ThreadX Generic Source Code
        AddThreadXFilesDir(thirdPartyThreadX, configName, threadxSrcPath, coreName)

    #if compiler is IAR
    if compiler == 1 or coreArch == "CORTEX-A5":
        coreName = coreArch.replace("-", "_").replace("PLUS", "").replace("EJS","").lower()
        threadxCoreName = coreName.replace("926","9").replace("cortex_a5", "cortex-a5")
        threadxSrcPath =  "../thirdparty_expresslogic/tx58" + threadxCoreName + "_generic_iar/threadx/"
        if threadxFileSymbolConfig == 0:
            execfile(Module.getPath() + "config/arch/arm/devices_" + coreName + "/threadx_config.py")
        AddIARThreadXFiles(thirdPartyThreadX, threadxSrcPath, coreName)

