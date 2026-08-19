classdef tDevice < matlab.unittest.TestCase
%TDEVICE Unit tests for soapysdr.Device using MockDeviceBackend.

    properties
        Mock MockDeviceBackend
    end

    methods (TestMethodSetup)
        function createMock(testCase)
            testCase.Mock = MockDeviceBackend();
            testCase.Mock.Returns.getDriverKey = "mock_driver";
            testCase.Mock.Returns.getHardwareKey = "mock_hw";
            testCase.Mock.Returns.getHardwareInfo = ...
                dictionary(["serial", "revision"], ...
                           ["MOCK001", "v2"]);
        end
    end

    methods (Test)
        function constructWithBackend(testCase)
            dev = soapysdr.Device(Backend=testCase.Mock);
            testCase.verifyNotEmpty(dev);
        end

        function getDriverKeyDelegates(testCase)
            dev = soapysdr.Device(Backend=testCase.Mock);
            result = dev.getDriverKey();
            testCase.verifyEqual(result, "mock_driver");
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"getDriverKey"});
        end

        function getHardwareKeyDelegates(testCase)
            dev = soapysdr.Device(Backend=testCase.Mock);
            result = dev.getHardwareKey();
            testCase.verifyEqual(result, "mock_hw");
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"getHardwareKey"});
        end

        function getHardwareInfoDelegates(testCase)
            dev = soapysdr.Device(Backend=testCase.Mock);
            result = dev.getHardwareInfo();
            testCase.verifyEqual(result("serial"), "MOCK001");
            testCase.verifyEqual(result("revision"), "v2");
        end

        function deleteIsIdempotent(testCase)
            dev = soapysdr.Device(Backend=testCase.Mock);
            delete(dev);
            testCase.verifyEqual(testCase.Mock.DeleteCount, 1);
        end

        function noArgsThrows(testCase)
            testCase.verifyError(@() soapysdr.Device(), ...
                "soapysdr:Device:InvalidArgs");
        end
    end

end
