#pragma once

#include "mex.hpp"

#include <SoapySDR/Device.hpp>

#include <memory>
#include <functional>

using namespace matlab::data;
using matlab::mex::ArgumentList;

using EnginePtrT = std::shared_ptr<matlab::engine::MATLABEngine>;
using HandlerFn = std::function<void(
    ArgumentList&, ArgumentList&, ArrayFactory&, EnginePtrT&)>;
using DeviceGetterFn = std::function<SoapySDR::Device*(
    uint64_t, ArrayFactory&, EnginePtrT&)>;
