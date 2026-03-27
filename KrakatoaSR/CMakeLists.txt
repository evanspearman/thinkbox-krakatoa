cmake_minimum_required(VERSION 3.20)

if(POLICY CMP0167)
    cmake_policy(SET CMP0167 NEW)
endif()

project(KrakatoaSR LANGUAGES CXX)

set(KRAKATOASR_LIBRARY_TYPE "SHARED" CACHE STRING "Either SHARED or STATIC")
set_property(CACHE KRAKATOASR_LIBRARY_TYPE PROPERTY STRINGS SHARED STATIC)

option(BUILD_EXAMPLES "Build the KrakatoaSR examples" ON)

add_library(krakatoasr ${KRAKATOASR_LIBRARY_TYPE})

target_compile_features(krakatoasr PUBLIC cxx_std_17)

set_target_properties(krakatoasr PROPERTIES
    CXX_EXTENSIONS OFF
    PROJECT_LABEL "KrakatoaSR"
)

target_include_directories(krakatoasr
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
)

file(GLOB_RECURSE KRAKATOASR_HEADERS CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/include/*.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/include/*.hpp"
)

file(GLOB_RECURSE KRAKATOASR_SOURCES CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp"
)

target_sources(krakatoasr
    PRIVATE
        stdafx.cpp
        stdafx.h
        ${KRAKATOASR_HEADERS}
        ${KRAKATOASR_SOURCES}
)

find_package(thinkboxlibrary REQUIRED CONFIG)
find_package(krakatoa REQUIRED CONFIG)
find_package(Boost REQUIRED CONFIG)
find_package(OpenEXR REQUIRED)
find_package(ZLIB REQUIRED)
find_package(TBB REQUIRED)
pkg_check_modules(XXHASH REQUIRED IMPORTED_TARGET libxxhash)
find_package(OpenImageIO REQUIRED)

target_link_libraries(krakatoasr
    PUBLIC
        thinkboxlibrary::thinkboxlibrary
        krakatoa::krakatoa
        Boost::boost
        OpenEXR::OpenEXR
        ZLIB::ZLIB
        TBB::tbb
        PkgConfig::XXHASH
        OpenImageIO::OpenImageIO
)

if(KRAKATOASR_LIBRARY_TYPE STREQUAL "STATIC")
    target_compile_definitions(krakatoasr PUBLIC KSR_STATIC)
else()
    # The Conan version of Boost was built with this, and it changes the library names.
    # As a result, we need to set this to tell Boost to look for the right libraries to
    # link against.
    target_compile_definitions(krakatoasr PUBLIC BOOST_AUTO_LINK_SYSTEM)

    if(APPLE)
        target_link_libraries(krakatoasr PRIVATE
            "-framework CoreServices"
            "-framework CoreFoundation"
            "-framework IOKit"
        )

        target_link_options(krakatoasr PRIVATE
            "-Wl,-exported_symbols_list,${PROJECT_SOURCE_DIR}/KrakatoaSR.exp"
        )
    elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
        target_link_options(krakatoasr PRIVATE
            "-Wl,--version-script=${PROJECT_SOURCE_DIR}/KrakatoaSR.map"
            "-s"
        )
    endif()
endif()

if(MSVC)
    target_compile_options(krakatoasr PRIVATE /W4 /WX /MP)

    target_compile_options(krakatoasr PRIVATE
        "$<$<CONFIG:Release>:/O2>"
        "$<$<CONFIG:RelWithDebInfo>:/Od>"
    )

    target_compile_definitions(krakatoasr PRIVATE
        _USE_MATH_DEFINES
        _UNICODE
        _CRT_SECURE_NO_WARNINGS
    )
else()
    target_compile_options(krakatoasr PRIVATE -Wall -Wextra -Wpedantic -Werror -pthread)
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    target_compile_definitions(krakatoasr PRIVATE
        LINUX=1
        BOOST_FILESYSTEM_VERSION=3
    )
endif()

if(UNIX)
    target_compile_definitions(krakatoasr PRIVATE
        _BOOL
        REQUIRE_IOSTREAM
    )

    set_target_properties(krakatoasr PROPERTIES
        POSITION_INDEPENDENT_CODE ON
    )
endif()

target_precompile_headers(krakatoasr PRIVATE stdafx.h)

if(BUILD_EXAMPLES)
    add_subdirectory(Example)
endif()

install(
    DIRECTORY include/
    DESTINATION include
    FILES_MATCHING
        PATTERN "*.h"
        PATTERN "*.hpp"
)

install(
    TARGETS krakatoasr
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)
