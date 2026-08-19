classdef tDevice < matlab.unittest.TestCase
%TDEVICE Unit tests for soapysdr.Device using MockDeviceBackend.

    properties
        Mock MockDeviceBackend
    end

    methods (TestMethodSetup)
        function createMock(testCase)
            testCase.Mock = MockDeviceBackend();
        end
    end

    methods (Test)
        function constructWithEmptyArgs(testCase)
            % Device created with no input arguments
            dev = soapysdr.Device(BackendConstructor=@(kwargs)testCase.ConstructMockBackend(kwargs));
            testCase.verifyNotEmpty(dev);
            testCase.verifyEmpty(testCase.Mock.ConstructorArgs);
        end

        function constructWithDictArgs(testCase)
            % Device created with dictionary input
            dictin = dictionary(["key1","key2"],["val1","val2"]);
            dev = soapysdr.Device(dictin,BackendConstructor=@(kwargs)testCase.ConstructMockBackend(kwargs));
            testCase.verifyNotEmpty(dev);
            testCase.verifyEqual(testCase.Mock.ConstructorArgs,["key1","val1";"key2","val2"]);
        end

        function constructWithKvArgsLast(testCase)
            % Device created with kv inputs - inject first
            dev = soapysdr.Device(BackendConstructor=@(kwargs)testCase.ConstructMockBackend(kwargs),key1='val1');
            testCase.verifyNotEmpty(dev);
            testCase.verifyEqual(testCase.Mock.ConstructorArgs,["key1" "val1"]);
        end

        function constructWithKvArgsMid(testCase)
            % Device created with kv inputs - inject middle
            dev = soapysdr.Device(key1='val1',BackendConstructor=@(kwargs)testCase.ConstructMockBackend(kwargs),key2='val2');
            testCase.verifyNotEmpty(dev);
            testCase.verifyEqual(testCase.Mock.ConstructorArgs,["key1" "val1";"key2" "val2"]);
        end

        function constructWithKvArgslast(testCase)
            % Device created with kv inputs - inject last
            dev = soapysdr.Device(key1='val1',key2='val2',BackendConstructor=@(kwargs)testCase.ConstructMockBackend(kwargs));
            testCase.verifyNotEmpty(dev);
            testCase.verifyEqual(testCase.Mock.ConstructorArgs,["key1" "val1";"key2" "val2"]);
        end

        function getDriverKeyDelegates(testCase)
            dev = soapysdr.Device(BackendConstructor=@(kwargs)testCase.ConstructMockBackend(kwargs));
            result = dev.getDriverKey();
            testCase.verifyEqual(result, "mock_driver");
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"getDriverKey"});
        end

        function getHardwareKeyDelegates(testCase)
            dev = soapysdr.Device(BackendConstructor=@(kwargs)testCase.ConstructMockBackend(kwargs));
            result = dev.getHardwareKey();
            testCase.verifyEqual(result, "mock_hw");
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"getHardwareKey"});
        end

        function getHardwareInfoDelegates(testCase)
            dev = soapysdr.Device(BackendConstructor=@(kwargs)testCase.ConstructMockBackend(kwargs));
            result = dev.getHardwareInfo();
            testCase.verifyEqual(result("serial"), "MOCK001");
            testCase.verifyEqual(result("revision"), "v2");
        end

        function deleteBackend(testCase)
            dev = soapysdr.Device(BackendConstructor=@(kwargs)testCase.ConstructMockBackend(kwargs));
            delete(dev);
            testCase.verifyTrue(~isvalid(testCase.Mock));
        end
    end

    methods (Access=private)
        function be = ConstructMockBackend(testCase,kwargs)
            testCase.Mock.setConstructorArgs(kwargs);
            be = testCase.Mock;
        end
    end

end
