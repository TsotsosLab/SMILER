cmake_minimum_required(VERSION 2.8)

project(BMS)

find_package(OpenCV REQUIRED)
include_directories(${OpenCV_INCLUDE_DIRS})
link_directories(${OpenCV_LIBRARY_DIRS})

add_executable(BMS src/main.cpp src/BMS.cpp src/BMS.h)
target_link_libraries(BMS ${OpenCV_LIBS})
