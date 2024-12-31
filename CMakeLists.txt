cmake_minimum_required(VERSION 3.21)
project(template-project)
set(CMAKE_CXX_STANDARD 17)

include(cmake/CPM.cmake)
include(cmake/SFML.cmake)

add_subdirectory(src)
