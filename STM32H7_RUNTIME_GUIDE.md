# STM32H7 Runtime for Ada Drivers Library

## Overview

This runtime provides bare-metal Ada support for STM32H7 series microcontrollers (STM32H743/H750) running at up to 400MHz. It implements the GNAT Runtime Library (RTS) with full clock configuration, peripheral access, and three runtime profiles suitable for different application requirements.

## Features

- **Full STM32H7 Support**: Cortex-M7 @ 400MHz with 150 interrupt vectors
- **Multi-Domain Clock System**: D1/D2/D3 power domain architecture
- **Multiple Clock Sources**: HSE (25MHz), HSI (64MHz), CSI (4MHz)
- **VOS Voltage Scaling**: Automatic configuration for maximum performance
- **SVD-Generated Peripherals**: Type-safe register access for all peripherals
- **Memory Layout**: DTCM (128KB), ITCM (64KB), Flash (2MB), AXI SRAM (512KB)
- **Three Runtime Profiles**: ZFP, Ravenscar-SFP, and Embedded

## Hardware Configuration

### Supported Boards
- **STM32H743 Discovery** (STM32H743ZI)
- **STM32H750 Discovery** (STM32H750XB)
- **Generic STM32H743** (custom boards with 25MHz HSE)

### Clock Configuration
The runtime configures the following clock tree:

```
HSE (25MHz) → PLL1:
  - DIVM = /5    → 5 MHz (PLL input)
  - DIVN = ×160  → 800 MHz (VCO)
  - DIVP = /2    → 400 MHz (SYSCLK)

Domain Clocks:
  - D1CPRE = /2  → 200 MHz (D1 domain)
  - HPRE   = /1  → 400 MHz (AHB)
  - D1PPRE = /2  → 100 MHz (APB3)
  - D2PPRE = /2  → 100 MHz (APB1/APB2)
  - D3PPRE = /2  → 100 MHz (APB4)

Flash Latency: 4 wait states @ VOS1
Voltage Scale: VOS1 (1.15V-1.26V) for 400MHz operation
```

## File Structure

```
arm/stm32/stm32h7x/
├── svd/
│   ├── a-intnam.ads              # Interrupt names (150 interrupts)
│   ├── handler.S                 # Interrupt vector table
│   ├── i-stm32-rcc.ads           # RCC peripheral (4626 lines)
│   ├── i-stm32-pwr.ads           # PWR peripheral
│   ├── i-stm32-flash.ads         # Flash controller
│   ├── i-stm32-gpio.ads          # GPIO ports
│   └── ...                       # Additional peripherals
├── setup_pll.adb                 # PLL initialization (306 lines)
├── setup_pll.ads                 # PLL interface
├── s-stm32.adb                   # System clock readback
├── s-bbmcpa.ads                  # MCU parameters
├── s-bbbopa.ads                  # Board parameters
└── memory-map.ld                 # Linker script

arm/stm32/
└── s-stm32.ads                   # Shared STM32 definitions (H7 extensions)
```

## Building the Runtime

### Prerequisites

```bash
# Alire toolchain (recommended)
alr toolchain --select gprbuild=25.0.1 gnat_arm_elf=15.2.1

# Or install manually:
# - ARM GNAT 15.2.1 or later
# - GPRbuild 25.0.1 or later
```

### Build Instructions

```bash
cd bb-runtimes

# Build all profiles
python3 build_rts.py \
  --output=/tmp/stm32h7_runtime \
  --link \
  --rts-src-descriptor gnat_rts_sources/lib/gnat/rts-sources.json \
  --profiles light,light-tasking,embedded \
  stm32h743disco

# Install to system location
python3 build_rts.py \
  --output=~/.local/share/bb-runtimes/stm32h7 \
  --link \
  --rts-src-descriptor gnat_rts_sources/lib/gnat/rts-sources.json \
  --profiles light,light-tasking,embedded \
  stm32h743disco
```

### Runtime Profiles

| Profile | Description | Use Case |
|---------|-------------|----------|
| `light-stm32h743disco` | Zero Footprint (ZFP) | No tasking, minimal footprint |
| `light-tasking-stm32h743disco` | Ravenscar-SFP | Protected objects, basic tasking |
| `embedded-stm32h743disco` | Full embedded | Containers, full Ada runtime |

## Using with Ada Drivers Library

### Project Configuration

Create a GPR project file:

```ada
-- stm32h7_project.gpr
project STM32H7_Project is

   for Languages use ("Ada");
   for Main use ("main.adb");
   for Source_Dirs use ("src");
   for Object_Dir use "obj";

   -- Specify runtime and target
   for Runtime ("Ada") use "light-stm32h743disco";
   for Target use "arm-eabi";

   package Compiler is
      for Default_Switches ("Ada") use 
        ("-g",           -- Debug info
         "-O2",          -- Optimize
         "-gnatwa",      -- All warnings
         "-gnatQ",       -- Don't quit on errors
         "-gnat2022");   -- Ada 2022
   end Compiler;

   package Builder is
      for Default_Switches ("Ada") use ("-g");
      for Global_Configuration_Pragmas use "gnat.adc";
   end Builder;

   package Linker is
      for Default_Switches ("Ada") use 
        ("-Wl,--gc-sections",
         "-Wl,--print-memory-usage");
   end Linker;

end STM32H7_Project;
```

### Build Your Application

```bash
gprbuild -P stm32h7_project.gpr -p
arm-eabi-objcopy -O binary obj/main main.bin
```

### Example Application

```ada
-- main.adb
with System.STM32;           -- Clock information
with Interfaces.STM32.RCC;   use Interfaces.STM32.RCC;
with Interfaces.STM32.GPIO;  use Interfaces.STM32.GPIO;
with Interfaces.STM32;       use Interfaces.STM32;

procedure Main is
   -- Runtime has already configured clocks to 400MHz
   -- System.STM32.System_Clock_Frequencies.SYSCLK = 400_000_000
begin
   -- Enable GPIOB clock
   RCC_Periph.AHB4ENR.GPIOBEN := True;
   
   -- Configure PB0 as output
   GPIOB_Periph.MODER.Arr (0) := 1;  -- General purpose output
   GPIOB_Periph.OTYPER.OT.Arr (0) := False;  -- Push-pull
   GPIOB_Periph.OSPEEDR.Arr (0) := 3;  -- Very high speed
   
   -- Blink LED
   loop
      GPIOB_Periph.BSRR.BS.Arr (0) := True;   -- Set
      delay 0.5;
      GPIOB_Periph.BSRR.BR.Arr (0) := True;   -- Reset
      delay 0.5;
   end loop;
end Main;
```

## Peripheral Access

All STM32H7 peripherals are accessible through SVD-generated interfaces:

```ada
with Interfaces.STM32.RCC;    -- Reset and Clock Control
with Interfaces.STM32.PWR;    -- Power Control
with Interfaces.STM32.FLASH;  -- Flash Memory
with Interfaces.STM32.GPIO;   -- GPIO Ports A-K
with Interfaces.STM32.USART;  -- USART1-8
with Interfaces.STM32.SPI;    -- SPI1-6
with Interfaces.STM32.I2C;    -- I2C1-4
with Interfaces.STM32.DMA;    -- DMA1-2
with Interfaces.STM32.ADC;    -- ADC1-3
-- ... and many more
```

### Example: Reading System Clock

```ada
with System.STM32; use System.STM32;
with Ada.Text_IO;  use Ada.Text_IO;

procedure Show_Clocks is
   package UInt32_IO is new Ada.Text_IO.Modular_IO (UInt32);
   Clocks : constant RCC_System_Clocks := System_Clock_Frequencies;
begin
   Put ("SYSCLK:  "); UInt32_IO.Put (Clocks.SYSCLK, Width => 10); 
   Put_Line (" Hz");
   
   Put ("HCLK:    "); UInt32_IO.Put (Clocks.HCLK, Width => 10); 
   Put_Line (" Hz");
   
   Put ("PCLK1:   "); UInt32_IO.Put (Clocks.PCLK1, Width => 10); 
   Put_Line (" Hz");
   
   Put ("PCLK2:   "); UInt32_IO.Put (Clocks.PCLK2, Width => 10); 
   Put_Line (" Hz");
   
   Put ("TIMCLK1: "); UInt32_IO.Put (Clocks.TIMCLK1, Width => 10); 
   Put_Line (" Hz");
end Show_Clocks;
```

## Memory Map

The linker script defines the following memory regions:

| Region | Address | Size | Description |
|--------|---------|------|-------------|
| Flash | 0x08000000 | 2MB | Program memory |
| DTCM | 0x20000000 | 128KB | Data Tightly Coupled Memory |
| ITCM | 0x00000000 | 64KB | Instruction Tightly Coupled Memory |
| AXI SRAM | 0x24000000 | 512KB | Main RAM |
| SRAM1 | 0x30000000 | 128KB | Additional RAM |
| SRAM2 | 0x30020000 | 128KB | Additional RAM |
| SRAM3 | 0x30040000 | 32KB | Additional RAM |
| SRAM4 | 0x38000000 | 64KB | Additional RAM |

### Memory Usage Tips

- **DTCM**: Fastest RAM, use for stack and frequently accessed data
- **ITCM**: Fastest code execution, use for ISR and critical code
- **AXI SRAM**: Main working memory, DMA-capable
- **Flash**: Execute-in-place (XiP), 4 wait states @ 400MHz

## Advanced Features

### Multi-Source Clock Support

The setup_pll.adb supports three clock sources:

```ada
-- In s-bbbopa.ads (Board Parameters)
package System.BB.Board_Parameters is
   pragma No_Elaboration_Code_All;
   pragma Pure;

   -- Select clock source: HSE, HSI, or CSI
   PLL_Source_Frequency : constant := 25_000_000;  -- HSE 25MHz
   Main_Clock_Frequency : constant := 400_000_000;  -- Target 400MHz
end System.BB.Board_Parameters;
```

### Compile-Time Validation

The runtime includes compile-time checks for PLL parameters:

```ada
pragma Compile_Time_Error
  (PLLM not in 1 .. 63, "PLLM must be in 1 .. 63");
pragma Compile_Time_Error
  (VCO_Out not in 192_000_000 .. 960_000_000,
   "VCO output must be 192-960 MHz");
pragma Compile_Time_Error
  (PLLP_Output not in 1_000_000 .. 480_000_000,
   "PLLP output must be 1-480 MHz");
```

### Voltage Scaling

The runtime automatically configures VOS (Voltage Output Scale):

- **VOS0**: 480MHz (requires external SMPS, not enabled by default)
- **VOS1**: 400MHz (default, enabled after PLL lock)
- **VOS2**: 300MHz
- **VOS3**: 170MHz

## Porting to Custom Boards

### 1. Modify Board Parameters

Edit or create `arm/stm32/stm32h7x/s-bbbopa.ads`:

```ada
package System.BB.Board_Parameters is
   pragma No_Elaboration_Code_All;
   pragma Pure;

   -- Change these for your board
   HSE_Clock_Frequency  : constant := 25_000_000;  -- Your crystal
   Main_Clock_Frequency : constant := 400_000_000; -- Target freq
end System.BB.Board_Parameters;
```

### 2. Adjust PLL Configuration (if needed)

The setup_pll.adb automatically calculates PLL dividers, but you can customize:

```ada
-- In setup_pll.adb, modify these constants:
PLLM : constant := 5;   -- Input divider
PLLN : constant := 160; -- Multiplier
PLLP : constant := 2;   -- Output divider
```

### 3. Update cortexm.py

Add your board configuration in `arm/cortexm.py`:

```python
elif target.startswith('myboard-stm32h7'):
    stm32_common(target, 'stm32h7x')
    # Add custom memory sizes or settings
```

### 4. Rebuild Runtime

```bash
python3 build_rts.py --output=/tmp/runtime \
  --link --rts-src-descriptor gnat_rts_sources/lib/gnat/rts-sources.json \
  --profiles light myboard-stm32h7
```

## Technical Details

### Clock Source Selection

The runtime determines the PLL source based on `s-bbbopa.ads`:

- **HSE**: External oscillator (typically 25MHz on Discovery boards)
- **HSI**: Internal RC oscillator (64MHz on H7, not 16MHz like F4/F7)
- **CSI**: Low-power internal oscillator (4MHz, unique to H7)

### Power Domain Architecture

STM32H7 has three independent power domains:

- **D1**: CPU, AXI SRAM, peripherals on APB3
- **D2**: Peripherals on APB1/APB2, SRAM1/2/3
- **D3**: Low-power peripherals on APB4, SRAM4, backup domain

Each domain has independent clock gating and can enter low-power modes separately.

### Flash Configuration

The runtime sets optimal flash parameters:

- **Latency**: 4 wait states (required for 400MHz @ VOS1)
- **Prefetch**: Enabled
- **ART**: Adaptive Real-Time memory accelerator enabled
- **Width**: 256-bit access (32 bytes)

### Interrupt Handling

STM32H7 supports 150 external interrupts:

```ada
-- Available in a-intnam.ads
with Ada.Interrupts.Names;

procedure Setup_USART1_IRQ is
begin
   Attach_Handler 
     (Handler => USART1_Handler'Access,
      Interrupt => Ada.Interrupts.Names.USART1_Interrupt);
end Setup_USART1_IRQ;
```

## Troubleshooting

### Clock Not Running at 400MHz

1. Check HSE crystal frequency in `s-bbbopa.ads`
2. Verify voltage scale is VOS1 (required for 400MHz)
3. Check PLL lock status in debugger: `RCC_Periph.CR.PLL1RDY`

### Build Errors

```bash
# Ensure correct toolchain selected
alr toolchain --select gnat_arm_elf=15.2.1 gprbuild=25.0.1

# Verify runtime sources exist
ls gnat_rts_sources/lib/gnat/rts-sources.json
```

### Linker Errors (Out of Memory)

Adjust memory layout in `memory-map.ld` or use different SRAM regions:

```ld
MEMORY
{
  flash (rx)   : ORIGIN = 0x08000000, LENGTH = 2048K
  dtcm (rwx)   : ORIGIN = 0x20000000, LENGTH = 128K   /* Fast data */
  ram (rwx)    : ORIGIN = 0x24000000, LENGTH = 512K   /* Main RAM */
}
```

## Performance Characteristics

- **CPU**: 1027 DMIPS @ 400MHz (2.14 DMIPS/MHz)
- **Flash**: 4 wait states, ~90 MHz effective with prefetch
- **TCM**: Zero wait states, 400 MHz effective
- **AXI SRAM**: Zero wait states, 200 MHz (HCLK/2)
- **FPU**: Double-precision, IEEE 754 compliant

## References

- [STM32H743 Reference Manual (RM0433)](https://www.st.com/resource/en/reference_manual/rm0433-stm32h742-stm32h743753-and-stm32h750-value-line-advanced-armbased-32bit-mcus-stmicroelectronics.pdf)
- [STM32H743 Datasheet](https://www.st.com/resource/en/datasheet/stm32h743zi.pdf)
- [GNAT Runtime Documentation](https://docs.adacore.com/gnat_rm-docs/html/gnat_rm/gnat_rm/implementation_defined_characteristics.html)
- [BB Runtimes Repository](https://github.com/AdaCore/bb-runtimes)

## License

GNAT Runtime Library Exception - See COPYING.RUNTIME and COPYING3

## Contributing

Improvements and bug fixes welcome! Submit pull requests to the bb-runtimes repository.

## Credits

- **Clock Configuration**: Based on STMicroelectronics reference implementation
- **SVD Generation**: Using AdaCore's svd2ada tool
- **Runtime Sources**: AdaCore GNAT Runtime Library

---

**Version**: 1.0  
**Date**: January 2026  
**Tested**: STM32H743ZI Discovery, GNAT ARM ELF 15.2.1, GPRbuild 25.0.1
