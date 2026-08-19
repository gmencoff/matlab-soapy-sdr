classdef Device < handle
%DEVICE Interface to a SoapySDR device.
%   A Device object represents an open connection to a SoapySDR-
%   compatible SDR device. Use it to query and configure device
%   parameters such as frequency, gain, sample rate, and antennas.
%
%   CONSTRUCTION:
%       devices = soapysdr.find();
%       dev = soapysdr.Device(devices{1});
%
%       dev = soapysdr.Device(driver="rtlsdr");
%
%   NOTES:
%       - Direction arguments use "RX" or "TX" (case-sensitive).
%       - Channel indices are zero-based, matching SoapySDR convention.
%       - Call delete(dev) to release the native device when done.
%
%   See also: soapysdr.find

    properties (Access = private)
        pBackend
    end

    methods
        function obj = Device(varargin)
        %DEVICE Construct a Device from enumeration result or kwargs.
        %   dev = soapysdr.Device(devices{1}) constructs from a
        %   dictionary returned by soapysdr.find.
        %
        %   dev = soapysdr.Device(driver="rtlsdr") constructs using
        %   name-value pairs specifying device identification.
        %
        %   dev = soapysdr.Device(Backend=backend) injects a custom
        %   DeviceBackend for testing (not for public use).
            obj.pBackend = parseConstructorArgs(varargin{:});
        end

        function delete(obj)
        %DELETE Release the native SoapySDR device.
        %   Calling delete multiple times is safe (idempotent).
            if ~isempty(obj.pBackend)
                obj.pBackend.delete();
                obj.pBackend = [];
            end
        end

        % --- Identification ---

        function result = getDriverKey(obj)
        %GETDRIVERKEY Return the driver key for this device.
            result = obj.pBackend.getDriverKey();
        end

        function result = getHardwareKey(obj)
        %GETHARDWAREKEY Return the hardware key for this device.
            result = obj.pBackend.getHardwareKey();
        end

        function result = getHardwareInfo(obj)
        %GETHARDWAREINFO Return hardware info as a dictionary.
            result = obj.pBackend.getHardwareInfo();
        end

        % --- Channels ---

        function setFrontendMapping(obj, direction, mapping)
        %SETFRONTENDMAPPING Set the frontend mapping.
            obj.pBackend.setFrontendMapping(direction, mapping);
        end

        function result = getFrontendMapping(obj, direction)
        %GETFRONTENDMAPPING Get the frontend mapping string.
            result = obj.pBackend.getFrontendMapping(direction);
        end

        function result = getNumChannels(obj, direction)
        %GETNUMCHANNELS Get the number of channels for a direction.
            result = obj.pBackend.getNumChannels(direction);
        end

        function result = getChannelInfo(obj, direction, channel)
        %GETCHANNELINFO Get channel info as a dictionary.
            result = obj.pBackend.getChannelInfo(direction, channel);
        end

        function result = getFullDuplex(obj, direction, channel)
        %GETFULLDUPLEX Query full-duplex support for a channel.
            result = obj.pBackend.getFullDuplex(direction, channel);
        end

        % --- Stream Discovery ---

        function result = getStreamFormats(obj, direction, channel)
        %GETSTREAMFORMATS List available stream formats.
            result = obj.pBackend.getStreamFormats(direction, channel);
        end

        function [format, fullScale] = getNativeStreamFormat(obj, direction, channel)
        %GETNATIVESTREAMFORMAT Get the native stream format.
            [format, fullScale] = obj.pBackend.getNativeStreamFormat(direction, channel);
        end

        function result = getStreamArgsInfo(obj, direction, channel)
        %GETSTREAMARGSINFO Get stream argument info.
            result = obj.pBackend.getStreamArgsInfo(direction, channel);
        end

        % --- Antenna ---

        function result = listAntennas(obj, direction, channel)
        %LISTANTENNAS List available antenna names.
            result = obj.pBackend.listAntennas(direction, channel);
        end

        function setAntenna(obj, direction, channel, name)
        %SETANTENNA Set the selected antenna.
            obj.pBackend.setAntenna(direction, channel, name);
        end

        function result = getAntenna(obj, direction, channel)
        %GETANTENNA Get the currently selected antenna.
            result = obj.pBackend.getAntenna(direction, channel);
        end

        % --- Frontend Corrections ---

        function result = hasDCOffsetMode(obj, direction, channel)
        %HASDCOFFSETMODE Query if automatic DC offset is supported.
            result = obj.pBackend.hasDCOffsetMode(direction, channel);
        end

        function setDCOffsetMode(obj, direction, channel, automatic)
        %SETDCOFFSETMODE Set automatic DC offset correction mode.
            obj.pBackend.setDCOffsetMode(direction, channel, automatic);
        end

        function result = getDCOffsetMode(obj, direction, channel)
        %GETDCOFFSETMODE Get automatic DC offset correction mode.
            result = obj.pBackend.getDCOffsetMode(direction, channel);
        end

        function result = hasDCOffset(obj, direction, channel)
        %HASDCOFFSET Query if manual DC offset is supported.
            result = obj.pBackend.hasDCOffset(direction, channel);
        end

        function setDCOffset(obj, direction, channel, offset)
        %SETDCOFFSET Set the DC offset correction (complex).
            obj.pBackend.setDCOffset(direction, channel, offset);
        end

        function result = getDCOffset(obj, direction, channel)
        %GETDCOFFSET Get the DC offset correction (complex).
            result = obj.pBackend.getDCOffset(direction, channel);
        end

        function result = hasIQBalance(obj, direction, channel)
        %HASIQBALANCE Query if IQ balance correction is supported.
            result = obj.pBackend.hasIQBalance(direction, channel);
        end

        function setIQBalance(obj, direction, channel, balance)
        %SETIQBALANCE Set IQ balance correction (complex).
            obj.pBackend.setIQBalance(direction, channel, balance);
        end

        function result = getIQBalance(obj, direction, channel)
        %GETIQBALANCE Get IQ balance correction (complex).
            result = obj.pBackend.getIQBalance(direction, channel);
        end

        function result = hasIQBalanceMode(obj, direction, channel)
        %HASIQBALANCEMODE Query if auto IQ balance is supported.
            result = obj.pBackend.hasIQBalanceMode(direction, channel);
        end

        function setIQBalanceMode(obj, direction, channel, automatic)
        %SETIQBALANCEMODE Set automatic IQ balance mode.
            obj.pBackend.setIQBalanceMode(direction, channel, automatic);
        end

        function result = getIQBalanceMode(obj, direction, channel)
        %GETIQBALANCEMODE Get automatic IQ balance mode.
            result = obj.pBackend.getIQBalanceMode(direction, channel);
        end

        function result = hasFrequencyCorrection(obj, direction, channel)
        %HASFREQUENCYCORRECTION Query frequency correction support.
            result = obj.pBackend.hasFrequencyCorrection(direction, channel);
        end

        function setFrequencyCorrection(obj, direction, channel, value)
        %SETFREQUENCYCORRECTION Set frequency correction in PPM.
            obj.pBackend.setFrequencyCorrection(direction, channel, value);
        end

        function result = getFrequencyCorrection(obj, direction, channel)
        %GETFREQUENCYCORRECTION Get frequency correction in PPM.
            result = obj.pBackend.getFrequencyCorrection(direction, channel);
        end

        % --- Gain ---

        function result = listGains(obj, direction, channel)
        %LISTGAINS List available gain element names.
            result = obj.pBackend.listGains(direction, channel);
        end

        function result = hasGainMode(obj, direction, channel)
        %HASGAINMODE Query if automatic gain mode is supported.
            result = obj.pBackend.hasGainMode(direction, channel);
        end

        function setGainMode(obj, direction, channel, automatic)
        %SETGAINMODE Set automatic gain control mode.
            obj.pBackend.setGainMode(direction, channel, automatic);
        end

        function result = getGainMode(obj, direction, channel)
        %GETGAINMODE Get automatic gain control mode.
            result = obj.pBackend.getGainMode(direction, channel);
        end

        function setGain(obj, direction, channel, valueOrName, value)
        %SETGAIN Set overall or element gain.
        %   dev.setGain("RX", 0, 30) sets overall gain to 30.
        %   dev.setGain("RX", 0, "LNA", 20) sets named element.
            if nargin == 4
                obj.pBackend.setGain(direction, channel, valueOrName);
            else
                obj.pBackend.setGainElement(direction, channel, valueOrName, value);
            end
        end

        function result = getGain(obj, direction, channel, name)
        %GETGAIN Get overall or element gain.
        %   val = dev.getGain("RX", 0) gets overall gain.
        %   val = dev.getGain("RX", 0, "LNA") gets named element.
            if nargin == 3
                result = obj.pBackend.getGain(direction, channel);
            else
                result = obj.pBackend.getGainElement(direction, channel, name);
            end
        end

        function result = getGainRange(obj, direction, channel, name)
        %GETGAINRANGE Get overall or element gain range.
        %   r = dev.getGainRange("RX", 0) gets overall range.
        %   r = dev.getGainRange("RX", 0, "LNA") gets element range.
            if nargin == 3
                result = obj.pBackend.getGainRange(direction, channel);
            else
                result = obj.pBackend.getGainElementRange(direction, channel, name);
            end
        end

        % --- Frequency ---

        function setFrequency(obj, direction, channel, frequencyOrName, varargin)
        %SETFREQUENCY Set overall or component frequency.
        %   dev.setFrequency("RX", 0, 1e9) sets overall.
        %   dev.setFrequency("RX", 0, 1e9, args) sets with kwargs.
        %   dev.setFrequency("RX", 0, "RF", 1e9) sets component.
        %   dev.setFrequency("RX", 0, "RF", 1e9, args) with kwargs.
            if isnumeric(frequencyOrName)
                freq = frequencyOrName;
                if isempty(varargin)
                    args = dictionary;
                else
                    args = varargin{1};
                end
                obj.pBackend.setFrequency(direction, channel, freq, args);
            else
                name = frequencyOrName;
                freq = varargin{1};
                if numel(varargin) < 2
                    args = dictionary;
                else
                    args = varargin{2};
                end
                obj.pBackend.setFrequencyComponent(direction, channel, name, freq, args);
            end
        end

        function result = getFrequency(obj, direction, channel, name)
        %GETFREQUENCY Get overall or component frequency.
        %   f = dev.getFrequency("RX", 0) gets overall.
        %   f = dev.getFrequency("RX", 0, "RF") gets component.
            if nargin == 3
                result = obj.pBackend.getFrequency(direction, channel);
            else
                result = obj.pBackend.getFrequencyComponent(direction, channel, name);
            end
        end

        function result = listFrequencies(obj, direction, channel)
        %LISTFREQUENCIES List tunable frequency component names.
            result = obj.pBackend.listFrequencies(direction, channel);
        end

        function result = getFrequencyRange(obj, direction, channel, name)
        %GETFREQUENCYRANGE Get overall or component frequency range.
        %   r = dev.getFrequencyRange("RX", 0) gets overall.
        %   r = dev.getFrequencyRange("RX", 0, "RF") gets component.
            if nargin == 3
                result = obj.pBackend.getFrequencyRange(direction, channel);
            else
                result = obj.pBackend.getFrequencyComponentRange(direction, channel, name);
            end
        end

        function result = getFrequencyArgsInfo(obj, direction, channel)
        %GETFREQUENCYARGSINFO Get frequency tuning argument info.
            result = obj.pBackend.getFrequencyArgsInfo(direction, channel);
        end

        % --- Sample Rate ---

        function setSampleRate(obj, direction, channel, rate)
        %SETSAMPLERATE Set the sample rate in Hz.
            obj.pBackend.setSampleRate(direction, channel, rate);
        end

        function result = getSampleRate(obj, direction, channel)
        %GETSAMPLERATE Get the sample rate in Hz.
            result = obj.pBackend.getSampleRate(direction, channel);
        end

        function result = getSampleRateRange(obj, direction, channel)
        %GETSAMPLERATERANGE Get available sample rate ranges.
            result = obj.pBackend.getSampleRateRange(direction, channel);
        end

        % --- Bandwidth ---

        function setBandwidth(obj, direction, channel, bw)
        %SETBANDWIDTH Set the baseband filter bandwidth in Hz.
            obj.pBackend.setBandwidth(direction, channel, bw);
        end

        function result = getBandwidth(obj, direction, channel)
        %GETBANDWIDTH Get the baseband filter bandwidth in Hz.
            result = obj.pBackend.getBandwidth(direction, channel);
        end

        function result = getBandwidthRange(obj, direction, channel)
        %GETBANDWIDTHRANGE Get available bandwidth ranges.
            result = obj.pBackend.getBandwidthRange(direction, channel);
        end

        % --- Clocking ---

        function setMasterClockRate(obj, rate)
        %SETMASTERCLOCKRATE Set the master clock rate in Hz.
            obj.pBackend.setMasterClockRate(rate);
        end

        function result = getMasterClockRate(obj)
        %GETMASTERCLOCKRATE Get the master clock rate in Hz.
            result = obj.pBackend.getMasterClockRate();
        end

        function result = getMasterClockRates(obj)
        %GETMASTERCLOCKRATES Get available master clock rate ranges.
            result = obj.pBackend.getMasterClockRates();
        end

        function setReferenceClockRate(obj, rate)
        %SETREFERENCECLOCKRATE Set the reference clock rate in Hz.
            obj.pBackend.setReferenceClockRate(rate);
        end

        function result = getReferenceClockRate(obj)
        %GETREFERENCECLOCKRATE Get the reference clock rate in Hz.
            result = obj.pBackend.getReferenceClockRate();
        end

        function result = getReferenceClockRates(obj)
        %GETREFERENCECLOCKRATES Get available reference clock ranges.
            result = obj.pBackend.getReferenceClockRates();
        end

        function result = listClockSources(obj)
        %LISTCLOCKSOURCES List available clock sources.
            result = obj.pBackend.listClockSources();
        end

        function setClockSource(obj, source)
        %SETCLOCKSOURCE Set the clock source.
            obj.pBackend.setClockSource(source);
        end

        function result = getClockSource(obj)
        %GETCLOCKSOURCE Get the current clock source.
            result = obj.pBackend.getClockSource();
        end

        % --- Time ---

        function result = listTimeSources(obj)
        %LISTTIMESOURCES List available time sources.
            result = obj.pBackend.listTimeSources();
        end

        function setTimeSource(obj, source)
        %SETTIMESOURCE Set the time source.
            obj.pBackend.setTimeSource(source);
        end

        function result = getTimeSource(obj)
        %GETTIMESOURCE Get the current time source.
            result = obj.pBackend.getTimeSource();
        end

        function result = hasHardwareTime(obj, what)
        %HASHARDWARETIME Query hardware time support.
        %   tf = dev.hasHardwareTime() checks default.
        %   tf = dev.hasHardwareTime("PPS") checks named source.
            if nargin < 2
                what = "";
            end
            result = obj.pBackend.hasHardwareTime(what);
        end

        function result = getHardwareTime(obj, what)
        %GETHARDWARETIME Get the hardware time in nanoseconds.
        %   t = dev.getHardwareTime() gets default.
        %   t = dev.getHardwareTime("PPS") gets named source.
            if nargin < 2
                what = "";
            end
            result = obj.pBackend.getHardwareTime(what);
        end

        function setHardwareTime(obj, timeNs, what)
        %SETHARDWARETIME Set the hardware time in nanoseconds.
        %   dev.setHardwareTime(t) sets default.
        %   dev.setHardwareTime(t, "PPS") sets named source.
            if nargin < 3
                what = "";
            end
            obj.pBackend.setHardwareTime(timeNs, what);
        end

        % --- Sensors ---

        function result = listSensors(obj)
        %LISTSENSORS List available device-level sensor names.
            result = obj.pBackend.listSensors();
        end

        function result = getSensorInfo(obj, key)
        %GETSENSORINFO Get info for a device-level sensor.
            result = obj.pBackend.getSensorInfo(key);
        end

        function result = readSensor(obj, key)
        %READSENSOR Read a device-level sensor value.
            result = obj.pBackend.readSensor(key);
        end

        function result = listChannelSensors(obj, direction, channel)
        %LISTCHANNELSENSORS List channel-level sensor names.
            result = obj.pBackend.listChannelSensors(direction, channel);
        end

        function result = getChannelSensorInfo(obj, direction, channel, key)
        %GETCHANNELSENSORINFO Get info for a channel-level sensor.
            result = obj.pBackend.getChannelSensorInfo(direction, channel, key);
        end

        function result = readChannelSensor(obj, direction, channel, key)
        %READCHANNELSENSOR Read a channel-level sensor value.
            result = obj.pBackend.readChannelSensor(direction, channel, key);
        end

        % --- Settings ---

        function result = getSettingInfo(obj)
        %GETSETTINGINFO Get info for all device-level settings.
            result = obj.pBackend.getSettingInfo();
        end

        function result = getSettingInfoForKey(obj, key)
        %GETSETTINGINFOFORKEY Get info for one device-level setting.
            result = obj.pBackend.getSettingInfoForKey(key);
        end

        function writeSetting(obj, key, value)
        %WRITESETTING Write a device-level setting value.
            obj.pBackend.writeSetting(key, value);
        end

        function result = readSetting(obj, key)
        %READSETTING Read a device-level setting value.
            result = obj.pBackend.readSetting(key);
        end

        function result = getChannelSettingInfo(obj, direction, channel)
        %GETCHANNELSETTINGINFO Get info for channel-level settings.
            result = obj.pBackend.getChannelSettingInfo(direction, channel);
        end

        function result = getChannelSettingInfoForKey(obj, direction, channel, key)
        %GETCHANNELSETTINGINFOFORKEY Get info for one channel setting.
            result = obj.pBackend.getChannelSettingInfoForKey(direction, channel, key);
        end

        function writeChannelSetting(obj, direction, channel, key, value)
        %WRITECHANNELSETTING Write a channel-level setting value.
            obj.pBackend.writeChannelSetting(direction, channel, key, value);
        end

        function result = readChannelSetting(obj, direction, channel, key)
        %READCHANNELSETTING Read a channel-level setting value.
            result = obj.pBackend.readChannelSetting(direction, channel, key);
        end

        % --- GPIO ---

        function result = listGPIOBanks(obj)
        %LISTGPIOBANKS List available GPIO bank names.
            result = obj.pBackend.listGPIOBanks();
        end

        function writeGPIO(obj, bank, value, mask)
        %WRITEGPIO Write GPIO value, optionally with mask.
        %   dev.writeGPIO("MAIN", 0xFF) writes all bits.
        %   dev.writeGPIO("MAIN", 0x01, 0x01) writes with mask.
            if nargin < 4
                mask = [];
            end
            obj.pBackend.writeGPIO(bank, value, mask);
        end

        function result = readGPIO(obj, bank)
        %READGPIO Read GPIO value for a bank.
            result = obj.pBackend.readGPIO(bank);
        end

        function writeGPIODir(obj, bank, dir, mask)
        %WRITEGPIODIR Write GPIO direction, optionally with mask.
            if nargin < 4
                mask = [];
            end
            obj.pBackend.writeGPIODir(bank, dir, mask);
        end

        function result = readGPIODir(obj, bank)
        %READGPIODIR Read GPIO direction for a bank.
            result = obj.pBackend.readGPIODir(bank);
        end

        % --- Register ---

        function result = listRegisterInterfaces(obj)
        %LISTREGISTERINTERFACES List register interface names.
            result = obj.pBackend.listRegisterInterfaces();
        end

        function writeRegister(obj, name, addr, value)
        %WRITEREGISTER Write a single register value.
            obj.pBackend.writeRegister(name, addr, value);
        end

        function result = readRegister(obj, name, addr)
        %READREGISTER Read a single register value.
            result = obj.pBackend.readRegister(name, addr);
        end

        function writeRegisters(obj, name, addr, values)
        %WRITEREGISTERS Write a block of register values.
            obj.pBackend.writeRegisters(name, addr, values);
        end

        function result = readRegisters(obj, name, addr, length)
        %READREGISTERS Read a block of register values.
            result = obj.pBackend.readRegisters(name, addr, length);
        end

        % --- I2C ---

        function writeI2C(obj, addr, data)
        %WRITEI2C Write data to an I2C device.
            obj.pBackend.writeI2C(addr, data);
        end

        function result = readI2C(obj, addr, numBytes)
        %READI2C Read data from an I2C device.
            result = obj.pBackend.readI2C(addr, numBytes);
        end

        % --- SPI ---

        function result = transactSPI(obj, addr, data, numBits)
        %TRANSACTSPI Perform an SPI transaction.
            result = obj.pBackend.transactSPI(addr, data, numBits);
        end

        % --- UART ---

        function result = listUARTs(obj)
        %LISTUARTS List available UART device names.
            result = obj.pBackend.listUARTs();
        end

        function writeUART(obj, which, data)
        %WRITEUART Write data to a UART.
            obj.pBackend.writeUART(which, data);
        end

        function result = readUART(obj, which, timeoutUs)
        %READUART Read data from a UART with timeout.
            result = obj.pBackend.readUART(which, timeoutUs);
        end

        % --- Streaming ---

        function streamHandle = setupStream(obj, direction, format, channels, args)
        %SETUPSTREAM Initialize a stream for RX or TX.
        %   h = dev.setupStream("RX", "CF32") opens channel 0.
        %   h = dev.setupStream("RX", "CF32", [0 1]) opens channels.
        %   h = dev.setupStream("RX", "CF32", 0, args) with kwargs.
            if nargin < 4
                channels = uint64(0);
            end
            if nargin < 5
                args = dictionary;
            end
            streamHandle = obj.pBackend.setupStream(direction, format, channels, args);
        end

        function closeStream(obj, streamHandle)
        %CLOSESTREAM Close an open stream and release resources.
            obj.pBackend.closeStream(streamHandle);
        end

        function result = getStreamMTU(obj, streamHandle)
        %GETSTREAMMTU Get the stream maximum transfer unit in elements.
            result = obj.pBackend.getStreamMTU(streamHandle);
        end

        function activateStream(obj, streamHandle, flags, timeNs, numElems)
        %ACTIVATESTREAM Activate a stream for I/O operations.
        %   dev.activateStream(h) activates with defaults.
        %   dev.activateStream(h, flags, timeNs, numElems) explicit.
            if nargin < 3
                flags = int32(0);
            end
            if nargin < 4
                timeNs = int64(0);
            end
            if nargin < 5
                numElems = int32(0);
            end
            obj.pBackend.activateStream(streamHandle, flags, timeNs, numElems);
        end

        function deactivateStream(obj, streamHandle, flags, timeNs)
        %DEACTIVATESTREAM Deactivate a stream.
        %   dev.deactivateStream(h) deactivates with defaults.
        %   dev.deactivateStream(h, flags, timeNs) explicit.
            if nargin < 3
                flags = int32(0);
            end
            if nargin < 4
                timeNs = int64(0);
            end
            obj.pBackend.deactivateStream(streamHandle, flags, timeNs);
        end

        function [data, numRead, flags, timeNs] = readStream(obj, streamHandle, numElems, timeoutUs)
        %READSTREAM Read samples from an RX stream.
        %   [data, numRead, flags, timeNs] = dev.readStream(h, 1024)
        %   data is numElems x numChannels. numRead may be negative
        %   (error code). See soapysdr.ErrorCode.
            if nargin < 4
                timeoutUs = int64(100000);
            end
            [data, numRead, flags, timeNs] = obj.pBackend.readStream(streamHandle, numElems, timeoutUs);
        end

        function numWritten = writeStream(obj, streamHandle, data, flags, timeNs, timeoutUs)
        %WRITESTREAM Write samples to a TX stream.
        %   numWritten = dev.writeStream(h, data)
        %   numWritten = dev.writeStream(h, data, flags, timeNs, timeoutUs)
        %   numWritten may be negative (error code).
            if nargin < 4
                flags = int32(0);
            end
            if nargin < 5
                timeNs = int64(0);
            end
            if nargin < 6
                timeoutUs = int64(100000);
            end
            numWritten = obj.pBackend.writeStream(streamHandle, data, flags, timeNs, timeoutUs);
        end

        function [ret, chanMask, flags, timeNs] = readStreamStatus(obj, streamHandle, timeoutUs)
        %READSTREAMSTATUS Read stream status (non-blocking by default).
        %   [ret, chanMask, flags, timeNs] = dev.readStreamStatus(h)
        %   [ret, chanMask, flags, timeNs] = dev.readStreamStatus(h, timeoutUs)
            if nargin < 3
                timeoutUs = int64(0);
            end
            [ret, chanMask, flags, timeNs] = obj.pBackend.readStreamStatus(streamHandle, timeoutUs);
        end
    end

end

function [backend] = parseConstructorArgs(varargin)
%PARSECONSTRUCTORARGS Parse Device constructor arguments.

    beidx = find(cellfun(@(x) (ischar(x) || (isstring(x) && isscalar(x))) && strcmp(string(x), "BackendConstructor"), varargin), 1);
    beInjected = ~isempty(beidx);
    if beInjected
        args = [varargin(1:beidx-1),varargin(beidx+2:end)];
        backendFcn = varargin{beidx+1};
    else
        args = varargin;
    end

    if ~isempty(args) && isscalar(args) && isa(args{1}, "dictionary")
        dict = args{1};
        keys = dict.keys();
        values = dict.values();
        kwargs = [keys(:), values(:)];
    elseif ~isempty(args) && mod(numel(args), 2) == 0
        names = args(1:2:end);
        vals = args(2:2:end);

        backendIdx = find(strcmp(names, "Backend"), 1);
        if ~isempty(backendIdx)
            backend = vals{backendIdx};
            return
        end

        kwargs = strings(numel(names), 2);
        for i = 1:numel(names)
            kwargs(i, 1) = string(names{i});
            kwargs(i, 2) = string(vals{i});
        end
    else
        kwargs = strings(0, 2);
    end

    if beInjected
        backend = backendFcn(kwargs);
    else
        backend = soapysdr.internal.MexDeviceBackend(kwargs);
    end
end
