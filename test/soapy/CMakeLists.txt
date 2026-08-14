cmake_minimum_required(VERSION 3.20)
project(MatlabTestSoapyModule LANGUAGES CXX)

find_path(SOAPY_INCLUDE_DIR SoapySDR/Device.h REQUIRED)
find_library(SOAPY_LIBRARY SoapySDR REQUIRED)

add_library(matlabTestDevice MODULE MatlabTestDevice.cpp)
target_include_directories(matlabTestDevice PRIVATE ${SOAPY_INCLUDE_DIR})
target_link_libraries(matlabTestDevice PRIVATE ${SOAPY_LIBRARY})

set_target_properties(matlabTestDevice PROPERTIES
    PREFIX "lib"
    SUFFIX "${CMAKE_SHARED_MODULE_SUFFIX}"
)
