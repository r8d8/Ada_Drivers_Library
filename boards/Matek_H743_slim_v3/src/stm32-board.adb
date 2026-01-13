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

with STM32.Device; use STM32.Device;
with STM32.SPI;    use STM32.SPI;
with STM32.GPIO;   use STM32.GPIO;

with Matek_H743_Slim_V3; use Matek_H743_Slim_V3;

package body STM32.Board is

   ---------------------
   -- Initialize_LEDs --
   ---------------------

   procedure Initialize_LEDs is
      Configuration : GPIO_Port_Configuration;
   begin
      Enable_Clock (All_LEDs);

      Configuration.Mode        := Mode_Out;
      Configuration.Output_Type := Push_Pull;
      Configuration.Speed       := Speed_100MHz;
      Configuration.Resistors   := Floating;

      Configure_IO (All_LEDs, Configuration);

      All_LEDs_Off;
   end Initialize_LEDs;

   ------------------
   -- All_LEDs_Off --
   ------------------

   procedure All_LEDs_Off is
   begin
      Clear (All_LEDs);
   end All_LEDs_Off;

   -----------------
   -- All_LEDs_On --
   -----------------

   procedure All_LEDs_On is
   begin
      Set (All_LEDs);
   end All_LEDs_On;

   ------------------------
   -- Initialize_IMU_IO --
   ------------------------

   procedure Initialize_IMU_IO is
      SPI_Pins : constant GPIO_Points := (SPI1_SCK, SPI1_MISO, SPI1_MOSI);
      SPI_Config : GPIO_Port_Configuration;
      SPI_AF : constant GPIO_Alternate_Function := GPIO_AF_SPI1_5;
   begin
      --  Enable clocks
      Enable_Clock (SPI_Pins);
      Enable_Clock (IMU1_CS);
      Enable_Clock (SPI_1_Port);

      --  Configure SPI pins (AF mode)
      SPI_Config.Mode           := Mode_AF;
      SPI_Config.AF             := SPI_AF;
      SPI_Config.Output_Type    := Push_Pull;
      SPI_Config.Speed          := Speed_100MHz;
      SPI_Config.Resistors      := Floating;
      Configure_IO (SPI_Pins, SPI_Config);

      --  Configure CS pin as output (manually controlled)
      SPI_Config.Mode        := Mode_Out;
      SPI_Config.Output_Type := Push_Pull;
      SPI_Config.Speed       := Speed_100MHz;
      SPI_Config.Resistors   := Floating;
      Configure_IO (IMU1_CS, SPI_Config);

      --  Deassert CS (active low)
      Set (IMU1_CS);

      --  Configure SPI peripheral
      --  H743 SPI1 clock is on APB2 (max 100MHz for H7)
      --  We'll use prescaler to get ~16MHz for ICM42688P
      --  100MHz / 8 = 12.5MHz (safe and within spec)
      declare
         SPI_Conf : SPI_Configuration;
      begin
         SPI_Conf.Mode                := Master;
         SPI_Conf.Baud_Rate_Prescaler := BRDiv_8;     -- 100MHz / 8 = 12.5MHz
         SPI_Conf.Clock_Polarity      := High;        -- CPOL = 1
         SPI_Conf.Clock_Phase         := P2Edge;      -- CPHA = 1 (MODE3)
         SPI_Conf.First_Bit           := MSB_First;
         SPI_Conf.CRC_Poly            := 0;
         SPI_Conf.Slave_Management    := Software_Managed;
         SPI_Conf.Direction           := D2Lines_FullDuplex;
         SPI_Conf.Data_Size           := HAL.SPI.Data_Size_8b;
         SPI_Conf.Fifo_Level          := True;

         Configure (SPI_1_Port, SPI_Conf);
         Enable (SPI_1_Port);
      end;
   end Initialize_IMU_IO;

   --------------------
   -- Initialize_IMU --
   --------------------

   procedure Initialize_IMU is
   begin
      Initialize_IMU_IO;
      ICM_Device.Initialize;
   end Initialize_IMU;

   --------------
   -- Test_IMU --
   --------------

   function Test_IMU return Boolean is
   begin
      return ICM_Device.Test;
   end Test_IMU;

end STM32.Board;
