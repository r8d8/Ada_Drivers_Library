# STM32 H7 Migration Guide: F4/F7 to H7 Differences

This document outlines the key differences between STM32 F4/F7 and STM32 H7 series, based on SVD analysis.

## Bus Architecture Changes

### H7 Introduces New Buses

**F4/F7 buses:**
- AHB1, AHB2, AHB3
- APB1, APB2

**H7 buses:**
- AHB1, AHB2, AHB3, **AHB4** (new)
- APB1L (low), APB1H (high), APB2, **APB3**, **APB4** (new)

The APB1 bus has been split into APB1LENR (APB1 Low) and APB1HENR (APB1 High).

## Critical Peripheral Relocations

### GPIO: AHB1 → AHB4
**Impact: HIGH** - All GPIO operations affected

| Peripheral | F4/F7 Bus | H7 Bus |
|-----------|-----------|---------|
| GPIO A-I  | AHB1ENR   | **AHB4ENR** |

**Required Changes:**
- `RCC_Periph.AHB1ENR.GPIOxEN` → `RCC_Periph.AHB4ENR.GPIOxEN`
- `RCC_Periph.AHB1RSTR.GPIOxRST` → `RCC_Periph.AHB4RSTR.GPIOxRST`
- ✅ **FIXED** in stm32-device.adb

### ADC: APB2 → AHB1/AHB4 (Split)
**Impact: HIGH** - ADC clock enable logic changed

| Peripheral | F4/F7 Bus | F4/F7 Bit | H7 Bus | H7 Bit |
|-----------|-----------|-----------|---------|---------|
| ADC1      | APB2ENR   | ADC1EN    | AHB1ENR | **ADC12EN** (shared) |
| ADC2      | APB2ENR   | ADC2EN    | AHB1ENR | **ADC12EN** (shared) |
| ADC3      | APB2ENR   | ADC3EN    | **AHB4ENR** | ADC3EN |

**Critical:** ADC1 and ADC2 now share a single clock enable bit (ADC12EN) on AHB1.

**Required Changes:**
```ada
-- OLD (F4/F7):
if This'Address = ADC1_Base then
   RCC_Periph.APB2ENR.ADC1EN := True;
elsif This'Address = ADC2_Base then
   RCC_Periph.APB2ENR.ADC2EN := True;
elsif This'Address = ADC3_Base then
   RCC_Periph.APB2ENR.ADC3EN := True;

-- NEW (H7):
if This'Address = ADC1_Base or This'Address = ADC2_Base then
   RCC_Periph.AHB1ENR.ADC12EN := True;
elsif This'Address = ADC3_Base then
   RCC_Periph.AHB4ENR.ADC3EN := True;
```

**Reset:**
```ada
-- OLD:
RCC_Periph.APB2RSTR.ADCRST := True;

-- NEW: Need to check if ADC12RST exists or if there are separate reset bits
RCC_Periph.AHB1RSTR.ADC12RST := True;  -- For ADC1/2
RCC_Periph.AHB4RSTR.ADC3RST := True;   -- For ADC3
```

### DAC: APB1 → APB1L
**Impact: MEDIUM** - DAC clock naming changed

| Peripheral | F4/F7 Bus | F4/F7 Bit | H7 Bus | H7 Bit |
|-----------|-----------|-----------|---------|---------|
| DAC       | APB1ENR   | DACEN     | **APB1LENR** | **DAC12EN** |

**Required Changes:**
```ada
-- OLD:
RCC_Periph.APB1ENR.DACEN := True;
RCC_Periph.APB1RSTR.DACRST := True;

-- NEW:
RCC_Periph.APB1LENR.DAC12EN := True;
RCC_Periph.APB1LRSTR.DAC12RST := True;
```

### SYSCFG: APB2 → APB4
**Impact: HIGH** - System configuration

| Peripheral | F4/F7 Bus | H7 Bus |
|-----------|-----------|---------|
| SYSCFG    | APB2ENR   | **APB4ENR** |

**Required Changes:**
- `RCC_Periph.APB2ENR.SYSCFGEN` → `RCC_Periph.APB4ENR.SYSCFGEN`
- ✅ **FIXED** in stm32-device.adb and stm32-rcc.adb

### CRC: AHB1 → AHB4

| Peripheral | F4/F7 Bus | H7 Bus |
|-----------|-----------|---------|
| CRC       | AHB1ENR   | **AHB4ENR** |

### I2C: APB1 → APB1L
**Impact: MEDIUM** - I2C1/2/3 moved, I2C4 is new on APB4

| Peripheral | F4/F7 Bus | H7 Bus |
|-----------|-----------|---------|
| I2C1      | APB1ENR   | **APB1LENR** |
| I2C2      | APB1ENR   | **APB1LENR** |
| I2C3      | APB1ENR   | **APB1LENR** |
| I2C4      | N/A       | **APB4ENR** (new) |

### SPI: Split Across Multiple Buses

| Peripheral | F4/F7 Bus | H7 Bus |
|-----------|-----------|---------|
| SPI1      | APB2ENR   | APB2ENR (same) |
| SPI2      | APB1ENR   | **APB1LENR** |
| SPI3      | APB1ENR   | **APB1LENR** |
| SPI4      | N/A       | **APB2ENR** (new) |
| SPI5      | N/A       | **APB2ENR** (new) |
| SPI6      | N/A       | **APB4ENR** (new) |

### Timers: APB1 → APB1L

| Peripheral | F4/F7 Bus | H7 Bus |
|-----------|-----------|---------|
| TIM2-7    | APB1ENR   | **APB1LENR** |
| TIM12-14  | APB1ENR   | **APB1LENR** |
| TIM15-17  | N/A       | APB2ENR (new) |

### USART/UART: APB1 → APB1L

| Peripheral | F4/F7 Bus | H7 Bus |
|-----------|-----------|---------|
| USART2/3  | APB1ENR   | **APB1LENR** |
| UART4/5   | APB1ENR   | **APB1LENR** |
| USART7/8  | N/A       | **APB1LENR** (new) |
| LPUART1   | N/A       | **APB4ENR** (new) |

## New Peripherals in H7

### Power & Clock Management
- **HSEM** (Hardware Semaphore) - AHB4ENR
- **VREF** (Voltage Reference) - APB4ENR
- **BDMA** (Basic DMA) - AHB4ENR
- **MDMA** (Master DMA) - AHB3ENR

### Multimedia
- **LTDC** (LCD-TFT Display Controller) - APB3ENR
- **DMA2D** (Chrom-Art Accelerator) - AHB3ENR
- **JPGDEC** (JPEG Decoder) - AHB3ENR
- **SAI1-4** (Serial Audio Interface) - APB2/APB4ENR
- **SPDIFRX** (S/PDIF Receiver) - APB1LENR

### Low-Power Timers
- **LPTIM1-5** (Low-Power Timers) - APB1L/APB4ENR

### Analog
- **COMP12** (Comparators) - APB4ENR
- **DFSDM1** (Digital Filter) - APB2ENR

### Connectivity
- **FDCAN/CAN_CCU** (replaces CAN1/CAN2)
- **QUADSPI** - AHB3ENR
- **SDMMC1/2** - AHB3/AHB2ENR
- **HRTIM** (High-Resolution Timer) - APB2ENR

### Crypto
- **CRYPT** (Cryptographic processor) - AHB2ENR
- **HASH** (Hash processor) - AHB2ENR

### Ethernet
- **ETH1MAC/ETH1RX/ETH1TX** (replaces ETHMAC*) - AHB1ENR

### USB
- **USB1OTGHS/USB2OTGHS** (replaces OTGHS) - AHB1ENR

## Removed/Renamed Peripherals

### Removed in H7
- **CAN1EN, CAN2EN** - Replaced by FDCAN
- **TIM9EN, TIM10EN, TIM11EN** - Removed
- **PWREN** - Power interface clock removed (always on?)
- **SDIOEN** - Replaced by SDMMC1EN/SDMMC2EN
- **WWDGEN** - Renamed to WWDG1EN on APB3

### Name Changes
- `BKPSRAMEN` → `BKPRAMEN`
- `DACEN` → `DAC12EN`
- `ADCRST` → `ADC12RST` (combined ADC1/2)
- `ETHMAC*` → `ETH1MAC*`
- `OTGHS*` → `USB*OTGHS*`
- `FSMCEN` → `FMCEN` (Flexible Memory Controller)

## Status in Current Codebase

### ✅ Fixed (stm32h7x/stm32-device.adb)
- GPIO clock enable: AHB1ENR → AHB4ENR
- GPIO reset: AHB1RSTR → AHB4RSTR
- SYSCFG clock: APB2ENR → APB4ENR
- Type qualifications: UInt4 → HAL.UInt4

### ❌ Needs Fixing
- **ADC Enable_Clock**: Still uses APB2ENR.ADC1EN/2EN/3EN
- **ADC Reset_All_ADC_Units**: Still uses APB2RSTR.ADCRST
- **DAC Enable_Clock**: Still uses APB1ENR.DACEN (should be APB1LENR.DAC12EN)
- **DAC Reset**: Still uses APB1RSTR.DACRST (should be APB1LRSTR.DAC12RST)
- **I2C clocks**: May need APB1ENR → APB1LENR updates
- **SPI clocks**: May need APB1ENR → APB1LENR updates for SPI2/3
- **Timer clocks**: May need APB1ENR → APB1LENR updates
- **USART clocks**: May need APB1ENR → APB1LENR updates

### 🔄 Temporarily Disabled
- SPI drivers (excluded from build, need H7-specific implementation)
- RTC driver (excluded from build)
- WWDG driver (excluded from build, renamed to WWDG1 on APB3)

## Recommended Fix Strategy

1. **For blinky** (immediate): Comment out or conditionally compile ADC/DAC functions since blinky doesn't use them
2. **Short term**: Implement proper H7-specific peripheral enable/reset functions
3. **Medium term**: Generate new Ada bindings from https://github.com/modm-io/cmsis-svd-stm32/blob/main/stm32h7/STM32H743.svd
4. **Long term**: Port all peripheral drivers (SPI, RTC, WWDG, etc.) to use H7 registers correctly

## References

- SVD files analyzed:
  - `/workspace/arch/ARM/STM32/svd/stm32f40x/stm32_svd-rcc.ads`
  - `/workspace/arch/ARM/STM32/svd/stm32h7x/stm32_svd-rcc.ads`
- STM32H7 Reference Manual (RM0433)
- STM32F4 Reference Manual (RM0090)
