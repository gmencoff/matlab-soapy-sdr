classdef MockDeviceBackend < soapysdr.internal.DeviceBackend
%MOCKDEVICEBACKEND Test mock for DeviceBackend.
%   Records all method calls and returns configurable values.
%   Configure returns via the Returns property before calling methods.

    properties
        Calls cell = {}
        Returns struct = struct()
        DeleteCount (1,1) double = 0
    end

    methods
        function delete(obj)
            obj.DeleteCount = obj.DeleteCount + 1;
        end

        function result = getDriverKey(obj)
            obj.Calls{end+1} = {"getDriverKey"};
            result = getReturn(obj, "getDriverKey");
        end

        function result = getHardwareKey(obj)
            obj.Calls{end+1} = {"getHardwareKey"};
            result = getReturn(obj, "getHardwareKey");
        end

        function result = getHardwareInfo(obj)
            obj.Calls{end+1} = {"getHardwareInfo"};
            result = getReturn(obj, "getHardwareInfo");
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
