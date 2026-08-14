function devices = enumerate(mexInterface)
%ENUMERATE Discover SoapySDR devices and return as dictionaries.
%   DEVICES = soapysdr.internal.enumerate() enumerates all SoapySDR
%   devices and returns a cell array of dictionary objects, one per
%   discovered device. Each dictionary maps string keys to string
%   values.
%
%   DEVICES = soapysdr.internal.enumerate(MEXINTERFACE) uses the
%   specified MexInterface object for dependency injection during
%   testing.

    arguments
        mexInterface (1,1) soapysdr.internal.MexInterface = ...
            soapysdr.internal.MexBackend()
    end

    raw = mexInterface.enumerate();

    devices = cellfun(@(x) dictionary(x(:,1), x(:,2)), raw, ...
        UniformOutput=false);

end
