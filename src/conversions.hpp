#pragma once

#include "mex.hpp"

#include <SoapySDR/Device.hpp>
#include <SoapySDR/Types.hpp>
#include <SoapySDR/Constants.h>

#include <string>
#include <vector>
#include <complex>

using namespace matlab::data;

// --- String conversions ---

inline std::string toStdString(const StringArray& arr, size_t index) {
    std::u16string u16 = arr[index];
    return std::string(u16.begin(), u16.end());
}

inline std::string toStdString(const Array& arr) {
    StringArray strArr = arr;
    std::u16string u16 = strArr[0];
    return std::string(u16.begin(), u16.end());
}

inline Array toMatlabString(ArrayFactory& factory, const std::string& s) {
    return factory.createScalar(s);
}

inline Array toMatlabStringArray(
        ArrayFactory& factory,
        const std::vector<std::string>& vec) {
    if (vec.empty()) {
        return factory.createArray<MATLABString>({1, 0});
    }
    StringArray result = factory.createArray<MATLABString>(
        {1, vec.size()});
    for (size_t i = 0; i < vec.size(); i++) {
        result[0][i] = MATLABString(std::u16string(
            vec[i].begin(), vec[i].end()));
    }
    return result;
}

// --- Kwargs conversions ---

inline SoapySDR::Kwargs toKwargs(const Array& arr) {
    SoapySDR::Kwargs kwargs;
    if (arr.getNumberOfElements() == 0) {
        return kwargs;
    }
    StringArray strArr = arr;
    size_t numRows = strArr.getDimensions()[0];
    for (size_t i = 0; i < numRows; i++) {
        std::u16string u16key = strArr[i][0];
        std::u16string u16val = strArr[i][1];
        std::string key(u16key.begin(), u16key.end());
        std::string val(u16val.begin(), u16val.end());
        kwargs[key] = val;
    }
    return kwargs;
}

inline Array kwargsToMatlab(
        ArrayFactory& factory,
        const SoapySDR::Kwargs& kwargs) {
    size_t n = kwargs.size();
    if (n == 0) {
        return factory.createArray<MATLABString>({0, 2});
    }
    StringArray result = factory.createArray<MATLABString>({n, 2});
    size_t i = 0;
    for (const auto& kv : kwargs) {
        result[i][0] = MATLABString(
            std::u16string(kv.first.begin(), kv.first.end()));
        result[i][1] = MATLABString(
            std::u16string(kv.second.begin(), kv.second.end()));
        i++;
    }
    return result;
}

// --- Direction conversion ---

inline int directionToSoapy(const std::string& dir) {
    if (dir == "RX") return SOAPY_SDR_RX;
    if (dir == "TX") return SOAPY_SDR_TX;
    throw std::invalid_argument("Direction must be \"RX\" or \"TX\".");
}

// --- Range conversions ---

inline Array rangeToMatlab(
        ArrayFactory& factory,
        const SoapySDR::Range& range) {
    StructArray result = factory.createStructArray(
        {1, 1}, {"Minimum", "Maximum", "Step"});
    result[0]["Minimum"] = factory.createScalar(range.minimum());
    result[0]["Maximum"] = factory.createScalar(range.maximum());
    result[0]["Step"] = factory.createScalar(range.step());
    return result;
}

inline Array rangeListToMatlab(
        ArrayFactory& factory,
        const SoapySDR::RangeList& ranges) {
    if (ranges.empty()) {
        return factory.createStructArray(
            {1, 0}, {"Minimum", "Maximum", "Step"});
    }
    StructArray result = factory.createStructArray(
        {1, ranges.size()}, {"Minimum", "Maximum", "Step"});
    for (size_t i = 0; i < ranges.size(); i++) {
        result[i]["Minimum"] = factory.createScalar(
            ranges[i].minimum());
        result[i]["Maximum"] = factory.createScalar(
            ranges[i].maximum());
        result[i]["Step"] = factory.createScalar(ranges[i].step());
    }
    return result;
}

// --- ArgInfo conversions ---

inline std::string argTypeToString(SoapySDR::ArgInfo::Type type) {
    switch (type) {
        case SoapySDR::ArgInfo::BOOL:   return "bool";
        case SoapySDR::ArgInfo::INT:    return "int";
        case SoapySDR::ArgInfo::FLOAT:  return "float";
        case SoapySDR::ArgInfo::STRING: return "string";
        default: return "";
    }
}

inline Array argInfoToMatlab(
        ArrayFactory& factory,
        const SoapySDR::ArgInfo& info) {
    StructArray result = factory.createStructArray(
        {1, 1},
        {"Key", "Value", "Name", "Description", "Units",
         "Type", "Range", "Options", "OptionNames"});

    result[0]["Key"] = factory.createScalar(info.key);
    result[0]["Value"] = factory.createScalar(info.value);
    result[0]["Name"] = factory.createScalar(info.name);
    result[0]["Description"] = factory.createScalar(info.description);
    result[0]["Units"] = factory.createScalar(info.units);
    result[0]["Type"] = factory.createScalar(argTypeToString(info.type));
    result[0]["Range"] = rangeToMatlab(factory, info.range);
    result[0]["Options"] = toMatlabStringArray(factory, info.options);
    result[0]["OptionNames"] = toMatlabStringArray(
        factory, info.optionNames);

    return result;
}

inline Array argInfoListToMatlab(
        ArrayFactory& factory,
        const SoapySDR::ArgInfoList& infoList) {
    if (infoList.empty()) {
        return factory.createStructArray(
            {1, 0},
            {"Key", "Value", "Name", "Description", "Units",
             "Type", "Range", "Options", "OptionNames"});
    }
    StructArray result = factory.createStructArray(
        {1, infoList.size()},
        {"Key", "Value", "Name", "Description", "Units",
         "Type", "Range", "Options", "OptionNames"});

    for (size_t i = 0; i < infoList.size(); i++) {
        const auto& info = infoList[i];
        result[i]["Key"] = factory.createScalar(info.key);
        result[i]["Value"] = factory.createScalar(info.value);
        result[i]["Name"] = factory.createScalar(info.name);
        result[i]["Description"] = factory.createScalar(
            info.description);
        result[i]["Units"] = factory.createScalar(info.units);
        result[i]["Type"] = factory.createScalar(
            argTypeToString(info.type));
        result[i]["Range"] = rangeToMatlab(factory, info.range);
        result[i]["Options"] = toMatlabStringArray(
            factory, info.options);
        result[i]["OptionNames"] = toMatlabStringArray(
            factory, info.optionNames);
    }
    return result;
}

// --- Stream format info ---

struct FormatInfo {
    ArrayType arrayType;
    bool isComplex;
    size_t elemBytes;
};

inline FormatInfo getFormatInfo(const std::string& format) {
    if (format == "CF32") return {ArrayType::SINGLE, true, 8};
    if (format == "CF64") return {ArrayType::DOUBLE, true, 16};
    if (format == "CS32") return {ArrayType::INT32, true, 8};
    if (format == "CS16") return {ArrayType::INT16, true, 4};
    if (format == "CS8")  return {ArrayType::INT8, true, 2};
    if (format == "CU16") return {ArrayType::UINT16, true, 4};
    if (format == "CU8")  return {ArrayType::UINT8, true, 2};
    if (format == "F32")  return {ArrayType::SINGLE, false, 4};
    if (format == "F64")  return {ArrayType::DOUBLE, false, 8};
    if (format == "S16")  return {ArrayType::INT16, false, 2};
    if (format == "S8")   return {ArrayType::INT8, false, 1};
    if (format == "U8")   return {ArrayType::UINT8, false, 1};
    return {ArrayType::SINGLE, true, 8};
}

// --- Numeric conversions ---

inline uint64_t toUint64(const Array& arr) {
    TypedArray<uint64_t> typed = arr;
    return typed[0];
}

inline Array toMatlabUint64(ArrayFactory& factory, uint64_t val) {
    return factory.createScalar(val);
}
