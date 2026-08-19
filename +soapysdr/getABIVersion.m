function version = getABIVersion()
%GETABIVERSION Return the SoapySDR ABI version string.
%   VERSION = soapysdr.getABIVersion() returns the ABI version that the
%   SoapySDR library was built against. This is used for binary
%   compatibility checking between the library and device modules.

    version = soapysdr.internal.soapysdr_mex("getABIVersion");

end
