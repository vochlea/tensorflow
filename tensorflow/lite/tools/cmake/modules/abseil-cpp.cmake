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

if(TARGET abseil-cpp OR abseil-cpp_POPULATED)
  return()
endif()

# Use local source instead of fetching from network
set(TFLITE_DEPS_DIR "${CMAKE_CURRENT_LIST_DIR}/../../../../../deps")
set(abseil-cpp_SOURCE_DIR "${TFLITE_DEPS_DIR}/abseil-cpp")
set(abseil-cpp_BINARY_DIR "${CMAKE_BINARY_DIR}/abseil-cpp-build")
set(abseil-cpp_POPULATED TRUE)


set(ABSL_USE_GOOGLETEST_HEAD OFF CACHE BOOL "Disable googletest")
set(ABSL_RUN_TESTS OFF CACHE BOOL "Disable build of ABSL tests")
add_subdirectory(
  "${abseil-cpp_SOURCE_DIR}"
  "${abseil-cpp_BINARY_DIR}"
)

