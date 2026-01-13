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

--  Board support for Matek H743 Slim V3 flight controller

with Matek_H743_Slim_V3; use Matek_H743_Slim_V3;
with STM32.Device;       use STM32.Device;
with STM32.GPIO;         use STM32.GPIO;
with STM32.SPI;          use STM32.SPI;

with ICM42688P;          use ICM42688P;
with Ravenscar_Time;

package STM32.Board is
   pragma Elaborate_Body;

   subtype User_LED is GPIO_Point;

   --  LEDs on the board
   Blue_LED  : User_LED renames LED_ACT;
   Green_LED : User_LED renames LED_BE;
   
   All_LEDs : GPIO_Points renames Matek_H743_Slim_V3.All_LEDs;
   LCH_LED  : GPIO_Point renames Blue_LED;

   procedure Initialize_LEDs;
   --  MUST be called prior to any use of the LEDs

   procedure Turn_On  (This : in out User_LED) renames STM32.GPIO.Set;
   procedure Turn_Off (This : in out User_LED) renames STM32.GPIO.Clear;
   procedure Toggle   (This : in out User_LED) renames STM32.GPIO.Toggle;

   procedure All_LEDs_Off with Inline;
   procedure All_LEDs_On  with Inline;

   ---------
   -- SPI --
   ---------

   --  SPI1 for primary IMU (ICM42688P)
   SPI_1_Port : SPI_Port renames SPI_1;

   ---------
   -- IMU --
   ---------

   --  ICM42688P on SPI1
   ICM_Device : ICM42688P_Device
     (Port => SPI_1_Port'Access,
      CS   => IMU1_CS'Access,
      Time => Ravenscar_Time.Delays'Access);

   --  Initialize SPI and GPIO for IMU
   procedure Initialize_IMU_IO;

   --  Initialize the ICM42688P sensor
   procedure Initialize_IMU;

   --  Test if IMU is responding
   function Test_IMU return Boolean;

end STM32.Board;
