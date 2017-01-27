project(quickstart)

cmake_minimum_required(VERSION 2.8.12 FATAL_ERROR)
cmake_policy(SET CMP0043 NEW)
find_package(Qt5 REQUIRED NO_MODULE COMPONENTS Widgets)
find_package(KF5WindowSystem)
find_package(KF5GlobalAccel)

set(CMAKE_AUTOMOC ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)

add_executable(quickstart
    entry.cpp
    main.cpp
    view.cpp
)

qt5_use_modules(quickstart Core Gui Widgets)
target_link_libraries(quickstart KF5::WindowSystem KF5::GlobalAccel)
install(TARGETS quickstart DESTINATION bin)
