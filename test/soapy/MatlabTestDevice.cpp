#include <SoapySDR/Device.hpp>
#include <SoapySDR/Registry.hpp>

#include <string>
#include <vector>

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
        const SoapySDR::Kwargs&) {
    return nullptr;
}

static SoapySDR::Registry registerMatlabTest(
    "matlab_test", &findMatlabTestDevices, &makeMatlabTestDevice,
    SOAPY_SDR_ABI_VERSION);
