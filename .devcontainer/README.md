# Ada Drivers Library Devcontainer

This devcontainer provides a complete development environment for the Ada Drivers Library with support for STM32H7 embedded development.

## What's Included

### Toolchains
- **ARM GCC Toolchain** (arm-none-eabi) - Version 13.2.Rel1
- **GNAT Ada Compiler** for ARM ELF - Version 13.2.0
- **GPRbuild** - Ada project build tool
- **Alire** - Ada package manager

### Tools
- **svd2ada** - Generate Ada bindings from SVD files
- **CMSIS-SVD** - STM32 SVD files repository
- Git, Python3, and standard development tools

### VS Code Extensions
- AdaCore Ada Language Support
- C/C++ Tools (for viewing assembly/linker)
- Git Graph

## Getting Started

### Prerequisites
- Docker Desktop installed
- VS Code with "Dev Containers" extension

### Opening the Project

1. Open VS Code
2. Open this folder (Ada_Drivers_Library)
3. When prompted, click "Reopen in Container"
4. Wait for the container to build (first time only, ~5-10 minutes)
5. The post-create script will automatically generate STM32H7x SVD files

### Manual SVD Generation

If you need to regenerate SVD files:

```bash
# Find available STM32H7 SVD files
find /opt/cmsis-svd -name "*STM32H7*.svd"

# Generate bindings
svd2ada /opt/cmsis-svd/data/STMicro/STM32H7x3.svd \
    --boolean \
    -o arch/ARM/STM32/svd/stm32h7x \
    -p STM32_SVD \
    --base-types-package HAL \
    --gen-uint-always
```

### Building the Project

```bash
# Build Matek H743 Slim V3 board support (SFP runtime)
gprbuild -P boards/Matek_H743_slim_v3/matek_h743_slim_v3_sfp.gpr

# Build with Full runtime
gprbuild -P boards/Matek_H743_slim_v3/matek_h743_slim_v3_full.gpr

# Clean build artifacts
gprclean -P boards/Matek_H743_slim_v3/matek_h743_slim_v3_sfp.gpr
```

### Creating a Blinky Example

Create a simple LED blink example:

```bash
# Create example directory
mkdir -p examples/Matek_H743_slim_v3/blinky/src

# Create main.adb (see examples in other boards)
```

## Troubleshooting

### Container Won't Build
- Check Docker Desktop is running
- Ensure you have enough disk space (need ~3GB)
- Try rebuilding: F1 → "Dev Containers: Rebuild Container"

### Compiler Not Found
The toolchain uses `arm-none-eabi-gcc`. If projects expect `arm-eabi-gcc`, create a symlink:
```bash
sudo ln -s /opt/arm-gcc/bin/arm-none-eabi-gcc /usr/local/bin/arm-eabi-gcc
```

### SVD Files Missing
Run the post-create script manually:
```bash
bash .devcontainer/post-create.sh
```

## Development Workflow

1. **Edit source files** in `boards/Matek_H743_slim_v3/src/`
2. **Build** with `gprbuild -P boards/Matek_H743_slim_v3/matek_h743_slim_v3_sfp.gpr`
3. **Flash** to hardware (requires additional tools like OpenOCD)
4. **Debug** using GDB and appropriate debug probe

## Runtime Requirements

The Matek H743 board requires one of these runtimes:
- `light-tasking-stm32h7` (Ravenscar SFP)
- `ravenscar-full-stm32h7` (Full Ravenscar)

These may need to be built from the [bb-runtimes](https://github.com/AdaCore/bb-runtimes) repository if not included with your GNAT toolchain.

## Additional Resources

- [Ada Drivers Library Documentation](../docs/)
- [AdaCore Documentation](https://docs.adacore.com/)
- [ARM GCC Embedded](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm)
- [Alire Package Manager](https://alire.ada.dev/)
