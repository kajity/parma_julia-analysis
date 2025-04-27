cmake_minimum_required(VERSION 3.10)
project(parma_analysis CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if (NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

# add_compile_options(-fPIC)
set(CMAKE_CXX_FLAGS "-Wall -Wextra -Werror -Wnon-virtual-dtor -Wdisabled-optimization")
# set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Werror -Wfloat-equal")
set(CMAKE_CXX_FLAGS_DEBUG "-O0 -g")
set(CMAKE_CXX_FLAGS_RELEASE "-O3")

if (CMAKE_BUILD_TYPE STREQUAL "Debug")
    message("Compile flags:\n\t${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_DEBUG}")
elseif (CMAKE_BUILD_TYPE STREQUAL "Release")
    message("Compile flags:\n\t${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_RELEASE}")
else()
    message("Compile flags:\n\t${CMAKE_CXX_FLAGS}")
endif()

add_subdirectory(parma_cpp)

set(PARMA_SUBROUTINES ${CMAKE_CURRENT_SOURCE_DIR}/parma_cpp/subroutines.cpp)
set(PARMA_MAIN ${CMAKE_CURRENT_SOURCE_DIR}/parma_cpp/main-simple.cpp)

include_directories(${CMAKE_BINARY_DIR})

add_library(parma SHARED ${PARMA_SUBROUTINES})
add_library(parma-main SHARED ${PARMA_MAIN} ${PARMA_SUBROUTINES})
