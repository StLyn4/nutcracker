include(CMakeParseArguments)

function(is_top_level_project)
  set(optional)
  set(one RESULT)
  set(multiple)
  cmake_parse_arguments(X "${optional}" "${one}" "${multiple}" "${ARGV}")

  if(PROJECT_IS_TOP_LEVEL OR ${CMAKE_PROJECT_NAME} STREQUAL ${PROJECT_NAME})
    set("${X_RESULT}" YES PARENT_SCOPE)
  else()
    set("${X_RESULT}" NO PARENT_SCOPE)
  endif()
endfunction()
