classdef MexBackend < soapysdr.internal.MexInterface
%MEXBACKEND Concrete MexInterface that calls the SoapySDR MEX file.

    methods
        function raw = enumerate(~)
        %ENUMERATE Call the MEX to enumerate SoapySDR devices.
            raw = soapysdr.internal.soapysdr_mex("enumerate");
        end
    end

end
