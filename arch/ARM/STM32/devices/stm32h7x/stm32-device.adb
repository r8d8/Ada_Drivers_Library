------------------------------------------------------------------------------
--                                                                          --
--                     Copyright (C) 2015-2016, AdaCore                     --
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

with System;        use System;
with STM32_SVD.RCC; use STM32_SVD.RCC;

package body STM32.Device is


   HPRE_Presc_Table : constant array (HAL.UInt4) of HAL.UInt32 :=
     (1, 1, 1, 1, 1, 1, 1, 1, 2, 4, 8, 16, 64, 128, 256, 512);

   PPRE_Presc_Table : constant array (HAL.UInt3) of HAL.UInt32 :=
     (1, 1, 1, 1, 2, 4, 8, 16);

   function PLLSAI_Enabled return Boolean;

   ------------------
   -- Enable_Clock --
   ------------------

   procedure Enable_Clock (This : aliased in out GPIO_Port) is
   begin
      if This'Address = GPIOA_Base then
         RCC_Periph.AHB4ENR.GPIOAEN := True;
      elsif This'Address = GPIOB_Base then
         RCC_Periph.AHB4ENR.GPIOBEN := True;
      elsif This'Address = GPIOC_Base then
         RCC_Periph.AHB4ENR.GPIOCEN := True;
      elsif This'Address = GPIOD_Base then
         RCC_Periph.AHB4ENR.GPIODEN := True;
      elsif This'Address = GPIOE_Base then
         RCC_Periph.AHB4ENR.GPIOEEN := True;
      elsif This'Address = GPIOF_Base then
         RCC_Periph.AHB4ENR.GPIOFEN := True;
      elsif This'Address = GPIOG_Base then
         RCC_Periph.AHB4ENR.GPIOGEN := True;
      elsif This'Address = GPIOH_Base then
         RCC_Periph.AHB4ENR.GPIOHEN := True;
      elsif This'Address = GPIOI_Base then
         RCC_Periph.AHB4ENR.GPIOIEN := True;
      elsif This'Address = GPIOJ_Base then
         RCC_Periph.AHB4ENR.GPIOJEN := True;
      elsif This'Address = GPIOK_Base then
         RCC_Periph.AHB4ENR.GPIOKEN := True;
      else
         raise Unknown_Device;
      end if;
   end Enable_Clock;

   ------------------
   -- Enable_Clock --
   ------------------

   procedure Enable_Clock (Point : GPIO_Point)
   is
   begin
      Enable_Clock (Point.Periph.all);
   end Enable_Clock;

   ------------------
   -- Enable_Clock --
   ------------------

   procedure Enable_Clock (Points : GPIO_Points)
   is
   begin
      for Point of Points loop
         Enable_Clock (Point);
      end loop;
   end Enable_Clock;

   -----------
   -- Reset --
   -----------

   procedure Reset (This : aliased in out GPIO_Port) is
   begin
      if This'Address = GPIOA_Base then
         RCC_Periph.AHB4RSTR.GPIOARST := True;
         RCC_Periph.AHB4RSTR.GPIOARST := False;
      elsif This'Address = GPIOB_Base then
         RCC_Periph.AHB4RSTR.GPIOBRST := True;
         RCC_Periph.AHB4RSTR.GPIOBRST := False;
      elsif This'Address = GPIOC_Base then
         RCC_Periph.AHB4RSTR.GPIOCRST := True;
         RCC_Periph.AHB4RSTR.GPIOCRST := False;
      elsif This'Address = GPIOD_Base then
         RCC_Periph.AHB4RSTR.GPIODRST := True;
         RCC_Periph.AHB4RSTR.GPIODRST := False;
      elsif This'Address = GPIOE_Base then
         RCC_Periph.AHB4RSTR.GPIOERST := True;
         RCC_Periph.AHB4RSTR.GPIOERST := False;
      elsif This'Address = GPIOF_Base then
         RCC_Periph.AHB4RSTR.GPIOFRST := True;
         RCC_Periph.AHB4RSTR.GPIOFRST := False;
      elsif This'Address = GPIOG_Base then
         RCC_Periph.AHB4RSTR.GPIOGRST := True;
         RCC_Periph.AHB4RSTR.GPIOGRST := False;
      elsif This'Address = GPIOH_Base then
         RCC_Periph.AHB4RSTR.GPIOHRST := True;
         RCC_Periph.AHB4RSTR.GPIOHRST := False;
      elsif This'Address = GPIOI_Base then
         RCC_Periph.AHB4RSTR.GPIOIRST := True;
         RCC_Periph.AHB4RSTR.GPIOIRST := False;
      elsif This'Address = GPIOJ_Base then
         RCC_Periph.AHB4RSTR.GPIOJRST := True;
         RCC_Periph.AHB4RSTR.GPIOJRST := False;
      elsif This'Address = GPIOK_Base then
         RCC_Periph.AHB4RSTR.GPIOKRST := True;
         RCC_Periph.AHB4RSTR.GPIOKRST := False;
      else
         raise Unknown_Device;
      end if;
   end Reset;

   -----------
   -- Reset --
   -----------

   procedure Reset (Point : GPIO_Point) is
   begin
      Reset (Point.Periph.all);
   end Reset;

   -----------
   -- Reset --
   -----------

   procedure Reset (Points : GPIO_Points)
   is
      Do_Reset : Boolean;
   begin
      for J in Points'Range loop
         Do_Reset := True;
         for K in Points'First .. J - 1 loop
            if Points (K).Periph = Points (J).Periph then
               Do_Reset := False;

               exit;
            end if;
         end loop;

         if Do_Reset then
            Reset (Points (J).Periph.all);
         end if;
      end loop;
   end Reset;

   ------------------------------
   -- GPIO_Port_Representation --
   ------------------------------

   function GPIO_Port_Representation (Port : GPIO_Port) return HAL.UInt4 is
   begin
      if Port'Address = GPIOA_Base then
         return 0;
      elsif Port'Address = GPIOB_Base then
         return 1;
      elsif Port'Address = GPIOC_Base then
         return 2;
      elsif Port'Address = GPIOD_Base then
         return 3;
      elsif Port'Address = GPIOE_Base then
         return 4;
      elsif Port'Address = GPIOF_Base then
         return 5;
      elsif Port'Address = GPIOG_Base then
         return 6;
      elsif Port'Address = GPIOH_Base then
         return 7;
      elsif Port'Address = GPIOI_Base then
         return 8;
      elsif Port'Address = GPIOJ_Base then
         return 9;
      elsif Port'Address = GPIOK_Base then
         return 10;
      else
         raise Program_Error;
      end if;
   end GPIO_Port_Representation;

   ------------------
   -- Enable_Clock --
   ------------------

   procedure Enable_Clock (This : aliased in out Analog_To_Digital_Converter)
   is
   begin
      if This'Address = ADC1_Base or This'Address = ADC2_Base then
         --  ADC1 and ADC2 share a single clock enable bit on H7
         RCC_Periph.AHB1ENR.ADC12EN := True;
      elsif This'Address = ADC3_Base then
         RCC_Periph.AHB4ENR.ADC3EN := True;
      else
         raise Unknown_Device;
      end if;
   end Enable_Clock;

   -------------------------
   -- Reset_All_ADC_Units --
   -------------------------

   procedure Reset_All_ADC_Units is
   begin
      --  H7 has separate reset bits for ADC1/2 (combined) and ADC3
      RCC_Periph.AHB1RSTR.ADC12RST := True;
      RCC_Periph.AHB1RSTR.ADC12RST := False;
      RCC_Periph.AHB4RSTR.ADC3RST := True;
      RCC_Periph.AHB4RSTR.ADC3RST := False;
   end Reset_All_ADC_Units;

   ------------------
   -- Enable_Clock --
   ------------------

   procedure Enable_Clock (This : aliased in out Digital_To_Analog_Converter)
   is
      pragma Unreferenced (This);
   begin
      --  H7 DAC is on APB1L bus with renamed enable bit
      RCC_Periph.APB1LENR.DAC12EN := True;
   end Enable_Clock;

   -----------
   -- Reset --
   -----------

   procedure Reset (This : aliased in out Digital_To_Analog_Converter) is
      pragma Unreferenced (This);
   begin
      --  H7 DAC is on APB1L bus with renamed reset bit
      RCC_Periph.APB1LRSTR.DAC12RST := True;
      RCC_Periph.APB1LRSTR.DAC12RST := False;
   end Reset;

   ------------------
   -- Enable_Clock --
   ------------------

--     procedure Enable_Clock (This : aliased in out USART) is
--     begin
--        if This'Address = USART1_Base then
--           RCC_Periph.APB2ENR.USART1EN := True;
--        elsif This'Address = USART2_Base then
--           RCC_Periph.APB1ENR.USART2EN := True;
--        elsif This'Address = USART3_Base then
--           RCC_Periph.APB1ENR.USART3EN := True;
--        elsif This'Address = UART4_Base then
--           RCC_Periph.APB1ENR.UART4EN := True;
--        elsif This'Address = UART5_Base then
--           RCC_Periph.APB1ENR.UART5EN := True;
--        elsif This'Address = USART6_Base then
--           RCC_Periph.APB2ENR.USART6EN := True;
--        elsif This'Address = UART7_Base then
--           RCC_Periph.APB1ENR.UART7ENR := True;
--        elsif This'Address = UART8_Base then
--           RCC_Periph.APB1ENR.UART8ENR := True;
--        else
--           raise Unknown_Device;
--        end if;
--     end Enable_Clock;

   -----------
   -- Reset --
   -----------

--     procedure Reset (This : aliased in out USART) is
--     begin
--        if This'Address = USART1_Base then
--           RCC_Periph.APB2RSTR.USART1RST := True;
--           RCC_Periph.APB2RSTR.USART1RST := False;
--        elsif This'Address = USART2_Base then
--           RCC_Periph.APB1RSTR.UART2RST := True;
--           RCC_Periph.APB1RSTR.UART2RST := False;
--        elsif This'Address = USART3_Base then
--           RCC_Periph.APB1RSTR.UART3RST := True;
--           RCC_Periph.APB1RSTR.UART3RST := False;
--        elsif This'Address = UART4_Base then
--           RCC_Periph.APB1RSTR.UART4RST := True;
--           RCC_Periph.APB1RSTR.UART4RST := False;
--        elsif This'Address = UART5_Base then
--           RCC_Periph.APB1RSTR.UART5RST := True;
--           RCC_Periph.APB1RSTR.UART5RST := False;
--        elsif This'Address = USART6_Base then
--           RCC_Periph.APB2RSTR.USART6RST := True;
--           RCC_Periph.APB2RSTR.USART6RST := False;
--        elsif This'Address = UART7_Base then
--           RCC_Periph.APB1RSTR.UART7RST := True;
--           RCC_Periph.APB1RSTR.UART7RST := False;
--        elsif This'Address = UART8_Base then
--           RCC_Periph.APB1RSTR.UART8RST := True;
--           RCC_Periph.APB1RSTR.UART8RST := False;
--        else
--           raise Unknown_Device;
--        end if;
--     end Reset;

   ------------------
   -- Enable_Clock --
   ------------------

   procedure Enable_Clock (This : aliased in out DMA_Controller) is
   begin
      if This'Address = STM32_SVD.DMA1_Base then
         RCC_Periph.AHB1ENR.DMA1EN := True;
      elsif This'Address = STM32_SVD.DMA2_Base then
         RCC_Periph.AHB1ENR.DMA2EN := True;
      else
         raise Unknown_Device;
      end if;
   end Enable_Clock;

   -----------
   -- Reset --
   -----------

   procedure Reset (This : aliased in out DMA_Controller) is
   begin
      if This'Address = STM32_SVD.DMA1_Base then
         RCC_Periph.AHB1RSTR.DMA1RST := True;
         RCC_Periph.AHB1RSTR.DMA1RST := False;
      elsif This'Address = STM32_SVD.DMA2_Base then
         RCC_Periph.AHB1RSTR.DMA2RST := True;
         RCC_Periph.AHB1RSTR.DMA2RST := False;
      else
         raise Unknown_Device;
      end if;
   end Reset;

   ----------------
   -- As_Port_Id --
   ----------------

   function As_Port_Id (Port : I2C_Port'Class) return I2C_Port_Id is
   begin
      if Port.Periph.all'Address = I2C1_Base then
         return I2C_Id_1;
      elsif Port.Periph.all'Address = I2C2_Base then
         return I2C_Id_2;
      elsif Port.Periph.all'Address = I2C3_Base then
         return I2C_Id_3;
      elsif Port.Periph.all'Address = I2C4_Base then
         return I2C_Id_4;
      else
         raise Unknown_Device;
      end if;
   end As_Port_Id;

   ------------------
   -- Enable_Clock --
   ------------------

   procedure Enable_Clock (This : I2C_Port'Class) is
   begin
      Enable_Clock (As_Port_Id (This));
   end Enable_Clock;

   ------------------
   -- Enable_Clock --
   ------------------

   procedure Enable_Clock (This : I2C_Port_Id) is
   begin
      case This is
         when I2C_Id_1 =>
            RCC_Periph.APB1LENR.I2C1EN := True;
         when I2C_Id_2 =>
            RCC_Periph.APB1LENR.I2C2EN := True;
         when I2C_Id_3 =>
            RCC_Periph.APB1LENR.I2C3EN := True;
         when I2C_Id_4 =>
            --  H7 NOTE: I2C4 is on APB4, not APB1
            RCC_Periph.APB4ENR.I2C4EN := True;
      end case;
   end Enable_Clock;

   -----------
   -- Reset --
   -----------

   procedure Reset (This : I2C_Port'Class) is
   begin
      Reset (As_Port_Id (This));
   end Reset;

   -----------
   -- Reset --
   -----------

   procedure Reset (This : I2C_Port_Id) is
   begin
      case This is
         when I2C_Id_1 =>
            RCC_Periph.APB1LRSTR.I2C1RST := True;
            RCC_Periph.APB1LRSTR.I2C1RST := False;
         when I2C_Id_2 =>
            RCC_Periph.APB1LRSTR.I2C2RST := True;
            RCC_Periph.APB1LRSTR.I2C2RST := False;
         when I2C_Id_3 =>
            RCC_Periph.APB1LRSTR.I2C3RST := True;
            RCC_Periph.APB1LRSTR.I2C3RST := False;
         when I2C_Id_4 =>
            --  H7 NOTE: I2C4 is on APB4, not APB1
            RCC_Periph.APB4RSTR.I2C4RST := True;
            RCC_Periph.APB4RSTR.I2C4RST := False;
      end case;
   end Reset;

   ------------------
   -- Enable_Clock --
   ------------------

   procedure Enable_Clock (This : SPI_Port'Class) is
   begin
      if This.Periph.all'Address = SPI1_Base then
         RCC_Periph.APB2ENR.SPI1EN := True;
      elsif This.Periph.all'Address = SPI2_Base then
         RCC_Periph.APB1LENR.SPI2EN := True;
      elsif This.Periph.all'Address = SPI3_Base then
         RCC_Periph.APB1LENR.SPI3EN := True;
      elsif This.Periph.all'Address = SPI4_Base then
         RCC_Periph.APB2ENR.SPI4EN := True;
      elsif This.Periph.all'Address = SPI5_Base then
         RCC_Periph.APB2ENR.SPI5EN := True;
      elsif This.Periph.all'Address = SPI6_Base then
         RCC_Periph.APB4ENR.SPI6EN := True;
      else
         raise Unknown_Device;
      end if;
   end Enable_Clock;

   -----------
   -- Reset --
   -----------

   procedure Reset (This : SPI_Port'Class) is
   begin
      if This.Periph.all'Address = SPI1_Base then
         RCC_Periph.APB2RSTR.SPI1RST := True;
         RCC_Periph.APB2RSTR.SPI1RST := False;
      elsif This.Periph.all'Address = SPI2_Base then
         RCC_Periph.APB1LRSTR.SPI2RST := True;
         RCC_Periph.APB1LRSTR.SPI2RST := False;
      elsif This.Periph.all'Address = SPI3_Base then
         RCC_Periph.APB1LRSTR.SPI3RST := True;
         RCC_Periph.APB1LRSTR.SPI3RST := False;
      elsif This.Periph.all'Address = SPI4_Base then
         RCC_Periph.APB2RSTR.SPI4RST := True;
         RCC_Periph.APB2RSTR.SPI4RST := False;
      elsif This.Periph.all'Address = SPI5_Base then
         RCC_Periph.APB2RSTR.SPI5RST := True;
         RCC_Periph.APB2RSTR.SPI5RST := False;
      elsif This.Periph.all'Address = SPI6_Base then
         RCC_Periph.APB4RSTR.SPI6RST := True;
         RCC_Periph.APB4RSTR.SPI6RST := False;
      else
         raise Unknown_Device;
      end if;
   end Reset;

   --  I2S functions also temporarily disabled
   --  ------------------
   --  -- Enable_Clock --
   --  ------------------
   --
   --  procedure Enable_Clock (This : I2S_Port) is
   --  begin
   --     if This.Periph.all'Address = SPI1_Base then
   --        RCC_Periph.APB2ENR.SPI1EN := True;
   --     elsif This.Periph.all'Address = SPI2_Base then
   --        --  H7 NOTE: SPI2 is on APB1L
   --        RCC_Periph.APB1LENR.SPI2EN := True;
   --     elsif This.Periph.all'Address = SPI3_Base then
   --        --  H7 NOTE: SPI3 is on APB1L
   --        RCC_Periph.APB1LENR.SPI3EN := True;
   --     elsif This.Periph.all'Address = SPI4_Base then
   --        RCC_Periph.APB2ENR.SPI4EN := True;
   --     elsif This.Periph.all'Address = SPI5_Base then
   --        RCC_Periph.APB2ENR.SPI5EN := True;
   --     elsif This.Periph.all'Address = SPI6_Base then
   --        --  H7 NOTE: SPI6 is on APB4
   --        RCC_Periph.APB4ENR.SPI6EN := True;
   --     else
   --        raise Unknown_Device;
   --     end if;
   --  end Enable_Clock;
   --
   --  -----------
   --  -- Reset --
   --  -----------
   --
   --  procedure Reset (This : in out I2S_Port) is
   --  begin
   --     if This.Periph.all'Address = SPI1_Base then
   --        RCC_Periph.APB2RSTR.SPI1RST := True;
   --        RCC_Periph.APB2RSTR.SPI1RST := False;
   --     elsif This.Periph.all'Address = SPI2_Base then
   --        --  H7 NOTE: SPI2 is on APB1L
   --        RCC_Periph.APB1LRSTR.SPI2RST := True;
   --        RCC_Periph.APB1LRSTR.SPI2RST := False;
   --     elsif This.Periph.all'Address = SPI3_Base then
   --        --  H7 NOTE: SPI3 is on APB1L
   --        RCC_Periph.APB1LRSTR.SPI3RST := True;
   --        RCC_Periph.APB1LRSTR.SPI3RST := False;
   --     elsif This.Periph.all'Address = SPI4_Base then
   --        RCC_Periph.APB2RSTR.SPI4RST := True;
   --        RCC_Periph.APB2RSTR.SPI4RST := False;
   --     elsif This.Periph.all'Address = SPI5_Base then
   --        RCC_Periph.APB2RSTR.SPI5RST := True;
   --        RCC_Periph.APB2RSTR.SPI5RST := False;
   --     elsif This.Periph.all'Address = SPI6_Base then
   --        --  H7 NOTE: SPI6 is on APB4
   --        RCC_Periph.APB4RSTR.SPI6RST := True;
   --        RCC_Periph.APB4RSTR.SPI6RST := False;
   --     else
   --        raise Unknown_Device;
   --     end if;
   --  end Reset;

   ------------------
   -- Enable_Clock --
   ------------------

   procedure Enable_Clock (This : in out Timer) is
   begin
      if This'Address = TIM1_Base then
         RCC_Periph.APB2ENR.TIM1EN := True;
      elsif This'Address = TIM2_Base then
         RCC_Periph.APB1LENR.TIM2EN := True;
      elsif This'Address = TIM3_Base then
         RCC_Periph.APB1LENR.TIM3EN := True;
      elsif This'Address = TIM4_Base then
         RCC_Periph.APB1LENR.TIM4EN := True;
      elsif This'Address = TIM5_Base then
         RCC_Periph.APB1LENR.TIM5EN := True;
      elsif This'Address = TIM6_Base then
         RCC_Periph.APB1LENR.TIM6EN := True;
      elsif This'Address = TIM7_Base then
         RCC_Periph.APB1LENR.TIM7EN := True;
      elsif This'Address = TIM8_Base then
         RCC_Periph.APB2ENR.TIM8EN := True;
      --  H7 NOTE: TIM9, TIM10, TIM11 do not exist on STM32H7
      elsif This'Address = TIM12_Base then
         RCC_Periph.APB1LENR.TIM12EN := True;
      elsif This'Address = TIM13_Base then
         RCC_Periph.APB1LENR.TIM13EN := True;
      elsif This'Address = TIM14_Base then
         RCC_Periph.APB1LENR.TIM14EN := True;
      else
         raise Unknown_Device;
      end if;
   end Enable_Clock;

   -----------
   -- Reset --
   -----------

   procedure Reset (This : in out Timer) is
   begin
      if This'Address = TIM1_Base then
         RCC_Periph.APB2RSTR.TIM1RST := True;
         RCC_Periph.APB2RSTR.TIM1RST := False;
      elsif This'Address = TIM2_Base then
         RCC_Periph.APB1LRSTR.TIM2RST := True;
         RCC_Periph.APB1LRSTR.TIM2RST := False;
      elsif This'Address = TIM3_Base then
         RCC_Periph.APB1LRSTR.TIM3RST := True;
         RCC_Periph.APB1LRSTR.TIM3RST := False;
      elsif This'Address = TIM4_Base then
         RCC_Periph.APB1LRSTR.TIM4RST := True;
         RCC_Periph.APB1LRSTR.TIM4RST := False;
      elsif This'Address = TIM5_Base then
         RCC_Periph.APB1LRSTR.TIM5RST := True;
         RCC_Periph.APB1LRSTR.TIM5RST := False;
      elsif This'Address = TIM6_Base then
         RCC_Periph.APB1LRSTR.TIM6RST := True;
         RCC_Periph.APB1LRSTR.TIM6RST := False;
      elsif This'Address = TIM7_Base then
         RCC_Periph.APB1LRSTR.TIM7RST := True;
         RCC_Periph.APB1LRSTR.TIM7RST := False;
      elsif This'Address = TIM8_Base then
         RCC_Periph.APB2RSTR.TIM8RST := True;
         RCC_Periph.APB2RSTR.TIM8RST := False;
      --  H7 NOTE: TIM9, TIM10, TIM11 do not exist on STM32H7
      --  They have been replaced by TIM15, TIM16, TIM17
      elsif This'Address = TIM12_Base then
         RCC_Periph.APB1LRSTR.TIM12RST := True;
         RCC_Periph.APB1LRSTR.TIM12RST := False;
      elsif This'Address = TIM13_Base then
         RCC_Periph.APB1LRSTR.TIM13RST := True;
         RCC_Periph.APB1LRSTR.TIM13RST := False;
      elsif This'Address = TIM14_Base then
         RCC_Periph.APB1LRSTR.TIM14RST := True;
         RCC_Periph.APB1LRSTR.TIM14RST := False;
      else
         raise Unknown_Device;
      end if;
   end Reset;

   ------------------
   -- Enable_Clock --
   ------------------
   ------------------
   -- Enable_Clock --
   ------------------

   procedure Enable_Clock (This : in out SAI_Port)
   is
   begin
      if This'Address = SAI1_Base then
         RCC_Periph.APB2ENR.SAI1EN := True;
      elsif This'Address = SAI2_Base then
         RCC_Periph.APB2ENR.SAI2EN := True;
      else
         raise Unknown_Device;
      end if;
   end Enable_Clock;

   -----------
   -- Reset --
   -----------

   procedure Reset (This : in out SAI_Port)
   is
   begin
      if This'Address = SAI1_Base then
         RCC_Periph.APB2RSTR.SAI1RST := True;
         RCC_Periph.APB2RSTR.SAI1RST := False;
      elsif This'Address = SAI2_Base then
         RCC_Periph.APB2RSTR.SAI2RST := True;
         RCC_Periph.APB2RSTR.SAI2RST := False;
      else
         raise Unknown_Device;
      end if;
   end Reset;

   ---------------------
   -- Get_Input_Clock --
   ---------------------

   function Get_Input_Clock (Periph : SAI_Port) return HAL.UInt32
   is
      pragma Unreferenced (Periph);
   begin
      --  TODO: Implement proper PLL3 SAI clock calculation for STM32H7
      --  For now, return a nominal frequency
      --  STM32H7 uses PLL3 P output for SAI clocks by default
      return 11_289_600;  --  Common SAI frequency for audio (44.1kHz * 256)
   end Get_Input_Clock;

   ------------------
   -- Enable_Clock --
   ------------------

   procedure Enable_Clock (This : in out SDMMC_Controller)
   is
   begin
      if This.Periph.all'Address = SDMMC1_Base then
         --  H7 NOTE: SDMMC1 is on AHB3, not APB2
         RCC_Periph.AHB3ENR.SDMMC1EN := True;
      elsif This.Periph.all'Address = SDMMC2_Base then
         --  H7 NOTE: SDMMC2 is on AHB2, not APB2
         RCC_Periph.AHB2ENR.SDMMC2EN := True;
      else
         raise Unknown_Device;
      end if;
   end Enable_Clock;

   -----------
   -- Reset --
   -----------

   procedure Reset (This : in out SDMMC_Controller)
   is
   begin
      if This.Periph.all'Address = SDMMC1_Base then
         --  H7 NOTE: SDMMC1 is on AHB3, not APB2
         RCC_Periph.AHB3RSTR.SDMMC1RST := True;
         RCC_Periph.AHB3RSTR.SDMMC1RST := False;
      elsif This.Periph.all'Address = SDMMC2_Base then
         --  H7 NOTE: SDMMC2 is on AHB2, not APB2
         RCC_Periph.AHB2RSTR.SDMMC2RST := True;
         RCC_Periph.AHB2RSTR.SDMMC2RST := False;
      else
         raise Unknown_Device;
      end if;
   end Reset;

   ----------------------
   -- Set_Clock_Source --
   ----------------------

   procedure Set_Clock_Source
     (This : in out SDMMC_Controller;
      Src  : SDMMC_Clock_Source)
   is
      Sel_Value : constant Boolean := Src = Src_Sysclk;
      pragma Unreferenced (Sel_Value);
   begin
      --  H7 TODO: SDMMC clock source selection
      --  H7 uses D1CCIPR register, not DKCFGR2
      --  See RM0433 Section 7.7.22 for SDMMC clock mux
      raise Program_Error with "SDMMC clock source not yet implemented for STM32H7";

--        if This.Periph.all'Address = SDMMC1_Base then
--           RCC_Periph.DKCFGR2.SDMMC1SEL := Sel_Value;
--        elsif This.Periph.all'Address = SDMMC2_Base then
--           RCC_Periph.DKCFGR2.SDMMC2SEL := Sel_Value;
--        else
--           raise Unknown_Device;
--        end if;
--  
--        case Src is
--           when Src_Sysclk =>
--              STM32.SDMMC.Set_Clk_Src_Speed
--                (This, System_Clock_Frequencies.SYSCLK);
--           when Src_48Mhz =>
--              STM32.SDMMC.Set_Clk_Src_Speed
--                (This, 48_000_000);
--        end case;
   end Set_Clock_Source;

   ------------------------------
   -- System_Clock_Frequencies --
   ------------------------------

   function System_Clock_Frequencies return RCC_System_Clocks
   is
      Source       : constant HAL.UInt2 := HAL.UInt2 (RCC_Periph.CFGR.SWS);
      Result       : RCC_System_Clocks;
   begin
      Result.I2SCLK := 0;

      case Source is
         when 0 =>
            --  HSI as source
            Result.SYSCLK := HSI_VALUE;
         when 1 =>
            --  HSE as source
            Result.SYSCLK := HSE_VALUE;
         when 2 =>
            --  PLL as source
            --  H7 TODO: PLL clock calculation is significantly different
            --  H7 uses PLL1DIVR register with DIVN1, DIVP1, DIVQ1, DIVR1
            --  For now, assume PLL is already configured correctly by bootloader/startup
            --  This needs proper implementation reading PLL1DIVR registers
            Result.SYSCLK := 400_000_000;  -- Typical H7 system clock
            Result.I2SCLK := 0;
         when others =>
            Result.SYSCLK := HSI_VALUE;
      end case;

      --  H7 uses Domain configuration registers for prescalers
      --  Domain 1 contains CPU and AXI bus
      --  Domain 2 contains APB1/APB2
      --  Domain 3 contains APB3/APB4
      declare
         HPRE  : constant HAL.UInt4 := HAL.UInt4 (RCC_Periph.D1CFGR.HPRE);
         PPRE1 : constant HAL.UInt3 := HAL.UInt3 (RCC_Periph.D2CFGR.D2PPRE1);
         PPRE2 : constant HAL.UInt3 := HAL.UInt3 (RCC_Periph.D2CFGR.D2PPRE2);
      begin
         Result.HCLK  := Result.SYSCLK / HPRE_Presc_Table (HPRE);
         Result.PCLK1 := Result.HCLK / PPRE_Presc_Table (PPRE1);
         Result.PCLK2 := Result.HCLK / PPRE_Presc_Table (PPRE2);

         --  H7 TODO: Timer clocks
         --  H7 has different timer clock architecture than F4/F7
         --  For now, use simplified calculation (standard mode)
         --  See RM0433 Section 7.7.12 for H7-specific timer clock details
         if PPRE_Presc_Table (PPRE1) = 1 then
            Result.TIMCLK1 := Result.PCLK1;
         else
            Result.TIMCLK1 := Result.PCLK1 * 2;
         end if;
         if PPRE_Presc_Table (PPRE2) = 1 then
            Result.TIMCLK2 := Result.PCLK2;
         else
            Result.TIMCLK2 := Result.PCLK2 * 2;
         end if;
      end;

      --  H7 TODO: I2S Clock calculation
      --  H7 has different PLL architecture (no PLLI2S)
      --  I2S clocks come from PLL2 or PLL3 on H7
      Result.I2SCLK := 0;

      return Result;
   end System_Clock_Frequencies;

   --  H7 NOTE: PLLI2S does not exist on STM32H7.
   --  H7 has PLL1, PLL2, and PLL3 with different configuration.
   --  These functions are not implemented for H7.

   --------------------
   -- PLLI2S_Enabled --
   --------------------

   function PLLI2S_Enabled return Boolean is
   begin
      raise Program_Error with "PLLI2S not available on STM32H7";
      return False;
   end PLLI2S_Enabled;

   ------------------------
   -- Set_PLLI2S_Factors --
   ------------------------

   procedure Set_PLLI2S_Factors (Pll_N : HAL.UInt9;
                                 Pll_R : HAL.UInt3)
   is
   begin
      raise Program_Error with "PLLI2S not available on STM32H7";
   end Set_PLLI2S_Factors;

   -------------------
   -- Enable_PLLI2S --
   -------------------

   procedure Enable_PLLI2S is
   begin
      raise Program_Error with "PLLI2S not available on STM32H7";
   end Enable_PLLI2S;

   --------------------
   -- Disable_PLLI2S --
   --------------------

   procedure Disable_PLLI2S is
   begin
      raise Program_Error with "PLLI2S not available on STM32H7";
   end Disable_PLLI2S;

   --  H7 NOTE: PLLSAI does not exist on STM32H7.
   --  H7 has PLL1, PLL2, and PLL3 with different configuration.
   --  These functions are not implemented for H7.

   ------------------
   -- PLLSAI_Ready --
   ------------------

   function PLLSAI_Ready return Boolean is
   begin
      raise Program_Error with "PLLSAI not available on STM32H7";
      return False;
   end PLLSAI_Ready;

   -------------------
   -- Enable_PLLSAI --
   -------------------

   procedure Enable_PLLSAI is
   begin
      raise Program_Error with "PLLSAI not available on STM32H7";
   end Enable_PLLSAI;

   --------------------
   -- Disable_PLLSAI --
   --------------------

   procedure Disable_PLLSAI is
   begin
      raise Program_Error with "PLLSAI not available on STM32H7";
   end Disable_PLLSAI;

   --------------------
   -- PLLSAI_Enabled --
   --------------------

   function PLLSAI_Enabled return Boolean is
   begin
      raise Program_Error with "PLLSAI not available on STM32H7";
      return False;
   end PLLSAI_Enabled;

   ------------------------
   -- Set_PLLSAI_Factors --
   ------------------------

   procedure Set_PLLSAI_Factors (LCD  : HAL.UInt3;
                                 VCO  : HAL.UInt9;
                                 DivR : PLLSAI_DivR)
   is
   begin
      raise Program_Error with "PLLSAI not available on STM32H7";
   end Set_PLLSAI_Factors;

   -------------------------
   -- Configure_SAI_Clock --
   -------------------------
   --  SAI support temporarily disabled
   --  procedure Configure_SAI_I2S_Clock
   --    (Periph     : SAI_Port;
   --     PLLI2SN    : UInt9;
   --     PLLI2SQ    : UInt4;
   --     PLLI2SDIVQ : DIVQ)
   --  is
   --     PLLI2SCFGR : PLLI2SCFGR_Register := RCC_Periph.PLLI2SCFGR;
   --     SAION      : constant Boolean := PLLSAI_Enabled;
   --  begin
   --     if SAION then
   --        Disable_PLLSAI;
   --     end if;
   --
   --     if RCC_Periph.CR.PLLI2SON then
   --        RCC_Periph.CR.PLLI2SON := False;
   --     end if;
   --
   --     --  We will configure the PLLSAI2 clock from a PLLI2S source.
   --     --  SAI2SEL (page 188 of the STM32F7xx Ref manual):
   --     --  00: SAI2 clock = PLLSAI_Q / PLLSAIDIVQ
   --     --  01: SAI2 clock = PLLI2S_Q / PLLI2SDIVQ
   --     --  10: SAI2 clock = AF input frequency
   --     --  11: invalid
   --     if Periph'Address = SAI1_Base then
   --        RCC_Periph.DKCFGR1.SAI1SEL := 2#01#;
   --     elsif Periph'Address = SAI2_Base then
   --        RCC_Periph.DKCFGR1.SAI2SEL := 2#01#;
   --     else
   --        raise Unknown_Device;
   --     end if;
   --
   --     PLLI2SCFGR.PLLI2SN := PLLI2SN;
   --     PLLI2SCFGR.PLLI2SQ := PLLI2SQ;
   --     RCC_Periph.PLLI2SCFGR := PLLI2SCFGR;
   --
   --     RCC_Periph.DKCFGR1.PLLI2SDIV := UInt5 (PLLI2SDIVQ - 1);
   --
   --     if SAION then
   --        Enable_PLLSAI;
   --     end if;
   --
   --     RCC_Periph.CR.PLLI2SON := True;
   --
   --     loop
   --        exit when RCC_Periph.CR.PLLI2SRDY;
   --     end loop;
   --  end Configure_SAI_I2S_Clock;

   --  H7 NOTE: DCMI clock enable is different on H7
   --  TODO: Check if DCMI exists and use correct register

   -----------------------
   -- Enable_DCMI_Clock --
   -----------------------

   procedure Enable_DCMI_Clock is
   begin
      --  H7 TODO: Verify DCMI peripheral exists and clock register
      raise Program_Error with "DCMI clock not yet implemented for STM32H7";
   end Enable_DCMI_Clock;

   ----------------
   -- Reset_DCMI --
   ----------------

   procedure Reset_DCMI is
   begin
      --  H7 TODO: Verify DCMI peripheral exists and reset register
      raise Program_Error with "DCMI reset not yet implemented for STM32H7";
   end Reset_DCMI;

end STM32.Device;
