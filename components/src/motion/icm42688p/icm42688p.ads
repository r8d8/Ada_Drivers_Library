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

--  ICM42688P 6-axis IMU SPI device driver
--
--  This driver supports the TDK InvenSense ICM-42688-P high-performance
--  6-axis MEMS MotionTracking device. It features:
--  - 3-axis gyroscope with ±2000 dps full scale range
--  - 3-axis accelerometer with ±16g full scale range
--  - 32kHz maximum gyro sampling rate
--  - Low noise (16 µg/√Hz accel, 0.004 dps/√Hz gyro)
--  - 2KB FIFO buffer
--  - 4 user banks for register access

with Interfaces;     use Interfaces;
with HAL;            use HAL;
with HAL.SPI;        use HAL.SPI;
with HAL.GPIO;       use HAL.GPIO;
with HAL.Time;

package ICM42688P is

   type ICM42688P_Device
     (Port : not null HAL.SPI.Any_SPI_Port;
      CS   : not null HAL.GPIO.Any_GPIO_Point;
      Time : not null HAL.Time.Any_Delays) is tagged limited private;

   --  Device identification
   ICM42688P_WHO_AM_I_VALUE : constant := 16#47#;

   --  Startup and reset timing
   ICM42688P_STARTUP_TIME_MS : constant := 100;
   ICM42688P_RESET_TIME_MS   : constant := 10;

   --  Type representing the register banks in ICM42688P
   --  The ICM42688P has 4 register banks that must be selected
   --  before accessing registers
   type ICM42688P_Register_Bank is
     (Bank_0,  --  Primary configuration and data registers
      Bank_1,  --  Sensor configuration registers
      Bank_2,  --  Gyro and accel offset registers
      Bank_4); --  Apex (advanced) feature registers
   for ICM42688P_Register_Bank use
     (Bank_0 => 0,
      Bank_1 => 1,
      Bank_2 => 2,
      Bank_4 => 4);
   for ICM42688P_Register_Bank'Size use 3;

   --  Type representing the power modes
   type ICM42688P_Power_Mode is
     (Sleep_Mode,
      Standby_Mode,
      Low_Noise_Mode,
      Low_Power_Mode);

   --  Type representing the gyroscope full-scale ranges
   type ICM42688P_Gyro_FS_Range is
     (Gyro_FS_2000,   --  ±2000 dps
      Gyro_FS_1000,   --  ±1000 dps
      Gyro_FS_500,    --  ±500 dps
      Gyro_FS_250,    --  ±250 dps
      Gyro_FS_125,    --  ±125 dps
      Gyro_FS_62_5,   --  ±62.5 dps
      Gyro_FS_31_25,  --  ±31.25 dps
      Gyro_FS_15_625) --  ±15.625 dps
     with Size => 3;
   for ICM42688P_Gyro_FS_Range use
     (Gyro_FS_2000   => 2#000#,
      Gyro_FS_1000   => 2#001#,
      Gyro_FS_500    => 2#010#,
      Gyro_FS_250    => 2#011#,
      Gyro_FS_125    => 2#100#,
      Gyro_FS_62_5   => 2#101#,
      Gyro_FS_31_25  => 2#110#,
      Gyro_FS_15_625 => 2#111#);

   --  Type representing the accelerometer full-scale ranges
   type ICM42688P_Accel_FS_Range is
     (Accel_FS_16,  --  ±16g
      Accel_FS_8,   --  ±8g
      Accel_FS_4,   --  ±4g
      Accel_FS_2)   --  ±2g
     with Size => 2;
   for ICM42688P_Accel_FS_Range use
     (Accel_FS_16 => 2#00#,
      Accel_FS_8  => 2#01#,
      Accel_FS_4  => 2#10#,
      Accel_FS_2  => 2#11#);

   --  Type representing Output Data Rate (ODR) for gyroscope
   type ICM42688P_Gyro_ODR is
     (Gyro_ODR_32kHz,
      Gyro_ODR_16kHz,
      Gyro_ODR_8kHz,
      Gyro_ODR_4kHz,
      Gyro_ODR_2kHz,
      Gyro_ODR_1kHz,
      Gyro_ODR_500Hz,
      Gyro_ODR_200Hz,
      Gyro_ODR_100Hz,
      Gyro_ODR_50Hz,
      Gyro_ODR_25Hz,
      Gyro_ODR_12_5Hz)
     with Size => 4;
   for ICM42688P_Gyro_ODR use
     (Gyro_ODR_32kHz  => 16#01#,
      Gyro_ODR_16kHz  => 16#02#,
      Gyro_ODR_8kHz   => 16#03#,
      Gyro_ODR_4kHz   => 16#04#,
      Gyro_ODR_2kHz   => 16#05#,
      Gyro_ODR_1kHz   => 16#06#,
      Gyro_ODR_500Hz  => 16#07#,
      Gyro_ODR_200Hz  => 16#08#,
      Gyro_ODR_100Hz  => 16#09#,
      Gyro_ODR_50Hz   => 16#0A#,
      Gyro_ODR_25Hz   => 16#0B#,
      Gyro_ODR_12_5Hz => 16#0C#);

   --  Type representing Output Data Rate (ODR) for accelerometer
   type ICM42688P_Accel_ODR is
     (Accel_ODR_32kHz,
      Accel_ODR_16kHz,
      Accel_ODR_8kHz,
      Accel_ODR_4kHz,
      Accel_ODR_2kHz,
      Accel_ODR_1kHz,
      Accel_ODR_500Hz,
      Accel_ODR_200Hz,
      Accel_ODR_100Hz,
      Accel_ODR_50Hz,
      Accel_ODR_25Hz,
      Accel_ODR_12_5Hz)
     with Size => 4;
   for ICM42688P_Accel_ODR use
     (Accel_ODR_32kHz  => 16#01#,
      Accel_ODR_16kHz  => 16#02#,
      Accel_ODR_8kHz   => 16#03#,
      Accel_ODR_4kHz   => 16#04#,
      Accel_ODR_2kHz   => 16#05#,
      Accel_ODR_1kHz   => 16#06#,
      Accel_ODR_500Hz  => 16#07#,
      Accel_ODR_200Hz  => 16#08#,
      Accel_ODR_100Hz  => 16#09#,
      Accel_ODR_50Hz   => 16#0A#,
      Accel_ODR_25Hz   => 16#0B#,
      Accel_ODR_12_5Hz => 16#0C#);

   --  Conversion factors for raw data to physical units
   --  Gyroscope: degrees per second per LSB
   ICM42688P_GYRO_SENSITIVITY_2000DPS   : constant := (2.0 * 2000.0) / 65536.0;
   ICM42688P_GYRO_SENSITIVITY_1000DPS   : constant := (2.0 * 1000.0) / 65536.0;
   ICM42688P_GYRO_SENSITIVITY_500DPS    : constant := (2.0 * 500.0) / 65536.0;
   ICM42688P_GYRO_SENSITIVITY_250DPS    : constant := (2.0 * 250.0) / 65536.0;
   ICM42688P_GYRO_SENSITIVITY_125DPS    : constant := (2.0 * 125.0) / 65536.0;
   ICM42688P_GYRO_SENSITIVITY_62_5DPS   : constant := (2.0 * 62.5) / 65536.0;
   ICM42688P_GYRO_SENSITIVITY_31_25DPS  : constant := (2.0 * 31.25) / 65536.0;
   ICM42688P_GYRO_SENSITIVITY_15_625DPS : constant := (2.0 * 15.625) / 65536.0;

   --  Accelerometer: G per LSB
   ICM42688P_ACCEL_SENSITIVITY_16G : constant := (2.0 * 16.0) / 65536.0;
   ICM42688P_ACCEL_SENSITIVITY_8G  : constant := (2.0 * 8.0) / 65536.0;
   ICM42688P_ACCEL_SENSITIVITY_4G  : constant := (2.0 * 4.0) / 65536.0;
   ICM42688P_ACCEL_SENSITIVITY_2G  : constant := (2.0 * 2.0) / 65536.0;

   --  Public procedures and functions

   --  Initialize the ICM42688P device
   procedure Initialize (Device : in out ICM42688P_Device);

   --  Test if the ICM42688P is initialized and connected
   function Test (Device : in out ICM42688P_Device) return Boolean;

   --  Test connection by reading WHO_AM_I register
   function Test_Connection (Device : in out ICM42688P_Device) return Boolean;

   --  Perform device reset (soft reset)
   procedure Reset (Device : in out ICM42688P_Device);

   --  Set power mode for both gyro and accel
   procedure Set_Power_Mode
     (Device      : in out ICM42688P_Device;
      Gyro_Mode   : ICM42688P_Power_Mode;
      Accel_Mode  : ICM42688P_Power_Mode);

   --  Set gyroscope full-scale range
   procedure Set_Gyro_FS_Range
     (Device   : in out ICM42688P_Device;
      FS_Range : ICM42688P_Gyro_FS_Range);

   --  Set accelerometer full-scale range
   procedure Set_Accel_FS_Range
     (Device   : in out ICM42688P_Device;
      FS_Range : ICM42688P_Accel_FS_Range);

   --  Set gyroscope output data rate
   procedure Set_Gyro_ODR
     (Device : in out ICM42688P_Device;
      ODR    : ICM42688P_Gyro_ODR);

   --  Set accelerometer output data rate
   procedure Set_Accel_ODR
     (Device : in out ICM42688P_Device;
      ODR    : ICM42688P_Accel_ODR);

   --  Get raw 6-axis motion sensor readings (accel/gyro)
   procedure Get_Motion_6
     (Device : in out ICM42688P_Device;
      Acc_X  : out Integer_16;
      Acc_Y  : out Integer_16;
      Acc_Z  : out Integer_16;
      Gyro_X : out Integer_16;
      Gyro_Y : out Integer_16;
      Gyro_Z : out Integer_16);

   --  Read gyroscope data only
   procedure Read_Gyro
     (Device : in out ICM42688P_Device;
      X      : out Integer_16;
      Y      : out Integer_16;
      Z      : out Integer_16);

   --  Read accelerometer data only
   procedure Read_Accel
     (Device : in out ICM42688P_Device;
      X      : out Integer_16;
      Y      : out Integer_16;
      Z      : out Integer_16);

   --  Read temperature sensor (in Celsius)
   function Read_Temperature (Device : in out ICM42688P_Device) return Float;

   --  Check if new data is available
   function Data_Ready (Device : in out ICM42688P_Device) return Boolean;

private

   type ICM42688P_Device
     (Port : not null HAL.SPI.Any_SPI_Port;
      CS   : not null HAL.GPIO.Any_GPIO_Point;
      Time : not null HAL.Time.Any_Delays) is tagged limited record
      Is_Init         : Boolean := False;
      Current_Bank    : ICM42688P_Register_Bank := Bank_0;
      Gyro_FS         : ICM42688P_Gyro_FS_Range := Gyro_FS_2000;
      Accel_FS        : ICM42688P_Accel_FS_Range := Accel_FS_16;
   end record;

   --  Bank 0 Register Map
   ICM42688P_REG_DEVICE_CONFIG     : constant := 16#11#;
   ICM42688P_REG_INT_CONFIG        : constant := 16#14#;
   ICM42688P_REG_FIFO_CONFIG       : constant := 16#16#;
   ICM42688P_REG_TEMP_DATA1        : constant := 16#1D#;
   ICM42688P_REG_TEMP_DATA0        : constant := 16#1E#;
   ICM42688P_REG_ACCEL_DATA_X1     : constant := 16#1F#;
   ICM42688P_REG_ACCEL_DATA_X0     : constant := 16#20#;
   ICM42688P_REG_ACCEL_DATA_Y1     : constant := 16#21#;
   ICM42688P_REG_ACCEL_DATA_Y0     : constant := 16#22#;
   ICM42688P_REG_ACCEL_DATA_Z1     : constant := 16#23#;
   ICM42688P_REG_ACCEL_DATA_Z0     : constant := 16#24#;
   ICM42688P_REG_GYRO_DATA_X1      : constant := 16#25#;
   ICM42688P_REG_GYRO_DATA_X0      : constant := 16#26#;
   ICM42688P_REG_GYRO_DATA_Y1      : constant := 16#27#;
   ICM42688P_REG_GYRO_DATA_Y0      : constant := 16#28#;
   ICM42688P_REG_GYRO_DATA_Z1      : constant := 16#29#;
   ICM42688P_REG_GYRO_DATA_Z0      : constant := 16#2A#;
   ICM42688P_REG_TMST_FSYNCH       : constant := 16#2B#;
   ICM42688P_REG_TMST_FSYNCL       : constant := 16#2C#;
   ICM42688P_REG_INT_STATUS        : constant := 16#2D#;
   ICM42688P_REG_FIFO_COUNTH       : constant := 16#2E#;
   ICM42688P_REG_FIFO_COUNTL       : constant := 16#2F#;
   ICM42688P_REG_FIFO_DATA         : constant := 16#30#;
   ICM42688P_REG_APEX_DATA0        : constant := 16#31#;
   ICM42688P_REG_APEX_DATA1        : constant := 16#32#;
   ICM42688P_REG_APEX_DATA2        : constant := 16#33#;
   ICM42688P_REG_APEX_DATA3        : constant := 16#34#;
   ICM42688P_REG_APEX_DATA4        : constant := 16#35#;
   ICM42688P_REG_APEX_DATA5        : constant := 16#36#;
   ICM42688P_REG_INT_STATUS2       : constant := 16#37#;
   ICM42688P_REG_INT_STATUS3       : constant := 16#38#;
   ICM42688P_REG_SIGNAL_PATH_RESET : constant := 16#4B#;
   ICM42688P_REG_INTF_CONFIG0      : constant := 16#4C#;
   ICM42688P_REG_INTF_CONFIG1      : constant := 16#4D#;
   ICM42688P_REG_PWR_MGMT0         : constant := 16#4E#;
   ICM42688P_REG_GYRO_CONFIG0      : constant := 16#4F#;
   ICM42688P_REG_ACCEL_CONFIG0     : constant := 16#50#;
   ICM42688P_REG_GYRO_CONFIG1      : constant := 16#51#;
   ICM42688P_REG_GYRO_ACCEL_CONFIG0 : constant := 16#52#;
   ICM42688P_REG_ACCEL_CONFIG1     : constant := 16#53#;
   ICM42688P_REG_TMST_CONFIG       : constant := 16#54#;
   ICM42688P_REG_APEX_CONFIG0      : constant := 16#56#;
   ICM42688P_REG_SMD_CONFIG        : constant := 16#57#;
   ICM42688P_REG_FIFO_CONFIG1      : constant := 16#5F#;
   ICM42688P_REG_FIFO_CONFIG2      : constant := 16#60#;
   ICM42688P_REG_FIFO_CONFIG3      : constant := 16#61#;
   ICM42688P_REG_FSYNC_CONFIG      : constant := 16#62#;
   ICM42688P_REG_INT_CONFIG0       : constant := 16#63#;
   ICM42688P_REG_INT_CONFIG1       : constant := 16#64#;
   ICM42688P_REG_INT_SOURCE0       : constant := 16#65#;
   ICM42688P_REG_INT_SOURCE1       : constant := 16#66#;
   ICM42688P_REG_INT_SOURCE3       : constant := 16#68#;
   ICM42688P_REG_INT_SOURCE4       : constant := 16#69#;
   ICM42688P_REG_FIFO_LOST_PKT0    : constant := 16#6C#;
   ICM42688P_REG_FIFO_LOST_PKT1    : constant := 16#6D#;
   ICM42688P_REG_SELF_TEST_CONFIG  : constant := 16#70#;
   ICM42688P_REG_WHO_AM_I          : constant := 16#75#;
   ICM42688P_REG_REG_BANK_SEL      : constant := 16#76#;

   --  Bank 1 Register Map (Sensor configuration)
   ICM42688P_REG_SENSOR_CONFIG0    : constant := 16#03#;
   ICM42688P_REG_GYRO_CONFIG_STATIC2 : constant := 16#0B#;
   ICM42688P_REG_GYRO_CONFIG_STATIC3 : constant := 16#0C#;
   ICM42688P_REG_GYRO_CONFIG_STATIC4 : constant := 16#0D#;
   ICM42688P_REG_GYRO_CONFIG_STATIC5 : constant := 16#0E#;
   ICM42688P_REG_GYRO_CONFIG_STATIC6 : constant := 16#0F#;
   ICM42688P_REG_GYRO_CONFIG_STATIC7 : constant := 16#10#;
   ICM42688P_REG_GYRO_CONFIG_STATIC8 : constant := 16#11#;
   ICM42688P_REG_GYRO_CONFIG_STATIC9 : constant := 16#12#;
   ICM42688P_REG_GYRO_CONFIG_STATIC10 : constant := 16#13#;
   ICM42688P_REG_XG_ST_DATA        : constant := 16#5F#;
   ICM42688P_REG_YG_ST_DATA        : constant := 16#60#;
   ICM42688P_REG_ZG_ST_DATA        : constant := 16#61#;
   ICM42688P_REG_TMSTVAL0          : constant := 16#62#;
   ICM42688P_REG_TMSTVAL1          : constant := 16#63#;
   ICM42688P_REG_TMSTVAL2          : constant := 16#64#;
   ICM42688P_REG_INTF_CONFIG4      : constant := 16#7A#;
   ICM42688P_REG_INTF_CONFIG5      : constant := 16#7B#;
   ICM42688P_REG_INTF_CONFIG6      : constant := 16#7C#;

   --  Bank 2 Register Map (Gyro and Accel offsets)
   ICM42688P_REG_GYRO_X_OFF_USR_H  : constant := 16#03#;
   ICM42688P_REG_GYRO_X_OFF_USR_L  : constant := 16#04#;
   ICM42688P_REG_GYRO_Y_OFF_USR_H  : constant := 16#05#;
   ICM42688P_REG_GYRO_Y_OFF_USR_L  : constant := 16#06#;
   ICM42688P_REG_GYRO_Z_OFF_USR_H  : constant := 16#07#;
   ICM42688P_REG_GYRO_Z_OFF_USR_L  : constant := 16#08#;
   ICM42688P_REG_ACCEL_X_OFF_USR_H : constant := 16#09#;
   ICM42688P_REG_ACCEL_X_OFF_USR_L : constant := 16#0A#;
   ICM42688P_REG_ACCEL_Y_OFF_USR_H : constant := 16#0B#;
   ICM42688P_REG_ACCEL_Y_OFF_USR_L : constant := 16#0C#;
   ICM42688P_REG_ACCEL_Z_OFF_USR_H : constant := 16#0D#;
   ICM42688P_REG_ACCEL_Z_OFF_USR_L : constant := 16#0E#;

   --  SPI read/write bits
   ICM42688P_SPI_READ  : constant := 16#80#;
   ICM42688P_SPI_WRITE : constant := 16#00#;

   --  Internal procedures

   --  Select register bank
   procedure Select_Bank
     (Device : in out ICM42688P_Device;
      Bank   : ICM42688P_Register_Bank);

   --  Read a single register
   procedure Read_Register
     (Device   : ICM42688P_Device;
      Reg_Addr : UInt8;
      Data     : out UInt8);

   --  Read multiple registers
   procedure Read_Registers
     (Device   : ICM42688P_Device;
      Reg_Addr : UInt8;
      Data     : out SPI_Data_8b);

   --  Write a single register
   procedure Write_Register
     (Device   : ICM42688P_Device;
      Reg_Addr : UInt8;
      Data     : UInt8);

   --  Combine high and low bytes into signed 16-bit integer
   function Combine_Bytes (High : UInt8; Low : UInt8) return Integer_16;
   pragma Inline (Combine_Bytes);

end ICM42688P;
