classdef tDeviceIntegration < matlab.unittest.TestCase
%TDEVICEINTEGRATION Integration tests for soapysdr.Device.
%   These tests require the compiled MEX binary and the fake
%   matlab_test SoapySDR plugin to be available.

    properties
        Device soapysdr.Device
    end

    methods (TestMethodSetup)
        function createDevice(testCase)
            testCase.Device = soapysdr.Device( ...
                driver="matlab_test", serial="TEST001");
            testCase.addTeardown(@delete, testCase.Device);
        end
    end

    methods (Test)
        function getDriverKeyReturnsExpected(testCase)
            result = testCase.Device.getDriverKey();
            testCase.verifyEqual(result, "matlab_test");
        end

        function getHardwareKeyReturnsExpected(testCase)
            result = testCase.Device.getHardwareKey();
            testCase.verifyEqual(result, "matlab_test_hw");
        end

        function getHardwareInfoReturnsDict(testCase)
            info = testCase.Device.getHardwareInfo();
            testCase.verifyClass(info, "dictionary");
            testCase.verifyEqual(info("serial"), "TEST001");
            testCase.verifyEqual(info("firmware"), "1.0.0");
            testCase.verifyEqual(info("platform"), "test");
        end

        function deviceCanBeDeleted(testCase)
            dev = soapysdr.Device( ...
                driver="matlab_test", serial="TEST002");
            delete(dev);
        end

        function doubleDeleteIsSafe(testCase)
            dev = soapysdr.Device( ...
                driver="matlab_test", serial="TEST002");
            delete(dev);
            delete(dev);
        end

        function constructFromEnumerateResult(testCase)
            devices = soapysdr.enumerate();
            testDevices = devices(cellfun(@(d) ...
                d.isKey("driver") && d("driver") == "matlab_test", ...
                devices));
            testCase.assumeNotEmpty(testDevices);
            dev = soapysdr.Device(testDevices{1});
            testCase.addTeardown(@delete, dev);
            testCase.verifyEqual(dev.getDriverKey(), "matlab_test");
        end
    end

end
