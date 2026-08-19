#pragma once

#include "mex.hpp"
#include "conversions.hpp"

#include <SoapySDR/Device.hpp>

#include <string>
#include <memory>
#include <functional>
#include <unordered_map>
#include <complex>

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

    // === Identification ===

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

    // === Channels ===

    table["setFrontendMapping"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            std::string mapping = toStdString(in[3]);
            auto* dev = getDevice(id, f, e);
            dev->setFrontendMapping(dir, mapping);
        };

    table["getFrontendMapping"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            auto* dev = getDevice(id, f, e);
            out[0] = toMatlabString(f, dev->getFrontendMapping(dir));
        };

    table["getNumChannels"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            auto* dev = getDevice(id, f, e);
            out[0] = f.createScalar(
                static_cast<double>(dev->getNumChannels(dir)));
        };

    table["getChannelInfo"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            auto* dev = getDevice(id, f, e);
            out[0] = kwargsToMatlab(f, dev->getChannelInfo(dir, ch));
        };

    table["getFullDuplex"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            auto* dev = getDevice(id, f, e);
            out[0] = f.createScalar(dev->getFullDuplex(dir, ch));
        };

    // === Stream Discovery ===

    table["getStreamFormats"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            auto* dev = getDevice(id, f, e);
            out[0] = toMatlabStringArray(f,
                dev->getStreamFormats(dir, ch));
        };

    table["getNativeStreamFormat"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            auto* dev = getDevice(id, f, e);
            double fullScale = 0.0;
            std::string fmt =
                dev->getNativeStreamFormat(dir, ch, fullScale);
            out[0] = toMatlabString(f, fmt);
            out[1] = f.createScalar(fullScale);
        };

    table["getStreamArgsInfo"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            auto* dev = getDevice(id, f, e);
            out[0] = argInfoListToMatlab(f,
                dev->getStreamArgsInfo(dir, ch));
        };

    // === Antenna ===

    table["listAntennas"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            auto* dev = getDevice(id, f, e);
            out[0] = toMatlabStringArray(f,
                dev->listAntennas(dir, ch));
        };

    table["setAntenna"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            std::string name = toStdString(in[4]);
            auto* dev = getDevice(id, f, e);
            dev->setAntenna(dir, ch, name);
        };

    table["getAntenna"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            auto* dev = getDevice(id, f, e);
            out[0] = toMatlabString(f, dev->getAntenna(dir, ch));
        };

    // === Frontend Corrections ===

    table["hasDCOffsetMode"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            auto* dev = getDevice(id, f, e);
            out[0] = f.createScalar(dev->hasDCOffsetMode(dir, ch));
        };

    table["setDCOffsetMode"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            TypedArray<bool> val = in[4];
            auto* dev = getDevice(id, f, e);
            dev->setDCOffsetMode(dir, ch, val[0]);
        };

    table["getDCOffsetMode"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            auto* dev = getDevice(id, f, e);
            out[0] = f.createScalar(dev->getDCOffsetMode(dir, ch));
        };

    table["hasDCOffset"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            auto* dev = getDevice(id, f, e);
            out[0] = f.createScalar(dev->hasDCOffset(dir, ch));
        };

    table["setDCOffset"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            TypedArray<double> realPart = in[4];
            TypedArray<double> imagPart = in[5];
            auto* dev = getDevice(id, f, e);
            dev->setDCOffset(dir, ch,
                std::complex<double>(realPart[0], imagPart[0]));
        };

    table["getDCOffset"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            auto* dev = getDevice(id, f, e);
            std::complex<double> offset = dev->getDCOffset(dir, ch);
            out[0] = f.createScalar(offset.real());
            out[1] = f.createScalar(offset.imag());
        };

    table["hasIQBalance"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            auto* dev = getDevice(id, f, e);
            out[0] = f.createScalar(dev->hasIQBalance(dir, ch));
        };

    table["setIQBalance"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            TypedArray<double> realPart = in[4];
            TypedArray<double> imagPart = in[5];
            auto* dev = getDevice(id, f, e);
            dev->setIQBalance(dir, ch,
                std::complex<double>(realPart[0], imagPart[0]));
        };

    table["getIQBalance"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            auto* dev = getDevice(id, f, e);
            std::complex<double> bal = dev->getIQBalance(dir, ch);
            out[0] = f.createScalar(bal.real());
            out[1] = f.createScalar(bal.imag());
        };

    table["hasIQBalanceMode"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            auto* dev = getDevice(id, f, e);
            out[0] = f.createScalar(dev->hasIQBalanceMode(dir, ch));
        };

    table["setIQBalanceMode"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            TypedArray<bool> val = in[4];
            auto* dev = getDevice(id, f, e);
            dev->setIQBalanceMode(dir, ch, val[0]);
        };

    table["getIQBalanceMode"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            auto* dev = getDevice(id, f, e);
            out[0] = f.createScalar(dev->getIQBalanceMode(dir, ch));
        };

    table["hasFrequencyCorrection"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            auto* dev = getDevice(id, f, e);
            out[0] = f.createScalar(
                dev->hasFrequencyCorrection(dir, ch));
        };

    table["setFrequencyCorrection"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            TypedArray<double> val = in[4];
            auto* dev = getDevice(id, f, e);
            dev->setFrequencyCorrection(dir, ch, val[0]);
        };

    table["getFrequencyCorrection"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            auto* dev = getDevice(id, f, e);
            out[0] = f.createScalar(
                dev->getFrequencyCorrection(dir, ch));
        };

    // === Gain ===

    table["listGains"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            auto* dev = getDevice(id, f, e);
            out[0] = toMatlabStringArray(f,
                dev->listGains(dir, ch));
        };

    table["hasGainMode"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            auto* dev = getDevice(id, f, e);
            out[0] = f.createScalar(dev->hasGainMode(dir, ch));
        };

    table["setGainMode"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            TypedArray<bool> val = in[4];
            auto* dev = getDevice(id, f, e);
            dev->setGainMode(dir, ch, val[0]);
        };

    table["getGainMode"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            auto* dev = getDevice(id, f, e);
            out[0] = f.createScalar(dev->getGainMode(dir, ch));
        };

    table["setGain"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            TypedArray<double> val = in[4];
            auto* dev = getDevice(id, f, e);
            dev->setGain(dir, ch, val[0]);
        };

    table["setGainElement"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            std::string name = toStdString(in[4]);
            TypedArray<double> val = in[5];
            auto* dev = getDevice(id, f, e);
            dev->setGain(dir, ch, name, val[0]);
        };

    table["getGain"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            auto* dev = getDevice(id, f, e);
            out[0] = f.createScalar(dev->getGain(dir, ch));
        };

    table["getGainElement"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            std::string name = toStdString(in[4]);
            auto* dev = getDevice(id, f, e);
            out[0] = f.createScalar(dev->getGain(dir, ch, name));
        };

    table["getGainRange"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            auto* dev = getDevice(id, f, e);
            out[0] = rangeToMatlab(f, dev->getGainRange(dir, ch));
        };

    table["getGainElementRange"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            std::string name = toStdString(in[4]);
            auto* dev = getDevice(id, f, e);
            out[0] = rangeToMatlab(f,
                dev->getGainRange(dir, ch, name));
        };

    // === Frequency ===

    table["setFrequency"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            TypedArray<double> freq = in[4];
            SoapySDR::Kwargs args;
            if (in.size() > 5) {
                args = toKwargs(in[5]);
            }
            auto* dev = getDevice(id, f, e);
            dev->setFrequency(dir, ch, freq[0], args);
        };

    table["setFrequencyComponent"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            std::string name = toStdString(in[4]);
            TypedArray<double> freq = in[5];
            SoapySDR::Kwargs args;
            if (in.size() > 6) {
                args = toKwargs(in[6]);
            }
            auto* dev = getDevice(id, f, e);
            dev->setFrequency(dir, ch, name, freq[0], args);
        };

    table["getFrequency"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            auto* dev = getDevice(id, f, e);
            out[0] = f.createScalar(dev->getFrequency(dir, ch));
        };

    table["getFrequencyComponent"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            std::string name = toStdString(in[4]);
            auto* dev = getDevice(id, f, e);
            out[0] = f.createScalar(
                dev->getFrequency(dir, ch, name));
        };

    table["listFrequencies"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            auto* dev = getDevice(id, f, e);
            out[0] = toMatlabStringArray(f,
                dev->listFrequencies(dir, ch));
        };

    table["getFrequencyRange"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            auto* dev = getDevice(id, f, e);
            out[0] = rangeListToMatlab(f,
                dev->getFrequencyRange(dir, ch));
        };

    table["getFrequencyComponentRange"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            std::string name = toStdString(in[4]);
            auto* dev = getDevice(id, f, e);
            out[0] = rangeListToMatlab(f,
                dev->getFrequencyRange(dir, ch, name));
        };

    table["getFrequencyArgsInfo"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            auto* dev = getDevice(id, f, e);
            out[0] = argInfoListToMatlab(f,
                dev->getFrequencyArgsInfo(dir, ch));
        };

    // === Sample Rate ===

    table["setSampleRate"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            TypedArray<double> rate = in[4];
            auto* dev = getDevice(id, f, e);
            dev->setSampleRate(dir, ch, rate[0]);
        };

    table["getSampleRate"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            auto* dev = getDevice(id, f, e);
            out[0] = f.createScalar(dev->getSampleRate(dir, ch));
        };

    table["getSampleRateRange"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            auto* dev = getDevice(id, f, e);
            out[0] = rangeListToMatlab(f,
                dev->getSampleRateRange(dir, ch));
        };

    // === Bandwidth ===

    table["setBandwidth"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            TypedArray<double> bw = in[4];
            auto* dev = getDevice(id, f, e);
            dev->setBandwidth(dir, ch, bw[0]);
        };

    table["getBandwidth"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            auto* dev = getDevice(id, f, e);
            out[0] = f.createScalar(dev->getBandwidth(dir, ch));
        };

    table["getBandwidthRange"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            auto* dev = getDevice(id, f, e);
            out[0] = rangeListToMatlab(f,
                dev->getBandwidthRange(dir, ch));
        };

    // === Clocking ===

    table["setMasterClockRate"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            TypedArray<double> rate = in[2];
            auto* dev = getDevice(id, f, e);
            dev->setMasterClockRate(rate[0]);
        };

    table["getMasterClockRate"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            auto* dev = getDevice(id, f, e);
            out[0] = f.createScalar(dev->getMasterClockRate());
        };

    table["getMasterClockRates"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            auto* dev = getDevice(id, f, e);
            out[0] = rangeListToMatlab(f,
                dev->getMasterClockRates());
        };

    table["setReferenceClockRate"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            TypedArray<double> rate = in[2];
            auto* dev = getDevice(id, f, e);
            dev->setReferenceClockRate(rate[0]);
        };

    table["getReferenceClockRate"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            auto* dev = getDevice(id, f, e);
            out[0] = f.createScalar(dev->getReferenceClockRate());
        };

    table["getReferenceClockRates"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            auto* dev = getDevice(id, f, e);
            out[0] = rangeListToMatlab(f,
                dev->getReferenceClockRates());
        };

    table["listClockSources"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            auto* dev = getDevice(id, f, e);
            out[0] = toMatlabStringArray(f,
                dev->listClockSources());
        };

    table["setClockSource"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            std::string source = toStdString(in[2]);
            auto* dev = getDevice(id, f, e);
            dev->setClockSource(source);
        };

    table["getClockSource"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            auto* dev = getDevice(id, f, e);
            out[0] = toMatlabString(f, dev->getClockSource());
        };

    // === Time ===

    table["listTimeSources"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            auto* dev = getDevice(id, f, e);
            out[0] = toMatlabStringArray(f,
                dev->listTimeSources());
        };

    table["setTimeSource"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            std::string source = toStdString(in[2]);
            auto* dev = getDevice(id, f, e);
            dev->setTimeSource(source);
        };

    table["getTimeSource"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            auto* dev = getDevice(id, f, e);
            out[0] = toMatlabString(f, dev->getTimeSource());
        };

    table["hasHardwareTime"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            std::string what = "";
            if (in.size() > 2) {
                what = toStdString(in[2]);
            }
            auto* dev = getDevice(id, f, e);
            out[0] = f.createScalar(dev->hasHardwareTime(what));
        };

    table["getHardwareTime"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            std::string what = "";
            if (in.size() > 2) {
                what = toStdString(in[2]);
            }
            auto* dev = getDevice(id, f, e);
            long long timeNs = dev->getHardwareTime(what);
            out[0] = f.createScalar(static_cast<int64_t>(timeNs));
        };

    table["setHardwareTime"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            TypedArray<int64_t> timeNs = in[2];
            std::string what = "";
            if (in.size() > 3) {
                what = toStdString(in[3]);
            }
            auto* dev = getDevice(id, f, e);
            dev->setHardwareTime(
                static_cast<long long>(timeNs[0]), what);
        };

    // === Sensors ===

    table["listSensors"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            auto* dev = getDevice(id, f, e);
            out[0] = toMatlabStringArray(f, dev->listSensors());
        };

    table["getSensorInfo"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            std::string key = toStdString(in[2]);
            auto* dev = getDevice(id, f, e);
            out[0] = argInfoToMatlab(f, dev->getSensorInfo(key));
        };

    table["readSensor"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            std::string key = toStdString(in[2]);
            auto* dev = getDevice(id, f, e);
            out[0] = toMatlabString(f, dev->readSensor(key));
        };

    table["listChannelSensors"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            auto* dev = getDevice(id, f, e);
            out[0] = toMatlabStringArray(f,
                dev->listSensors(dir, ch));
        };

    table["getChannelSensorInfo"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            std::string key = toStdString(in[4]);
            auto* dev = getDevice(id, f, e);
            out[0] = argInfoToMatlab(f,
                dev->getSensorInfo(dir, ch, key));
        };

    table["readChannelSensor"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            std::string key = toStdString(in[4]);
            auto* dev = getDevice(id, f, e);
            out[0] = toMatlabString(f,
                dev->readSensor(dir, ch, key));
        };

    // === Settings ===

    table["getSettingInfo"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            auto* dev = getDevice(id, f, e);
            out[0] = argInfoListToMatlab(f, dev->getSettingInfo());
        };

    table["getSettingInfoForKey"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            std::string key = toStdString(in[2]);
            auto* dev = getDevice(id, f, e);
            out[0] = argInfoToMatlab(f, dev->getSettingInfo(key));
        };

    table["writeSetting"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            std::string key = toStdString(in[2]);
            std::string value = toStdString(in[3]);
            auto* dev = getDevice(id, f, e);
            dev->writeSetting(key, value);
        };

    table["readSetting"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            std::string key = toStdString(in[2]);
            auto* dev = getDevice(id, f, e);
            out[0] = toMatlabString(f, dev->readSetting(key));
        };

    table["getChannelSettingInfo"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            auto* dev = getDevice(id, f, e);
            out[0] = argInfoListToMatlab(f,
                dev->getSettingInfo(dir, ch));
        };

    table["getChannelSettingInfoForKey"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            std::string key = toStdString(in[4]);
            auto* dev = getDevice(id, f, e);
            out[0] = argInfoToMatlab(f,
                dev->getSettingInfo(dir, ch, key));
        };

    table["writeChannelSetting"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            std::string key = toStdString(in[4]);
            std::string value = toStdString(in[5]);
            auto* dev = getDevice(id, f, e);
            dev->writeSetting(dir, ch, key, value);
        };

    table["readChannelSetting"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            int dir = directionToSoapy(toStdString(in[2]));
            size_t ch = static_cast<size_t>(toUint64(in[3]));
            std::string key = toStdString(in[4]);
            auto* dev = getDevice(id, f, e);
            out[0] = toMatlabString(f,
                dev->readSetting(dir, ch, key));
        };

    // === GPIO ===

    table["listGPIOBanks"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            auto* dev = getDevice(id, f, e);
            out[0] = toMatlabStringArray(f, dev->listGPIOBanks());
        };

    table["writeGPIO"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            std::string bank = toStdString(in[2]);
            TypedArray<uint32_t> val = in[3];
            auto* dev = getDevice(id, f, e);
            if (in.size() > 4) {
                TypedArray<uint32_t> mask = in[4];
                dev->writeGPIO(bank, val[0], mask[0]);
            } else {
                dev->writeGPIO(bank, val[0]);
            }
        };

    table["readGPIO"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            std::string bank = toStdString(in[2]);
            auto* dev = getDevice(id, f, e);
            out[0] = f.createScalar(
                static_cast<uint32_t>(dev->readGPIO(bank)));
        };

    table["writeGPIODir"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            std::string bank = toStdString(in[2]);
            TypedArray<uint32_t> dir = in[3];
            auto* dev = getDevice(id, f, e);
            if (in.size() > 4) {
                TypedArray<uint32_t> mask = in[4];
                dev->writeGPIODir(bank, dir[0], mask[0]);
            } else {
                dev->writeGPIODir(bank, dir[0]);
            }
        };

    table["readGPIODir"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            std::string bank = toStdString(in[2]);
            auto* dev = getDevice(id, f, e);
            out[0] = f.createScalar(
                static_cast<uint32_t>(dev->readGPIODir(bank)));
        };

    // === Register ===

    table["listRegisterInterfaces"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            auto* dev = getDevice(id, f, e);
            out[0] = toMatlabStringArray(f,
                dev->listRegisterInterfaces());
        };

    table["writeRegister"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            std::string name = toStdString(in[2]);
            TypedArray<uint32_t> addr = in[3];
            TypedArray<uint32_t> value = in[4];
            auto* dev = getDevice(id, f, e);
            dev->writeRegister(name, addr[0], value[0]);
        };

    table["readRegister"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            std::string name = toStdString(in[2]);
            TypedArray<uint32_t> addr = in[3];
            auto* dev = getDevice(id, f, e);
            out[0] = f.createScalar(
                static_cast<uint32_t>(
                    dev->readRegister(name, addr[0])));
        };

    table["writeRegisters"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            std::string name = toStdString(in[2]);
            TypedArray<uint32_t> addr = in[3];
            TypedArray<uint32_t> values = in[4];
            std::vector<unsigned> vec;
            for (auto val : values) {
                vec.push_back(static_cast<unsigned>(val));
            }
            auto* dev = getDevice(id, f, e);
            dev->writeRegisters(name, addr[0], vec);
        };

    table["readRegisters"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            std::string name = toStdString(in[2]);
            TypedArray<uint32_t> addr = in[3];
            TypedArray<uint64_t> length = in[4];
            auto* dev = getDevice(id, f, e);
            std::vector<unsigned> regs = dev->readRegisters(
                name, addr[0], static_cast<size_t>(length[0]));
            TypedArray<uint32_t> result =
                f.createArray<uint32_t>({1, regs.size()});
            for (size_t i = 0; i < regs.size(); i++) {
                result[0][i] = static_cast<uint32_t>(regs[i]);
            }
            out[0] = result;
        };

    // === I2C ===

    table["writeI2C"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            TypedArray<int32_t> addr = in[2];
            TypedArray<uint8_t> data = in[3];
            std::string dataStr(data.begin(), data.end());
            auto* dev = getDevice(id, f, e);
            dev->writeI2C(addr[0], dataStr);
        };

    table["readI2C"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            TypedArray<int32_t> addr = in[2];
            TypedArray<uint64_t> numBytes = in[3];
            auto* dev = getDevice(id, f, e);
            std::string data = dev->readI2C(
                addr[0], static_cast<size_t>(numBytes[0]));
            TypedArray<uint8_t> result =
                f.createArray<uint8_t>({1, data.size()});
            for (size_t i = 0; i < data.size(); i++) {
                result[0][i] = static_cast<uint8_t>(data[i]);
            }
            out[0] = result;
        };

    // === SPI ===

    table["transactSPI"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            TypedArray<int32_t> addr = in[2];
            TypedArray<uint32_t> data = in[3];
            TypedArray<uint64_t> numBits = in[4];
            auto* dev = getDevice(id, f, e);
            unsigned result = dev->transactSPI(
                addr[0], data[0],
                static_cast<size_t>(numBits[0]));
            out[0] = f.createScalar(static_cast<uint32_t>(result));
        };

    // === UART ===

    table["listUARTs"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            auto* dev = getDevice(id, f, e);
            out[0] = toMatlabStringArray(f, dev->listUARTs());
        };

    table["writeUART"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            std::string which = toStdString(in[2]);
            std::string data = toStdString(in[3]);
            auto* dev = getDevice(id, f, e);
            dev->writeUART(which, data);
        };

    table["readUART"] =
        [getDevice](auto& out, auto& in, auto& f, auto& e) {
            uint64_t id = toUint64(in[1]);
            std::string which = toStdString(in[2]);
            long timeoutUs = 100000;
            if (in.size() > 3) {
                TypedArray<int64_t> timeout = in[3];
                timeoutUs = static_cast<long>(timeout[0]);
            }
            auto* dev = getDevice(id, f, e);
            out[0] = toMatlabString(f,
                dev->readUART(which, timeoutUs));
        };
}
