# Find a DDS implementation.
# Currently only RTI's DDS implementation is searched for.
#
# The following directories are searched:
# DDS_ROOT (CMake variable)
# DDS_ROOT (Environment variable)
# NDDSHOME (Environment variable)
#
# Prior to calling this script, you may set the DDS_HOST variable. This is used
# when searching for some implementations as a name for the directory
# containing the library files. For example, it could be set to
# "x64Linux2.6gcc4.1.1".
#
# This sets the following variables:
# DDS_FOUND - True if DDS was found.
# DDS_VENDOR - Name of the DDS vendor found (e.g. "RTI")
# DDS_INCLUDE_DIRS - Directories containing the DDS include files.
# DDS_LIBRARIES - Libraries needed to use DDS.
# DDS_DEFINITIONS - Compiler flags for DDS.
# DDS_VERSION - The version of DDS found.
# DDS_VERSION_MAJOR - The major version of DDS found.
# DDS_VERSION_MINOR - The minor version of DDS found.
# DDS_VERSION_PATCH - The revision version of DDS found.
# DDS_VERSION_CAN - The candidate version of DDS found.

find_path(DDS_INCLUDE_DIR ndds/ndds_cpp.h
    HINTS ${DDS_ROOT}/include $ENV{DDS_ROOT}/include
    $ENV{NDDSHOME}/include)

if(NOT DDS_HOST)
    set(DDS_HOST "x64Linux2.6gcc4.1.1")
endif(NOT DDS_HOST)
find_library(DDS_C_LIBRARY nddsc
    HINTS ${DDS_ROOT}/lib $ENV{DDS_ROOT}/lib $ENV{NDDSHOME}/lib
    PATH_SUFFIXES ${DDS_HOST})
find_library(DDS_CPP_LIBRARY nddscpp
    HINTS ${DDS_ROOT}/lib $ENV{DDS_ROOT}/lib $ENV{NDDSHOME}/lib
    PATH_SUFFIXES ${DDS_HOST})
find_library(DDS_CORE_LIBRARY nddscore
    HINTS ${DDS_ROOT}/lib $ENV{DDS_ROOT}/lib $ENV{NDDSHOME}/lib
    PATH_SUFFIXES ${DDS_HOST})

if(WIN32)
    set(DDS_EXTRA_LIBRARIES netapi32 advapi32 user32 ws2_32)
    set(DDS_DEFINITIONS -DRTI_WIN32 -DNDDS_DLL_VARIABLE /MD)
else(WIN32)
    set(DDS_EXTRA_LIBRARIES dl nsl m pthread rt)
    if(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86_64")
        set(bits_flag -m64)
    else(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86_64")
        set(bits_flag -m32)
    endif(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86_64")
    set(DDS_DEFINITIONS -DRTI_UNIX -m64)
endif(WIN32)

set(DDS_INCLUDE_DIRS ${DDS_INCLUDE_DIR} ${DDS_INCLUDE_DIR}/ndds)
set(DDS_LIBRARIES ${DDS_C_LIBRARY} ${DDS_CPP_LIBRARY} ${DDS_CORE_LIBRARY}
    ${DDS_EXTRA_LIBRARIES})

file(GLOB DDS_VERSION_FILE ${DDS_ROOT}/rev_target_rtidds.*
    $ENV{DDS_ROOT}/rev_target_rtidds.*
    $ENV{NDDSHOME}/rev_target_rtidds.*)
if(DDS_VERSION_FILE)
    string(REGEX MATCH "rtidds.([0-9]+).([0-9]+)([a-z]*)"
        DDS_VERSION "${DDS_VERSION_FILE}")
    set(DDS_VERSION_MAJOR ${CMAKE_MATCH_1})
    set(DDS_VERSION_MINOR ${CMAKE_MATCH_2})
    set(DDS_VERSION_PATCH ${CMAKE_MATCH_3})
    set(DDS_VERSION_CAN)
endif(DDS_VERSION_FILE)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(DDS
    REQUIRED_VARS DDS_INCLUDE_DIR DDS_C_LIBRARY DDS_CPP_LIBRARY
    DDS_CORE_LIBRARY
    VERSION_VAR ${DDS_VERSION})

