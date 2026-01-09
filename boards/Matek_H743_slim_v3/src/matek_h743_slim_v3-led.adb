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
with STM32.GPIO;   use STM32.GPIO;

package body Matek_H743_Slim_V3.LED is

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize is
      Config : GPIO_Port_Configuration;
   begin
      Enable_Clock (All_LEDs);

      Config.Mode        := Mode_Out;
      Config.Output_Type := Push_Pull;
      Config.Speed       := Speed_Low;
      Config.Resistors   := Floating;

      Configure_IO (All_LEDs, Config);

      --  LEDs are active low, so set them high to turn them off initially
      All_LEDs_Off;
   end Initialize;

   -------------------
   -- Turn_On_ACT   --
   -------------------

   procedure Turn_On_ACT is
   begin
      Clear (LED_ACT);  --  Active low
   end Turn_On_ACT;

   --------------------
   -- Turn_Off_ACT   --
   --------------------

   procedure Turn_Off_ACT is
   begin
      Set (LED_ACT);  --  Active low
   end Turn_Off_ACT;

   -----------------
   -- Toggle_ACT  --
   -----------------

   procedure Toggle_ACT is
   begin
      Toggle (LED_ACT);
   end Toggle_ACT;

   ------------------
   -- Turn_On_BE   --
   ------------------

   procedure Turn_On_BE is
   begin
      Clear (LED_BE);  --  Active low
   end Turn_On_BE;

   -------------------
   -- Turn_Off_BE   --
   -------------------

   procedure Turn_Off_BE is
   begin
      Set (LED_BE);  --  Active low
   end Turn_Off_BE;

   ----------------
   -- Toggle_BE  --
   ----------------

   procedure Toggle_BE is
   begin
      Toggle (LED_BE);
   end Toggle_BE;

   ------------------
   -- All_LEDs_On  --
   ------------------

   procedure All_LEDs_On is
   begin
      Clear (All_LEDs);  --  Active low
   end All_LEDs_On;

   -------------------
   -- All_LEDs_Off  --
   -------------------

   procedure All_LEDs_Off is
   begin
      Set (All_LEDs);  --  Active low
   end All_LEDs_Off;

end Matek_H743_Slim_V3.LED;
