include(TopLevelProject)

function(setup_code_quality_tools PROJECT_NAME)
  is_top_level_project(RESULT IS_TOP_LEVEL_PROJECT)
  if(NOT IS_TOP_LEVEL_PROJECT)
    return()
  endif()

  # Clang tidy as static analyzer
  option(CQT_USE_CLANG_TIDY "Use clang-tidy" OFF)
  if(CQT_USE_CLANG_TIDY)
    find_program(
      CLANG_TIDY_EXE
      NAMES "clang-tidy" "clang-tidy-11" "clang-tidy-10"
      DOC "Path to clang-tidy executable"
    )
    if(CLANG_TIDY_EXE)
      message(STATUS "clang-tidy found: ${CLANG_TIDY_EXE}")
      set_target_properties(${PROJECT_NAME} PROPERTIES CXX_CLANG_TIDY "${CLANG_TIDY_EXE}")
    else()
      message(STATUS "clang-tidy not found - skipped")
    endif()
  endif()

  # AddressSanitizer and LeakSanitizer
  option(CQT_USE_ADDRESS_SANITIZER "Use AddressSanitizer and LeakSanitizer" OFF)
  if(CQT_USE_ADDRESS_SANITIZER)
    if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
      message(STATUS "Configuring with LLVM AddressSanitizer")
      set(NUTCRACKER_MEMCHECK_FLAGS
        -fno-optimize-sibling-calls
        -fno-omit-frame-pointer
        -fsanitize=address
        -fsanitize-address-use-after-scope
        -fsanitize=leak
      )
      target_compile_options(${PROJECT_NAME} PUBLIC -O1 -g ${NUTCRACKER_MEMCHECK_FLAGS})
      target_link_libraries(${PROJECT_NAME} PUBLIC -g ${NUTCRACKER_MEMCHECK_FLAGS})
    else()
      message(STATUS "GCC or Clang required for sanitizers: found ${CMAKE_CXX_COMPILER_ID} - skipped")
    endif()
  endif()

  # MemorySanitizer
  option(CQT_USE_MEMORY_SANITIZER "Use MemorySanitizer" OFF)
  if(CQT_USE_UNDEFINED_BEHAVIOR_SANITIZER)
    if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
      message(STATUS "Configuring with LLVM AddressSanitizer")
      set(NUTCRACKER_MEMCHECK_FLAGS
        -fno-optimize-sibling-calls
        -fno-omit-frame-pointer
        -fsanitize=memory
        -fsanitize-memory-track-origins
      )
      target_compile_options(${PROJECT_NAME} PUBLIC -O1 -g ${NUTCRACKER_MEMCHECK_FLAGS})
      target_link_libraries(${PROJECT_NAME} PUBLIC -g ${NUTCRACKER_MEMCHECK_FLAGS})
    else()
      message(STATUS "GCC or Clang required for sanitizers: found ${CMAKE_CXX_COMPILER_ID} - skipped")
    endif()
  endif()

  # UndefinedBehaviorSanitizer
  option(CQT_USE_UNDEFINED_BEHAVIOR_SANITIZER "Use UndefinedBehaviorSanitizer" OFF)
  if(CQT_USE_UNDEFINED_BEHAVIOR_SANITIZER)
    if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
      message(STATUS "Configuring with LLVM AddressSanitizer")
      set(NUTCRACKER_MEMCHECK_FLAGS
        -fno-optimize-sibling-calls
        -fno-omit-frame-pointer
        -fsanitize=undefined
      )
      target_compile_options(${PROJECT_NAME} PUBLIC -O1 -g ${NUTCRACKER_MEMCHECK_FLAGS})
      target_link_libraries(${PROJECT_NAME} PUBLIC -g ${NUTCRACKER_MEMCHECK_FLAGS})
    else()
      message(STATUS "GCC or Clang required for sanitizers: found ${CMAKE_CXX_COMPILER_ID} - skipped")
    endif()
  endif()

  # Coverage testing
  option(CQT_USE_CODE_COVERAGE "Use code coverage" OFF)
  if(CQT_USE_CODE_COVERAGE)
    if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
      message(STATUS "Configuring with coverage")
      target_compile_options(${PROJECT_NAME} PRIVATE --coverage -O0)
      target_link_libraries(${PROJECT_NAME} PRIVATE --coverage)
    else()
      message(STATUS "GCC or Clang required for coverage analysis: found ${CMAKE_CXX_COMPILER_ID} - skipped")
    endif()
  endif()
endfunction()
