cmake_minimum_required(VERSION 3.10)

project(simd_sample LANGUAGES C Swift)

add_executable(simd_sample main.swift simd_sample.swift)
		
#find_library(METAL_LIBRARY Metal REQUIRED)
#find_library(FOUNDATION_LIBRARY Foundation)
#target_link_libraries(metal_simple ${METAL_LIBRARY} ${FOUNDATION_LIBRARY})
    
	
