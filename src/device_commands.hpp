#pragma once

#include "mex.hpp"
#include "conversions.hpp"

#include <SoapySDR/Device.hpp>

#include <string>
#include <memory>
#include <functional>
#include <unordered_map>

using namespace matlab::data;
using matlab::mex::ArgumentList;

using EnginePtrT = std::shared_ptr<matlab::engine::MATLABEngine>;
using HandlerFn = std::function<void(
    ArgumentList&, ArgumentList&, ArrayFactory&, EnginePtrT&)>;
using DeviceGetterFn = std::function<SoapySDR::Device*(
    uint64_t, ArrayFactory&, EnginePtrT&)>;

inline void registerDeviceCommands(
        std::unordered_map<std::string, HandlerFn>& table,
        DeviceGetterFn getDevice) {

    // --- Identification ---

    table["getDriverKey"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            auto* dev = getDevice(id, f, e);
            out[0] = toMatlabString(f, dev->getDriverKey());
        };

    table["getHardwareKey"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            auto* dev = getDevice(id, f, e);
            out[0] = toMatlabString(f, dev->getHardwareKey());
        };

    table["getHardwareInfo"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            auto* dev = getDevice(id, f, e);
            out[0] = kwargsToMatlab(f, dev->getHardwareInfo());
        };
}
