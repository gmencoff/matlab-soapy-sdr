#include <SoapySDR/Device.h>
#include <SoapySDR/Registry.h>

#include <string>
#include <vector>

static std::vector<SoapySDRKwargs> findMatlabTestDevices(
        const SoapySDRKwargs*) {
    std::vector<SoapySDRKwargs> results;

    SoapySDRKwargs dev1 = {};
    SoapySDRKwargs_set(&dev1, "driver", "matlab_test");
    SoapySDRKwargs_set(&dev1, "label", "MATLAB Test Device 1");
    SoapySDRKwargs_set(&dev1, "serial", "TEST001");
    results.push_back(dev1);

    SoapySDRKwargs dev2 = {};
    SoapySDRKwargs_set(&dev2, "driver", "matlab_test");
    SoapySDRKwargs_set(&dev2, "label", "MATLAB Test Device 2");
    SoapySDRKwargs_set(&dev2, "serial", "TEST002");
    results.push_back(dev2);

    return results;
}

static SoapySDRDevice* makeMatlabTestDevice(const SoapySDRKwargs*) {
    return nullptr;
}

static SoapySDR::Registry registerMatlabTest(
    "matlab_test", &findMatlabTestDevices, &makeMatlabTestDevice,
    SOAPY_SDR_ABI_VERSION);
