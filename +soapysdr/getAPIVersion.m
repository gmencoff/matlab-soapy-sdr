function version = getAPIVersion()
%GETAPIVERSION Return the SoapySDR API version string.
%   VERSION = soapysdr.getAPIVersion() returns the API version of the
%   SoapySDR library as a string in "major.minor.increment" format.

    version = soapysdr.internal.soapysdr_mex("getAPIVersion");

end
