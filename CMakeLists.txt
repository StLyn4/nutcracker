cmake_minimum_required(VERSION 3.13)
project(nutcracker VERSION 1.0 LANGUAGES CXX)

# Add a local folder to search for CMake modules
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

set(SOURCE_FILES
  src/main.cpp
  src/BinaryReader.h
  src/BlockState.h
  src/Errors.cpp
  src/Errors.h
  src/Expressions.h
  src/Formatters.h
  src/NutDecompiler.cpp
  src/NutScript.cpp
  src/NutScript.h
  src/SqObject.cpp
  src/SqObject.h
  src/Statements.cpp
  src/Statements.h
)

# Add the source files to the project
add_executable(${PROJECT_NAME} ${SOURCE_FILES})

# Set default startup project for Visual Studio
set_directory_properties(PROPERTIES
  VS_STARTUP_PROJECT ${PROJECT_NAME}
)

# Set language standard to C++11 and
set_target_properties(${PROJECT_NAME} PROPERTIES
  CXX_STANDARD 11
  CXX_STANDARD_REQUIRED ON
)

# Set the default build type to Release
include(DefaultBuildType)
set_default_build_type("Release")

# Generate a configuration file
configure_file(src/config.h.in src/config.h @ONLY NEWLINE_STYLE LF)

# Add "<project>/build/src" folder to search for generated headers
target_include_directories(${PROJECT_NAME} PRIVATE "${PROJECT_BINARY_DIR}/src")
# ... and "<project>/include" for normal ones
target_include_directories(${PROJECT_NAME} PRIVATE "${PROJECT_SOURCE_DIR}/include")

# Enable IPO in release mode if possible
include(CheckIPOSupported)
check_ipo_supported(RESULT IS_IPO_SUPPORTED)
if(IS_IPO_SUPPORTED)
  message(STATUS "Enabling interprocedural optimization for release mode")
  set_target_properties(${PROJECT_NAME} PROPERTIES
    INTERPROCEDURAL_OPTIMIZATION_RELEASE ON
    INTERPROCEDURAL_OPTIMIZATION_MINSIZEREL ON
  )
endif()

# Use CCache if possible
include(CCache)
setup_ccache(${PROJECT_NAME})

# Set compiler settings
if(MSVC)
  target_compile_options(${PROJECT_NAME} PRIVATE /W3 /WX)

  # By default, CMake uses the third level of optimization - change to the second
  target_compile_options(${PROJECT_NAME} PRIVATE $<$<CONFIG:Release>:/O2>)
else()
  # target_compile_options(${PROJECT_NAME} PRIVATE -Wall -pedantic)

  # By default, CMake uses the third level of optimization - change to the second
  target_compile_options(${PROJECT_NAME} PRIVATE $<$<CONFIG:Release>:-O2>)
  target_link_options(${PROJECT_NAME} PRIVATE $<$<CONFIG:Release>:-O2>)

  # Remove debug information in release mode
  target_link_options(${PROJECT_NAME} PRIVATE $<$<CONFIG:Release>:-s> $<$<CONFIG:MinSizeRel>:-s>)
endif()

# Optional code quality tools
option(NUTCRACKER_USE_CODE_QUALITY_TOOLS "Use code quality tools" OFF)
if(NUTCRACKER_USE_CODE_QUALITY_TOOLS)
  include(CodeQuality)
  setup_code_quality_tools(${PROJECT_NAME})
endif()
