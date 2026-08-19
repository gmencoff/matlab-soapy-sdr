#include <SoapySDR/Device.hpp>
#include <SoapySDR/Registry.hpp>

#include <string>
#include <vector>
#include <map>
#include <complex>
#include <cmath>
#include <algorithm>

class MatlabTestDevice : public SoapySDR::Device {
public:
    MatlabTestDevice(const SoapySDR::Kwargs& args) {
        if (args.count("serial")) {
            serial_ = args.at("serial");
        }
        // Initialize per-channel state
        for (size_t i = 0; i < 2; i++) {
            rxFrequency_[i] = 100e6;
            rxGain_[i] = 0.0;
            rxBandwidth_[i] = 2.5e6;
            rxSampleRate_[i] = 1e6;
            rxAntenna_[i] = "RX1";
            rxGainMode_[i] = false;
        }
        txFrequency_[0] = 100e6;
        txGain_[0] = 0.0;
        txBandwidth_[0] = 2.5e6;
        txSampleRate_[0] = 1e6;
        txAntenna_[0] = "TX1";
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

    void setFrontendMapping(
            const int direction,
            const std::string& mapping) override {
        if (direction == SOAPY_SDR_RX)
            rxFrontendMapping_ = mapping;
        else
            txFrontendMapping_ = mapping;
    }

    std::string getFrontendMapping(const int direction) const override {
        if (direction == SOAPY_SDR_RX)
            return rxFrontendMapping_;
        return txFrontendMapping_;
    }

    size_t getNumChannels(const int direction) const override {
        if (direction == SOAPY_SDR_RX) return 2;
        if (direction == SOAPY_SDR_TX) return 1;
        return 0;
    }

    SoapySDR::Kwargs getChannelInfo(
            const int direction,
            const size_t channel) const override {
        SoapySDR::Kwargs info;
        info["name"] = (direction == SOAPY_SDR_RX ? "RX" : "TX") +
            std::to_string(channel);
        return info;
    }

    bool getFullDuplex(
            const int, const size_t) const override {
        return true;
    }

    // --- Stream Discovery ---

    std::vector<std::string> getStreamFormats(
            const int, const size_t) const override {
        return {"CF32", "CS16", "CS8"};
    }

    std::string getNativeStreamFormat(
            const int, const size_t,
            double& fullScale) const override {
        fullScale = 32767.0;
        return "CS16";
    }

    SoapySDR::ArgInfoList getStreamArgsInfo(
            const int, const size_t) const override {
        return {};
    }

    // --- Antenna ---

    std::vector<std::string> listAntennas(
            const int direction,
            const size_t) const override {
        if (direction == SOAPY_SDR_RX)
            return {"RX1", "RX2"};
        return {"TX1"};
    }

    void setAntenna(
            const int direction,
            const size_t channel,
            const std::string& name) override {
        if (direction == SOAPY_SDR_RX)
            rxAntenna_[channel] = name;
        else
            txAntenna_[channel] = name;
    }

    std::string getAntenna(
            const int direction,
            const size_t channel) const override {
        if (direction == SOAPY_SDR_RX)
            return rxAntenna_.at(channel);
        return txAntenna_.at(channel);
    }

    // --- Frontend Corrections ---

    bool hasDCOffsetMode(const int, const size_t) const override {
        return true;
    }

    void setDCOffsetMode(
            const int, const size_t,
            const bool automatic) override {
        dcOffsetMode_ = automatic;
    }

    bool getDCOffsetMode(const int, const size_t) const override {
        return dcOffsetMode_;
    }

    bool hasDCOffset(const int, const size_t) const override {
        return true;
    }

    void setDCOffset(
            const int, const size_t,
            const std::complex<double>& offset) override {
        dcOffset_ = offset;
    }

    std::complex<double> getDCOffset(
            const int, const size_t) const override {
        return dcOffset_;
    }

    bool hasIQBalance(const int, const size_t) const override {
        return true;
    }

    void setIQBalance(
            const int, const size_t,
            const std::complex<double>& balance) override {
        iqBalance_ = balance;
    }

    std::complex<double> getIQBalance(
            const int, const size_t) const override {
        return iqBalance_;
    }

    bool hasFrequencyCorrection(
            const int, const size_t) const override {
        return true;
    }

    void setFrequencyCorrection(
            const int, const size_t,
            const double value) override {
        freqCorrection_ = value;
    }

    double getFrequencyCorrection(
            const int, const size_t) const override {
        return freqCorrection_;
    }

    // --- Gain ---

    std::vector<std::string> listGains(
            const int, const size_t) const override {
        return {"LNA", "VGA", "IF"};
    }

    bool hasGainMode(const int, const size_t) const override {
        return true;
    }

    void setGainMode(
            const int direction, const size_t channel,
            const bool automatic) override {
        if (direction == SOAPY_SDR_RX)
            rxGainMode_[channel] = automatic;
    }

    bool getGainMode(
            const int direction,
            const size_t channel) const override {
        if (direction == SOAPY_SDR_RX)
            return rxGainMode_.at(channel);
        return false;
    }

    void setGain(
            const int direction, const size_t channel,
            const double value) override {
        if (direction == SOAPY_SDR_RX)
            rxGain_[channel] = value;
        else
            txGain_[channel] = value;
    }

    void setGain(
            const int direction, const size_t channel,
            const std::string& name,
            const double value) override {
        elementGains_[name] = value;
    }

    double getGain(
            const int direction,
            const size_t channel) const override {
        if (direction == SOAPY_SDR_RX)
            return rxGain_.at(channel);
        return txGain_.at(channel);
    }

    double getGain(
            const int direction, const size_t channel,
            const std::string& name) const override {
        auto it = elementGains_.find(name);
        if (it != elementGains_.end()) return it->second;
        return 0.0;
    }

    SoapySDR::Range getGainRange(
            const int, const size_t) const override {
        return SoapySDR::Range(0.0, 73.0, 1.0);
    }

    SoapySDR::Range getGainRange(
            const int, const size_t,
            const std::string& name) const override {
        if (name == "LNA") return SoapySDR::Range(0.0, 30.0, 1.0);
        if (name == "VGA") return SoapySDR::Range(0.0, 40.0, 1.0);
        return SoapySDR::Range(0.0, 20.0, 1.0);
    }

    // --- Frequency ---

    void setFrequency(
            const int direction, const size_t channel,
            const double frequency,
            const SoapySDR::Kwargs&) override {
        if (direction == SOAPY_SDR_RX)
            rxFrequency_[channel] = frequency;
        else
            txFrequency_[channel] = frequency;
    }

    void setFrequency(
            const int, const size_t,
            const std::string& name,
            const double frequency,
            const SoapySDR::Kwargs&) override {
        componentFreqs_[name] = frequency;
    }

    double getFrequency(
            const int direction,
            const size_t channel) const override {
        if (direction == SOAPY_SDR_RX)
            return rxFrequency_.at(channel);
        return txFrequency_.at(channel);
    }

    double getFrequency(
            const int, const size_t,
            const std::string& name) const override {
        auto it = componentFreqs_.find(name);
        if (it != componentFreqs_.end()) return it->second;
        return 0.0;
    }

    std::vector<std::string> listFrequencies(
            const int, const size_t) const override {
        return {"RF", "BB"};
    }

    SoapySDR::RangeList getFrequencyRange(
            const int, const size_t) const override {
        return {SoapySDR::Range(70e6, 6e9, 0.0)};
    }

    SoapySDR::RangeList getFrequencyRange(
            const int, const size_t,
            const std::string& name) const override {
        if (name == "RF")
            return {SoapySDR::Range(70e6, 6e9, 0.0)};
        return {SoapySDR::Range(-50e6, 50e6, 0.0)};
    }

    SoapySDR::ArgInfoList getFrequencyArgsInfo(
            const int, const size_t) const override {
        SoapySDR::ArgInfo info;
        info.key = "OFFSET";
        info.value = "0";
        info.name = "Offset";
        info.description = "Frequency offset";
        info.type = SoapySDR::ArgInfo::FLOAT;
        return {info};
    }

    // --- Sample Rate ---

    void setSampleRate(
            const int direction, const size_t channel,
            const double rate) override {
        if (direction == SOAPY_SDR_RX)
            rxSampleRate_[channel] = rate;
        else
            txSampleRate_[channel] = rate;
    }

    double getSampleRate(
            const int direction,
            const size_t channel) const override {
        if (direction == SOAPY_SDR_RX)
            return rxSampleRate_.at(channel);
        return txSampleRate_.at(channel);
    }

    SoapySDR::RangeList getSampleRateRange(
            const int, const size_t) const override {
        return {SoapySDR::Range(225e3, 3.2e6, 0.0)};
    }

    // --- Bandwidth ---

    void setBandwidth(
            const int direction, const size_t channel,
            const double bw) override {
        if (direction == SOAPY_SDR_RX)
            rxBandwidth_[channel] = bw;
        else
            txBandwidth_[channel] = bw;
    }

    double getBandwidth(
            const int direction,
            const size_t channel) const override {
        if (direction == SOAPY_SDR_RX)
            return rxBandwidth_.at(channel);
        return txBandwidth_.at(channel);
    }

    SoapySDR::RangeList getBandwidthRange(
            const int, const size_t) const override {
        return {SoapySDR::Range(200e3, 8e6, 0.0)};
    }

    // --- Clocking ---

    void setMasterClockRate(const double rate) override {
        masterClockRate_ = rate;
    }

    double getMasterClockRate() const override {
        return masterClockRate_;
    }

    SoapySDR::RangeList getMasterClockRates() const override {
        return {SoapySDR::Range(10e6, 80e6, 0.0)};
    }

    std::vector<std::string> listClockSources() const override {
        return {"internal", "external"};
    }

    void setClockSource(const std::string& source) override {
        clockSource_ = source;
    }

    std::string getClockSource() const override {
        return clockSource_;
    }

    // --- Time ---

    std::vector<std::string> listTimeSources() const override {
        return {"none", "PPS"};
    }

    void setTimeSource(const std::string& source) override {
        timeSource_ = source;
    }

    std::string getTimeSource() const override {
        return timeSource_;
    }

    bool hasHardwareTime(const std::string&) const override {
        return true;
    }

    long long getHardwareTime(const std::string&) const override {
        return hardwareTime_;
    }

    void setHardwareTime(
            const long long timeNs,
            const std::string&) override {
        hardwareTime_ = timeNs;
    }

    // --- Sensors ---

    std::vector<std::string> listSensors() const override {
        return {"temp", "voltage"};
    }

    SoapySDR::ArgInfo getSensorInfo(
            const std::string& key) const override {
        SoapySDR::ArgInfo info;
        info.key = key;
        if (key == "temp") {
            info.name = "Temperature";
            info.description = "Device temperature";
            info.units = "C";
            info.type = SoapySDR::ArgInfo::FLOAT;
        } else {
            info.name = "Voltage";
            info.description = "Supply voltage";
            info.units = "V";
            info.type = SoapySDR::ArgInfo::FLOAT;
        }
        return info;
    }

    std::string readSensor(const std::string& key) const override {
        if (key == "temp") return "45.2";
        return "3.3";
    }

    std::vector<std::string> listSensors(
            const int, const size_t) const override {
        return {"rssi"};
    }

    SoapySDR::ArgInfo getSensorInfo(
            const int, const size_t,
            const std::string& key) const override {
        SoapySDR::ArgInfo info;
        info.key = key;
        info.name = "RSSI";
        info.description = "Received signal strength";
        info.units = "dBm";
        info.type = SoapySDR::ArgInfo::FLOAT;
        return info;
    }

    std::string readSensor(
            const int, const size_t,
            const std::string&) const override {
        return "-60.5";
    }

    // --- Settings ---

    SoapySDR::ArgInfoList getSettingInfo() const override {
        SoapySDR::ArgInfo info;
        info.key = "agc_mode";
        info.value = "slow";
        info.name = "AGC Mode";
        info.description = "Automatic gain control mode";
        info.type = SoapySDR::ArgInfo::STRING;
        info.options = {"slow", "fast", "off"};
        info.optionNames = {"Slow", "Fast", "Off"};
        return {info};
    }

    void writeSetting(
            const std::string& key,
            const std::string& value) override {
        settings_[key] = value;
    }

    std::string readSetting(
            const std::string& key) const override {
        auto it = settings_.find(key);
        if (it != settings_.end()) return it->second;
        return "";
    }

    SoapySDR::ArgInfoList getSettingInfo(
            const int, const size_t) const override {
        return {};
    }

    void writeSetting(
            const int, const size_t,
            const std::string& key,
            const std::string& value) override {
        channelSettings_[key] = value;
    }

    std::string readSetting(
            const int, const size_t,
            const std::string& key) const override {
        auto it = channelSettings_.find(key);
        if (it != channelSettings_.end()) return it->second;
        return "";
    }

    // --- GPIO ---

    std::vector<std::string> listGPIOBanks() const override {
        return {"MAIN"};
    }

    void writeGPIO(
            const std::string&,
            const unsigned value) override {
        gpioValue_ = value;
    }

    void writeGPIO(
            const std::string&,
            const unsigned value,
            const unsigned mask) override {
        gpioValue_ = (gpioValue_ & ~mask) | (value & mask);
    }

    unsigned readGPIO(const std::string&) const override {
        return gpioValue_;
    }

    void writeGPIODir(
            const std::string&,
            const unsigned dir) override {
        gpioDir_ = dir;
    }

    void writeGPIODir(
            const std::string&,
            const unsigned dir,
            const unsigned mask) override {
        gpioDir_ = (gpioDir_ & ~mask) | (dir & mask);
    }

    unsigned readGPIODir(const std::string&) const override {
        return gpioDir_;
    }

    // --- Streaming ---

    SoapySDR::Stream* setupStream(
            const int direction,
            const std::string& format,
            const std::vector<size_t>& channels,
            const SoapySDR::Kwargs&) override {
        auto* state = new TestStreamState();
        state->direction = direction;
        state->format = format;
        state->channels = channels.empty()
            ? std::vector<size_t>{0} : channels;
        state->active = false;
        return reinterpret_cast<SoapySDR::Stream*>(state);
    }

    void closeStream(SoapySDR::Stream* stream) override {
        auto* state = reinterpret_cast<TestStreamState*>(stream);
        delete state;
    }

    size_t getStreamMTU(SoapySDR::Stream*) const override {
        return 1024;
    }

    int activateStream(
            SoapySDR::Stream* stream,
            const int,
            const long long,
            const size_t) override {
        auto* state = reinterpret_cast<TestStreamState*>(stream);
        state->active = true;
        return 0;
    }

    int deactivateStream(
            SoapySDR::Stream* stream,
            const int,
            const long long) override {
        auto* state = reinterpret_cast<TestStreamState*>(stream);
        state->active = false;
        return 0;
    }

    int readStream(
            SoapySDR::Stream* stream,
            void* const* buffs,
            const size_t numElems,
            int& flags,
            long long& timeNs,
            const long) override {
        auto* state = reinterpret_cast<TestStreamState*>(stream);
        flags = 0;
        timeNs = 1000000;

        for (size_t ch = 0; ch < state->channels.size(); ch++) {
            if (state->format == "CF32") {
                auto* buf = reinterpret_cast<
                    std::complex<float>*>(buffs[ch]);
                for (size_t i = 0; i < numElems; i++) {
                    buf[i] = std::complex<float>(
                        static_cast<float>(i + 1),
                        static_cast<float>(-(int)(i + 1)));
                }
            } else if (state->format == "CS16") {
                auto* buf = reinterpret_cast<int16_t*>(buffs[ch]);
                for (size_t i = 0; i < numElems; i++) {
                    buf[2 * i] = static_cast<int16_t>(i + 1);
                    buf[2 * i + 1] = static_cast<int16_t>(
                        -(int)(i + 1));
                }
            }
        }
        return static_cast<int>(numElems);
    }

    int writeStream(
            SoapySDR::Stream*,
            const void* const*,
            const size_t numElems,
            int&,
            const long long,
            const long) override {
        return static_cast<int>(numElems);
    }

    int readStreamStatus(
            SoapySDR::Stream*,
            size_t& chanMask,
            int& flags,
            long long& timeNs,
            const long) const override {
        chanMask = 0;
        flags = 0;
        timeNs = 0;
        return -1;
    }

private:
    struct TestStreamState {
        int direction;
        std::string format;
        std::vector<size_t> channels;
        bool active;
    };
    std::string serial_ = "UNKNOWN";

    // Channel state
    std::map<size_t, double> rxFrequency_;
    std::map<size_t, double> txFrequency_;
    std::map<size_t, double> rxGain_;
    std::map<size_t, double> txGain_;
    std::map<size_t, double> rxBandwidth_;
    std::map<size_t, double> txBandwidth_;
    std::map<size_t, double> rxSampleRate_;
    std::map<size_t, double> txSampleRate_;
    std::map<size_t, std::string> rxAntenna_;
    std::map<size_t, std::string> txAntenna_;
    std::map<size_t, bool> rxGainMode_;
    std::map<std::string, double> elementGains_;
    std::map<std::string, double> componentFreqs_;

    // Frontend corrections
    bool dcOffsetMode_ = false;
    std::complex<double> dcOffset_ = {0.0, 0.0};
    std::complex<double> iqBalance_ = {1.0, 0.0};
    double freqCorrection_ = 0.0;

    // Frontend mapping
    std::string rxFrontendMapping_;
    std::string txFrontendMapping_;

    // Clocking
    double masterClockRate_ = 40e6;
    std::string clockSource_ = "internal";

    // Time
    std::string timeSource_ = "none";
    long long hardwareTime_ = 0;

    // Settings
    mutable std::map<std::string, std::string> settings_;
    mutable std::map<std::string, std::string> channelSettings_;

    // GPIO
    unsigned gpioValue_ = 0;
    unsigned gpioDir_ = 0;
};

static std::vector<SoapySDR::Kwargs> findMatlabTestDevices(
        const SoapySDR::Kwargs& filter) {
    std::vector<SoapySDR::Kwargs> allDevices;

    SoapySDR::Kwargs dev1;
    dev1["driver"] = "matlab_test";
    dev1["label"] = "MATLAB Test Device 1";
    dev1["serial"] = "TEST001";
    allDevices.push_back(dev1);

    SoapySDR::Kwargs dev2;
    dev2["driver"] = "matlab_test";
    dev2["label"] = "MATLAB Test Device 2";
    dev2["serial"] = "TEST002";
    allDevices.push_back(dev2);

    if (filter.empty()) {
        return allDevices;
    }

    std::vector<SoapySDR::Kwargs> results;
    for (const auto& dev : allDevices) {
        bool matches = true;
        for (const auto& kv : filter) {
            if (kv.first == "driver") continue;
            auto it = dev.find(kv.first);
            if (it == dev.end() || it->second != kv.second) {
                matches = false;
                break;
            }
        }
        if (matches) {
            results.push_back(dev);
        }
    }
    return results;
}

static SoapySDR::Device* makeMatlabTestDevice(
        const SoapySDR::Kwargs& args) {
    return new MatlabTestDevice(args);
}

static SoapySDR::Registry registerMatlabTest(
    "matlab_test", &findMatlabTestDevices, &makeMatlabTestDevice,
    SOAPY_SDR_ABI_VERSION);
