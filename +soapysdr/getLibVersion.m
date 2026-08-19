function version = getLibVersion()
%GETLIBVERSION Return the SoapySDR library version string.
%   VERSION = soapysdr.getLibVersion() returns the library build version
%   of SoapySDR as a string in "major.minor.patch-buildInfo" format.

    version = soapysdr.internal.soapysdr_mex("getLibVersion");

end
