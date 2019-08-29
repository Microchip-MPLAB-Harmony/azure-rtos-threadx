<#--
/*******************************************************************************
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
*******************************************************************************/
-->
<#if HarmonyCore?? >
    <#lt>    /* Allocate the stack for _APP_IDLE_Tasks threads */
    <#lt>    tx_byte_allocate(&byte_pool_0,
    <#lt>        (VOID **) &_APP_IDLE_Task_Stk_Ptr,
    <#lt>        TX_MINIMUM_STACK,
    <#lt>        TX_NO_WAIT
    <#lt>    );

    <#lt>    /* create the _APP_IDLE_Tasks thread */
    <#lt>    tx_thread_create(&_APP_IDLE_Task_TCB,
    <#lt>        "_APP_IDLE_Tasks",
    <#lt>        _APP_IDLE_Tasks,
    <#lt>        1,
    <#lt>        _APP_IDLE_Task_Stk_Ptr,
    <#lt>        TX_MINIMUM_STACK,
    <#lt>        (TX_MAX_PRIORITIES - 1),
    <#lt>        (TX_MAX_PRIORITIES - 1),
    <#lt>        TX_NO_TIME_SLICE,
    <#lt>        TX_AUTO_START
    <#lt>    );

    <#list 0..(HarmonyCore.GEN_APP_TASK_COUNT - 1) as i>
        <#assign GEN_APP_TASK_NAME_STR = "HarmonyCore.GEN_APP_TASK_NAME_" + i>
        <#assign GEN_APP_TASK_NAME = GEN_APP_TASK_NAME_STR?eval>
        <#assign GEN_APP_RTOS_TASK_SIZE_STR = "HarmonyCore.GEN_APP_RTOS_TASK_" + i + "_SIZE">
        <#assign GEN_APP_RTOS_TASK_SIZE = GEN_APP_RTOS_TASK_SIZE_STR?eval>
        <#assign GEN_APP_RTOS_TASK_PRIO_STR = "HarmonyCore.GEN_APP_RTOS_TASK_" + i + "_PRIO">
        <#assign GEN_APP_RTOS_TASK_PRIO = GEN_APP_RTOS_TASK_PRIO_STR?eval>
        <#if HarmonyCore.SELECT_RTOS == "ThreadX">
        <#lt>    /* Allocate the stack for _${GEN_APP_TASK_NAME?upper_case} threads */
        <#lt>    tx_byte_allocate(&byte_pool_0,
        <#lt>        (VOID **) &_${GEN_APP_TASK_NAME?upper_case}_Task_Stk_Ptr,
        <#lt>        ${GEN_APP_RTOS_TASK_SIZE},
        <#lt>        TX_NO_WAIT
        <#lt>    );

        <#lt>    /* create the _${GEN_APP_TASK_NAME?upper_case} thread */
        <#lt>    tx_thread_create(&_${GEN_APP_TASK_NAME?upper_case}_Task_TCB,
        <#lt>        "_${GEN_APP_TASK_NAME?upper_case}_Tasks",
        <#lt>        _${GEN_APP_TASK_NAME?upper_case}_Tasks,
        <#lt>        ${i},
        <#lt>        _${GEN_APP_TASK_NAME?upper_case}_Task_Stk_Ptr,
        <#lt>        ${GEN_APP_RTOS_TASK_SIZE},
        <#lt>        ${GEN_APP_RTOS_TASK_PRIO},
        <#lt>        ${GEN_APP_RTOS_TASK_PRIO},
        <#lt>        TX_NO_TIME_SLICE,
        <#lt>        TX_AUTO_START
        <#lt>    );
        </#if>
    </#list>
</#if>