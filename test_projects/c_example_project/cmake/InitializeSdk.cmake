#**********************************************************************************#
# Copyright by @bkozdras <b.kozdras@gmail.com>                                     #
# Purpose: To initialize SDK (all external libraries).                             #
# Version: 1.0                                                                     #
# Licence: MIT                                                                     #
#**********************************************************************************#

message(STATUS "Processing: ${CMAKE_CURRENT_LIST_FILE}")

if (TESTING_ENABLED)
    message(STATUS "Fetching and building CMocka external library for UT/MT purposes!")
    include(${CMAKE_CURRENT_LIST_DIR}/FetchCMocka.cmake)
else ()
    message(STATUS "Skipped fetching CMocka. Building for target!")
endif (TESTING_ENABLED)
