#**********************************************************************************#
# Copyright by @bkozdras <b.kozdras@gmail.com>                                     #
# Purpose: To build project: combined for target (AVR) and testing (this arch).    #
# Version: 1.0                                                                     #
# Licence: MIT                                                                     #
#**********************************************************************************#

message(STATUS "Processing: ${CMAKE_CURRENT_LIST_FILE}")

cmake_minimum_required(VERSION 3.20 FATAL_ERROR)

execute_process(COMMAND uname -m
    COMMAND tr -d '\n'
    OUTPUT_VARIABLE THIS_ARCH)

set(REQUESTED_ARCH "AVR" CACHE STRING "Requested build architecture")
set(UNIT_TESTING_ENABLED OFF CACHE BOOL "Enabled unit tests")
set(MODULE_TESTING_ENABLED OFF CACHE BOOL "Enabled module tests")

if (UNIT_TESTING_ENABLED OR MODULE_TESTING_ENABLED)
    set(TESTING_ENABLED ON)
else ()
    set(TESTING_ENABLED OFF)
endif (UNIT_TESTING_ENABLED OR MODULE_TESTING_ENABLED)

message(STATUS "Passed project settings:")
message(STATUS "Requested architecture: ${REQUESTED_ARCH}")
message(STATUS "Is Unit Testing enabled: ${UNIT_TESTING_ENABLED}")
message(STATUS "Is Module Testing enabled: ${MODULE_TESTING_ENABLED}")
message(STATUS "Is Testing enabled: ${TESTING_ENABLED}")

if (REQUESTED_ARCH STREQUAL "AVR")
    if (TESTING_ENABLED)
        message(FATAL_ERROR "Building project for target architecture AVR cannot be combined with UT/MT!")
    endif (TESTING_ENABLED)
elseif (REQUESTED_ARCH STREQUAL "${THIS_ARCH}")
    if (NOT TESTING_ENABLED)
        message(FATAL_ERROR "Building for architecture ${THIS_ARCH} is only supported for UT or MT testing!")
    endif (NOT TESTING_ENABLED)
else ()
    message(FATAL_ERROR "Wrong architecture requested! Only AVR and ${THIS_ARCH} are supported!")
endif (REQUESTED_ARCH STREQUAL "AVR")

set(PROJECT_NAME AvrCExampleProject)
set(GCC_VERSION $ENV{GCC_MAJOR_VERSION}.$ENV{GCC_MINOR_VERSION})

project(${PROJECT_NAME} VERSION 1.0)

message(STATUS "Project name: ${PROJECT_NAME}")
message(STATUS "CMake version: ${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION}.${CMAKE_PATCH_VERSION}")
message(STATUS "GCC version: ${GCC_VERSION}")
message(STATUS "Target architecture: AVR")
message(STATUS "This architecture \(used for tests\): ${THIS_ARCH}")

enable_language(ASM)
enable_language(C)

include(cmake/InitializeSdk.cmake)

include_directories(include)
add_subdirectory(src)
if (TESTING_ENABLED)
    enable_testing()
    add_subdirectory(test)
endif (TESTING_ENABLED)
