cmake_minimum_required(VERSION 3.5)
project(learning_algorithm)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

set(SOURCE_FILES hua-jia-wen-ti.cpp)

add_executable(learning_algorithm ${SOURCE_FILES})