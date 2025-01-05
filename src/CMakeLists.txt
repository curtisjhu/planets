
add_executable(${PROJECT_NAME} main.cpp)
# Verstion
target_compile_features(${PROJECT_NAME} PRIVATE cxx_std_17)

# Headers
target_include_directories(${PROJECT_NAME} PRIVATE ${PROJECT_SOURCE_DIR}/include)

# Shaders
add_custom_target(copy_shaders ALL 
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${PROJECT_SOURCE_DIR}/shaders ${PROJECT_BINARY_DIR}/shaders
)

include(CMakePrintHelpers)

# SFML
find_package(SFML 2.6 COMPONENTS system graphics window REQUIRED)
cmake_print_variables(SFML_FOUND)
target_link_libraries(${PROJECT_NAME} PRIVATE
	sfml-system
	sfml-graphics
	sfml-window
)

# IMGUI
find_package(IMGUI REQUIRED)
cmake_print_variables(IMGUI_FOUND)

add_library(imgui ${IMGUI_SOURCE_DIR}/imgui.cpp
                  ${IMGUI_SOURCE_DIR}/imgui_demo.cpp
                  ${IMGUI_SOURCE_DIR}/imgui_draw.cpp
                  ${IMGUI_SOURCE_DIR}/imgui_tables.cpp
                  ${IMGUI_SOURCE_DIR}/imgui_widgets.cpp
                )


target_include_directories(${PROJECT_NAME} PRIVATE
    ${IMGUI_SOURCE_DIR}
    ${IMGUI_SOURCE_DIR}/backends
)

target_link_libraries(${PROJECT_NAME} PRIVATE imgui)

# IMGUI-SFML
target_link_libraries(${PROJECT_NAME} PRIVATE ImGui-SFML::ImGui-SFML)


install(TARGETS ${PROJECT_NAME}
        RUNTIME DESTINATION .)


