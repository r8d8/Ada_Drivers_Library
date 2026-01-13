------------------------------------------------------------------------------
--                                                                          --
--                       Copyright (C) 2026, AdaCore                        --
--                                                                          --
--  This is a simple example demonstrating the use of the ICM42688P driver  --
--  for the Matek H743 board.                                               --
--                                                                          --
------------------------------------------------------------------------------

with Ada.Real_Time;      use Ada.Real_Time;
with HAL;                use HAL;
with ICM42688P;          use ICM42688P;
with Interfaces;         use Interfaces;

--  Note: This is a conceptual example. Actual usage requires proper board
--  initialization with SPI and GPIO configuration for the Matek H743.

procedure ICM42688P_Example is

   --  Example assuming you have initialized the SPI and GPIO
   --  (Replace with actual board-specific initialization)
   
   --  SPI1_Port : access SPI_Port; -- Your SPI port
   --  CS_Pin    : access GPIO_Point; -- Your chip select pin
   --  Delays    : access Ravenscar_Time.Delays_Type;
   
   --  IMU : ICM42688P_Device (SPI1_Port, CS_Pin, Delays);
   
   Gyro_X, Gyro_Y, Gyro_Z   : Integer_16;
   Acc_X, Acc_Y, Acc_Z       : Integer_16;
   Temperature              : Float;
   
   Next_Release : Time := Clock;
   Period       : constant Time_Span := Milliseconds (2);  -- 500 Hz

begin
   --  Initialize the IMU
   --  IMU.Initialize;
   
   --  Verify connection
   --  if not IMU.Test then
   --     -- Handle initialization error
   --     return;
   --  end if;

   --  Main loop: Read sensor data at 500Hz
   loop
      --  Wait for next sample time
      Next_Release := Next_Release + Period;
      delay until Next_Release;
      
      --  Check if new data is available
      --  if IMU.Data_Ready then
         --  Read 6-axis motion data
         --  IMU.Get_Motion_6 (Acc_X, Acc_Y, Acc_Z, Gyro_X, Gyro_Y, Gyro_Z);
         
         --  Convert to physical units
         --  Gyro_X_DPS := Float (Gyro_X) * ICM42688P_GYRO_SENSITIVITY_2000DPS;
         --  Acc_X_G := Float (Acc_X) * ICM42688P_ACCEL_SENSITIVITY_16G;
         
         --  Read temperature (optional, less frequently)
         --  Temperature := IMU.Read_Temperature;
         
         --  Process the data...
      --  end if;
      
   end loop;

end ICM42688P_Example;
