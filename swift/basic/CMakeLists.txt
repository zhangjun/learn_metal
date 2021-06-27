cmake_minimum_required(VERSION 3.10)

project(basic LANGUAGES C Swift)

add_executable(basic main.swift)

#find_library(METAL_LIBRARY Metal REQUIRED)
#find_library(FOUNDATION_LIBRARY Foundation)
#target_link_libraries(metal_simple ${METAL_LIBRARY} ${FOUNDATION_LIBRARY})
