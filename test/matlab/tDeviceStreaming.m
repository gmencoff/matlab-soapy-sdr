classdef tDeviceStreaming < matlab.unittest.TestCase
%TDEVICESTREAMING Unit tests for Device streaming methods using mock.

    properties
        Mock MockDeviceBackend
        Dev soapysdr.Device
    end

    methods (TestMethodSetup)
        function createDevice(testCase)
            testCase.Mock = MockDeviceBackend();
            testCase.Dev = soapysdr.Device("Backend", testCase.Mock);
        end
    end

    methods (Test)
        % --- setupStream ---

        function setupStreamDefaultChannel(testCase)
            testCase.Mock.Returns.setupStream = uint64(42);
            h = testCase.Dev.setupStream("RX", "CF32");
            testCase.verifyEqual(h, uint64(42));
            call = testCase.Mock.Calls{end};
            testCase.verifyEqual(call{1}, "setupStream");
            testCase.verifyEqual(call{2}, "RX");
            testCase.verifyEqual(call{3}, "CF32");
            testCase.verifyEqual(call{4}, uint64(0));
        end

        function setupStreamMultiChannel(testCase)
            testCase.Mock.Returns.setupStream = uint64(7);
            h = testCase.Dev.setupStream("RX", "CF32", [0 1]);
            testCase.verifyEqual(h, uint64(7));
            call = testCase.Mock.Calls{end};
            testCase.verifyEqual(call{4}, [0 1]);
        end

        function setupStreamWithArgs(testCase)
            testCase.Mock.Returns.setupStream = uint64(10);
            args = dictionary("buffers", "16");
            h = testCase.Dev.setupStream("TX", "CS16", uint64(0), args);
            testCase.verifyEqual(h, uint64(10));
            call = testCase.Mock.Calls{end};
            testCase.verifyEqual(call{2}, "TX");
            testCase.verifyEqual(call{3}, "CS16");
            testCase.verifyEqual(call{5}("buffers"), "16");
        end

        % --- closeStream ---

        function closeStreamDelegates(testCase)
            testCase.Mock.Returns.setupStream = uint64(1);
            h = testCase.Dev.setupStream("RX", "CF32");
            testCase.Dev.closeStream(h);
            call = testCase.Mock.Calls{end};
            testCase.verifyEqual(call{1}, "closeStream");
            testCase.verifyEqual(call{2}, uint64(1));
        end

        % --- getStreamMTU ---

        function getStreamMTUDelegates(testCase)
            testCase.Mock.Returns.setupStream = uint64(1);
            testCase.Mock.Returns.getStreamMTU = uint64(1024);
            h = testCase.Dev.setupStream("RX", "CF32");
            mtu = testCase.Dev.getStreamMTU(h);
            testCase.verifyEqual(mtu, uint64(1024));
            call = testCase.Mock.Calls{end};
            testCase.verifyEqual(call{1}, "getStreamMTU");
            testCase.verifyEqual(call{2}, uint64(1));
        end

        % --- activateStream ---

        function activateStreamDefaults(testCase)
            testCase.Mock.Returns.setupStream = uint64(5);
            h = testCase.Dev.setupStream("RX", "CF32");
            testCase.Dev.activateStream(h);
            call = testCase.Mock.Calls{end};
            testCase.verifyEqual(call{1}, "activateStream");
            testCase.verifyEqual(call{2}, uint64(5));
            testCase.verifyEqual(call{3}, int32(0));
            testCase.verifyEqual(call{4}, int64(0));
            testCase.verifyEqual(call{5}, int32(0));
        end

        function activateStreamExplicit(testCase)
            testCase.Mock.Returns.setupStream = uint64(5);
            h = testCase.Dev.setupStream("RX", "CF32");
            testCase.Dev.activateStream(h, soapysdr.StreamFlags.HAS_TIME, int64(1000), int32(512));
            call = testCase.Mock.Calls{end};
            testCase.verifyEqual(call{3}, soapysdr.StreamFlags.HAS_TIME);
            testCase.verifyEqual(call{4}, int64(1000));
            testCase.verifyEqual(call{5}, int32(512));
        end

        % --- deactivateStream ---

        function deactivateStreamDefaults(testCase)
            testCase.Mock.Returns.setupStream = uint64(3);
            h = testCase.Dev.setupStream("RX", "CF32");
            testCase.Dev.deactivateStream(h);
            call = testCase.Mock.Calls{end};
            testCase.verifyEqual(call{1}, "deactivateStream");
            testCase.verifyEqual(call{2}, uint64(3));
            testCase.verifyEqual(call{3}, int32(0));
            testCase.verifyEqual(call{4}, int64(0));
        end

        function deactivateStreamExplicit(testCase)
            testCase.Mock.Returns.setupStream = uint64(3);
            h = testCase.Dev.setupStream("RX", "CF32");
            testCase.Dev.deactivateStream(h, soapysdr.StreamFlags.END_BURST, int64(500));
            call = testCase.Mock.Calls{end};
            testCase.verifyEqual(call{3}, soapysdr.StreamFlags.END_BURST);
            testCase.verifyEqual(call{4}, int64(500));
        end

        % --- readStream ---

        function readStreamBasic(testCase)
            testCase.Mock.Returns.setupStream = uint64(1);
            expected = complex(single([1; 2; 3; 4]), single([-1; -2; -3; -4]));
            testCase.Mock.Returns.readStream = {expected, int32(4), int32(0), int64(0)};
            h = testCase.Dev.setupStream("RX", "CF32");
            [data, numRead, flags, timeNs] = testCase.Dev.readStream(h, 4);
            testCase.verifyEqual(data, expected);
            testCase.verifyEqual(numRead, int32(4));
            testCase.verifyEqual(flags, int32(0));
            testCase.verifyEqual(timeNs, int64(0));
        end

        function readStreamWithTimeout(testCase)
            testCase.Mock.Returns.setupStream = uint64(1);
            testCase.Mock.Returns.readStream = {complex(single(zeros(8, 1))), int32(8), int32(0), int64(0)};
            h = testCase.Dev.setupStream("RX", "CF32");
            testCase.Dev.readStream(h, 8, int64(50000));
            call = testCase.Mock.Calls{end};
            testCase.verifyEqual(call{1}, "readStream");
            testCase.verifyEqual(call{3}, 8);
            testCase.verifyEqual(call{4}, int64(50000));
        end

        function readStreamDefaultTimeout(testCase)
            testCase.Mock.Returns.setupStream = uint64(1);
            testCase.Mock.Returns.readStream = {complex(single(zeros(4, 1))), int32(4), int32(0), int64(0)};
            h = testCase.Dev.setupStream("RX", "CF32");
            testCase.Dev.readStream(h, 4);
            call = testCase.Mock.Calls{end};
            testCase.verifyEqual(call{4}, int64(100000));
        end

        function readStreamMultiChannel(testCase)
            testCase.Mock.Returns.setupStream = uint64(2);
            data2ch = complex(single(ones(4, 2)), single(zeros(4, 2)));
            testCase.Mock.Returns.readStream = {data2ch, int32(4), int32(0), int64(0)};
            h = testCase.Dev.setupStream("RX", "CF32", [0 1]);
            [data, numRead, ~, ~] = testCase.Dev.readStream(h, 4);
            testCase.verifySize(data, [4, 2]);
            testCase.verifyEqual(numRead, int32(4));
        end

        function readStreamErrorCode(testCase)
            testCase.Mock.Returns.setupStream = uint64(1);
            testCase.Mock.Returns.readStream = {complex(single(zeros(0, 1))), soapysdr.ErrorCode.TIMEOUT, int32(0), int64(0)};
            h = testCase.Dev.setupStream("RX", "CF32");
            [~, numRead, ~, ~] = testCase.Dev.readStream(h, 1024);
            testCase.verifyEqual(numRead, soapysdr.ErrorCode.TIMEOUT);
        end

        % --- writeStream ---

        function writeStreamBasic(testCase)
            testCase.Mock.Returns.setupStream = uint64(1);
            testCase.Mock.Returns.writeStream = int32(4);
            h = testCase.Dev.setupStream("TX", "CF32");
            data = complex(single([1; 2; 3; 4]), single([0; 0; 0; 0]));
            numWritten = testCase.Dev.writeStream(h, data);
            testCase.verifyEqual(numWritten, int32(4));
            call = testCase.Mock.Calls{end};
            testCase.verifyEqual(call{1}, "writeStream");
            testCase.verifyEqual(call{3}, data);
        end

        function writeStreamWithFlags(testCase)
            testCase.Mock.Returns.setupStream = uint64(1);
            testCase.Mock.Returns.writeStream = int32(4);
            h = testCase.Dev.setupStream("TX", "CF32");
            data = complex(single(ones(4, 1)));
            numWritten = testCase.Dev.writeStream(h, data, soapysdr.StreamFlags.HAS_TIME, int64(5000), int64(200000));
            testCase.verifyEqual(numWritten, int32(4));
            call = testCase.Mock.Calls{end};
            testCase.verifyEqual(call{4}, soapysdr.StreamFlags.HAS_TIME);
            testCase.verifyEqual(call{5}, int64(5000));
            testCase.verifyEqual(call{6}, int64(200000));
        end

        function writeStreamDefaults(testCase)
            testCase.Mock.Returns.setupStream = uint64(1);
            testCase.Mock.Returns.writeStream = int32(2);
            h = testCase.Dev.setupStream("TX", "CF32");
            data = complex(single([1; 2]));
            testCase.Dev.writeStream(h, data);
            call = testCase.Mock.Calls{end};
            testCase.verifyEqual(call{4}, int32(0));
            testCase.verifyEqual(call{5}, int64(0));
            testCase.verifyEqual(call{6}, int64(100000));
        end

        % --- readStreamStatus ---

        function readStreamStatusBasic(testCase)
            testCase.Mock.Returns.setupStream = uint64(1);
            testCase.Mock.Returns.readStreamStatus = {int32(0), int32(0), int32(0), int64(0)};
            h = testCase.Dev.setupStream("RX", "CF32");
            [ret, chanMask, flags, timeNs] = testCase.Dev.readStreamStatus(h);
            testCase.verifyEqual(ret, int32(0));
            testCase.verifyEqual(chanMask, int32(0));
            testCase.verifyEqual(flags, int32(0));
            testCase.verifyEqual(timeNs, int64(0));
        end

        function readStreamStatusWithTimeout(testCase)
            testCase.Mock.Returns.setupStream = uint64(1);
            testCase.Mock.Returns.readStreamStatus = {int32(0), int32(0), int32(0), int64(0)};
            h = testCase.Dev.setupStream("RX", "CF32");
            testCase.Dev.readStreamStatus(h, int64(50000));
            call = testCase.Mock.Calls{end};
            testCase.verifyEqual(call{3}, int64(50000));
        end

        function readStreamStatusDefaultTimeout(testCase)
            testCase.Mock.Returns.setupStream = uint64(1);
            testCase.Mock.Returns.readStreamStatus = {int32(0), int32(0), int32(0), int64(0)};
            h = testCase.Dev.setupStream("RX", "CF32");
            testCase.Dev.readStreamStatus(h);
            call = testCase.Mock.Calls{end};
            testCase.verifyEqual(call{3}, int64(0));
        end

        % --- StreamFlags constants ---

        function streamFlagsValues(testCase)
            testCase.verifyEqual(soapysdr.StreamFlags.HAS_TIME, int32(1));
            testCase.verifyEqual(soapysdr.StreamFlags.END_BURST, int32(2));
            testCase.verifyEqual(soapysdr.StreamFlags.ONE_PACKET, int32(4));
            testCase.verifyEqual(soapysdr.StreamFlags.MORE_FRAGMENTS, int32(8));
            testCase.verifyEqual(soapysdr.StreamFlags.WAIT_TRIGGER, int32(16));
        end

        function streamFlagsCombine(testCase)
            combined = bitor(soapysdr.StreamFlags.HAS_TIME, soapysdr.StreamFlags.END_BURST);
            testCase.verifyEqual(combined, int32(3));
        end

        % --- ErrorCode constants ---

        function errorCodeValues(testCase)
            testCase.verifyEqual(soapysdr.ErrorCode.TIMEOUT, int32(-1));
            testCase.verifyEqual(soapysdr.ErrorCode.STREAM_ERROR, int32(-2));
            testCase.verifyEqual(soapysdr.ErrorCode.CORRUPTION, int32(-3));
            testCase.verifyEqual(soapysdr.ErrorCode.OVERFLOW, int32(-4));
            testCase.verifyEqual(soapysdr.ErrorCode.UNDERFLOW, int32(-5));
            testCase.verifyEqual(soapysdr.ErrorCode.NOT_SUPPORTED, int32(-6));
            testCase.verifyEqual(soapysdr.ErrorCode.TIME_ERROR, int32(-7));
        end
    end

end
