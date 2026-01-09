#!/bin/bash

# Post-create script for Ada Drivers Library devcontainer

echo "🚀 Setting up Ada Drivers Library development environment..."

# Verify toolchain installation
echo "📦 Checking toolchain..."
arm-none-eabi-gcc --version
arm-eabi-gcc --version || echo "⚠️  arm-eabi-gcc not found, using arm-none-eabi-gcc"

# Build gprbuild if needed using alr
if ! command -v gprbuild &> /dev/null; then
    echo "🔧 Building gprbuild..."
    alr toolchain --select gprbuild gnat_arm_elf || true
fi

gprbuild --version

# Build svd2ada if not already built
if [ ! -f "/opt/svd2ada/svd2ada" ]; then
    echo "🔧 Building svd2ada..."
    cd /opt/svd2ada
    gprbuild -P svd2ada.gpr -p
    cd /workspace
fi

# Check svd2ada
echo "🔧 Checking svd2ada..."
if command -v svd2ada &> /dev/null; then
    echo "✅ svd2ada is available"
else
    echo "⚠️  svd2ada not found in PATH"
fi

# Generate STM32H7x SVD files if not present
if [ ! -d "arch/ARM/STM32/svd/stm32h7x" ]; then
    echo "📝 Generating STM32H7x SVD files..."
    
    # Find STM32H7 SVD file
    H7_SVD=$(find /opt/cmsis-svd -name "*STM32H7*.svd" | head -n 1)
    
    if [ -n "$H7_SVD" ]; then
        echo "   Found SVD file: $H7_SVD"
        mkdir -p arch/ARM/STM32/svd/stm32h7x
        
        # Generate Ada bindings
        svd2ada "$H7_SVD" \
            --boolean \
            -o arch/ARM/STM32/svd/stm32h7x \
            -p STM32_SVD \
            --base-types-package HAL \
            --gen-uint-always
        
        if [ $? -eq 0 ]; then
            echo "✅ STM32H7x SVD files generated successfully"
            
            # Uncomment SVD paths in project files
            echo "   Updating project files..."
            sed -i 's|--  Src_Dirs_Root & "/arch/ARM/STM32/svd/stm32h7x"|Src_Dirs_Root & "/arch/ARM/STM32/svd/stm32h7x"|g' \
                boards/Matek_H743_slim_v3/matek_h743_slim_v3_sfp.gpr \
                boards/Matek_H743_slim_v3/matek_h743_slim_v3_full.gpr
            
            # Remove TODO note lines
            sed -i '/NOTE: STM32H7x SVD files need to be generated/d' \
                boards/Matek_H743_slim_v3/matek_h743_slim_v3_sfp.gpr \
                boards/Matek_H743_slim_v3/matek_h743_slim_v3_full.gpr
        else
            echo "❌ Failed to generate SVD files"
        fi
    else
        echo "⚠️  No STM32H7 SVD file found in /opt/cmsis-svd"
    fi
else
    echo "✅ STM32H7x SVD files already exist"
fi

# # Set proper permissions
# echo "🔐 Setting permissions..."
# chmod -R u+rw .

# Display useful information
echo ""
echo "✨ Development environment ready!"
echo ""
echo "📚 Quick start:"
echo "   - Edit board files in: boards/Matek_H743_slim_v3/"
echo "   - Build SFP project: gprbuild -P boards/Matek_H743_slim_v3/matek_h743_slim_v3_sfp.gpr"
echo "   - Build Full project: gprbuild -P boards/Matek_H743_slim_v3/matek_h743_slim_v3_full.gpr"
echo ""
echo "🔧 Available tools:"
echo "   - ARM GCC: $(arm-none-eabi-gcc --version | head -n 1)"
echo "   - Ada compiler: $(arm-eabi-gnatmake --version 2>/dev/null || echo 'Use arm-none-eabi-gnatmake')"
echo "   - GPRbuild: $(gprbuild --version 2>&1 | head -n 1)"
echo ""
