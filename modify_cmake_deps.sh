#!/bin/bash

# Script to modify all TensorFlow Lite CMake dependency files to use local sources

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CMAKE_MODULES_DIR="$SCRIPT_DIR/tensorflow/lite/tools/cmake/modules"
DEPS_DIR="$SCRIPT_DIR/deps"

echo "Modifying CMake files to use local dependencies..."

# Function to modify a cmake file to use local source
modify_cmake_file() {
    local file=$1
    local dep_name=$2
    
    echo "Modifying $file for dependency: $dep_name"
    
    # Create a backup
    cp "$file" "$file.bak"
    
    # Create a temporary file with modifications
    cat > "$file.tmp" << 'EOF'
#
# Copyright 2020 The TensorFlow Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

EOF
    
    # Add the target check
    echo "if(TARGET $dep_name OR ${dep_name}_POPULATED)" >> "$file.tmp"
    echo "  return()" >> "$file.tmp"
    echo "endif()" >> "$file.tmp"
    echo "" >> "$file.tmp"
    
    # Add local source configuration
    echo "# Use local source instead of fetching from network" >> "$file.tmp"
    echo "set(TFLITE_DEPS_DIR \"\${CMAKE_CURRENT_LIST_DIR}/../../../../deps\")" >> "$file.tmp"
    echo "set(${dep_name}_SOURCE_DIR \"\${TFLITE_DEPS_DIR}/${dep_name}\")" >> "$file.tmp"
    echo "set(${dep_name}_BINARY_DIR \"\${CMAKE_BINARY_DIR}/${dep_name}-build\")" >> "$file.tmp"
    echo "set(${dep_name}_POPULATED TRUE)" >> "$file.tmp"
    echo "" >> "$file.tmp"
    
    # Extract the rest of the file after the OverridableFetchContent_Populate section
    # This is a bit complex, but we need to preserve any custom build logic
    awk '
    BEGIN { skip = 0; found_end = 0 }
    /^OverridableFetchContent_Declare/ { skip = 1 }
    /^endif\(\)/ && skip == 1 { skip = 0; found_end = 1; next }
    skip == 0 && found_end == 1 { print }
    ' "$file.bak" >> "$file.tmp"
    
    # Move the temporary file to the original
    mv "$file.tmp" "$file"
}

# List of dependencies and their cmake files
deps="abseil-cpp:abseil-cpp.cmake cpuinfo:cpuinfo.cmake eigen:eigen.cmake farmhash:farmhash.cmake fft2d:fft2d.cmake fp16_headers:fp16_headers.cmake gemmlowp:gemmlowp.cmake ruy:ruy.cmake xnnpack:xnnpack.cmake vulkan_headers:vulkan_headers.cmake opencl_headers:opencl_headers.cmake opengl_headers:opengl_headers.cmake egl_headers:egl_headers.cmake neon2sse:neon2sse.cmake"

# Skip flatbuffers since we already modified it
# Skip test-only dependencies (googletest, google_benchmark)
# Skip dependencies that require special handling (re2, nsync)

for dep_pair in $deps; do
    dep_name="${dep_pair%%:*}"
    cmake_filename="${dep_pair##*:}"
    cmake_file="${CMAKE_MODULES_DIR}/${cmake_filename}"
    if [ -f "$cmake_file" ]; then
        modify_cmake_file "$cmake_file" "$dep_name"
    else
        echo "Warning: $cmake_file not found"
    fi
done

# Handle special cases manually

# re2.cmake uses Findre2.cmake
if [ -f "${CMAKE_MODULES_DIR}/Findre2.cmake" ]; then
    echo "Modifying Findre2.cmake..."
    cp "${CMAKE_MODULES_DIR}/Findre2.cmake" "${CMAKE_MODULES_DIR}/Findre2.cmake.bak"
    
    # For Find modules, we need a different approach
    cat > "${CMAKE_MODULES_DIR}/Findre2.cmake" << 'EOF'
#
# Copyright 2020 The TensorFlow Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if(TARGET re2 OR re2_POPULATED)
  return()
endif()

# Use local source instead of fetching from network
set(TFLITE_DEPS_DIR "${CMAKE_CURRENT_LIST_DIR}/../../../../deps")
set(re2_SOURCE_DIR "${TFLITE_DEPS_DIR}/re2")
set(re2_BINARY_DIR "${CMAKE_BINARY_DIR}/re2-build")
set(re2_POPULATED TRUE)

add_subdirectory(
  "${re2_SOURCE_DIR}"
  "${re2_BINARY_DIR}"
  EXCLUDE_FROM_ALL
)
EOF
fi

# nsync
if [ -f "${CMAKE_MODULES_DIR}/Findnsync.cmake" ]; then
    echo "Modifying Findnsync.cmake..."
    cp "${CMAKE_MODULES_DIR}/Findnsync.cmake" "${CMAKE_MODULES_DIR}/Findnsync.cmake.bak"
    
    cat > "${CMAKE_MODULES_DIR}/Findnsync.cmake" << 'EOF'
#
# Copyright 2020 The TensorFlow Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if(TARGET nsync OR nsync_POPULATED)
  return()
endif()

# Use local source instead of fetching from network
set(TFLITE_DEPS_DIR "${CMAKE_CURRENT_LIST_DIR}/../../../../deps")
set(nsync_SOURCE_DIR "${TFLITE_DEPS_DIR}/nsync")
set(nsync_BINARY_DIR "${CMAKE_BINARY_DIR}/nsync-build")
set(nsync_POPULATED TRUE)

set(NSYNC_LANGUAGE CXX)
set(NSYNC_BUILD_TESTS OFF)
add_subdirectory(
  "${nsync_SOURCE_DIR}"
  "${nsync_BINARY_DIR}"
)
EOF
fi

echo ""
echo "All CMake files have been modified!"
echo "Backup files created with .bak extension"
echo ""
echo "Next steps:"
echo "1. Test the build to ensure everything works"
echo "2. Remove backup files if everything is working: rm ${CMAKE_MODULES_DIR}/*.bak"