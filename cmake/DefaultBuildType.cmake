include(TopLevelProject)

function(set_default_build_type BUILD_TYPE)
  # Do not set the build type if our project is not the main one
  is_top_level_project(RESULT IS_TOP_LEVEL_PROJECT)
  if(NOT IS_TOP_LEVEL_PROJECT)
    message(WARNING "NOT TOP LEVEL")
    return()
  endif()

  if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    message(STATUS "Setting build type to '${BUILD_TYPE}' as none was specified")
    set(CMAKE_BUILD_TYPE "${BUILD_TYPE}" CACHE STRING "Choose the type of build" FORCE)
    # Set the possible values of build type for cmake-gui
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
  elseif(CMAKE_BUILD_TYPE)
    message(STATUS "Build type '${CMAKE_BUILD_TYPE}' was specified")
  else()
    message(STATUS "Selected generator does not support build type specification using CMake: ${CMAKE_GENERATOR}")
  endif()
endfunction()
