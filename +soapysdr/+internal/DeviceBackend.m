classdef (Abstract) DeviceBackend < handle
%DEVICEBACKEND Abstract interface for SoapySDR device operations.
%   Subclass this to provide a concrete device backend (MEX-based) or
%   a test mock. Each instance represents a single opened device.
%
%   The production implementation is MexDeviceBackend, which holds a
%   native device handle and delegates to the soapysdr_mex binary.

    methods (Abstract)
        % --- Identification ---
        result = getDriverKey(obj)
        result = getHardwareKey(obj)
        result = getHardwareInfo(obj)
    end

end
