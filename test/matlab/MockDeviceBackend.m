classdef MockDeviceBackend < soapysdr.internal.DeviceBackend
%MOCKDEVICEBACKEND Test mock for DeviceBackend.
%   Records all method calls and returns configurable values.
%   Configure returns via the Returns property before calling methods.

    properties
        Calls cell = {}
        Returns struct = struct()
        DeleteCount (1,1) double = 0
        ConstructorArgs
    end

    methods
        function obj = setConstructorArgs(obj,kwargs)
            obj.ConstructorArgs = kwargs;
        end

        function delete(obj)
            obj.DeleteCount = obj.DeleteCount + 1;
        end

        function result = getDriverKey(obj)
            obj.Calls{end+1} = {"getDriverKey"};
            result = "mock_driver";
        end

        function result = getHardwareKey(obj)
            obj.Calls{end+1} = {"getHardwareKey"};
            result =  "mock_hw";
        end

        function result = getHardwareInfo(obj)
            obj.Calls{end+1} = {"getHardwareInfo"};
            result = dictionary(["serial", "revision"], ...
                           ["MOCK001", "v2"]);
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
