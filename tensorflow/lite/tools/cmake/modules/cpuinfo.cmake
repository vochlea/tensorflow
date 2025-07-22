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

if(TARGET cpuinfo OR cpuinfo_POPULATED)
  return()
endif()

# Use local source instead of fetching from network
set(TFLITE_DEPS_DIR "${CMAKE_CURRENT_LIST_DIR}/../../../../../deps")
set(cpuinfo_SOURCE_DIR "${TFLITE_DEPS_DIR}/cpuinfo")
set(cpuinfo_BINARY_DIR "${CMAKE_BINARY_DIR}/cpuinfo-build")
set(cpuinfo_POPULATED TRUE)


set(CPUINFO_SOURCE_DIR "${cpuinfo_SOURCE_DIR}" CACHE PATH "CPUINFO source directory")
set(CPUINFO_BUILD_TOOLS OFF CACHE BOOL "Disable cpuinfo command-line tools")
set(CPUINFO_BUILD_UNIT_TESTS OFF CACHE BOOL "Disable cpuinfo unit tests")
set(CPUINFO_BUILD_MOCK_TESTS OFF CACHE BOOL "Disable cpuinfo cpuinfo mock tests")
set(CPUINFO_BUILD_BENCHMARKS OFF CACHE BOOL "Disable cpuinfo micro-benchmarks")

add_subdirectory(
  "${cpuinfo_SOURCE_DIR}"
  "${cpuinfo_BINARY_DIR}"
)
