cmake_minimum_required(VERSION 3.10)
project(parma_cpp CXX)

set(MYLIB_DATADIR "${CMAKE_CURRENT_SOURCE_DIR}")
configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/config.h.in"
    "${CMAKE_BINARY_DIR}/config.h"
)
include_directories(${CMAKE_BINARY_DIR})

set(PARMA_SUBROUTINES ${CMAKE_CURRENT_SOURCE_DIR}/subroutines.cpp)
set(PARMA_MAIN ${CMAKE_CURRENT_SOURCE_DIR}/main-simple.cpp)

add_library(parma SHARED ${PARMA_SUBROUTINES})
add_library(parma-main SHARED ${PARMA_MAIN})
target_link_libraries(parma-main parma)
