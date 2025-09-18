# See absl/copts/copts.py and absl/copts/generate_copts.py
include(GENERATED_AbseilCopts)

set(ABSL_DEFAULT_LINKOPTS "")

if (BUILD_SHARED_LIBS AND MSVC)
  set(ABSL_BUILD_DLL TRUE)
  set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
else()
  set(ABSL_BUILD_DLL FALSE)
endif()

if(APPLE AND CMAKE_CXX_COMPILER_ID MATCHES [[Clang]])
  # Fix for macOS 26.0 SDK and newer clang versions that don't handle -Xarch_ flags correctly
  # Use single-architecture approach based on CMAKE_SYSTEM_PROCESSOR
  if(CMAKE_SYSTEM_PROCESSOR MATCHES "arm.*|aarch64")
    # ARM64 Mac
    if (CMAKE_SIZEOF_VOID_P STREQUAL "8")
      set(ABSL_RANDOM_RANDEN_COPTS "${ABSL_RANDOM_HWAES_ARM64_FLAGS}")
    else()
      set(ABSL_RANDOM_RANDEN_COPTS "")
    endif()
  elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64|amd64|AMD64")
    # Intel Mac
    set(ABSL_RANDOM_RANDEN_COPTS "${ABSL_RANDOM_HWAES_X64_FLAGS}")
  else()
    # Fallback to original multi-arch approach for other cases
    set(ABSL_RANDOM_RANDEN_COPTS "")
    foreach(_arch IN ITEMS "x86_64" "arm64")
      string(TOUPPER "${_arch}" _arch_uppercase)
      string(REPLACE "X86_64" "X64" _arch_uppercase ${_arch_uppercase})
      foreach(_flag IN LISTS ABSL_RANDOM_HWAES_${_arch_uppercase}_FLAGS)
        list(APPEND ABSL_RANDOM_RANDEN_COPTS "-Xarch_${_arch}" "${_flag}")
      endforeach()
    endforeach()
    # If a compiler happens to deal with an argument for a currently unused
    # architecture, it will warn about an unused command line argument.
    option(ABSL_RANDOM_RANDEN_COPTS_WARNING OFF
           "Warn if one of ABSL_RANDOM_RANDEN_COPTS is unused")
    if(ABSL_RANDOM_RANDEN_COPTS AND NOT ABSL_RANDOM_RANDEN_COPTS_WARNING)
      list(APPEND ABSL_RANDOM_RANDEN_COPTS "-Wno-unused-command-line-argument")
    endif()
  endif()
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64|amd64|AMD64")
  if (MSVC)
    set(ABSL_RANDOM_RANDEN_COPTS "${ABSL_RANDOM_HWAES_MSVC_X64_FLAGS}")
  else()
    set(ABSL_RANDOM_RANDEN_COPTS "${ABSL_RANDOM_HWAES_X64_FLAGS}")
  endif()
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "arm.*|aarch64")
  if (CMAKE_SIZEOF_VOID_P STREQUAL "8")
    set(ABSL_RANDOM_RANDEN_COPTS "${ABSL_RANDOM_HWAES_ARM64_FLAGS}")
  elseif(CMAKE_SIZEOF_VOID_P STREQUAL "4")
    set(ABSL_RANDOM_RANDEN_COPTS "${ABSL_RANDOM_HWAES_ARM32_FLAGS}")
  else()
    message(WARNING "Value of CMAKE_SIZEOF_VOID_P (${CMAKE_SIZEOF_VOID_P}) is not supported.")
  endif()
else()
  set(ABSL_RANDOM_RANDEN_COPTS "")
endif()


if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  set(ABSL_DEFAULT_COPTS "${ABSL_GCC_FLAGS}")
  set(ABSL_TEST_COPTS "${ABSL_GCC_TEST_FLAGS}")
elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")  # MATCHES so we get both Clang and AppleClang
  if(MSVC)
    # clang-cl is half MSVC, half LLVM
    set(ABSL_DEFAULT_COPTS "${ABSL_CLANG_CL_FLAGS}")
    set(ABSL_TEST_COPTS "${ABSL_CLANG_CL_TEST_FLAGS}")
  else()
    set(ABSL_DEFAULT_COPTS "${ABSL_LLVM_FLAGS}")
    set(ABSL_TEST_COPTS "${ABSL_LLVM_TEST_FLAGS}")
  endif()
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
  set(ABSL_DEFAULT_COPTS "${ABSL_MSVC_FLAGS}")
  set(ABSL_TEST_COPTS "${ABSL_MSVC_TEST_FLAGS}")
  set(ABSL_DEFAULT_LINKOPTS "${ABSL_MSVC_LINKOPTS}")
else()
  message(WARNING "Unknown compiler: ${CMAKE_CXX_COMPILER}.  Building with no default flags")
  set(ABSL_DEFAULT_COPTS "")
  set(ABSL_TEST_COPTS "")
endif()

set(ABSL_CXX_STANDARD "${CMAKE_CXX_STANDARD}")
