cmake_minimum_required(VERSION 2.8)

if(PACKAGE_SUFFIX)
	set(PROJECT_NAME quantlib.build-${PACKAGE_SUFFIX})
else(PACKAGE_SUFFIX)
	set(PROJECT_NAME quantlib.build)
endif(PACKAGE_SUFFIX)

project(${PROJECT_NAME})

#-----------------------------------------------------------------------------
# force off-tree build

if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
message(FATAL_ERROR "CMake generation is not allowed within the source directory!
Remove the CMakeCache.txt file and try again from another folder, e.g.:

   del CMakeCache.txt
   mkdir build
   cd build
   cmake ..
")
endif(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/stage/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/stage/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/stage/lib)

set(MY_OWN_INSTALL_PREFIX "install" CACHE PATH "Prefix prepended to install directories")
set(CMAKE_INSTALL_PREFIX "${MY_OWN_INSTALL_PREFIX}" CACHE INTERNAL "Prefix prepended to install directories" FORCE)

if(ADD_TESTS)
	set(Boost_USE_STATIC_LIBS ON)
	find_package(Boost 1.49 COMPONENTS unit_test_framework REQUIRED)
else(ADD_TESTS)
	find_package(Boost 1.49 REQUIRED)
endif(ADD_TESTS)

add_definitions(-DQL_NO_AUTO_LINK)

if(MSVC)
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /MP")
else(MSVC)
	set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -fomit-frame-pointer -march=native")
endif(MSVC)

include(quantlib.cmake)
include(quantlibswigjava.cmake)
include(InstallRequiredSystemLibraries)

set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "QuantLib + java binding")
set(CPACK_PACKAGE_VENDOR "Kozlov Taras")
set(CPACK_PACKAGE_VERSION_MAJOR "1")
set(CPACK_PACKAGE_VERSION_MINOR "2")
set(CPACK_PACKAGE_VERSION_PATCH "0")
set(CPACK_GENERATOR "ZIP")

include(CPack)
