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

if(TARGET gemmlowp OR gemmlowp_POPULATED)
  return()
endif()

# Use local source instead of fetching from network
set(TFLITE_DEPS_DIR "${CMAKE_CURRENT_LIST_DIR}/../../../../../deps")
set(gemmlowp_SOURCE_DIR "${TFLITE_DEPS_DIR}/gemmlowp")
set(gemmlowp_BINARY_DIR "${CMAKE_BINARY_DIR}/gemmlowp-build")
set(gemmlowp_POPULATED TRUE)


set(GEMMLOWP_SOURCE_DIR "${gemmlowp_SOURCE_DIR}" CACHE PATH "Source directory")
add_subdirectory(
  "${CMAKE_CURRENT_LIST_DIR}/gemmlowp"
  "${gemmlowp_BINARY_DIR}"
)
