include(CMakeParseArguments)

function(setup_ccache PROJECT_NAME)
  find_program(CCACHE_EXE "ccache" DOC "Path to CCache executable")
  if(CCACHE_EXE)
    message(STATUS "CCache found: ${CCACHE_EXE}")
    set_target_properties(${PROJECT_NAME} PROPERTIES
      C_COMPILER_LAUNCHER "${CCACHE_EXE}"
      CXX_COMPILER_LAUNCHER "${CCACHE_EXE}"
      CUDA_COMPILER_LAUNCHER "${CCACHE_EXE}"
    )
  endif()
endfunction()
