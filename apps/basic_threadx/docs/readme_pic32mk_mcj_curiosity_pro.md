---
grand_parent: Harmony 3 Azure RTOS ThreadX configurations and application examples
parent: Azure RTOS ThreadX application examples
title: Building and Running on PIC32MK MCJ Curiosity Pro Development Board
has_toc: false
---

[![MCHP](https://www.microchip.com/ResourcePackages/Microchip/assets/dist/images/logo.png)](https://www.microchip.com)

# Basic ThreadX

This example application blinks an LED to show the Azure RTOS ThreadX threads that are running and to indicate status

## Description

This demonstration creates a task which toggle an LED for every 500ms. 

## Downloading and building the application

To clone or download these applications from Github, go to the [main page of this repository](https://github.com/Microchip-MPLAB-Harmony/azure-rtos-threadx) and then click **Clone** button to clone this repository or download as zip file. This content can also be downloaded using content manager by following these [instructions](https://github.com/Microchip-MPLAB-Harmony/contentmanager/wiki)

Path of the application within the repository is **apps/basic_threadx/firmware/**

To build the application, refer to the following table and open the project using its IDE.

### Azure RTOS ThreadX Application

| Project Name      | Description                                    |
| ----------------- | ---------------------------------------------- |
| pic32mk_mcj_curiosity_pro.X | MPLABX Project for PIC32MK MCJ Curiosity Pro Development Board |

## Setting up PIC32MK MCJ Curiosity Pro Development Board

- Connect micro USB cable to the 'Debug USB' connector(J1) on the board to the computer

## Running the Application

1. Build and program the application using the MPLAB X IDE
2. The LED indicates the success or failure.
    - The LED toggles on success i.e. for every 500 ms.

Refer to the following table for LED name:  

| Board | LED Name |
| ----- | -------- |
| [PIC32MK MCJ Curiosity Pro Development Board] | LED2 |
|||
