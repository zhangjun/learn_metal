cmake_minimum_required(VERSION 3.10)

project(swift_cpp LANGUAGES C CXX Swift)

set(CMAKE_XCODE_ATTRIBUTE_SWIFT_OBJC_BRIDGING_HEADER "${PROJECT_SOURCE_DIR}/swift_cpp-Bridging-Header.h")	
set(CMAKE_XCODE_ATTRIBUTE_SWIFT_OBJC_INTERFACE_HEADER_NAME "swift_cpp-Bridging-Header.h")

add_executable(swift_cpp main.swift handler_wrapper.mm handler.cc)
		
#find_library(METAL_LIBRARY Metal REQUIRED)
#find_library(FOUNDATION_LIBRARY Foundation)
#target_link_libraries(metal_simple ${METAL_LIBRARY} ${FOUNDATION_LIBRARY})
    
	
