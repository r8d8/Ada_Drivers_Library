#!/bin/bash
# Fix SPI driver for STM32H7 architecture differences
cd /workspace/arch/ARM/STM32/drivers/spi_stm32h7

# Backup current state
cp stm32-spi.adb stm32-spi.adb.presed

# 1. Remove .DR from TXDR/RXDR registers (they're plain UInt32 in H7)
sed -i 's/\.TXDR\.DR/.TXDR/g' stm32-spi.adb
sed -i 's/\.RXDR\.DR/.RXDR/g' stm32-spi.adb

# 2. Fix HDDIR location: CFG2 -> CR1
sed -i 's/CFG2\.HDDIR/CR1.HDDIR/g' stm32-spi.adb

# 3. Fix Configure procedure - DSIZE and COMM assignments
# DSIZE: boolean -> conditional 15 for 16-bit, 7 for 8-bit
# COMM: enum values -> numeric 0/2/3
#This.Periph.CFG1.DSIZE := (if Conf.Data_Size = HAL.SPI.Data_Size_16b then 15 else 7);
# Will be done with multi_replace

# 4. I2S configuration register: I2SCFGR -> CGFR
sed -i 's/I2SCFGR\.I2SMOD/CGFR.I2SMOD/g' stm32-spi.adb

# 5. CRCPOLY: no .CRCPOLY subfield, direct assignment
sed -i 's/\.CRCPOLY\.CRCPOLY/.CRCPOLY/g' stm32-spi.adb

echo "Sed fixes applied"
