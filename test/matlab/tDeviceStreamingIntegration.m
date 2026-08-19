classdef tDeviceStreamingIntegration < matlab.unittest.TestCase
%TDEVICESTREAMINGINTEGRATION Full-stack streaming tests with fake plugin.

    properties
        Dev soapysdr.Device
    end

    methods (TestMethodSetup)
        function createDevice(testCase)
            testCase.Dev = soapysdr.Device(driver="matlab_test", serial="TEST001");
        end
    end

    methods (TestMethodTeardown)
        function deleteDevice(testCase)
            delete(testCase.Dev);
        end
    end

    methods (Test)
        % --- setupStream / closeStream lifecycle ---

        function setupAndCloseStream(testCase)
            h = testCase.Dev.setupStream("RX", "CF32");
            testCase.verifyClass(h, "uint64");
            testCase.verifyGreaterThan(h, uint64(0));
            testCase.Dev.closeStream(h);
        end

        function setupStreamMultiChannel(testCase)
            h = testCase.Dev.setupStream("RX", "CF32", [0 1]);
            testCase.verifyClass(h, "uint64");
            testCase.Dev.closeStream(h);
        end

        function setupStreamTX(testCase)
            h = testCase.Dev.setupStream("TX", "CF32");
            testCase.verifyClass(h, "uint64");
            testCase.Dev.closeStream(h);
        end

        % --- getStreamMTU ---

        function getStreamMTUValue(testCase)
            h = testCase.Dev.setupStream("RX", "CF32");
            mtu = testCase.Dev.getStreamMTU(h);
            testCase.verifyEqual(mtu, uint64(1024));
            testCase.Dev.closeStream(h);
        end

        % --- activate / deactivate ---

        function activateDeactivateStream(testCase)
            h = testCase.Dev.setupStream("RX", "CF32");
            testCase.Dev.activateStream(h);
            testCase.Dev.deactivateStream(h);
            testCase.Dev.closeStream(h);
        end

        function activateStreamWithFlags(testCase)
            h = testCase.Dev.setupStream("RX", "CF32");
            testCase.Dev.activateStream(h, soapysdr.StreamFlags.HAS_TIME, int64(1000), int32(0));
            testCase.Dev.deactivateStream(h);
            testCase.Dev.closeStream(h);
        end

        % --- readStream CF32 single channel ---

        function readStreamCF32SingleChannel(testCase)
            h = testCase.Dev.setupStream("RX", "CF32");
            testCase.Dev.activateStream(h);
            [data, numRead, flags, timeNs] = testCase.Dev.readStream(h, 8);
            testCase.verifyEqual(numRead, int32(8));
            testCase.verifyClass(data, "single");
            testCase.verifyTrue(~isreal(data));
            testCase.verifySize(data, [8, 1]);
            expected = complex(single((1:8)'), single(-(1:8)'));
            testCase.verifyEqual(data, expected);
            testCase.verifyEqual(flags, int32(0));
            testCase.verifyEqual(timeNs, int64(1000000));
            testCase.Dev.deactivateStream(h);
            testCase.Dev.closeStream(h);
        end

        % --- readStream CF32 multi-channel ---

        function readStreamCF32MultiChannel(testCase)
            h = testCase.Dev.setupStream("RX", "CF32", [0 1]);
            testCase.Dev.activateStream(h);
            [data, numRead, ~, ~] = testCase.Dev.readStream(h, 4);
            testCase.verifyEqual(numRead, int32(4));
            testCase.verifySize(data, [4, 2]);
            testCase.verifyClass(data, "single");
            testCase.verifyTrue(~isreal(data));
            expected = complex(single((1:4)'), single(-(1:4)'));
            testCase.verifyEqual(data(:, 1), expected);
            testCase.verifyEqual(data(:, 2), expected);
            testCase.Dev.deactivateStream(h);
            testCase.Dev.closeStream(h);
        end

        % --- readStream CS16 ---

        function readStreamCS16(testCase)
            h = testCase.Dev.setupStream("RX", "CS16");
            testCase.Dev.activateStream(h);
            [data, numRead, ~, ~] = testCase.Dev.readStream(h, 4);
            testCase.verifyEqual(numRead, int32(4));
            testCase.verifyClass(data, "int16");
            testCase.verifyTrue(~isreal(data));
            testCase.verifySize(data, [4, 1]);
            expected = complex(int16((1:4)'), int16(-(1:4)'));
            testCase.verifyEqual(data, expected);
            testCase.Dev.deactivateStream(h);
            testCase.Dev.closeStream(h);
        end

        % --- writeStream ---

        function writeStreamCF32(testCase)
            h = testCase.Dev.setupStream("TX", "CF32");
            testCase.Dev.activateStream(h);
            data = complex(single([1; 2; 3; 4]), single([5; 6; 7; 8]));
            numWritten = testCase.Dev.writeStream(h, data);
            testCase.verifyEqual(numWritten, int32(4));
            testCase.Dev.deactivateStream(h);
            testCase.Dev.closeStream(h);
        end

        function writeStreamWithFlags(testCase)
            h = testCase.Dev.setupStream("TX", "CF32");
            testCase.Dev.activateStream(h);
            data = complex(single([1; 2]), single([0; 0]));
            numWritten = testCase.Dev.writeStream(h, data, soapysdr.StreamFlags.END_BURST, int64(500), int64(50000));
            testCase.verifyEqual(numWritten, int32(2));
            testCase.Dev.deactivateStream(h);
            testCase.Dev.closeStream(h);
        end

        % --- readStreamStatus ---

        function readStreamStatusBasic(testCase)
            h = testCase.Dev.setupStream("RX", "CF32");
            testCase.Dev.activateStream(h);
            [ret, chanMask, flags, timeNs] = testCase.Dev.readStreamStatus(h);
            testCase.verifyClass(ret, "int32");
            testCase.verifyClass(chanMask, "int32");
            testCase.verifyClass(flags, "int32");
            testCase.verifyClass(timeNs, "int64");
            testCase.Dev.deactivateStream(h);
            testCase.Dev.closeStream(h);
        end

        % --- Full lifecycle ---

        function fullLifecycle(testCase)
            h = testCase.Dev.setupStream("RX", "CF32");
            mtu = testCase.Dev.getStreamMTU(h);
            testCase.verifyGreaterThan(mtu, uint64(0));
            testCase.Dev.activateStream(h);
            [~, numRead, ~, ~] = testCase.Dev.readStream(h, 16);
            testCase.verifyEqual(numRead, int32(16));
            testCase.Dev.deactivateStream(h);
            testCase.Dev.closeStream(h);
        end

        % --- Device delete with open stream (safe cleanup) ---

        function deviceDeleteClosesStreams(testCase)
            dev2 = soapysdr.Device(driver="matlab_test", serial="TEST001");
            h = dev2.setupStream("RX", "CF32");
            dev2.activateStream(h);
            delete(dev2);
        end

        % --- Multiple streams ---

        function multipleStreamsOnDevice(testCase)
            h1 = testCase.Dev.setupStream("RX", "CF32");
            h2 = testCase.Dev.setupStream("TX", "CF32");
            testCase.verifyNotEqual(h1, h2);
            testCase.Dev.closeStream(h1);
            testCase.Dev.closeStream(h2);
        end
    end

end
