
# Microchip MPLAB Harmony configurations and applications for Express Logic ThreadX Release Notes
## Release v3.0.0
### NEW FEATURES
- **New part support** - This release introduces initial support for 
    - Microchip 32 bit SAM MCU devices based on ARM Cortex M0+ core
    - Microchip 32 bit SAM MCU devices based on ARM Cortex M4 core
    - Microchip 32 bit SAM MCU devices based on ARM Cortex M7 core
    - Microchip 32 bit MCU devices in PIC32MZ DA family
    - Microchip 32 bit MCU devices in PIC32MZ EF family
    - Microchip 32 bit MCU devices in PIC32MK family
    - Microchip 32 bit SAMA5D27 MPU device (ARM cortex A5 core)
    - Microchip 32 bit SAM9X60 MPU device (ARM ARM926EJ-S core)
- Supports **Express Logic Threadx** - 5.8.x.x (Threadx source files are not included in this repo and must be procured directly from Express Logic)
- **Development kit and demo application support** - The following table provides number of ThreadX demo application available for different development kits

| Development kits | Applications |
| --- | --- |
| [SAM E54 Xplained Pro Evaluation Kit](https://www.microchip.com/developmenttools/ProductDetails/atsame54-xpro) | 1 |
| [SAM E70 Xplained Ultra Evaluation Kit](https://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=ATSAME70-XULT) | 1 |
| [PIC32MZ Embedded Graphics with Stacked DRAM (DA) Starter Kit (Crypto)](http://www.microchip.com/DevelopmentTools/ProductDetails/DM320010) | 1 |
| [PIC32MZ Embedded Connectivity with FPU (EF) Starter Kit](http://www.microchip.com/Developmenttools/ProductDetails/DM320007) | 1 |
| PIC32MK MCJ Curiosity Pro Development Board | 1 |
| [SAM C21N Xplained Pro Evaluation Kit](http://www.microchip.com/developmenttools/ProductDetails/atsamc21n-xpro)| 1 |
| [SAM A5D2 Xplained Ultra board](http://www.microchip.com/DevelopmentTools/ProductDetails/ATSAMA5D2C-XULT) | 2 |
| SAM 9X60 Evaluation Kit | 1 |

### KNOWN ISSUES

The current known issues are as follows:

- Threadx configurations for SAMA5D2 and SAM9X6 parts depend on csp and core version v3.5.1 or above
- When creating IAR projects for SAMA5D2 and SAM9X6 parts, project should be manually configured to generate code in ARM mode (Default mode is Thumb)
- When creating IAR projects for SAMA5D2 and SAM9X6 parts, preprocessor macro "TX_INCLUDE_USER_DEFINE_FILE" should be added to the IAR project configuration

### DEVELOPMENT TOOLS

- [MPLAB X IDE v5.25](https://www.microchip.com/mplab/mplab-x-ide)
- [MPLAB XC32 C/C++ Compiler v2.30](https://www.microchip.com/mplab/compilers)
- [IAR Embedded Workbench® for ARM® (v8.40 or above)](https://www.iar.com/iar-embedded-workbench/#!?architecture=Arm)
- MPLAB X IDE plug-ins: MPLAB Harmony Configurator (MHC) v3.3.0.1
