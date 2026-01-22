#!/bin/env bash

set -e

# Setup directory
BUILD_DIR="$(pwd)/kernel_local"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Clone
git clone https://chromium.googlesource.com/chromiumos/third_party/kernel \
    cros-kernel -b chromeos-6.12 --depth=1
cd cros-kernel

# Initial Config
CHROMEOS_KERNEL_FAMILY=termina ./chromeos/scripts/prepareconfig container-vm-x86_64

# --- AUTOMATION START ---
echo "Applying Binder IPC configurations..."
./scripts/config --enable CONFIG_ANDROID
./scripts/config --enable CONFIG_ANDROID_BINDER_IPC
./scripts/config --enable CONFIG_ANDROID_BINDERFS
./scripts/config --set-str CONFIG_ANDROID_BINDER_DEVICES ""

# Refresh config to satisfy dependencies
make LLVM=1 LLVM_IAS=1 olddefconfig
# --- AUTOMATION END ---

# Build
make LLVM=1 LLVM_IAS=1 bzImage -j$(nproc)

# Copy out
mkdir -p /mnt/chromeos/MyFiles/Kernels
cp arch/x86/boot/bzImage /mnt/chromeos/MyFiles/Kernels/bzImage

echo "----------------------------------------------------------"
echo "Kernel moved to MyFiles/Kernels/bzImage"
echo "Run this in crosh:"
echo "vmc stop termina && vmc start termina --enable-gpu --kernel /home/chronos/user/MyFiles/Kernels/bzImage"
echo "----------------------------------------------------------"
