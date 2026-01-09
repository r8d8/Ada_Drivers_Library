# Matek H743 Slim V3 Flight Controller Board

This directory contains board support for the **Matek H743 Slim V3** flight controller board.

## Board Information

- **Manufacturer**: Matek Systems
- **Product Page**: http://www.mateksys.com/?portfolio=h743-slim-v3
- **MCU**: STM32H743VIHx (ARM Cortex-M7F @ 480MHz)
- **Flash**: 2MB
- **RAM**: 1MB (512KB + 512KB)
- **External Oscillator**: 8MHz

## Features

The Matek H743 Slim V3 is a high-performance flight controller designed for drones and UAVs. Key features include:

### IMUs (Inertial Measurement Units)
- **IMU1** on SPI1: ICM42688P or MPU6000 (depending on board version)
- **IMU2** on SPI4: ICM20602 or ICM42605 (depending on board version)
- **IMU3** on SPI4: ICM42605 (V3 only)

### Communication Interfaces
- **8x UARTs**: 
  - UART1 (Telemetry 2)
  - UART2 (GPS1)
  - UART3 (GPS2)
  - UART4 (Spare)
  - UART6 (RC Input)
  - UART7 (Telemetry 1 with CTS/RTS)
  - UART8 (Spare)
- **2x I2C buses**: For external peripherals (compass, barometer, etc.)
- **4x SPI buses**: 
  - SPI1: Primary IMU
  - SPI2: MAX7456 OSD chip
  - SPI3: External devices
  - SPI4: Secondary/tertiary IMU
- **1x CAN bus**: CAN1 with silent control
- **1x USB**: USB OTG Full Speed

### Sensors
- **Barometer**: I2C (MS5611, DPS310, or BMP280)
- **OSD**: MAX7456 on SPI2
- **6x ADC inputs**: Battery voltage/current sensing (2 batteries), pressure sensor, RSSI

### Outputs
- **12x PWM outputs**: For motors and servos (using TIM4, TIM5, TIM8, TIM15)
- **1x NeoPixel LED output**: WS2812 LED strip (TIM1_CH1)
- **1x Beeper output**: TIM2_CH1
- **2x GPIO outputs**: PINIO1, PINIO2

### Storage
- **microSD card slot**: SDMMC1 interface with 4-bit mode

### Onboard LEDs
- **Blue LED** (marked ACT): PE3 (active low)
- **Green LED** (marked B/E): PE4 (active low)

## Usage

### Project Files

Two GNAT project files are provided:

1. **matek_h743_slim_v3_sfp.gpr**: Ravenscar Small Footprint (light-tasking) runtime
2. **matek_h743_slim_v3_full.gpr**: Ravenscar Full runtime with exception propagation

### Example: LED Blink

```ada
with Matek_H743_Slim_V3.LED;
with Ada.Real_Time; use Ada.Real_Time;

procedure Main is
begin
   Matek_H743_Slim_V3.LED.Initialize;
   
   loop
      Matek_H743_Slim_V3.LED.Toggle_ACT;
      delay until Clock + Milliseconds (500);
   end loop;
end Main;
```

### GPIO Pin Mappings

All GPIO pins are mapped in the `Matek_H743_Slim_V3` package. Examples:

```ada
with Matek_H743_Slim_V3; use Matek_H743_Slim_V3;
with STM32.GPIO; use STM32.GPIO;
with STM32.Device;

--  Access UART pins
UART2_TX  -- PD5 (GPS1 TX)
UART2_RX  -- PD6 (GPS1 RX)

--  Access SPI pins
SPI1_SCK  -- PA5
SPI1_MISO -- PA6
SPI1_MOSI -- PD7
IMU1_CS   -- PC15

--  Access I2C pins
I2C1_SCL  -- PB6
I2C1_SDA  -- PB7
```

## Runtime Requirements

This board requires one of the following Ada runtimes:

- **light-tasking-stm32h7**: Ravenscar Small Footprint profile
- **ravenscar-full-stm32h7**: Full Ravenscar profile with exception propagation

These runtimes must be installed in your GNAT toolchain. They are available from the AdaCore bb-runtimes repository.

## Hardware Notes

### Board Versions

There are multiple versions of the Matek H743 board with different IMU configurations:

- **V1**: ICM20602 + MPU6000
- **V1.5/V2**: ICM42605 + MPU6000  
- **V3**: ICM42688P + ICM42605

The pin mappings remain the same across versions.

### Power Supply

- **Input voltage**: 7V - 30V (2-6S LiPo)
- **5V output**: 2.5A max
- **3.3V output**: For internal use

### Important Considerations

1. **DMA Conflicts**: SPI1 and SPI4 do not share DMA to avoid conflicts when reading IMUs simultaneously
2. **UART6 RC Input**: PC7 can be configured as either a timer input (TIM3_CH2) for PWM RC input or as UART6_RX for serial protocols
3. **SD Card**: Uses SDMMC1 peripheral (not SDIO) for higher performance
4. **Flash Storage**: 2MB flash with 128KB reserved for bootloader

## References

- [ArduPilot hardware definition](https://github.com/ArduPilot/ardupilot/blob/master/libraries/AP_HAL_ChibiOS/hwdef/MatekH743/hwdef.dat)
- [Matek Systems website](http://www.mateksys.com)
- [Ada Drivers Library documentation](../../docs/)

## License

Copyright (C) 2026, AdaCore

This board support package is distributed under the same BSD 3-Clause license as the Ada Drivers Library.
