
add_executable(${PROJECT_NAME} main.cpp)

find_package(SFML 2.6 COMPONENTS system graphics window REQUIRED)

include(CMakePrintHelpers)
cmake_print_variables(SFML_FOUND)

target_link_libraries(${PROJECT_NAME} PRIVATE
	sfml-system
	sfml-graphics
	sfml-window
)

target_compile_features(${PROJECT_NAME} PRIVATE cxx_std_17)

if (WIN32 AND BUILD_SHARED_LIBS)
    add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_RUNTIME_DLLS:${PROJECT_NAME}> $<TARGET_FILE_DIR:${PROJECT_NAME}> COMMAND_EXPAND_LISTS)
endif()

install(TARGETS ${PROJECT_NAME})
