cmake_minimum_required(VERSION 3.21)
project(planets)
set(CMAKE_CXX_STANDARD 17)

set(CMAKE_BUILD_TYPE Debug)

include(cmake/CPM.cmake)
include(cmake/SFML.cmake)

# IMGUI NOT SUPPORTED FOR SFML (Painfful)
include(cmake/IMGUI.cmake)
# Need third party here
include(cmake/ImGui-SFML.cmake)


add_subdirectory(src)
