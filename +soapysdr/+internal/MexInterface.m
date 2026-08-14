classdef (Abstract) MexInterface
%MEXINTERFACE Abstract interface for SoapySDR MEX function dispatch.
%   Subclass this to provide a concrete MEX backend or a test mock.

    methods (Abstract)
        raw = enumerate(obj)
        %ENUMERATE Enumerate SoapySDR devices.
        %   RAW = enumerate(OBJ) returns a cell array where each
        %   element is an N-by-2 string array of key-value pairs.
    end

end
