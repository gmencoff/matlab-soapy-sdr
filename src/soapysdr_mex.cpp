#include "mex.hpp"
#include "mexAdapter.hpp"

#include <SoapySDR/Device.h>
#include <SoapySDR/Version.h>

#include <string>
#include <memory>

using namespace matlab::data;
using matlab::mex::ArgumentList;

class MexFunction : public matlab::mex::Function {
public:
    void operator()(ArgumentList outputs, ArgumentList inputs) override {
        ArrayFactory factory;
        std::shared_ptr<matlab::engine::MATLABEngine> engine =
            getEngine();

        validateInputs(inputs, engine, factory);

        std::string command = getCommand(inputs);

        if (command == "enumerate") {
            outputs[0] = doEnumerate(factory);
        } else {
            throwError(engine, factory,
                "soapysdr:mex:InvalidOperation",
                "Unknown MEX operation: " + command);
        }
    }

private:
    void validateInputs(
            ArgumentList& inputs,
            std::shared_ptr<matlab::engine::MATLABEngine>& engine,
            ArrayFactory& factory) {
        if (inputs.size() != 1) {
            throwError(engine, factory,
                "soapysdr:mex:InvalidInput",
                "Expected exactly one input argument "
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
    }

    std::string getCommand(ArgumentList& inputs) {
        StringArray commandArray = inputs[0];
        std::u16string u16cmd = commandArray[0];
        return std::string(u16cmd.begin(), u16cmd.end());
    }

    Array doEnumerate(ArrayFactory& factory) {
        size_t length = 0;
        SoapySDRKwargs* deviceList =
            SoapySDRDevice_enumerate(nullptr, &length);

        if (deviceList == nullptr && length > 0) {
            auto engine = getEngine();
            throwError(engine, factory,
                "soapysdr:mex:EnumerationFailed",
                "SoapySDR device enumeration failed.");
        }

        CellArray result = factory.createCellArray({1, length});

        for (size_t i = 0; i < length; i++) {
            SoapySDRKwargs& kwargs = deviceList[i];
            size_t numKeys = kwargs.size;

            StringArray kvPairs =
                factory.createArray<MATLABString>({numKeys, 2});

            for (size_t k = 0; k < numKeys; k++) {
                std::string key(kwargs.keys[k]);
                std::string val(kwargs.vals[k]);
                kvPairs[k][0] = MATLABString(
                    std::u16string(key.begin(), key.end()));
                kvPairs[k][1] = MATLABString(
                    std::u16string(val.begin(), val.end()));
            }

            result[0][i] = kvPairs;
        }

        SoapySDRKwargsList_clear(deviceList, length);

        return result;
    }

    void throwError(
            std::shared_ptr<matlab::engine::MATLABEngine>& engine,
            ArrayFactory& factory,
            const std::string& id,
            const std::string& message) {
        engine->feval(u"error", 0,
            {factory.createScalar(id),
             factory.createScalar(message)});
    }
};
