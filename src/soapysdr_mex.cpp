#include "mex.hpp"
#include "mexAdapter.hpp"

#include <SoapySDR/Device.hpp>
#include <SoapySDR/Types.hpp>
#include <SoapySDR/Version.hpp>

#include "conversions.hpp"
#include "device_commands.hpp"
#include "stream_commands.hpp"

#include <string>
#include <unordered_map>
#include <functional>
#include <memory>

using namespace matlab::data;
using matlab::mex::ArgumentList;

class MexFunction : public matlab::mex::Function {
public:
    MexFunction() {
        initCommandTable();
    }

    ~MexFunction() {
        for (auto& entry : streamRegistry_) {
            try {
                auto devIt = deviceRegistry_.find(entry.second.deviceId);
                if (devIt != deviceRegistry_.end() && devIt->second != nullptr) {
                    devIt->second->closeStream(entry.second.stream);
                }
            } catch (...) {
                // Best-effort cleanup; never throw from destructor.
            }
        }
        streamRegistry_.clear();
        for (auto& entry : deviceRegistry_) {
            try {
                SoapySDR::Device::unmake(entry.second);
            } catch (...) {
                // Best-effort cleanup; never throw from destructor.
            }
        }
        deviceRegistry_.clear();
    }

    void operator()(ArgumentList outputs, ArgumentList inputs) override {
        ArrayFactory factory;
        auto engine = getEngine();

        if (inputs.size() < 1) {
            throwError(engine, factory,
                "soapysdr:mex:InvalidInput",
                "Expected at least one input argument "
                "(operation name).");
        }
        if (inputs[0].getType() != ArrayType::MATLAB_STRING) {
            throwError(engine, factory,
                "soapysdr:mex:InvalidInput",
                "Operation name must be a string scalar.");
        }
        if (inputs[0].getNumberOfElements() != 1) {
            throwError(engine, factory,
                "soapysdr:mex:InvalidInput",
                "Operation name must be a string scalar.");
        }

        std::string command = toStdString(inputs[0]);

        auto it = commandTable_.find(command);
        if (it == commandTable_.end()) {
            throwError(engine, factory,
                "soapysdr:mex:InvalidOperation",
                "Unknown MEX operation: " + command);
        }

        try {
            it->second(outputs, inputs, factory, engine);
        } catch (const std::exception& e) {
            throwError(engine, factory,
                "soapysdr:SoapyError", e.what());
        }
    }

private:
    std::unordered_map<std::string, HandlerFn> commandTable_;
    std::unordered_map<uint64_t, SoapySDR::Device*> deviceRegistry_;
    uint64_t nextDeviceId_ = 1;
    StreamRegistryT streamRegistry_;
    uint64_t nextStreamId_ = 1;

    void initCommandTable() {
        commandTable_["enumerate"] =
            [this](auto& out, auto& in, auto& f, auto& e) {
                doEnumerate(out, f);
            };

        commandTable_["getAPIVersion"] =
            [](auto& out, auto& in, auto& f, auto& e) {
                out[0] = f.createScalar(SoapySDR::getAPIVersion());
            };

        commandTable_["getABIVersion"] =
            [](auto& out, auto& in, auto& f, auto& e) {
                out[0] = f.createScalar(SoapySDR::getABIVersion());
            };

        commandTable_["getLibVersion"] =
            [](auto& out, auto& in, auto& f, auto& e) {
                out[0] = f.createScalar(SoapySDR::getLibVersion());
            };

        commandTable_["make"] =
            [this](auto& out, auto& in, auto& f, auto& e) {
                doMake(out, in, f, e);
            };

        commandTable_["unmake"] =
            [this](auto& out, auto& in, auto& f, auto& e) {
                doUnmake(in, f, e);
            };

        registerDeviceCommands(commandTable_,
            [this](uint64_t id, ArrayFactory& f, EnginePtrT& e) {
                return getDevice(id, f, e);
            });

        registerStreamCommands(commandTable_,
            [this](uint64_t id, ArrayFactory& f, EnginePtrT& e) {
                return getDevice(id, f, e);
            },
            streamRegistry_,
            nextStreamId_,
            [this](uint64_t id, ArrayFactory& f, EnginePtrT& e)
                    -> StreamInfo& {
                return getStream(id, f, e);
            });
    }

    void doEnumerate(ArgumentList& outputs, ArrayFactory& factory) {
        SoapySDR::KwargsList devices = SoapySDR::Device::enumerate();

        CellArray result = factory.createCellArray(
            {1, devices.size()});

        for (size_t i = 0; i < devices.size(); i++) {
            result[0][i] = kwargsToMatlab(factory, devices[i]);
        }

        outputs[0] = result;
    }

    void doMake(
            ArgumentList& outputs,
            ArgumentList& inputs,
            ArrayFactory& factory,
            EnginePtrT& engine) {
        if (inputs.size() < 2) {
            throwError(engine, factory,
                "soapysdr:mex:InvalidInput",
                "make requires a kwargs argument.");
        }

        SoapySDR::Kwargs kwargs = toKwargs(inputs[1]);
        SoapySDR::Device* dev = SoapySDR::Device::make(kwargs);

        if (dev == nullptr) {
            throwError(engine, factory,
                "soapysdr:mex:MakeFailed",
                "SoapySDR::Device::make returned null.");
        }

        uint64_t id = nextDeviceId_++;
        deviceRegistry_[id] = dev;
        outputs[0] = factory.createScalar(id);
    }

    void doUnmake(
            ArgumentList& inputs,
            ArrayFactory& factory,
            EnginePtrT& engine) {
        if (inputs.size() < 2) {
            throwError(engine, factory,
                "soapysdr:mex:InvalidInput",
                "unmake requires a device handle.");
        }

        uint64_t id = toUint64(inputs[1]);
        auto it = deviceRegistry_.find(id);
        if (it == deviceRegistry_.end()) {
            throwError(engine, factory,
                "soapysdr:InvalidDevice",
                "Invalid device handle.");
        }

        // Close all streams belonging to this device
        for (auto sIt = streamRegistry_.begin();
                sIt != streamRegistry_.end(); ) {
            if (sIt->second.deviceId == id) {
                it->second->closeStream(sIt->second.stream);
                sIt = streamRegistry_.erase(sIt);
            } else {
                ++sIt;
            }
        }

        SoapySDR::Device::unmake(it->second);
        deviceRegistry_.erase(it);
    }

    SoapySDR::Device* getDevice(
            uint64_t id,
            ArrayFactory& factory,
            EnginePtrT& engine) {
        auto it = deviceRegistry_.find(id);
        if (it == deviceRegistry_.end()) {
            throwError(engine, factory,
                "soapysdr:InvalidDevice",
                "Invalid device handle.");
        }
        return it->second;
    }

    StreamInfo& getStream(
            uint64_t id,
            ArrayFactory& factory,
            EnginePtrT& engine) {
        auto it = streamRegistry_.find(id);
        if (it == streamRegistry_.end()) {
            throwError(engine, factory,
                "soapysdr:InvalidStream",
                "Invalid stream handle.");
        }
        return it->second;
    }

    void throwError(
            EnginePtrT& engine,
            ArrayFactory& factory,
            const std::string& id,
            const std::string& message) {
        engine->feval(u"error", 0,
            {factory.createScalar(id),
             factory.createScalar(message)});
    }
};
