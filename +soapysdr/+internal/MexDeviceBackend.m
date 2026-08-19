classdef MexDeviceBackend < soapysdr.internal.DeviceBackend
%MEXDEVICEBACKEND Concrete DeviceBackend that calls the SoapySDR MEX.

    properties (Access = private)
        pHandleId uint64 = uint64(0)
    end

    methods
        function obj = MexDeviceBackend(kwargs)
            obj.pHandleId = soapysdr.internal.soapysdr_mex("make", kwargs);
        end

        function delete(obj)
            if obj.pHandleId > 0
                soapysdr.internal.soapysdr_mex("unmake", obj.pHandleId);
                obj.pHandleId = uint64(0);
            end
        end

        % --- Identification ---

        function result = getDriverKey(obj)
            result = obj.mex("getDriverKey");
        end

        function result = getHardwareKey(obj)
            result = obj.mex("getHardwareKey");
        end

        function result = getHardwareInfo(obj)
            raw = obj.mex("getHardwareInfo");
            result = soapysdr.internal.kwargsToDictionary(raw);
        end

        % --- Channels ---

        function setFrontendMapping(obj, direction, mapping)
            obj.mex("setFrontendMapping", direction, mapping);
        end

        function result = getFrontendMapping(obj, direction)
            result = obj.mex("getFrontendMapping", direction);
        end

        function result = getNumChannels(obj, direction)
            result = obj.mex("getNumChannels", direction);
        end

        function result = getChannelInfo(obj, direction, channel)
            raw = obj.mex("getChannelInfo", direction, uint64(channel));
            result = soapysdr.internal.kwargsToDictionary(raw);
        end

        function result = getFullDuplex(obj, direction, channel)
            result = obj.mex("getFullDuplex", direction, uint64(channel));
        end

        % --- Stream Discovery ---

        function result = getStreamFormats(obj, direction, channel)
            result = obj.mex("getStreamFormats", direction, uint64(channel));
        end

        function [format, fullScale] = getNativeStreamFormat(obj, direction, channel)
            [format, fullScale] = soapysdr.internal.soapysdr_mex( ...
                "getNativeStreamFormat", obj.pHandleId, direction, uint64(channel));
        end

        function result = getStreamArgsInfo(obj, direction, channel)
            raw = obj.mex("getStreamArgsInfo", direction, uint64(channel));
            result = soapysdr.internal.structToArgInfoArray(raw);
        end

        % --- Antenna ---

        function result = listAntennas(obj, direction, channel)
            result = obj.mex("listAntennas", direction, uint64(channel));
        end

        function setAntenna(obj, direction, channel, name)
            obj.mex("setAntenna", direction, uint64(channel), name);
        end

        function result = getAntenna(obj, direction, channel)
            result = obj.mex("getAntenna", direction, uint64(channel));
        end

        % --- Frontend Corrections ---

        function result = hasDCOffsetMode(obj, direction, channel)
            result = obj.mex("hasDCOffsetMode", direction, uint64(channel));
        end

        function setDCOffsetMode(obj, direction, channel, automatic)
            obj.mex("setDCOffsetMode", direction, uint64(channel), automatic);
        end

        function result = getDCOffsetMode(obj, direction, channel)
            result = obj.mex("getDCOffsetMode", direction, uint64(channel));
        end

        function result = hasDCOffset(obj, direction, channel)
            result = obj.mex("hasDCOffset", direction, uint64(channel));
        end

        function setDCOffset(obj, direction, channel, offset)
            obj.mex("setDCOffset", direction, uint64(channel), real(offset), imag(offset));
        end

        function result = getDCOffset(obj, direction, channel)
            [re, im] = soapysdr.internal.soapysdr_mex( ...
                "getDCOffset", obj.pHandleId, direction, uint64(channel));
            result = complex(re, im);
        end

        function result = hasIQBalance(obj, direction, channel)
            result = obj.mex("hasIQBalance", direction, uint64(channel));
        end

        function setIQBalance(obj, direction, channel, balance)
            obj.mex("setIQBalance", direction, uint64(channel), real(balance), imag(balance));
        end

        function result = getIQBalance(obj, direction, channel)
            [re, im] = soapysdr.internal.soapysdr_mex( ...
                "getIQBalance", obj.pHandleId, direction, uint64(channel));
            result = complex(re, im);
        end

        function result = hasIQBalanceMode(obj, direction, channel)
            result = obj.mex("hasIQBalanceMode", direction, uint64(channel));
        end

        function setIQBalanceMode(obj, direction, channel, automatic)
            obj.mex("setIQBalanceMode", direction, uint64(channel), automatic);
        end

        function result = getIQBalanceMode(obj, direction, channel)
            result = obj.mex("getIQBalanceMode", direction, uint64(channel));
        end

        function result = hasFrequencyCorrection(obj, direction, channel)
            result = obj.mex("hasFrequencyCorrection", direction, uint64(channel));
        end

        function setFrequencyCorrection(obj, direction, channel, value)
            obj.mex("setFrequencyCorrection", direction, uint64(channel), value);
        end

        function result = getFrequencyCorrection(obj, direction, channel)
            result = obj.mex("getFrequencyCorrection", direction, uint64(channel));
        end

        % --- Gain ---

        function result = listGains(obj, direction, channel)
            result = obj.mex("listGains", direction, uint64(channel));
        end

        function result = hasGainMode(obj, direction, channel)
            result = obj.mex("hasGainMode", direction, uint64(channel));
        end

        function setGainMode(obj, direction, channel, automatic)
            obj.mex("setGainMode", direction, uint64(channel), automatic);
        end

        function result = getGainMode(obj, direction, channel)
            result = obj.mex("getGainMode", direction, uint64(channel));
        end

        function setGain(obj, direction, channel, value)
            obj.mex("setGain", direction, uint64(channel), value);
        end

        function setGainElement(obj, direction, channel, name, value)
            obj.mex("setGainElement", direction, uint64(channel), name, value);
        end

        function result = getGain(obj, direction, channel)
            result = obj.mex("getGain", direction, uint64(channel));
        end

        function result = getGainElement(obj, direction, channel, name)
            result = obj.mex("getGainElement", direction, uint64(channel), name);
        end

        function result = getGainRange(obj, direction, channel)
            raw = obj.mex("getGainRange", direction, uint64(channel));
            result = soapysdr.internal.structToRange(raw);
        end

        function result = getGainElementRange(obj, direction, channel, name)
            raw = obj.mex("getGainElementRange", direction, uint64(channel), name);
            result = soapysdr.internal.structToRange(raw);
        end

        % --- Frequency ---

        function setFrequency(obj, direction, channel, frequency, args)
            if isempty(args) || args.numEntries == 0
                obj.mex("setFrequency", direction, uint64(channel), frequency);
            else
                kwargs = [args.keys(:), args.values(:)];
                obj.mex("setFrequency", direction, uint64(channel), frequency, kwargs);
            end
        end

        function setFrequencyComponent(obj, direction, channel, name, frequency, args)
            if isempty(args) || args.numEntries == 0
                obj.mex("setFrequencyComponent", direction, uint64(channel), name, frequency);
            else
                kwargs = [args.keys(:), args.values(:)];
                obj.mex("setFrequencyComponent", direction, uint64(channel), name, frequency, kwargs);
            end
        end

        function result = getFrequency(obj, direction, channel)
            result = obj.mex("getFrequency", direction, uint64(channel));
        end

        function result = getFrequencyComponent(obj, direction, channel, name)
            result = obj.mex("getFrequencyComponent", direction, uint64(channel), name);
        end

        function result = listFrequencies(obj, direction, channel)
            result = obj.mex("listFrequencies", direction, uint64(channel));
        end

        function result = getFrequencyRange(obj, direction, channel)
            raw = obj.mex("getFrequencyRange", direction, uint64(channel));
            result = soapysdr.internal.structToRangeArray(raw);
        end

        function result = getFrequencyComponentRange(obj, direction, channel, name)
            raw = obj.mex("getFrequencyComponentRange", direction, uint64(channel), name);
            result = soapysdr.internal.structToRangeArray(raw);
        end

        function result = getFrequencyArgsInfo(obj, direction, channel)
            raw = obj.mex("getFrequencyArgsInfo", direction, uint64(channel));
            result = soapysdr.internal.structToArgInfoArray(raw);
        end

        % --- Sample Rate ---

        function setSampleRate(obj, direction, channel, rate)
            obj.mex("setSampleRate", direction, uint64(channel), rate);
        end

        function result = getSampleRate(obj, direction, channel)
            result = obj.mex("getSampleRate", direction, uint64(channel));
        end

        function result = getSampleRateRange(obj, direction, channel)
            raw = obj.mex("getSampleRateRange", direction, uint64(channel));
            result = soapysdr.internal.structToRangeArray(raw);
        end

        % --- Bandwidth ---

        function setBandwidth(obj, direction, channel, bw)
            obj.mex("setBandwidth", direction, uint64(channel), bw);
        end

        function result = getBandwidth(obj, direction, channel)
            result = obj.mex("getBandwidth", direction, uint64(channel));
        end

        function result = getBandwidthRange(obj, direction, channel)
            raw = obj.mex("getBandwidthRange", direction, uint64(channel));
            result = soapysdr.internal.structToRangeArray(raw);
        end

        % --- Clocking ---

        function setMasterClockRate(obj, rate)
            obj.mex("setMasterClockRate", rate);
        end

        function result = getMasterClockRate(obj)
            result = obj.mex("getMasterClockRate");
        end

        function result = getMasterClockRates(obj)
            raw = obj.mex("getMasterClockRates");
            result = soapysdr.internal.structToRangeArray(raw);
        end

        function setReferenceClockRate(obj, rate)
            obj.mex("setReferenceClockRate", rate);
        end

        function result = getReferenceClockRate(obj)
            result = obj.mex("getReferenceClockRate");
        end

        function result = getReferenceClockRates(obj)
            raw = obj.mex("getReferenceClockRates");
            result = soapysdr.internal.structToRangeArray(raw);
        end

        function result = listClockSources(obj)
            result = obj.mex("listClockSources");
        end

        function setClockSource(obj, source)
            obj.mex("setClockSource", source);
        end

        function result = getClockSource(obj)
            result = obj.mex("getClockSource");
        end

        % --- Time ---

        function result = listTimeSources(obj)
            result = obj.mex("listTimeSources");
        end

        function setTimeSource(obj, source)
            obj.mex("setTimeSource", source);
        end

        function result = getTimeSource(obj)
            result = obj.mex("getTimeSource");
        end

        function result = hasHardwareTime(obj, what)
            if what == ""
                result = obj.mex("hasHardwareTime");
            else
                result = obj.mex("hasHardwareTime", what);
            end
        end

        function result = getHardwareTime(obj, what)
            if what == ""
                result = obj.mex("getHardwareTime");
            else
                result = obj.mex("getHardwareTime", what);
            end
        end

        function setHardwareTime(obj, timeNs, what)
            if what == ""
                obj.mex("setHardwareTime", int64(timeNs));
            else
                obj.mex("setHardwareTime", int64(timeNs), what);
            end
        end

        % --- Sensors ---

        function result = listSensors(obj)
            result = obj.mex("listSensors");
        end

        function result = getSensorInfo(obj, key)
            raw = obj.mex("getSensorInfo", key);
            result = soapysdr.internal.structToArgInfo(raw);
        end

        function result = readSensor(obj, key)
            result = obj.mex("readSensor", key);
        end

        function result = listChannelSensors(obj, direction, channel)
            result = obj.mex("listChannelSensors", direction, uint64(channel));
        end

        function result = getChannelSensorInfo(obj, direction, channel, key)
            raw = obj.mex("getChannelSensorInfo", direction, uint64(channel), key);
            result = soapysdr.internal.structToArgInfo(raw);
        end

        function result = readChannelSensor(obj, direction, channel, key)
            result = obj.mex("readChannelSensor", direction, uint64(channel), key);
        end

        % --- Settings ---

        function result = getSettingInfo(obj)
            raw = obj.mex("getSettingInfo");
            result = soapysdr.internal.structToArgInfoArray(raw);
        end

        function result = getSettingInfoForKey(obj, key)
            raw = obj.mex("getSettingInfoForKey", key);
            result = soapysdr.internal.structToArgInfo(raw);
        end

        function writeSetting(obj, key, value)
            obj.mex("writeSetting", key, value);
        end

        function result = readSetting(obj, key)
            result = obj.mex("readSetting", key);
        end

        function result = getChannelSettingInfo(obj, direction, channel)
            raw = obj.mex("getChannelSettingInfo", direction, uint64(channel));
            result = soapysdr.internal.structToArgInfoArray(raw);
        end

        function result = getChannelSettingInfoForKey(obj, direction, channel, key)
            raw = obj.mex("getChannelSettingInfoForKey", direction, uint64(channel), key);
            result = soapysdr.internal.structToArgInfo(raw);
        end

        function writeChannelSetting(obj, direction, channel, key, value)
            obj.mex("writeChannelSetting", direction, uint64(channel), key, value);
        end

        function result = readChannelSetting(obj, direction, channel, key)
            result = obj.mex("readChannelSetting", direction, uint64(channel), key);
        end

        % --- GPIO ---

        function result = listGPIOBanks(obj)
            result = obj.mex("listGPIOBanks");
        end

        function writeGPIO(obj, bank, value, mask)
            if isempty(mask)
                obj.mex("writeGPIO", bank, uint32(value));
            else
                obj.mex("writeGPIO", bank, uint32(value), uint32(mask));
            end
        end

        function result = readGPIO(obj, bank)
            result = obj.mex("readGPIO", bank);
        end

        function writeGPIODir(obj, bank, dir, mask)
            if isempty(mask)
                obj.mex("writeGPIODir", bank, uint32(dir));
            else
                obj.mex("writeGPIODir", bank, uint32(dir), uint32(mask));
            end
        end

        function result = readGPIODir(obj, bank)
            result = obj.mex("readGPIODir", bank);
        end

        % --- Register ---

        function result = listRegisterInterfaces(obj)
            result = obj.mex("listRegisterInterfaces");
        end

        function writeRegister(obj, name, addr, value)
            obj.mex("writeRegister", name, uint32(addr), uint32(value));
        end

        function result = readRegister(obj, name, addr)
            result = obj.mex("readRegister", name, uint32(addr));
        end

        function writeRegisters(obj, name, addr, values)
            obj.mex("writeRegisters", name, uint32(addr), uint32(values));
        end

        function result = readRegisters(obj, name, addr, length)
            result = obj.mex("readRegisters", name, uint32(addr), uint64(length));
        end

        % --- I2C ---

        function writeI2C(obj, addr, data)
            obj.mex("writeI2C", int32(addr), uint8(data));
        end

        function result = readI2C(obj, addr, numBytes)
            result = obj.mex("readI2C", int32(addr), uint64(numBytes));
        end

        % --- SPI ---

        function result = transactSPI(obj, addr, data, numBits)
            result = obj.mex("transactSPI", int32(addr), uint32(data), uint64(numBits));
        end

        % --- UART ---

        function result = listUARTs(obj)
            result = obj.mex("listUARTs");
        end

        function writeUART(obj, which, data)
            obj.mex("writeUART", which, data);
        end

        function result = readUART(obj, which, timeoutUs)
            result = obj.mex("readUART", which, int64(timeoutUs));
        end

        % --- Streaming ---

        function streamHandle = setupStream(obj, direction, format, channels, args)
            if isempty(args) || (isa(args, "dictionary") && args.numEntries == 0)
                kwargs = strings(0, 2);
            else
                kwargs = [args.keys(:), args.values(:)];
            end
            streamHandle = soapysdr.internal.soapysdr_mex("setupStream", obj.pHandleId, direction, format, uint64(channels), kwargs);
        end

        function closeStream(obj, streamHandle)
            obj.mex("closeStream", uint64(streamHandle));
        end

        function result = getStreamMTU(obj, streamHandle)
            result = obj.mex("getStreamMTU", uint64(streamHandle));
        end

        function activateStream(obj, streamHandle, flags, timeNs, numElems)
            obj.mex("activateStream", uint64(streamHandle), int32(flags), int64(timeNs), int32(numElems));
        end

        function deactivateStream(obj, streamHandle, flags, timeNs)
            obj.mex("deactivateStream", uint64(streamHandle), int32(flags), int64(timeNs));
        end

        function [data, numRead, flags, timeNs] = readStream(obj, streamHandle, numElems, timeoutUs)
            [data, numRead, flags, timeNs] = soapysdr.internal.soapysdr_mex("readStream", obj.pHandleId, uint64(streamHandle), int64(numElems), int64(timeoutUs));
        end

        function numWritten = writeStream(obj, streamHandle, data, flags, timeNs, timeoutUs)
            numWritten = soapysdr.internal.soapysdr_mex("writeStream", obj.pHandleId, uint64(streamHandle), data, int32(flags), int64(timeNs), int64(timeoutUs));
        end

        function [ret, chanMask, flags, timeNs] = readStreamStatus(obj, streamHandle, timeoutUs)
            [ret, chanMask, flags, timeNs] = soapysdr.internal.soapysdr_mex("readStreamStatus", obj.pHandleId, uint64(streamHandle), int64(timeoutUs));
        end
    end

    methods (Access = private)
        function varargout = mex(obj, command, varargin)
            [varargout{1:nargout}] = soapysdr.internal.soapysdr_mex( ...
                command, obj.pHandleId, varargin{:});
        end
    end

end
