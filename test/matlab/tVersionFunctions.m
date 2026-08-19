classdef tVersionFunctions < matlab.unittest.TestCase
%TVERSIONFUNCTIONS Integration tests for soapysdr version functions.
%   These tests require the compiled MEX binary and SoapySDR library.

    methods (Test)
        function getAPIVersionReturnsNonEmptyString(testCase)
            version = soapysdr.getAPIVersion();
            testCase.verifyClass(version, "string");
            testCase.verifyGreaterThan(strlength(version), 0);
        end

        function getABIVersionReturnsNonEmptyString(testCase)
            version = soapysdr.getABIVersion();
            testCase.verifyClass(version, "string");
            testCase.verifyGreaterThan(strlength(version), 0);
        end

        function getLibVersionReturnsNonEmptyString(testCase)
            version = soapysdr.getLibVersion();
            testCase.verifyClass(version, "string");
            testCase.verifyGreaterThan(strlength(version), 0);
        end
    end

end
