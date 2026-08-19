classdef MockDeviceBackend < soapysdr.internal.DeviceBackend
%MOCKDEVICEBACKEND Test mock for DeviceBackend.
%   Records all method calls and returns configurable values.
%   Configure returns via the Returns property before calling methods.

    properties
        Calls cell = {}
        Returns struct = struct( ...
            "getDriverKey", "mock_driver", ...
            "getHardwareKey", "mock_hw", ...
            "getHardwareInfo", dictionary(["serial", "revision"], ["MOCK001", "v2"]))
        DeleteCount (1,1) double = 0
        ConstructorArgs
    end

    methods
        function obj = setConstructorArgs(obj, kwargs)
            obj.ConstructorArgs = kwargs;
        end

        function delete(obj)
            obj.DeleteCount = obj.DeleteCount + 1;
        end

        % --- Identification ---

        function result = getDriverKey(obj)
            obj.Calls{end+1} = {"getDriverKey"};
            result = obj.getReturn("getDriverKey");
        end

        function result = getHardwareKey(obj)
            obj.Calls{end+1} = {"getHardwareKey"};
            result = obj.getReturn("getHardwareKey");
        end

        function result = getHardwareInfo(obj)
            obj.Calls{end+1} = {"getHardwareInfo"};
            result = obj.getReturn("getHardwareInfo");
        end

        % --- Channels ---

        function setFrontendMapping(obj, direction, mapping)
            obj.Calls{end+1} = { ...
                "setFrontendMapping", direction, mapping};
        end

        function result = getFrontendMapping(obj, direction)
            obj.Calls{end+1} = {"getFrontendMapping", direction};
            result = obj.getReturn("getFrontendMapping");
        end

        function result = getNumChannels(obj, direction)
            obj.Calls{end+1} = {"getNumChannels", direction};
            result = obj.getReturn("getNumChannels");
        end

        function result = getChannelInfo(obj, direction, channel)
            obj.Calls{end+1} = { ...
                "getChannelInfo", direction, channel};
            result = obj.getReturn("getChannelInfo");
        end

        function result = getFullDuplex(obj, direction, channel)
            obj.Calls{end+1} = { ...
                "getFullDuplex", direction, channel};
            result = obj.getReturn("getFullDuplex");
        end

        % --- Stream Discovery ---

        function result = getStreamFormats(obj, direction, channel)
            obj.Calls{end+1} = { ...
                "getStreamFormats", direction, channel};
            result = obj.getReturn("getStreamFormats");
        end

        function [format, fullScale] = getNativeStreamFormat( ...
                obj, direction, channel)
            obj.Calls{end+1} = { ...
                "getNativeStreamFormat", direction, channel};
            r = obj.getReturn("getNativeStreamFormat");
            format = r{1};
            fullScale = r{2};
        end

        function result = getStreamArgsInfo(obj, direction, channel)
            obj.Calls{end+1} = { ...
                "getStreamArgsInfo", direction, channel};
            result = obj.getReturn("getStreamArgsInfo");
        end

        % --- Antenna ---

        function result = listAntennas(obj, direction, channel)
            obj.Calls{end+1} = { ...
                "listAntennas", direction, channel};
            result = obj.getReturn("listAntennas");
        end

        function setAntenna(obj, direction, channel, name)
            obj.Calls{end+1} = { ...
                "setAntenna", direction, channel, name};
        end

        function result = getAntenna(obj, direction, channel)
            obj.Calls{end+1} = { ...
                "getAntenna", direction, channel};
            result = obj.getReturn("getAntenna");
        end

        % --- Frontend Corrections ---

        function result = hasDCOffsetMode(obj, direction, channel)
            obj.Calls{end+1} = { ...
                "hasDCOffsetMode", direction, channel};
            result = obj.getReturn("hasDCOffsetMode");
        end

        function setDCOffsetMode(obj, direction, channel, automatic)
            obj.Calls{end+1} = { ...
                "setDCOffsetMode", direction, channel, automatic};
        end

        function result = getDCOffsetMode(obj, direction, channel)
            obj.Calls{end+1} = { ...
                "getDCOffsetMode", direction, channel};
            result = obj.getReturn("getDCOffsetMode");
        end

        function result = hasDCOffset(obj, direction, channel)
            obj.Calls{end+1} = { ...
                "hasDCOffset", direction, channel};
            result = obj.getReturn("hasDCOffset");
        end

        function setDCOffset(obj, direction, channel, offset)
            obj.Calls{end+1} = { ...
                "setDCOffset", direction, channel, offset};
        end

        function result = getDCOffset(obj, direction, channel)
            obj.Calls{end+1} = { ...
                "getDCOffset", direction, channel};
            result = obj.getReturn("getDCOffset");
        end

        function result = hasIQBalance(obj, direction, channel)
            obj.Calls{end+1} = { ...
                "hasIQBalance", direction, channel};
            result = obj.getReturn("hasIQBalance");
        end

        function setIQBalance(obj, direction, channel, balance)
            obj.Calls{end+1} = { ...
                "setIQBalance", direction, channel, balance};
        end

        function result = getIQBalance(obj, direction, channel)
            obj.Calls{end+1} = { ...
                "getIQBalance", direction, channel};
            result = obj.getReturn("getIQBalance");
        end

        function result = hasIQBalanceMode(obj, direction, channel)
            obj.Calls{end+1} = { ...
                "hasIQBalanceMode", direction, channel};
            result = obj.getReturn("hasIQBalanceMode");
        end

        function setIQBalanceMode(obj, direction, channel, automatic)
            obj.Calls{end+1} = { ...
                "setIQBalanceMode", direction, channel, automatic};
        end

        function result = getIQBalanceMode(obj, direction, channel)
            obj.Calls{end+1} = { ...
                "getIQBalanceMode", direction, channel};
            result = obj.getReturn("getIQBalanceMode");
        end

        function result = hasFrequencyCorrection( ...
                obj, direction, channel)
            obj.Calls{end+1} = { ...
                "hasFrequencyCorrection", direction, channel};
            result = obj.getReturn("hasFrequencyCorrection");
        end

        function setFrequencyCorrection( ...
                obj, direction, channel, value)
            obj.Calls{end+1} = { ...
                "setFrequencyCorrection", direction, channel, value};
        end

        function result = getFrequencyCorrection( ...
                obj, direction, channel)
            obj.Calls{end+1} = { ...
                "getFrequencyCorrection", direction, channel};
            result = obj.getReturn("getFrequencyCorrection");
        end

        % --- Gain ---

        function result = listGains(obj, direction, channel)
            obj.Calls{end+1} = {"listGains", direction, channel};
            result = obj.getReturn("listGains");
        end

        function result = hasGainMode(obj, direction, channel)
            obj.Calls{end+1} = {"hasGainMode", direction, channel};
            result = obj.getReturn("hasGainMode");
        end

        function setGainMode(obj, direction, channel, automatic)
            obj.Calls{end+1} = { ...
                "setGainMode", direction, channel, automatic};
        end

        function result = getGainMode(obj, direction, channel)
            obj.Calls{end+1} = {"getGainMode", direction, channel};
            result = obj.getReturn("getGainMode");
        end

        function setGain(obj, direction, channel, value)
            obj.Calls{end+1} = { ...
                "setGain", direction, channel, value};
        end

        function setGainElement(obj, direction, channel, name, value)
            obj.Calls{end+1} = { ...
                "setGainElement", direction, channel, name, value};
        end

        function result = getGain(obj, direction, channel)
            obj.Calls{end+1} = {"getGain", direction, channel};
            result = obj.getReturn("getGain");
        end

        function result = getGainElement( ...
                obj, direction, channel, name)
            obj.Calls{end+1} = { ...
                "getGainElement", direction, channel, name};
            result = obj.getReturn("getGainElement");
        end

        function result = getGainRange(obj, direction, channel)
            obj.Calls{end+1} = { ...
                "getGainRange", direction, channel};
            result = obj.getReturn("getGainRange");
        end

        function result = getGainElementRange( ...
                obj, direction, channel, name)
            obj.Calls{end+1} = { ...
                "getGainElementRange", direction, channel, name};
            result = obj.getReturn("getGainElementRange");
        end

        % --- Frequency ---

        function setFrequency( ...
                obj, direction, channel, frequency, args)
            obj.Calls{end+1} = { ...
                "setFrequency", direction, channel, ...
                frequency, args};
        end

        function setFrequencyComponent( ...
                obj, direction, channel, name, frequency, args)
            obj.Calls{end+1} = { ...
                "setFrequencyComponent", direction, channel, ...
                name, frequency, args};
        end

        function result = getFrequency(obj, direction, channel)
            obj.Calls{end+1} = { ...
                "getFrequency", direction, channel};
            result = obj.getReturn("getFrequency");
        end

        function result = getFrequencyComponent( ...
                obj, direction, channel, name)
            obj.Calls{end+1} = { ...
                "getFrequencyComponent", direction, channel, name};
            result = obj.getReturn("getFrequencyComponent");
        end

        function result = listFrequencies(obj, direction, channel)
            obj.Calls{end+1} = { ...
                "listFrequencies", direction, channel};
            result = obj.getReturn("listFrequencies");
        end

        function result = getFrequencyRange(obj, direction, channel)
            obj.Calls{end+1} = { ...
                "getFrequencyRange", direction, channel};
            result = obj.getReturn("getFrequencyRange");
        end

        function result = getFrequencyComponentRange( ...
                obj, direction, channel, name)
            obj.Calls{end+1} = { ...
                "getFrequencyComponentRange", direction, ...
                channel, name};
            result = obj.getReturn("getFrequencyComponentRange");
        end

        function result = getFrequencyArgsInfo( ...
                obj, direction, channel)
            obj.Calls{end+1} = { ...
                "getFrequencyArgsInfo", direction, channel};
            result = obj.getReturn("getFrequencyArgsInfo");
        end

        % --- Sample Rate ---

        function setSampleRate(obj, direction, channel, rate)
            obj.Calls{end+1} = { ...
                "setSampleRate", direction, channel, rate};
        end

        function result = getSampleRate(obj, direction, channel)
            obj.Calls{end+1} = { ...
                "getSampleRate", direction, channel};
            result = obj.getReturn("getSampleRate");
        end

        function result = getSampleRateRange(obj, direction, channel)
            obj.Calls{end+1} = { ...
                "getSampleRateRange", direction, channel};
            result = obj.getReturn("getSampleRateRange");
        end

        % --- Bandwidth ---

        function setBandwidth(obj, direction, channel, bw)
            obj.Calls{end+1} = { ...
                "setBandwidth", direction, channel, bw};
        end

        function result = getBandwidth(obj, direction, channel)
            obj.Calls{end+1} = { ...
                "getBandwidth", direction, channel};
            result = obj.getReturn("getBandwidth");
        end

        function result = getBandwidthRange(obj, direction, channel)
            obj.Calls{end+1} = { ...
                "getBandwidthRange", direction, channel};
            result = obj.getReturn("getBandwidthRange");
        end

        % --- Clocking ---

        function setMasterClockRate(obj, rate)
            obj.Calls{end+1} = {"setMasterClockRate", rate};
        end

        function result = getMasterClockRate(obj)
            obj.Calls{end+1} = {"getMasterClockRate"};
            result = obj.getReturn("getMasterClockRate");
        end

        function result = getMasterClockRates(obj)
            obj.Calls{end+1} = {"getMasterClockRates"};
            result = obj.getReturn("getMasterClockRates");
        end

        function setReferenceClockRate(obj, rate)
            obj.Calls{end+1} = {"setReferenceClockRate", rate};
        end

        function result = getReferenceClockRate(obj)
            obj.Calls{end+1} = {"getReferenceClockRate"};
            result = obj.getReturn("getReferenceClockRate");
        end

        function result = getReferenceClockRates(obj)
            obj.Calls{end+1} = {"getReferenceClockRates"};
            result = obj.getReturn("getReferenceClockRates");
        end

        function result = listClockSources(obj)
            obj.Calls{end+1} = {"listClockSources"};
            result = obj.getReturn("listClockSources");
        end

        function setClockSource(obj, source)
            obj.Calls{end+1} = {"setClockSource", source};
        end

        function result = getClockSource(obj)
            obj.Calls{end+1} = {"getClockSource"};
            result = obj.getReturn("getClockSource");
        end

        % --- Time ---

        function result = listTimeSources(obj)
            obj.Calls{end+1} = {"listTimeSources"};
            result = obj.getReturn("listTimeSources");
        end

        function setTimeSource(obj, source)
            obj.Calls{end+1} = {"setTimeSource", source};
        end

        function result = getTimeSource(obj)
            obj.Calls{end+1} = {"getTimeSource"};
            result = obj.getReturn("getTimeSource");
        end

        function result = hasHardwareTime(obj, what)
            obj.Calls{end+1} = {"hasHardwareTime", what};
            result = obj.getReturn("hasHardwareTime");
        end

        function result = getHardwareTime(obj, what)
            obj.Calls{end+1} = {"getHardwareTime", what};
            result = obj.getReturn("getHardwareTime");
        end

        function setHardwareTime(obj, timeNs, what)
            obj.Calls{end+1} = {"setHardwareTime", timeNs, what};
        end

        % --- Sensors ---

        function result = listSensors(obj)
            obj.Calls{end+1} = {"listSensors"};
            result = obj.getReturn("listSensors");
        end

        function result = getSensorInfo(obj, key)
            obj.Calls{end+1} = {"getSensorInfo", key};
            result = obj.getReturn("getSensorInfo");
        end

        function result = readSensor(obj, key)
            obj.Calls{end+1} = {"readSensor", key};
            result = obj.getReturn("readSensor");
        end

        function result = listChannelSensors( ...
                obj, direction, channel)
            obj.Calls{end+1} = { ...
                "listChannelSensors", direction, channel};
            result = obj.getReturn("listChannelSensors");
        end

        function result = getChannelSensorInfo( ...
                obj, direction, channel, key)
            obj.Calls{end+1} = { ...
                "getChannelSensorInfo", direction, channel, key};
            result = obj.getReturn("getChannelSensorInfo");
        end

        function result = readChannelSensor( ...
                obj, direction, channel, key)
            obj.Calls{end+1} = { ...
                "readChannelSensor", direction, channel, key};
            result = obj.getReturn("readChannelSensor");
        end

        % --- Settings ---

        function result = getSettingInfo(obj)
            obj.Calls{end+1} = {"getSettingInfo"};
            result = obj.getReturn("getSettingInfo");
        end

        function result = getSettingInfoForKey(obj, key)
            obj.Calls{end+1} = {"getSettingInfoForKey", key};
            result = obj.getReturn("getSettingInfoForKey");
        end

        function writeSetting(obj, key, value)
            obj.Calls{end+1} = {"writeSetting", key, value};
        end

        function result = readSetting(obj, key)
            obj.Calls{end+1} = {"readSetting", key};
            result = obj.getReturn("readSetting");
        end

        function result = getChannelSettingInfo( ...
                obj, direction, channel)
            obj.Calls{end+1} = { ...
                "getChannelSettingInfo", direction, channel};
            result = obj.getReturn("getChannelSettingInfo");
        end

        function result = getChannelSettingInfoForKey( ...
                obj, direction, channel, key)
            obj.Calls{end+1} = { ...
                "getChannelSettingInfoForKey", direction, ...
                channel, key};
            result = obj.getReturn("getChannelSettingInfoForKey");
        end

        function writeChannelSetting( ...
                obj, direction, channel, key, value)
            obj.Calls{end+1} = { ...
                "writeChannelSetting", direction, channel, ...
                key, value};
        end

        function result = readChannelSetting( ...
                obj, direction, channel, key)
            obj.Calls{end+1} = { ...
                "readChannelSetting", direction, channel, key};
            result = obj.getReturn("readChannelSetting");
        end

        % --- GPIO ---

        function result = listGPIOBanks(obj)
            obj.Calls{end+1} = {"listGPIOBanks"};
            result = obj.getReturn("listGPIOBanks");
        end

        function writeGPIO(obj, bank, value, mask)
            obj.Calls{end+1} = { ...
                "writeGPIO", bank, value, mask};
        end

        function result = readGPIO(obj, bank)
            obj.Calls{end+1} = {"readGPIO", bank};
            result = obj.getReturn("readGPIO");
        end

        function writeGPIODir(obj, bank, dir, mask)
            obj.Calls{end+1} = { ...
                "writeGPIODir", bank, dir, mask};
        end

        function result = readGPIODir(obj, bank)
            obj.Calls{end+1} = {"readGPIODir", bank};
            result = obj.getReturn("readGPIODir");
        end

        % --- Register ---

        function result = listRegisterInterfaces(obj)
            obj.Calls{end+1} = {"listRegisterInterfaces"};
            result = obj.getReturn("listRegisterInterfaces");
        end

        function writeRegister(obj, name, addr, value)
            obj.Calls{end+1} = { ...
                "writeRegister", name, addr, value};
        end

        function result = readRegister(obj, name, addr)
            obj.Calls{end+1} = {"readRegister", name, addr};
            result = obj.getReturn("readRegister");
        end

        function writeRegisters(obj, name, addr, values)
            obj.Calls{end+1} = { ...
                "writeRegisters", name, addr, values};
        end

        function result = readRegisters(obj, name, addr, length)
            obj.Calls{end+1} = { ...
                "readRegisters", name, addr, length};
            result = obj.getReturn("readRegisters");
        end

        % --- I2C ---

        function writeI2C(obj, addr, data)
            obj.Calls{end+1} = {"writeI2C", addr, data};
        end

        function result = readI2C(obj, addr, numBytes)
            obj.Calls{end+1} = {"readI2C", addr, numBytes};
            result = obj.getReturn("readI2C");
        end

        % --- SPI ---

        function result = transactSPI(obj, addr, data, numBits)
            obj.Calls{end+1} = { ...
                "transactSPI", addr, data, numBits};
            result = obj.getReturn("transactSPI");
        end

        % --- UART ---

        function result = listUARTs(obj)
            obj.Calls{end+1} = {"listUARTs"};
            result = obj.getReturn("listUARTs");
        end

        function writeUART(obj, which, data)
            obj.Calls{end+1} = {"writeUART", which, data};
        end

        function result = readUART(obj, which, timeoutUs)
            obj.Calls{end+1} = {"readUART", which, timeoutUs};
            result = obj.getReturn("readUART");
        end

        % --- Streaming ---

        function streamHandle = setupStream(obj, direction, format, channels, args)
            obj.Calls{end+1} = {"setupStream", direction, format, channels, args};
            streamHandle = obj.getReturn("setupStream");
        end

        function closeStream(obj, streamHandle)
            obj.Calls{end+1} = {"closeStream", streamHandle};
        end

        function result = getStreamMTU(obj, streamHandle)
            obj.Calls{end+1} = {"getStreamMTU", streamHandle};
            result = obj.getReturn("getStreamMTU");
        end

        function activateStream(obj, streamHandle, flags, timeNs, numElems)
            obj.Calls{end+1} = {"activateStream", streamHandle, flags, timeNs, numElems};
        end

        function deactivateStream(obj, streamHandle, flags, timeNs)
            obj.Calls{end+1} = {"deactivateStream", streamHandle, flags, timeNs};
        end

        function [data, numRead, flags, timeNs] = readStream(obj, streamHandle, numElems, timeoutUs)
            obj.Calls{end+1} = {"readStream", streamHandle, numElems, timeoutUs};
            r = obj.getReturn("readStream");
            data = r{1};
            numRead = r{2};
            flags = r{3};
            timeNs = r{4};
        end

        function numWritten = writeStream(obj, streamHandle, data, flags, timeNs, timeoutUs)
            obj.Calls{end+1} = {"writeStream", streamHandle, data, flags, timeNs, timeoutUs};
            numWritten = obj.getReturn("writeStream");
        end

        function [ret, chanMask, flags, timeNs] = readStreamStatus(obj, streamHandle, timeoutUs)
            obj.Calls{end+1} = {"readStreamStatus", streamHandle, timeoutUs};
            r = obj.getReturn("readStreamStatus");
            ret = r{1};
            chanMask = r{2};
            flags = r{3};
            timeNs = r{4};
        end
    end

    methods (Access = private)
        function result = getReturn(obj, methodName)
            if isfield(obj.Returns, methodName)
                result = obj.Returns.(methodName);
            else
                error("soapysdr:test:NotConfigured", ...
                    "MockDeviceBackend: no return value " + ...
                    "configured for '%s'.", methodName);
            end
        end
    end

end
