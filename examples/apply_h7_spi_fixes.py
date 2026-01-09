#!/usr/bin/env python3
import re

filepath = '/workspace/arch/ARM/STM32/drivers/spi_stm32h7/stm32-spi.adb'

with open(filepath, 'r') as f:
    content = f.read()

# Simple replacements for H7 register differences
fixes = {
    '.CR1.MSTR': '.CFG2.MASTER',
    '.CR1.BIDIOE': '.CR1.HDDIR', 
    '.CR1.CRCEN': '.CFG1.CRCEN',
    '.SR.TIFRFE': '.SR.TIFRE',
    '.CRCPOLY.CRCPOLY': '.CRCPOLY',
    'This.Periph.DR': 'This.Periph.TXDR',
}

for old, new in fixes.items():
    content = content.replace(old, new)

# Fix TXDR assignments with cast
content = re.sub(r'This\.Periph\.TXDR := ([^;]+);', r'This.Periph.TXDR := STM32_SVD.UInt32 (\1);', content)

# Fix RXDR reads with cast  
content = re.sub(r'return This\.Periph\.TXDR;', 'return HAL.UInt16 (This.Periph.RXDR and 16#FFFF#);', content)

# Comment out CRC operations that don't exist
content = content.replace('This.Periph.CR1.CRCNEXT := True;', 'null;  -- H7: No CRCNEXT')
content = content.replace('This.Periph.SR.CHSIDE', 'False  -- H7: No CHSIDE')
content = content.replace('This.Periph.SR.CRCERR', 'False  -- H7: No CRCERR')

with open(filepath, 'w') as f:
    f.write(content)

print("Basic H7 fixes applied")
