#!/bin/bash
# Build helper for Ada Drivers Library examples
# Uses Alire-managed toolchain from bb-runtimes

set -e

EXAMPLE_DIR="${1:-.}"
PROJECT="${2:-*.gpr}"

if [ ! -d "$EXAMPLE_DIR" ]; then
    echo "Error: Directory $EXAMPLE_DIR not found"
    exit 1
fi

cd "$EXAMPLE_DIR"

# Source Alire environment from bb-runtimes workspace
eval "$(cd /workspace/bb-runtimes && alr printenv --unix 2>/dev/null)"

# Find project file if not specified
if [ "$PROJECT" = "*.gpr" ]; then
    PROJECT=$(find . -maxdepth 1 -name "*.gpr" | head -1)
fi

if [ -z "$PROJECT" ]; then
    echo "Error: No .gpr file found in $EXAMPLE_DIR"
    exit 1
fi

echo "Building $(basename $PROJECT) in $(basename $EXAMPLE_DIR)..."
gprbuild -p -P "$PROJECT"
