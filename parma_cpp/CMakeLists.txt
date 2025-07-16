cmake_minimum_required(VERSION 3.10)
project(parma_cpp CXX)

set(DATADIR ${CMAKE_CURRENT_SOURCE_DIR})
add_compile_definitions(DATADIR="${DATADIR}")
include_directories(${CMAKE_BINARY_DIR})

set(PARMA_SUBROUTINES ${CMAKE_CURRENT_SOURCE_DIR}/subroutines.cpp)

add_library(parma SHARED ${PARMA_SUBROUTINES})

add_executable(main-simple main-simple.cpp)
target_link_libraries(main-simple parma)

add_executable(main main.cpp)
target_link_libraries(main parma)

add_executable(main-generator main-generator.cpp)
target_link_libraries(main-generator parma)
