#pragma once

#include "mex_types.hpp"
#include "conversions.hpp"

#include <SoapySDR/Device.hpp>

#include <string>
#include <unordered_map>
#include <vector>

struct StreamInfo {
    SoapySDR::Stream* stream;
    uint64_t deviceId;
    std::string format;
    size_t numChannels;
};

using StreamRegistryT = std::unordered_map<uint64_t, StreamInfo>;

using StreamGetterFn = std::function<StreamInfo&(
    uint64_t, ArrayFactory&, EnginePtrT&)>;

// --- Template helpers for type-dispatched stream I/O ---

template <typename T>
inline void doReadStream(
        ArgumentList& out,
        ArrayFactory& f,
        SoapySDR::Device* dev,
        const StreamInfo& info,
        size_t numElems,
        long timeoutUs) {
    size_t numCh = info.numChannels;
    TypedArray<T> arr = f.createArray<T>({numElems, numCh});
    auto* basePtr = reinterpret_cast<void*>(&(*arr.begin()));
    std::vector<void*> buffs(numCh);
    size_t colBytes = numElems * sizeof(T);
    for (size_t ch = 0; ch < numCh; ch++) {
        buffs[ch] = reinterpret_cast<char*>(basePtr) + ch * colBytes;
    }
    int flags = 0;
    long long timeNs = 0;
    int ret = dev->readStream(
        info.stream, buffs.data(), numElems, flags, timeNs, timeoutUs);
    out[0] = std::move(arr);
    out[1] = f.createScalar(static_cast<int32_t>(ret));
    out[2] = f.createScalar(static_cast<int32_t>(flags));
    out[3] = f.createScalar(static_cast<int64_t>(timeNs));
}

template <typename T>
inline const void* getWriteBasePtr(const Array& dataArr) {
    TypedArray<T> typed = dataArr;
    return reinterpret_cast<const void*>(&(*typed.cbegin()));
}

inline void dispatchReadStream(
        ArgumentList& out,
        ArrayFactory& f,
        SoapySDR::Device* dev,
        const StreamInfo& info,
        size_t numElems,
        long timeoutUs) {
    FormatInfo fmt = getFormatInfo(info.format);
    if (fmt.isComplex) {
        switch (fmt.arrayType) {
            case ArrayType::SINGLE:
                doReadStream<std::complex<float>>(out, f, dev, info, numElems, timeoutUs); return;
            case ArrayType::DOUBLE:
                doReadStream<std::complex<double>>(out, f, dev, info, numElems, timeoutUs); return;
            case ArrayType::INT32:
                doReadStream<std::complex<int32_t>>(out, f, dev, info, numElems, timeoutUs); return;
            case ArrayType::INT16:
                doReadStream<std::complex<int16_t>>(out, f, dev, info, numElems, timeoutUs); return;
            case ArrayType::INT8:
                doReadStream<std::complex<int8_t>>(out, f, dev, info, numElems, timeoutUs); return;
            case ArrayType::UINT16:
                doReadStream<std::complex<uint16_t>>(out, f, dev, info, numElems, timeoutUs); return;
            case ArrayType::UINT8:
                doReadStream<std::complex<uint8_t>>(out, f, dev, info, numElems, timeoutUs); return;
            default: break;
        }
    } else {
        switch (fmt.arrayType) {
            case ArrayType::SINGLE:
                doReadStream<float>(out, f, dev, info, numElems, timeoutUs); return;
            case ArrayType::DOUBLE:
                doReadStream<double>(out, f, dev, info, numElems, timeoutUs); return;
            case ArrayType::INT16:
                doReadStream<int16_t>(out, f, dev, info, numElems, timeoutUs); return;
            case ArrayType::INT8:
                doReadStream<int8_t>(out, f, dev, info, numElems, timeoutUs); return;
            case ArrayType::UINT8:
                doReadStream<uint8_t>(out, f, dev, info, numElems, timeoutUs); return;
            default: break;
        }
    }
}

inline const void* dispatchWriteBasePtr(
        const Array& dataArr,
        const FormatInfo& fmt) {
    if (fmt.isComplex) {
        switch (fmt.arrayType) {
            case ArrayType::SINGLE: return getWriteBasePtr<std::complex<float>>(dataArr);
            case ArrayType::DOUBLE: return getWriteBasePtr<std::complex<double>>(dataArr);
            case ArrayType::INT32:  return getWriteBasePtr<std::complex<int32_t>>(dataArr);
            case ArrayType::INT16:  return getWriteBasePtr<std::complex<int16_t>>(dataArr);
            case ArrayType::INT8:   return getWriteBasePtr<std::complex<int8_t>>(dataArr);
            case ArrayType::UINT16: return getWriteBasePtr<std::complex<uint16_t>>(dataArr);
            case ArrayType::UINT8:  return getWriteBasePtr<std::complex<uint8_t>>(dataArr);
            default: break;
        }
    } else {
        switch (fmt.arrayType) {
            case ArrayType::SINGLE: return getWriteBasePtr<float>(dataArr);
            case ArrayType::DOUBLE: return getWriteBasePtr<double>(dataArr);
            case ArrayType::INT16:  return getWriteBasePtr<int16_t>(dataArr);
            case ArrayType::INT8:   return getWriteBasePtr<int8_t>(dataArr);
            case ArrayType::UINT8:  return getWriteBasePtr<uint8_t>(dataArr);
            default: break;
        }
    }
    return nullptr;
}

// --- Command registration ---

inline void registerStreamCommands(
        std::unordered_map<std::string, HandlerFn>& table,
        DeviceGetterFn getDevice,
        StreamRegistryT& streamRegistry,
        uint64_t& nextStreamId,
        StreamGetterFn getStream) {

    // === setupStream ===

    table["setupStream"] =
        [getDevice, &streamRegistry, &nextStreamId](
                auto& out, auto& in, auto& f, auto& e) {
            uint64_t devId = toUint64(in[1]);
            auto* dev = getDevice(devId, f, e);
            int dir = directionToSoapy(toStdString(in[2]));
            std::string format = toStdString(in[3]);

            std::vector<size_t> channels;
            TypedArray<uint64_t> chArr = in[4];
            for (auto ch : chArr) {
                channels.push_back(static_cast<size_t>(ch));
            }

            SoapySDR::Kwargs kwargs;
            if (in.size() > 5 && in[5].getNumberOfElements() > 0) {
                kwargs = toKwargs(in[5]);
            }

            SoapySDR::Stream* stream = dev->setupStream(
                dir, format, channels, kwargs);

            uint64_t streamId = nextStreamId++;
            streamRegistry[streamId] = {
                stream, devId, format, channels.size()};
            out[0] = f.createScalar(streamId);
        };

    // === closeStream ===

    table["closeStream"] =
        [getDevice, &streamRegistry, getStream](
                auto& out, auto& in, auto& f, auto& e) {
            uint64_t streamId = toUint64(in[2]);
            auto& info = getStream(streamId, f, e);
            auto* dev = getDevice(info.deviceId, f, e);
            dev->closeStream(info.stream);
            streamRegistry.erase(streamId);
        };

    // === getStreamMTU ===

    table["getStreamMTU"] =
        [getDevice, getStream](
                auto& out, auto& in, auto& f, auto& e) {
            uint64_t streamId = toUint64(in[2]);
            auto& info = getStream(streamId, f, e);
            auto* dev = getDevice(info.deviceId, f, e);
            size_t mtu = dev->getStreamMTU(info.stream);
            out[0] = f.createScalar(static_cast<uint64_t>(mtu));
        };

    // === activateStream ===

    table["activateStream"] =
        [getDevice, getStream](
                auto& out, auto& in, auto& f, auto& e) {
            uint64_t streamId = toUint64(in[2]);
            auto& info = getStream(streamId, f, e);
            auto* dev = getDevice(info.deviceId, f, e);

            TypedArray<int32_t> flagsArr = in[3];
            int flags = static_cast<int>(flagsArr[0]);

            TypedArray<int64_t> timeArr = in[4];
            long long timeNs = static_cast<long long>(timeArr[0]);

            TypedArray<int32_t> numElemsArr = in[5];
            size_t numElems = static_cast<size_t>(numElemsArr[0]);

            dev->activateStream(info.stream, flags, timeNs, numElems);
        };

    // === deactivateStream ===

    table["deactivateStream"] =
        [getDevice, getStream](
                auto& out, auto& in, auto& f, auto& e) {
            uint64_t streamId = toUint64(in[2]);
            auto& info = getStream(streamId, f, e);
            auto* dev = getDevice(info.deviceId, f, e);

            TypedArray<int32_t> flagsArr = in[3];
            int flags = static_cast<int>(flagsArr[0]);

            TypedArray<int64_t> timeArr = in[4];
            long long timeNs = static_cast<long long>(timeArr[0]);

            dev->deactivateStream(info.stream, flags, timeNs);
        };

    // === readStream ===

    table["readStream"] =
        [getDevice, getStream](
                auto& out, auto& in, auto& f, auto& e) {
            uint64_t streamId = toUint64(in[2]);
            auto& info = getStream(streamId, f, e);
            auto* dev = getDevice(info.deviceId, f, e);

            TypedArray<int64_t> numElemsArr = in[3];
            const int64_t rawNumElems = numElemsArr[0];
            if (rawNumElems < 0) throw std::invalid_argument("numElems must be non-negative");
            const size_t numElems = static_cast<size_t>(rawNumElems);

            TypedArray<int64_t> timeoutArr = in[4];
            const int64_t rawTimeoutUs = timeoutArr[0];
            if (rawTimeoutUs < 0) throw std::invalid_argument("timeoutUs must be non-negative");
            long timeoutUs = static_cast<long>(rawTimeoutUs);
            dispatchReadStream(out, f, dev, info, numElems, timeoutUs);
        };

    // === writeStream ===

    table["writeStream"] =
        [getDevice, getStream](
                auto& out, auto& in, auto& f, auto& e) {
            uint64_t streamId = toUint64(in[2]);
            auto& info = getStream(streamId, f, e);
            auto* dev = getDevice(info.deviceId, f, e);

            FormatInfo fmtInfo = getFormatInfo(info.format);
            size_t numCh = info.numChannels;

            Array dataArr = in[3];
            size_t numElems = dataArr.getDimensions()[0];

            TypedArray<int32_t> flagsArr = in[4];
            int flags = static_cast<int>(flagsArr[0]);

            TypedArray<int64_t> timeArr = in[5];
            long long timeNs = static_cast<long long>(timeArr[0]);

            TypedArray<int64_t> timeoutArr = in[6];
            long timeoutUs = static_cast<long>(timeoutArr[0]);

            const void* basePtr = dispatchWriteBasePtr(dataArr, fmtInfo);
            std::vector<const void*> buffs(numCh);
            size_t colBytes = numElems * fmtInfo.elemBytes;
            for (size_t ch = 0; ch < numCh; ch++) {
                buffs[ch] = reinterpret_cast<const char*>(
                    basePtr) + ch * colBytes;
            }

            int ret = dev->writeStream(
                info.stream, buffs.data(), numElems,
                flags, timeNs, timeoutUs);
            out[0] = f.createScalar(static_cast<int32_t>(ret));
        };

    // === readStreamStatus ===

    table["readStreamStatus"] =
        [getDevice, getStream](
                auto& out, auto& in, auto& f, auto& e) {
            uint64_t streamId = toUint64(in[2]);
            auto& info = getStream(streamId, f, e);
            auto* dev = getDevice(info.deviceId, f, e);

            TypedArray<int64_t> timeoutArr = in[3];
            long timeoutUs = static_cast<long>(timeoutArr[0]);

            size_t chanMask = 0;
            int flags = 0;
            long long timeNs = 0;

            int ret = dev->readStreamStatus(
                info.stream, chanMask, flags, timeNs, timeoutUs);

            out[0] = f.createScalar(static_cast<int32_t>(ret));
            out[1] = f.createScalar(static_cast<int32_t>(chanMask));
            out[2] = f.createScalar(static_cast<int32_t>(flags));
            out[3] = f.createScalar(static_cast<int64_t>(timeNs));
        };
}
