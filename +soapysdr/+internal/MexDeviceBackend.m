classdef MexDeviceBackend < soapysdr.internal.DeviceBackend
%MEXDEVICEBACKEND Concrete DeviceBackend that calls the SoapySDR MEX.
%   Each instance holds a native device handle and delegates all
%   operations to soapysdr_mex. The handle is obtained via make() at
%   construction and released via unmake() at destruction.

    properties (Access = private)
        pHandleId uint64 = uint64(0)
    end

    methods
        function obj = MexDeviceBackend(kwargs)
        %MEXDEVICEBACKEND Construct by making a native SoapySDR device.
        %   OBJ = MexDeviceBackend(KWARGS) where KWARGS is an N-by-2
        %   string array of key-value pairs passed to SoapySDR::Device::make.
            obj.pHandleId = soapysdr.internal.soapysdr_mex( ...
                "make", kwargs);
        end

        function delete(obj)
        %DELETE Release the native SoapySDR device.
            if obj.pHandleId > 0
                soapysdr.internal.soapysdr_mex( ...
                    "unmake", obj.pHandleId);
                obj.pHandleId = uint64(0);
            end
        end

        % --- Identification ---

        function result = getDriverKey(obj)
            result = soapysdr.internal.soapysdr_mex( ...
                "getDriverKey", obj.pHandleId);
        end

        function result = getHardwareKey(obj)
            result = soapysdr.internal.soapysdr_mex( ...
                "getHardwareKey", obj.pHandleId);
        end

        function result = getHardwareInfo(obj)
            raw = soapysdr.internal.soapysdr_mex( ...
                "getHardwareInfo", obj.pHandleId);
            result = soapysdr.internal.kwargsToDictionary(raw);
        end
    end

end
