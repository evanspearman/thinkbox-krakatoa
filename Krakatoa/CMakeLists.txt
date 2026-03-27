cmake_minimum_required(VERSION 3.20)

if(POLICY CMP0167)
    cmake_policy(SET CMP0167 NEW)
endif()

project(Krakatoa LANGUAGES CXX)

add_library(krakatoa STATIC)

target_compile_features(krakatoa PUBLIC cxx_std_17)

set_target_properties(krakatoa PROPERTIES
    CXX_EXTENSIONS OFF
    PROJECT_LABEL "Krakatoa"
)

target_include_directories(krakatoa
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
        $<INSTALL_INTERFACE:include>
)

file(GLOB_RECURSE KRAKATOA_HEADERS CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/krakatoa/*.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/krakatoa/*.hpp"
)

file(GLOB_RECURSE KRAKATOA_SOURCES CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp"
)

target_sources(krakatoa
    PRIVATE
        stdafx.cpp
        stdafx.h
        ${KRAKATOA_HEADERS}
        ${KRAKATOA_SOURCES}
)

find_package(thinkboxlibrary REQUIRED CONFIG)
find_package(Boost REQUIRED CONFIG COMPONENTS filesystem thread program_options)
find_package(OpenEXR REQUIRED)
find_package(tinyxml2 REQUIRED CONFIG)
find_package(ZLIB REQUIRED)
find_package(TBB REQUIRED)

target_link_libraries(krakatoa
    PUBLIC
        thinkboxlibrary::thinkboxlibrary
        Boost::boost
        Boost::filesystem
        Boost::thread
        Boost::program_options
        OpenEXR::OpenEXR
        tinyxml2::tinyxml2
        ZLIB::ZLIB
        TBB::tbb
)

if(MSVC)
    target_compile_options(krakatoa PRIVATE /W4 /WX /MP)

    # Disable optimization for RelWithDebInfo to improve debugger usability.
    target_compile_options(krakatoa PRIVATE
        "$<$<CONFIG:Release>:/O2>"
        "$<$<CONFIG:RelWithDebInfo>:/Od>"
    )

    target_compile_definitions(krakatoa PRIVATE
        _USE_MATH_DEFINES
        _UNICODE
        _CRT_SECURE_NO_WARNINGS
    )
else()
    target_compile_options(krakatoa PRIVATE -Wall -Wextra -Wpedantic -Werror -pthread)
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    target_compile_definitions(krakatoa PRIVATE
        LINUX=1
        BOOST_FILESYSTEM_VERSION=3
    )
endif()

if(UNIX)
    target_compile_definitions(krakatoa PRIVATE
        _BOOL
        REQUIRE_IOSTREAM
    )

    set_target_properties(krakatoa PROPERTIES
        POSITION_INDEPENDENT_CODE ON
    )
endif()

target_precompile_headers(krakatoa PRIVATE stdafx.h)

install(
    DIRECTORY krakatoa
    DESTINATION include
    FILES_MATCHING
        PATTERN "*.h"
        PATTERN "*.hpp"
)

install(
    TARGETS krakatoa
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)
