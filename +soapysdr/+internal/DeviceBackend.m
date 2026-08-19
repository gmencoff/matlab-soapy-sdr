classdef (Abstract) DeviceBackend < handle
%DEVICEBACKEND Abstract interface for SoapySDR device operations.
%   Subclass this to provide a concrete device backend (MEX-based) or
%   a test mock. Each instance represents a single opened device.

    methods (Abstract)
        % --- Identification ---
        result = getDriverKey(obj)
        result = getHardwareKey(obj)
        result = getHardwareInfo(obj)

        % --- Channels ---
        setFrontendMapping(obj, direction, mapping)
        result = getFrontendMapping(obj, direction)
        result = getNumChannels(obj, direction)
        result = getChannelInfo(obj, direction, channel)
        result = getFullDuplex(obj, direction, channel)

        % --- Stream Discovery ---
        result = getStreamFormats(obj, direction, channel)
        [format, fullScale] = getNativeStreamFormat(obj, direction, channel)
        result = getStreamArgsInfo(obj, direction, channel)

        % --- Antenna ---
        result = listAntennas(obj, direction, channel)
        setAntenna(obj, direction, channel, name)
        result = getAntenna(obj, direction, channel)

        % --- Frontend Corrections ---
        result = hasDCOffsetMode(obj, direction, channel)
        setDCOffsetMode(obj, direction, channel, automatic)
        result = getDCOffsetMode(obj, direction, channel)
        result = hasDCOffset(obj, direction, channel)
        setDCOffset(obj, direction, channel, offset)
        result = getDCOffset(obj, direction, channel)
        result = hasIQBalance(obj, direction, channel)
        setIQBalance(obj, direction, channel, balance)
        result = getIQBalance(obj, direction, channel)
        result = hasIQBalanceMode(obj, direction, channel)
        setIQBalanceMode(obj, direction, channel, automatic)
        result = getIQBalanceMode(obj, direction, channel)
        result = hasFrequencyCorrection(obj, direction, channel)
        setFrequencyCorrection(obj, direction, channel, value)
        result = getFrequencyCorrection(obj, direction, channel)

        % --- Gain ---
        result = listGains(obj, direction, channel)
        result = hasGainMode(obj, direction, channel)
        setGainMode(obj, direction, channel, automatic)
        result = getGainMode(obj, direction, channel)
        setGain(obj, direction, channel, value)
        setGainElement(obj, direction, channel, name, value)
        result = getGain(obj, direction, channel)
        result = getGainElement(obj, direction, channel, name)
        result = getGainRange(obj, direction, channel)
        result = getGainElementRange(obj, direction, channel, name)

        % --- Frequency ---
        setFrequency(obj, direction, channel, frequency, args)
        setFrequencyComponent(obj, direction, channel, name, frequency, args)
        result = getFrequency(obj, direction, channel)
        result = getFrequencyComponent(obj, direction, channel, name)
        result = listFrequencies(obj, direction, channel)
        result = getFrequencyRange(obj, direction, channel)
        result = getFrequencyComponentRange(obj, direction, channel, name)
        result = getFrequencyArgsInfo(obj, direction, channel)

        % --- Sample Rate ---
        setSampleRate(obj, direction, channel, rate)
        result = getSampleRate(obj, direction, channel)
        result = getSampleRateRange(obj, direction, channel)

        % --- Bandwidth ---
        setBandwidth(obj, direction, channel, bw)
        result = getBandwidth(obj, direction, channel)
        result = getBandwidthRange(obj, direction, channel)

        % --- Clocking ---
        setMasterClockRate(obj, rate)
        result = getMasterClockRate(obj)
        result = getMasterClockRates(obj)
        setReferenceClockRate(obj, rate)
        result = getReferenceClockRate(obj)
        result = getReferenceClockRates(obj)
        result = listClockSources(obj)
        setClockSource(obj, source)
        result = getClockSource(obj)

        % --- Time ---
        result = listTimeSources(obj)
        setTimeSource(obj, source)
        result = getTimeSource(obj)
        result = hasHardwareTime(obj, what)
        result = getHardwareTime(obj, what)
        setHardwareTime(obj, timeNs, what)

        % --- Sensors ---
        result = listSensors(obj)
        result = getSensorInfo(obj, key)
        result = readSensor(obj, key)
        result = listChannelSensors(obj, direction, channel)
        result = getChannelSensorInfo(obj, direction, channel, key)
        result = readChannelSensor(obj, direction, channel, key)

        % --- Settings ---
        result = getSettingInfo(obj)
        result = getSettingInfoForKey(obj, key)
        writeSetting(obj, key, value)
        result = readSetting(obj, key)
        result = getChannelSettingInfo(obj, direction, channel)
        result = getChannelSettingInfoForKey(obj, direction, channel, key)
        writeChannelSetting(obj, direction, channel, key, value)
        result = readChannelSetting(obj, direction, channel, key)

        % --- GPIO ---
        result = listGPIOBanks(obj)
        writeGPIO(obj, bank, value, mask)
        result = readGPIO(obj, bank)
        writeGPIODir(obj, bank, dir, mask)
        result = readGPIODir(obj, bank)

        % --- Register ---
        result = listRegisterInterfaces(obj)
        writeRegister(obj, name, addr, value)
        result = readRegister(obj, name, addr)
        writeRegisters(obj, name, addr, values)
        result = readRegisters(obj, name, addr, length)

        % --- I2C ---
        writeI2C(obj, addr, data)
        result = readI2C(obj, addr, numBytes)

        % --- SPI ---
        result = transactSPI(obj, addr, data, numBits)

        % --- UART ---
        result = listUARTs(obj)
        writeUART(obj, which, data)
        result = readUART(obj, which, timeoutUs)

        % --- Streaming ---
        streamHandle = setupStream(obj, direction, format, channels, args)
        closeStream(obj, streamHandle)
        result = getStreamMTU(obj, streamHandle)
        activateStream(obj, streamHandle, flags, timeNs, numElems)
        deactivateStream(obj, streamHandle, flags, timeNs)
        [data, numRead, flags, timeNs] = readStream(obj, streamHandle, numElems, timeoutUs)
        numWritten = writeStream(obj, streamHandle, data, flags, timeNs, timeoutUs)
        [ret, chanMask, flags, timeNs] = readStreamStatus(obj, streamHandle, timeoutUs)
    end

end
