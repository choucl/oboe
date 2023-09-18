cmake_minimum_required(VERSION 3.22)

project(cmake_bsv
  VERSION 0.0
  DESCRIPTION "Integrate cmake to BSV"
  LANGUAGES CXX)

set(CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake/bluespec-cmake" ${CMAKE_MODULE_PATH})

include(BluespecTargets)

add_subdirectory(src)
