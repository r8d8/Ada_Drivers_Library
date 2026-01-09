------------------------------------------------------------------------------
--                                                                          --
--                       Copyright (C) 2026, AdaCore                        --
--                                                                          --
--  Redistribution and use in source and binary forms, with or without      --
--  modification, are permitted provided that the following conditions are  --
--  met:                                                                    --
--     1. Redistributions of source code must retain the above copyright    --
--        notice, this list of conditions and the following disclaimer.     --
--     2. Redistributions in binary form must reproduce the above copyright --
--        notice, this list of conditions and the following disclaimer in   --
--        the documentation and/or other materials provided with the        --
--        distribution.                                                     --
--     3. Neither the name of the copyright holder nor the names of its     --
--        contributors may be used to endorse or promote products derived   --
--        from this software without specific prior written permission.     --
--                                                                          --
--   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS    --
--   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT      --
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR  --
--   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT   --
--   HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, --
--   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT       --
--   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,  --
--   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY  --
--   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT    --
--   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE  --
--   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.   --
--                                                                          --
------------------------------------------------------------------------------

--  Matek H743 Slim V3 flight controller board
--  http://www.mateksys.com/?portfolio=h743-slim-v3

with STM32.GPIO;   use STM32.GPIO;
with STM32.Device;

package Matek_H743_Slim_V3 is

   --  LEDs
   --  Blue LED (marked ACT)
   LED_ACT   : GPIO_Point renames STM32.Device.PE3;
   --  Green LED (marked B/E)
   LED_BE    : GPIO_Point renames STM32.Device.PE4;

   All_LEDs  : GPIO_Points := (LED_ACT, LED_BE);

   --  SPI1 - IMU1 (ICM42688P/MPU6000)
   SPI1_SCK  : GPIO_Point renames STM32.Device.PA5;
   SPI1_MISO : GPIO_Point renames STM32.Device.PA6;
   SPI1_MOSI : GPIO_Point renames STM32.Device.PD7;
   IMU1_CS   : GPIO_Point renames STM32.Device.PC15;

   --  SPI2 - MAX7456 OSD
   SPI2_SCK     : GPIO_Point renames STM32.Device.PB13;
   SPI2_MISO    : GPIO_Point renames STM32.Device.PB14;
   SPI2_MOSI    : GPIO_Point renames STM32.Device.PB15;
   MAX7456_CS   : GPIO_Point renames STM32.Device.PB12;

   --  SPI3 - External
   SPI3_SCK  : GPIO_Point renames STM32.Device.PB3;
   SPI3_MISO : GPIO_Point renames STM32.Device.PB4;
   SPI3_MOSI : GPIO_Point renames STM32.Device.PB5;
   EXT_CS1   : GPIO_Point renames STM32.Device.PD4;
   EXT_CS2   : GPIO_Point renames STM32.Device.PE2;

   --  SPI4 - IMU2/IMU3 (ICM20602/ICM42605)
   SPI4_SCK  : GPIO_Point renames STM32.Device.PE12;
   SPI4_MISO : GPIO_Point renames STM32.Device.PE13;
   SPI4_MOSI : GPIO_Point renames STM32.Device.PE14;
   IMU2_CS   : GPIO_Point renames STM32.Device.PE11;
   IMU3_CS   : GPIO_Point renames STM32.Device.PC13;

   --  I2C1 - External peripherals
   I2C1_SCL : GPIO_Point renames STM32.Device.PB6;
   I2C1_SDA : GPIO_Point renames STM32.Device.PB7;

   --  I2C2 - External peripherals
   I2C2_SCL : GPIO_Point renames STM32.Device.PB10;
   I2C2_SDA : GPIO_Point renames STM32.Device.PB11;

   --  UART1 (Telemetry 2)
   UART1_TX : GPIO_Point renames STM32.Device.PA9;
   UART1_RX : GPIO_Point renames STM32.Device.PA10;

   --  UART2 (GPS1)
   UART2_TX : GPIO_Point renames STM32.Device.PD5;
   UART2_RX : GPIO_Point renames STM32.Device.PD6;

   --  UART3 (GPS2)
   UART3_TX : GPIO_Point renames STM32.Device.PD8;
   UART3_RX : GPIO_Point renames STM32.Device.PD9;

   --  UART4 (Spare)
   UART4_TX : GPIO_Point renames STM32.Device.PB9;
   UART4_RX : GPIO_Point renames STM32.Device.PB8;

   --  UART6 (RC input)
   UART6_TX : GPIO_Point renames STM32.Device.PC6;
   UART6_RX : GPIO_Point renames STM32.Device.PC7;

   --  UART7 (Telemetry 1)
   UART7_TX  : GPIO_Point renames STM32.Device.PE8;
   UART7_RX  : GPIO_Point renames STM32.Device.PE7;
   UART7_CTS : GPIO_Point renames STM32.Device.PE10;
   UART7_RTS : GPIO_Point renames STM32.Device.PE9;

   --  UART8 (Spare)
   UART8_TX : GPIO_Point renames STM32.Device.PE1;
   UART8_RX : GPIO_Point renames STM32.Device.PE0;

   --  USB OTG FS
   OTG_FS_DM : GPIO_Point renames STM32.Device.PA11;
   OTG_FS_DP : GPIO_Point renames STM32.Device.PA12;

   --  CAN1
   CAN1_RX     : GPIO_Point renames STM32.Device.PD0;
   CAN1_TX     : GPIO_Point renames STM32.Device.PD1;
   CAN1_SILENT : GPIO_Point renames STM32.Device.PD3;

   --  ADC inputs
   BATT_VOLTAGE_SENS  : GPIO_Point renames STM32.Device.PC0;
   BATT_CURRENT_SENS  : GPIO_Point renames STM32.Device.PC1;
   BATT2_VOLTAGE_SENS : GPIO_Point renames STM32.Device.PA4;
   BATT2_CURRENT_SENS : GPIO_Point renames STM32.Device.PA7;
   PRESSURE_SENS      : GPIO_Point renames STM32.Device.PC4;
   RSSI_ADC           : GPIO_Point renames STM32.Device.PC5;

   --  SDMMC1 (microSD card)
   SDMMC1_D0  : GPIO_Point renames STM32.Device.PC8;
   SDMMC1_D1  : GPIO_Point renames STM32.Device.PC9;
   SDMMC1_D2  : GPIO_Point renames STM32.Device.PC10;
   SDMMC1_D3  : GPIO_Point renames STM32.Device.PC11;
   SDMMC1_CK  : GPIO_Point renames STM32.Device.PC12;
   SDMMC1_CMD : GPIO_Point renames STM32.Device.PD2;

   --  Motor outputs (PWM)
   MOTOR1  : GPIO_Point renames STM32.Device.PB0;   -- TIM8_CH2N
   MOTOR2  : GPIO_Point renames STM32.Device.PB1;   -- TIM8_CH3N
   MOTOR3  : GPIO_Point renames STM32.Device.PA0;   -- TIM5_CH1
   MOTOR4  : GPIO_Point renames STM32.Device.PA1;   -- TIM5_CH2
   MOTOR5  : GPIO_Point renames STM32.Device.PA2;   -- TIM5_CH3
   MOTOR6  : GPIO_Point renames STM32.Device.PA3;   -- TIM5_CH4
   MOTOR7  : GPIO_Point renames STM32.Device.PD12;  -- TIM4_CH1
   MOTOR8  : GPIO_Point renames STM32.Device.PD13;  -- TIM4_CH2
   MOTOR9  : GPIO_Point renames STM32.Device.PD14;  -- TIM4_CH3
   MOTOR10 : GPIO_Point renames STM32.Device.PD15;  -- TIM4_CH4
   MOTOR11 : GPIO_Point renames STM32.Device.PE5;   -- TIM15_CH1
   MOTOR12 : GPIO_Point renames STM32.Device.PE6;   -- TIM15_CH2

   --  WS2812 LED output
   WS2812_LED : GPIO_Point renames STM32.Device.PA8;  -- TIM1_CH1

   --  Beeper
   BEEPER : GPIO_Point renames STM32.Device.PA15;  -- TIM2_CH1

   --  GPIO outputs
   PINIO1 : GPIO_Point renames STM32.Device.PD10;
   PINIO2 : GPIO_Point renames STM32.Device.PD11;

   --  Debug (SWD)
   SWDIO : GPIO_Point renames STM32.Device.PA13;
   SWCLK : GPIO_Point renames STM32.Device.PA14;

end Matek_H743_Slim_V3;
