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

with Ada.Unchecked_Conversion;

package body ICM42688P is

   -------------------
   -- Combine_Bytes --
   -------------------

   function Combine_Bytes (High : UInt8; Low : UInt8) return Integer_16 is
      function To_Signed is new Ada.Unchecked_Conversion
        (Source => UInt16, Target => Integer_16);
   begin
      return To_Signed (Shift_Left (UInt16 (High), 8) or UInt16 (Low));
   end Combine_Bytes;

   -----------------
   -- Select_Bank --
   -----------------

   procedure Select_Bank
     (Device : in out ICM42688P_Device;
      Bank   : ICM42688P_Register_Bank)
   is
   begin
      if Device.Current_Bank /= Bank then
         Write_Register
           (Device   => Device,
            Reg_Addr => ICM42688P_REG_REG_BANK_SEL,
            Data     => UInt8 (ICM42688P_Register_Bank'Enum_Rep (Bank)));
         Device.Current_Bank := Bank;
         --  Small delay after bank switch
         Device.Time.Delay_Microseconds (10);
      end if;
   end Select_Bank;

   -------------------
   -- Read_Register --
   -------------------

   procedure Read_Register
     (Device   : ICM42688P_Device;
      Reg_Addr : UInt8;
      Data     : out UInt8)
   is
      Status     : SPI_Status;
      Tx_Buffer  : SPI_Data_8b (1 .. 2);
      Rx_Buffer  : SPI_Data_8b (1 .. 2);
   begin
      --  Prepare SPI read command (MSB = 1 for read)
      Tx_Buffer (1) := Reg_Addr or ICM42688P_SPI_READ;
      Tx_Buffer (2) := 16#00#;  --  Dummy byte

      --  Assert chip select
      Device.CS.Clear;

      --  Perform SPI transaction
      Device.Port.Transmit (Tx_Buffer, Status);
      
      if Status /= Ok then
         Device.CS.Set;
         Data := 0;
         return;
      end if;

      Device.Port.Receive (Rx_Buffer, Status);

      --  Deassert chip select
      Device.CS.Set;

      if Status = Ok then
         Data := Rx_Buffer (2);  --  Data is in second byte
      else
         Data := 0;
      end if;
   end Read_Register;

   --------------------
   -- Read_Registers --
   --------------------

   procedure Read_Registers
     (Device   : ICM42688P_Device;
      Reg_Addr : UInt8;
      Data     : out SPI_Data_8b)
   is
      Status     : SPI_Status;
      Tx_Buffer  : SPI_Data_8b (1 .. Data'Length + 1);
      Rx_Buffer  : SPI_Data_8b (1 .. Data'Length + 1);
   begin
      --  Prepare SPI read command
      Tx_Buffer (1) := Reg_Addr or ICM42688P_SPI_READ;
      for I in 2 .. Tx_Buffer'Last loop
         Tx_Buffer (I) := 16#00#;  --  Dummy bytes
      end loop;

      --  Assert chip select
      Device.CS.Clear;

      --  Perform SPI transaction
      Device.Port.Transmit (Tx_Buffer, Status);
      
      if Status /= Ok then
         Device.CS.Set;
         Data := (others => 0);
         return;
      end if;

      Device.Port.Receive (Rx_Buffer, Status);

      --  Deassert chip select
      Device.CS.Set;

      if Status = Ok then
         --  Copy received data (skip first byte which is dummy)
         for I in Data'Range loop
            Data (I) := Rx_Buffer (I + 1);
         end loop;
      else
         Data := (others => 0);
      end if;
   end Read_Registers;

   --------------------
   -- Write_Register --
   --------------------

   procedure Write_Register
     (Device   : ICM42688P_Device;
      Reg_Addr : UInt8;
      Data     : UInt8)
   is
      Status    : SPI_Status;
      Tx_Buffer : SPI_Data_8b (1 .. 2);
   begin
      --  Prepare SPI write command (MSB = 0 for write)
      Tx_Buffer (1) := Reg_Addr and not ICM42688P_SPI_READ;
      Tx_Buffer (2) := Data;

      --  Assert chip select
      Device.CS.Clear;

      --  Perform SPI transaction
      Device.Port.Transmit (Tx_Buffer, Status);

      --  Deassert chip select
      Device.CS.Set;

      --  Small delay after write
      Device.Time.Delay_Microseconds (10);
   end Write_Register;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize (Device : in out ICM42688P_Device) is
   begin
      if Device.Is_Init then
         return;
      end if;

      --  Wait for device startup
      Device.Time.Delay_Milliseconds (ICM42688P_STARTUP_TIME_MS);

      --  Ensure CS is deasserted initially
      Device.CS.Set;

      --  Perform soft reset
      Reset (Device);

      --  Verify device ID
      if not Test_Connection (Device) then
         return;  --  Failed to detect device
      end if;

      --  Select Bank 0 for initial configuration
      Select_Bank (Device, Bank_0);

      --  Disable all interrupts initially
      Write_Register (Device, ICM42688P_REG_INT_SOURCE0, 16#00#);
      Write_Register (Device, ICM42688P_REG_INT_SOURCE1, 16#00#);

      --  Configure interface (SPI mode, no FIFO for now)
      Write_Register (Device, ICM42688P_REG_INTF_CONFIG1, 16#95#);

      --  Set default gyro range to ±2000 dps
      Set_Gyro_FS_Range (Device, Gyro_FS_2000);

      --  Set default accel range to ±16g
      Set_Accel_FS_Range (Device, Accel_FS_16);

      --  Set default ODR to 1kHz for both sensors
      Set_Gyro_ODR (Device, Gyro_ODR_1kHz);
      Set_Accel_ODR (Device, Accel_ODR_1kHz);

      --  Enable gyro and accel in low-noise mode
      Set_Power_Mode (Device, Low_Noise_Mode, Low_Noise_Mode);

      --  Mark as initialized
      Device.Is_Init := True;

      --  Wait for sensors to stabilize
      Device.Time.Delay_Milliseconds (50);
   end Initialize;

   ----------
   -- Test --
   ----------

   function Test (Device : in out ICM42688P_Device) return Boolean is
   begin
      return Device.Is_Init and then Test_Connection (Device);
   end Test;

   ---------------------
   -- Test_Connection --
   ---------------------

   function Test_Connection (Device : in out ICM42688P_Device) return Boolean is
      Who_Am_I : UInt8;
   begin
      --  Select Bank 0 where WHO_AM_I register is located
      Select_Bank (Device, Bank_0);

      Read_Register
        (Device   => Device,
         Reg_Addr => ICM42688P_REG_WHO_AM_I,
         Data     => Who_Am_I);

      return Who_Am_I = ICM42688P_WHO_AM_I_VALUE;
   end Test_Connection;

   -----------
   -- Reset --
   -----------

   procedure Reset (Device : in out ICM42688P_Device) is
   begin
      --  Select Bank 0
      Select_Bank (Device, Bank_0);

      --  Write to DEVICE_CONFIG register to trigger soft reset
      Write_Register (Device, ICM42688P_REG_DEVICE_CONFIG, 16#01#);

      --  Wait for reset to complete
      Device.Time.Delay_Milliseconds (ICM42688P_RESET_TIME_MS);

      --  Reset internal state
      Device.Current_Bank := Bank_0;
   end Reset;

   --------------------
   -- Set_Power_Mode --
   --------------------

   procedure Set_Power_Mode
     (Device      : in out ICM42688P_Device;
      Gyro_Mode   : ICM42688P_Power_Mode;
      Accel_Mode  : ICM42688P_Power_Mode)
   is
      PWR_Value : UInt8 := 0;
   begin
      --  Select Bank 0
      Select_Bank (Device, Bank_0);

      --  Build PWR_MGMT0 register value
      --  Gyro mode: bits 3:2
      --  Accel mode: bits 1:0
      case Gyro_Mode is
         when Sleep_Mode      => PWR_Value := PWR_Value or 16#00#;
         when Standby_Mode    => PWR_Value := PWR_Value or 16#04#;
         when Low_Power_Mode  => PWR_Value := PWR_Value or 16#08#;
         when Low_Noise_Mode  => PWR_Value := PWR_Value or 16#0C#;
      end case;

      case Accel_Mode is
         when Sleep_Mode      => PWR_Value := PWR_Value or 16#00#;
         when Standby_Mode    => PWR_Value := PWR_Value or 16#01#;
         when Low_Power_Mode  => PWR_Value := PWR_Value or 16#02#;
         when Low_Noise_Mode  => PWR_Value := PWR_Value or 16#03#;
      end case;

      Write_Register (Device, ICM42688P_REG_PWR_MGMT0, PWR_Value);

      --  Wait for power mode transition
      Device.Time.Delay_Milliseconds (1);
   end Set_Power_Mode;

   ------------------------
   -- Set_Gyro_FS_Range --
   ------------------------

   procedure Set_Gyro_FS_Range
     (Device   : in out ICM42688P_Device;
      FS_Range : ICM42688P_Gyro_FS_Range)
   is
      Config_Value : UInt8;
   begin
      --  Select Bank 0
      Select_Bank (Device, Bank_0);

      --  Read current GYRO_CONFIG0 register
      Read_Register (Device, ICM42688P_REG_GYRO_CONFIG0, Config_Value);

      --  Clear FS bits (bits 7:5) and set new value
      Config_Value := (Config_Value and 16#1F#) or
                      Shift_Left (UInt8 (ICM42688P_Gyro_FS_Range'Enum_Rep (FS_Range)), 5);

      Write_Register (Device, ICM42688P_REG_GYRO_CONFIG0, Config_Value);

      --  Update device state
      Device.Gyro_FS := FS_Range;
   end Set_Gyro_FS_Range;

   -------------------------
   -- Set_Accel_FS_Range --
   -------------------------

   procedure Set_Accel_FS_Range
     (Device   : in out ICM42688P_Device;
      FS_Range : ICM42688P_Accel_FS_Range)
   is
      Config_Value : UInt8;
   begin
      --  Select Bank 0
      Select_Bank (Device, Bank_0);

      --  Read current ACCEL_CONFIG0 register
      Read_Register (Device, ICM42688P_REG_ACCEL_CONFIG0, Config_Value);

      --  Clear FS bits (bits 6:5) and set new value
      Config_Value := (Config_Value and 16#9F#) or
                      Shift_Left (UInt8 (ICM42688P_Accel_FS_Range'Enum_Rep (FS_Range)), 5);

      Write_Register (Device, ICM42688P_REG_ACCEL_CONFIG0, Config_Value);

      --  Update device state
      Device.Accel_FS := FS_Range;
   end Set_Accel_FS_Range;

   ------------------
   -- Set_Gyro_ODR --
   ------------------

   procedure Set_Gyro_ODR
     (Device : in out ICM42688P_Device;
      ODR    : ICM42688P_Gyro_ODR)
   is
      Config_Value : UInt8;
   begin
      --  Select Bank 0
      Select_Bank (Device, Bank_0);

      --  Read current GYRO_CONFIG0 register
      Read_Register (Device, ICM42688P_REG_GYRO_CONFIG0, Config_Value);

      --  Clear ODR bits (bits 3:0) and set new value
      Config_Value := (Config_Value and 16#F0#) or
                      UInt8 (ICM42688P_Gyro_ODR'Enum_Rep (ODR));

      Write_Register (Device, ICM42688P_REG_GYRO_CONFIG0, Config_Value);
   end Set_Gyro_ODR;

   -------------------
   -- Set_Accel_ODR --
   -------------------

   procedure Set_Accel_ODR
     (Device : in out ICM42688P_Device;
      ODR    : ICM42688P_Accel_ODR)
   is
      Config_Value : UInt8;
   begin
      --  Select Bank 0
      Select_Bank (Device, Bank_0);

      --  Read current ACCEL_CONFIG0 register
      Read_Register (Device, ICM42688P_REG_ACCEL_CONFIG0, Config_Value);

      --  Clear ODR bits (bits 3:0) and set new value
      Config_Value := (Config_Value and 16#F0#) or
                      UInt8 (ICM42688P_Accel_ODR'Enum_Rep (ODR));

      Write_Register (Device, ICM42688P_REG_ACCEL_CONFIG0, Config_Value);
   end Set_Accel_ODR;

   -------------------
   -- Get_Motion_6 --
   -------------------

   procedure Get_Motion_6
     (Device : in out ICM42688P_Device;
      Acc_X  : out Integer_16;
      Acc_Y  : out Integer_16;
      Acc_Z  : out Integer_16;
      Gyro_X : out Integer_16;
      Gyro_Y : out Integer_16;
      Gyro_Z : out Integer_16)
   is
      Data : SPI_Data_8b (1 .. 12);
   begin
      --  Select Bank 0
      Select_Bank (Device, Bank_0);

      --  Read all 12 bytes starting from ACCEL_DATA_X1
      Read_Registers (Device, ICM42688P_REG_ACCEL_DATA_X1, Data);

      --  Combine bytes (high byte first, then low byte)
      Acc_X  := Combine_Bytes (Data (1), Data (2));
      Acc_Y  := Combine_Bytes (Data (3), Data (4));
      Acc_Z  := Combine_Bytes (Data (5), Data (6));
      Gyro_X := Combine_Bytes (Data (7), Data (8));
      Gyro_Y := Combine_Bytes (Data (9), Data (10));
      Gyro_Z := Combine_Bytes (Data (11), Data (12));
   end Get_Motion_6;

   ---------------
   -- Read_Gyro --
   ---------------

   procedure Read_Gyro
     (Device : in out ICM42688P_Device;
      X      : out Integer_16;
      Y      : out Integer_16;
      Z      : out Integer_16)
   is
      Data : SPI_Data_8b (1 .. 6);
   begin
      --  Select Bank 0
      Select_Bank (Device, Bank_0);

      --  Read 6 bytes starting from GYRO_DATA_X1
      Read_Registers (Device, ICM42688P_REG_GYRO_DATA_X1, Data);

      --  Combine bytes
      X := Combine_Bytes (Data (1), Data (2));
      Y := Combine_Bytes (Data (3), Data (4));
      Z := Combine_Bytes (Data (5), Data (6));
   end Read_Gyro;

   ----------------
   -- Read_Accel --
   ----------------

   procedure Read_Accel
     (Device : in out ICM42688P_Device;
      X      : out Integer_16;
      Y      : out Integer_16;
      Z      : out Integer_16)
   is
      Data : SPI_Data_8b (1 .. 6);
   begin
      --  Select Bank 0
      Select_Bank (Device, Bank_0);

      --  Read 6 bytes starting from ACCEL_DATA_X1
      Read_Registers (Device, ICM42688P_REG_ACCEL_DATA_X1, Data);

      --  Combine bytes
      X := Combine_Bytes (Data (1), Data (2));
      Y := Combine_Bytes (Data (3), Data (4));
      Z := Combine_Bytes (Data (5), Data (6));
   end Read_Accel;

   ----------------------
   -- Read_Temperature --
   ----------------------

   function Read_Temperature (Device : in out ICM42688P_Device) return Float is
      Data      : SPI_Data_8b (1 .. 2);
      Temp_Raw  : Integer_16;
      Temp_C    : Float;
   begin
      --  Select Bank 0
      Select_Bank (Device, Bank_0);

      --  Read temperature registers
      Read_Registers (Device, ICM42688P_REG_TEMP_DATA1, Data);

      --  Combine bytes
      Temp_Raw := Combine_Bytes (Data (1), Data (2));

      --  Convert to Celsius using ICM42688P formula:
      --  Temperature (°C) = (TEMP_DATA / 132.48) + 25
      Temp_C := (Float (Temp_Raw) / 132.48) + 25.0;

      return Temp_C;
   end Read_Temperature;

   ----------------
   -- Data_Ready --
   ----------------

   function Data_Ready (Device : in out ICM42688P_Device) return Boolean is
      Status : UInt8;
   begin
      --  Select Bank 0
      Select_Bank (Device, Bank_0);

      --  Read INT_STATUS register
      Read_Register (Device, ICM42688P_REG_INT_STATUS, Status);

      --  Bit 3 is DATA_RDY_INT
      return (Status and 16#08#) /= 0;
   end Data_Ready;

end ICM42688P;
