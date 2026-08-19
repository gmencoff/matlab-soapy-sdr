#include <SoapySDR/Device.hpp>
#include <SoapySDR/Registry.hpp>

#include <string>
#include <vector>
#include <map>

class MatlabTestDevice : public SoapySDR::Device {
public:
    MatlabTestDevice(const SoapySDR::Kwargs& args) {
        if (args.count("serial")) {
            serial_ = args.at("serial");
        }
    }

    // --- Identification ---

    std::string getDriverKey() const override {
        return "matlab_test";
    }

    std::string getHardwareKey() const override {
        return "matlab_test_hw";
    }

    SoapySDR::Kwargs getHardwareInfo() const override {
        SoapySDR::Kwargs info;
        info["serial"] = serial_;
        info["firmware"] = "1.0.0";
        info["platform"] = "test";
        return info;
    }

    // --- Channels ---

    size_t getNumChannels(const int direction) const override {
        if (direction == SOAPY_SDR_RX) return 2;
        if (direction == SOAPY_SDR_TX) return 1;
        return 0;
    }

    bool getFullDuplex(
            const int, const size_t) const override {
        return true;
    }

private:
    std::string serial_ = "UNKNOWN";
};

static std::vector<SoapySDR::Kwargs> findMatlabTestDevices(
        const SoapySDR::Kwargs&) {
    std::vector<SoapySDR::Kwargs> results;

    SoapySDR::Kwargs dev1;
    dev1["driver"] = "matlab_test";
    dev1["label"] = "MATLAB Test Device 1";
    dev1["serial"] = "TEST001";
    results.push_back(dev1);

    SoapySDR::Kwargs dev2;
    dev2["driver"] = "matlab_test";
    dev2["label"] = "MATLAB Test Device 2";
    dev2["serial"] = "TEST002";
    results.push_back(dev2);

    return results;
}

static SoapySDR::Device* makeMatlabTestDevice(
        const SoapySDR::Kwargs& args) {
    return new MatlabTestDevice(args);
}

static SoapySDR::Registry registerMatlabTest(
    "matlab_test", &findMatlabTestDevices, &makeMatlabTestDevice,
    SOAPY_SDR_ABI_VERSION);
