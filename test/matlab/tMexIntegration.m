classdef tMexIntegration < matlab.unittest.TestCase
%TMEXINTEGRATION Integration tests for soapysdr.internal.enumerate.
%   Exercises the full stack through the real MEX and SoapySDR with
%   the fake matlab_test plugin loaded via SOAPY_SDR_PLUGIN_PATH.

    methods (Test)
        function findsTestDevices(testCase)
            devices = soapysdr.internal.enumerate();

            testDevices = devices(cellfun(@(d) ...
                isKey(d, "driver") && d("driver") == "matlab_test", ...
                devices));

            testCase.verifyNumElements(testDevices, 2);
        end

        function verifiesSerialTEST001(testCase)
            devices = soapysdr.internal.enumerate();

            testDevices = devices(cellfun(@(d) ...
                isKey(d, "driver") && d("driver") == "matlab_test", ...
                devices));

            serials = cellfun(@(d) d("serial"), testDevices);
            testCase.verifyTrue(ismember("TEST001", serials));
        end

        function verifiesSerialTEST002(testCase)
            devices = soapysdr.internal.enumerate();

            testDevices = devices(cellfun(@(d) ...
                isKey(d, "driver") && d("driver") == "matlab_test", ...
                devices));

            serials = cellfun(@(d) d("serial"), testDevices);
            testCase.verifyTrue(ismember("TEST002", serials));
        end

        function verifiesLabels(testCase)
            devices = soapysdr.internal.enumerate();

            testDevices = devices(cellfun(@(d) ...
                isKey(d, "driver") && d("driver") == "matlab_test", ...
                devices));

            labels = cellfun(@(d) d("label"), testDevices);
            testCase.verifyTrue( ...
                ismember("MATLAB Test Device 1", labels));
            testCase.verifyTrue( ...
                ismember("MATLAB Test Device 2", labels));
        end
    end

end
