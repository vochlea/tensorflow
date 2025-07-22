#!/bin/bash

# Script to download all TensorFlow Lite dependencies
# This script downloads all dependencies that TensorFlow Lite would normally fetch during build

set -e  # Exit on error

DEPS_DIR="$(dirname "$0")/deps"
echo "Downloading TensorFlow Lite dependencies to: $DEPS_DIR"

# Function to clone a git repository
clone_repo() {
    local name=$1
    local url=$2
    local tag=$3
    local shallow=$4
    
    echo "Downloading $name from $url at tag $tag..."
    
    if [ -d "$DEPS_DIR/$name" ]; then
        echo "  $name already exists, skipping..."
        return
    fi
    
    if [ "$shallow" = "true" ]; then
        git clone --depth 1 --branch "$tag" "$url" "$DEPS_DIR/$name"
    else
        git clone "$url" "$DEPS_DIR/$name"
        cd "$DEPS_DIR/$name"
        git checkout "$tag"
        cd - > /dev/null
    fi
}

# Function to download and extract archive
download_archive() {
    local name=$1
    local url=$2
    
    echo "Downloading $name from $url..."
    
    if [ -d "$DEPS_DIR/$name" ]; then
        echo "  $name already exists, skipping..."
        return
    fi
    
    mkdir -p "$DEPS_DIR/$name"
    cd "$DEPS_DIR/$name"
    
    # Download the archive
    curl -L -o archive.tar.gz "$url"
    
    # Extract it
    tar -xzf archive.tar.gz --strip-components=1
    
    # Remove the archive
    rm archive.tar.gz
    
    cd - > /dev/null
}

# Create deps directory if it doesn't exist
mkdir -p "$DEPS_DIR"

# Download all dependencies

# 1. XNNPACK
clone_repo "xnnpack" "https://github.com/google/XNNPACK" "b9d4073a6913891ce9cbd8965c8d506075d2a45a" "false"

# 2. Vulkan Headers
clone_repo "vulkan_headers" "https://github.com/KhronosGroup/Vulkan-Headers" "32c07c0c5334aea069e518206d75e002ccd85389" "false"

# 3. Ruy
clone_repo "ruy" "https://github.com/google/ruy" "3286a34cc8de6149ac6844107dfdffac91531e72" "false"

# 4. OpenGL Headers
clone_repo "opengl_headers" "https://github.com/KhronosGroup/OpenGL-Registry.git" "0cb0880d91581d34f96899c86fc1bf35627b4b81" "false"

# 5. OpenCL Headers
clone_repo "opencl_headers" "https://github.com/KhronosGroup/OpenCL-Headers" "dcd5bede6859d26833cd85f0d6bbcee7382dc9b3" "false"

# 6. NEON2SSE (archive)
download_archive "neon2sse" "https://storage.googleapis.com/mirror.tensorflow.org/github.com/intel/ARM_NEON_2_x86_SSE/archive/a15b489e1222b2087007546b4912e21293ea86ff.tar.gz"

# 7. Gemmlowp
clone_repo "gemmlowp" "https://github.com/google/gemmlowp" "fda83bdc38b118cc6b56753bd540caa49e570745" "false"

# 8. FP16 Headers
clone_repo "fp16_headers" "https://github.com/Maratyszcza/FP16" "0a92994d729ff76a58f692d3028ca1b64b145d91" "false"

# 9. FlatBuffers
clone_repo "flatbuffers" "https://github.com/google/flatbuffers" "v23.1.21" "true"

# 10. FFT2D (archive)
download_archive "fft2d" "https://storage.googleapis.com/mirror.tensorflow.org/github.com/petewarden/OouraFFT/archive/v1.0.tar.gz"

# 11. Farmhash
clone_repo "farmhash" "https://github.com/google/farmhash" "0d859a811870d10f53a594927d0d0b97573ad06d" "false"

# 12. Eigen
clone_repo "eigen" "https://gitlab.com/libeigen/eigen.git" "b0f877f8e01e90a5b0f3a79d46ea234899f8b499" "false"

# 13. EGL Headers
clone_repo "egl_headers" "https://github.com/KhronosGroup/EGL-Registry.git" "649981109e263b737e7735933c90626c29a306f2" "false"

# 14. CPUInfo
clone_repo "cpuinfo" "https://github.com/pytorch/cpuinfo" "3dc310302210c1891ffcfb12ae67b11a3ad3a150" "false"

# 15. Abseil-cpp
clone_repo "abseil-cpp" "https://github.com/abseil/abseil-cpp" "b971ac5250ea8de900eae9f95e06548d14cd95fe" "false"

# 16. RE2
clone_repo "re2" "https://github.com/google/re2.git" "2021-02-02" "true"

# 17. nsync
clone_repo "nsync" "https://github.com/google/nsync.git" "1.22.0" "true"

# 18. Google Test (only needed for tests)
clone_repo "googletest" "https://github.com/google/googletest.git" "release-1.10.0" "true"

# 19. Google Benchmark (only needed for benchmarks)
clone_repo "google_benchmark" "https://github.com/google/benchmark.git" "v1.7.0" "true"

echo ""
echo "All dependencies downloaded successfully!"
echo "Next steps:"
echo "1. Run this script to download all dependencies"
echo "2. Modify the .cmake files to use local sources"
echo "3. Test the build"