set(IMGUI_SFML_FIND_SFML OFF)
set(IMGUI_SFML_IMGUI_DEMO ON)

# IMGUI_SFML is annoying
set(IMGUI_DIR ${IMGUI_SOURCE_DIR})
set(IMGUI_INCLUDE_DIR ${IMGUI_SOURCE_DIR})
set(IMGUI_SOURCES ${IMGUI_SOURCE_DIR}/imgui.cpp
                  ${IMGUI_SOURCE_DIR}/imgui_draw.cpp
                  ${IMGUI_SOURCE_DIR}/imgui_tables.cpp
                  ${IMGUI_SOURCE_DIR}/imgui_widgets.cpp)
set(IMGUI_DEMO_SOURCES ${IMGUI_SOURCE_DIR}/imgui_demo.cpp)

FetchContent_Declare(
  imgui-sfml
  GIT_REPOSITORY https://github.com/SFML/imgui-sfml.git
  GIT_TAG        2.6.x
  # GIT_COMMIT 5f54b69b6aee18db846c81633f86f78c2586dded
  # ^ or like this - sometimes it's better because FetchContent won't look
  # into remote to see if branch head was updated or not - good for stable
  # tags like 'vX.X' corresponding to releases
)

FetchContent_MakeAvailable(imgui-sfml)