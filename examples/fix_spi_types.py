#!/usr/bin/env python3
import re

# Read file
with open('/workspace/arch/ARM/STM32/drivers/spi_stm32h7/stm32-spi.adb', 'r') as f:
    content = f.read()

# Fix TXDR assignments: need STM32_SVD.UInt32() cast
# Pattern: This.Periph.TXDR := <something>;
# Need to wrap <something> with STM32_SVD.UInt32() if it's a UInt16 expression

# Fix specific patterns
fixes = [
    # TXDR := UInt16_variable -> TXDR := STM32_SVD.UInt32(UInt16_variable)
    (r'This\.Periph\.TXDR := (Outgoing|Data_Tx|Value)\s*;',
     r'This.Periph.TXDR := STM32_SVD.UInt32(\1);'),
    
    # RXDR reading -> HAL.UInt16(This.Periph.RXDR and 16#FFFF#)
    (r'(\w+) := This\.Periph\.RXDR\s*;',
     r'\1 := HAL.UInt16(This.Periph.RXDR and 16#FFFF#);'),
     
    # Data_Rx := This.Periph.RXDR
    (r'Data_Rx := This\.Periph\.RXDR\s*;',
     r'Data_Rx := HAL.UInt16(This.Periph.RXDR and 16#FFFF#);'),
]

for pattern, replacement in fixes:
    content = re.sub(pattern, replacement, content)

# Write back
with open('/workspace/arch/ARM/STM32/drivers/spi_stm32h7/stm32-spi.adb', 'w') as f:
    f.write(content)

print("Type conversion fixes applied")
