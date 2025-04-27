cmake_minimum_required(VERSION 3.10)
project(parma_cpp CXX)

set(MYLIB_DATADIR "${CMAKE_CURRENT_SOURCE_DIR}")

configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/config.h.in"
    "${CMAKE_BINARY_DIR}/config.h"
)
