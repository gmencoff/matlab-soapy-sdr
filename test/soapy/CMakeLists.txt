cmake_minimum_required(VERSION 3.20)
project(MatlabTestSoapyModule LANGUAGES CXX)

find_package(SoapySDR CONFIG REQUIRED)

add_library(matlabTestDevice MODULE MatlabTestDevice.cpp)
target_include_directories(matlabTestDevice PRIVATE ${SoapySDR_INCLUDE_DIRS})
target_link_libraries(matlabTestDevice PRIVATE ${SoapySDR_LIBRARIES})

set_target_properties(matlabTestDevice PROPERTIES
    PREFIX "lib"
    SUFFIX "${CMAKE_SHARED_MODULE_SUFFIX}"
)
