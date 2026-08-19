classdef Device < handle
%DEVICE Interface to a SoapySDR device.
%   A Device object represents an open connection to a SoapySDR-
%   compatible SDR device. Use it to query and configure device
%   parameters such as frequency, gain, sample rate, and antennas.
%
%   CONSTRUCTION:
%       devices = soapysdr.enumerate();
%       dev = soapysdr.Device(devices{1});
%
%       dev = soapysdr.Device(driver="rtlsdr");
%
%   NOTES:
%       - Direction arguments use "RX" or "TX" (case-sensitive).
%       - Channel indices are zero-based, matching SoapySDR convention.
%       - Call delete(dev) to release the native device when done.
%
%   See also: soapysdr.enumerate

    properties (Access = private)
        pBackend
    end

    methods
        function obj = Device(varargin)
        %DEVICE Construct a Device from enumeration result or kwargs.
        %   dev = soapysdr.Device(devices{1}) constructs from a
        %   dictionary returned by soapysdr.enumerate.
        %
        %   dev = soapysdr.Device(driver="rtlsdr") constructs using
        %   name-value pairs specifying device identification.
        %
        %   dev = soapysdr.Device(Backend=backend) injects a custom
        %   DeviceBackend for testing (not for public use).
            [backend, kwargs] = parseConstructorArgs(varargin{:});
            if ~isempty(backend)
                obj.pBackend = backend;
            else
                obj.pBackend = ...
                    soapysdr.internal.MexDeviceBackend(kwargs);
            end
        end

        function delete(obj)
        %DELETE Release the native SoapySDR device.
        %   Calling delete multiple times is safe (idempotent).
            if ~isempty(obj.pBackend)
                obj.pBackend.delete();
                obj.pBackend = ...
                    soapysdr.internal.DeviceBackend.empty;
            end
        end

        % --- Identification ---

        function result = getDriverKey(obj)
        %GETDRIVERKEY Return the driver key for this device.
        %   KEY = dev.getDriverKey() returns a string identifying the
        %   SoapySDR driver module (e.g., "rtlsdr", "uhd").
            result = obj.pBackend.getDriverKey();
        end

        function result = getHardwareKey(obj)
        %GETHARDWAREKEY Return the hardware key for this device.
        %   KEY = dev.getHardwareKey() returns a string identifying the
        %   hardware platform.
            result = obj.pBackend.getHardwareKey();
        end

        function result = getHardwareInfo(obj)
        %GETHARDWAREINFO Return hardware info as a dictionary.
        %   INFO = dev.getHardwareInfo() returns a dictionary mapping
        %   string keys to string values with device-specific metadata.
            result = obj.pBackend.getHardwareInfo();
        end
    end

end

function [backend, kwargs] = parseConstructorArgs(varargin)
%PARSECONSTRUCTORARGS Parse Device constructor arguments.
%   Handles three forms:
%     1. Device(dictionary)      — from enumerate result
%     2. Device(key=val, ...)    — name-value pairs
%     3. Device(Backend=backend) — dependency injection

    backend = soapysdr.internal.DeviceBackend.empty;
    kwargs = string.empty(0, 2);

    if isempty(varargin)
        error("soapysdr:Device:InvalidArgs", ...
            "Device requires either a dictionary, " + ...
            "name-value pairs, or a Backend argument.");
    end

    if numel(varargin) == 1 && isa(varargin{1}, "dictionary")
        dict = varargin{1};
        keys = dict.keys();
        values = dict.values();
        kwargs = [keys(:), values(:)];
        return
    end

    if mod(numel(varargin), 2) == 0
        names = varargin(1:2:end);
        vals = varargin(2:2:end);

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
        return
    end

    error("soapysdr:Device:InvalidArgs", ...
        "Device requires either a dictionary, " + ...
        "name-value pairs, or a Backend argument.");
end
