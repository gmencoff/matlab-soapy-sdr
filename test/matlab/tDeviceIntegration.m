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
        % --- Identification ---

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

        % --- Lifecycle ---

        function deviceCanBeDeleted(testCase)
            dev = soapysdr.Device( ...
                driver="matlab_test", serial="TEST002");
            testCase.verifyWarningFree(@()delete(dev));
        end

        function doubleDeleteIsSafe(testCase)
            dev = soapysdr.Device( ...
                driver="matlab_test", serial="TEST002");
            testCase.verifyWarningFree(@()delete(dev));
            testCase.verifyWarningFree(@()delete(dev));
        end

        function constructFromEnumerateResult(testCase)
            devices = soapysdr.find();
            testDevices = devices(cellfun(@(d) ...
                d.isKey("driver") && d("driver") == "matlab_test", ...
                devices));
            testCase.assumeNotEmpty(testDevices);
            dev = soapysdr.Device(testDevices{1});
            testCase.addTeardown(@delete, dev);
            testCase.verifyEqual(dev.getDriverKey(), "matlab_test");
        end

        function deviceTwoIdentification(testCase)
            dev = soapysdr.Device( ...
                driver="matlab_test", serial="TEST002");
            testCase.addTeardown(@delete, dev);
            testCase.verifyEqual(dev.getDriverKey(), "matlab_test");
            info = dev.getHardwareInfo();
            testCase.verifyEqual(info("serial"), "TEST002");
        end

        function multipleDevicesCoexist(testCase)
            dev1 = soapysdr.Device( ...
                driver="matlab_test", serial="TEST001");
            dev2 = soapysdr.Device( ...
                driver="matlab_test", serial="TEST002");
            testCase.addTeardown(@delete, dev1);
            testCase.addTeardown(@delete, dev2);

            info1 = dev1.getHardwareInfo();
            info2 = dev2.getHardwareInfo();
            testCase.verifyEqual(info1("serial"), "TEST001");
            testCase.verifyEqual(info2("serial"), "TEST002");
        end

        % --- Channels ---

        function getNumChannelsRx(testCase)
            result = testCase.Device.getNumChannels("RX");
            testCase.verifyEqual(result, 2);
        end

        function getNumChannelsTx(testCase)
            result = testCase.Device.getNumChannels("TX");
            testCase.verifyEqual(result, 1);
        end

        function getFullDuplexReturnsTrue(testCase)
            result = testCase.Device.getFullDuplex("RX", 0);
            testCase.verifyTrue(result);
        end

        function getChannelInfoReturnsDict(testCase)
            info = testCase.Device.getChannelInfo("RX", 0);
            testCase.verifyClass(info, "dictionary");
            testCase.verifyEqual(info("name"), "RX0");
        end

        function setAndGetFrontendMapping(testCase)
            testCase.Device.setFrontendMapping("RX", "0:0 1:1");
            result = testCase.Device.getFrontendMapping("RX");
            testCase.verifyEqual(result, "0:0 1:1");
        end

        % --- Stream Discovery ---

        function getStreamFormatsReturnsArray(testCase)
            formats = testCase.Device.getStreamFormats("RX", 0);
            testCase.verifyTrue(ismember("CF32", formats));
            testCase.verifyTrue(ismember("CS16", formats));
        end

        function getNativeStreamFormatReturnsCS16(testCase)
            [fmt, fs] = testCase.Device.getNativeStreamFormat( ...
                "RX", 0);
            testCase.verifyEqual(fmt, "CS16");
            testCase.verifyEqual(fs, 32767.0);
        end

        function getStreamArgsInfoReturnsEmpty(testCase)
            result = testCase.Device.getStreamArgsInfo("RX", 0);
            testCase.verifyEmpty(result);
        end

        % --- Antenna ---

        function listAntennasRx(testCase)
            antennas = testCase.Device.listAntennas("RX", 0);
            testCase.verifyEqual(antennas, ["RX1", "RX2"]);
        end

        function setAndGetAntenna(testCase)
            testCase.Device.setAntenna("RX", 0, "RX2");
            result = testCase.Device.getAntenna("RX", 0);
            testCase.verifyEqual(result, "RX2");
        end

        % --- Frontend Corrections ---

        function hasDCOffsetModeReturnsTrue(testCase)
            result = testCase.Device.hasDCOffsetMode("RX", 0);
            testCase.verifyTrue(result);
        end

        function setAndGetDCOffsetMode(testCase)
            testCase.Device.setDCOffsetMode("RX", 0, true);
            result = testCase.Device.getDCOffsetMode("RX", 0);
            testCase.verifyTrue(result);
        end

        function setAndGetDCOffset(testCase)
            testCase.Device.setDCOffset("RX", 0, ...
                complex(0.01, -0.02));
            result = testCase.Device.getDCOffset("RX", 0);
            testCase.verifyEqual(real(result), 0.01, ...
                AbsTol=1e-10);
            testCase.verifyEqual(imag(result), -0.02, ...
                AbsTol=1e-10);
        end

        function setAndGetIQBalance(testCase)
            testCase.Device.setIQBalance("RX", 0, ...
                complex(1.0, 0.005));
            result = testCase.Device.getIQBalance("RX", 0);
            testCase.verifyEqual(real(result), 1.0, AbsTol=1e-10);
            testCase.verifyEqual(imag(result), 0.005, ...
                AbsTol=1e-10);
        end

        function setAndGetFrequencyCorrection(testCase)
            testCase.Device.setFrequencyCorrection("RX", 0, 5.5);
            result = testCase.Device.getFrequencyCorrection("RX", 0);
            testCase.verifyEqual(result, 5.5, AbsTol=1e-10);
        end

        % --- Gain ---

        function listGainsReturnsExpected(testCase)
            gains = testCase.Device.listGains("RX", 0);
            testCase.verifyEqual(gains, ["LNA", "VGA", "IF"]);
        end

        function hasGainModeReturnsTrue(testCase)
            result = testCase.Device.hasGainMode("RX", 0);
            testCase.verifyTrue(result);
        end

        function setAndGetGainMode(testCase)
            testCase.Device.setGainMode("RX", 0, true);
            result = testCase.Device.getGainMode("RX", 0);
            testCase.verifyTrue(result);
        end

        function setAndGetOverallGain(testCase)
            testCase.Device.setGain("RX", 0, 42.5);
            result = testCase.Device.getGain("RX", 0);
            testCase.verifyEqual(result, 42.5, AbsTol=1e-10);
        end

        function setAndGetElementGain(testCase)
            testCase.Device.setGain("RX", 0, "LNA", 20);
            result = testCase.Device.getGain("RX", 0, "LNA");
            testCase.verifyEqual(result, 20.0, AbsTol=1e-10);
        end

        function getGainRangeOverall(testCase)
            r = testCase.Device.getGainRange("RX", 0);
            testCase.verifyClass(r, "soapysdr.Range");
            testCase.verifyEqual(r.Minimum, 0.0);
            testCase.verifyEqual(r.Maximum, 73.0);
            testCase.verifyEqual(r.Step, 1.0);
        end

        function getGainRangeElement(testCase)
            r = testCase.Device.getGainRange("RX", 0, "LNA");
            testCase.verifyEqual(r.Maximum, 30.0);
        end

        % --- Frequency ---

        function setAndGetFrequencyOverall(testCase)
            testCase.Device.setFrequency("RX", 0, 1.42e9);
            result = testCase.Device.getFrequency("RX", 0);
            testCase.verifyEqual(result, 1.42e9, AbsTol=1);
        end

        function setAndGetFrequencyComponent(testCase)
            testCase.Device.setFrequency("RX", 0, "RF", 900e6);
            result = testCase.Device.getFrequency("RX", 0, "RF");
            testCase.verifyEqual(result, 900e6, AbsTol=1);
        end

        function listFrequenciesReturnsExpected(testCase)
            result = testCase.Device.listFrequencies("RX", 0);
            testCase.verifyEqual(result, ["RF", "BB"]);
        end

        function getFrequencyRangeOverall(testCase)
            ranges = testCase.Device.getFrequencyRange("RX", 0);
            testCase.verifyGreaterThanOrEqual(numel(ranges), 1);
            testCase.verifyEqual(ranges(1).Minimum, 70e6);
            testCase.verifyEqual(ranges(1).Maximum, 6e9);
        end

        function getFrequencyRangeComponent(testCase)
            ranges = testCase.Device.getFrequencyRange( ...
                "RX", 0, "BB");
            testCase.verifyEqual(ranges(1).Minimum, -50e6);
            testCase.verifyEqual(ranges(1).Maximum, 50e6);
        end

        function getFrequencyArgsInfoReturnsArgInfo(testCase)
            infos = testCase.Device.getFrequencyArgsInfo("RX", 0);
            testCase.verifyGreaterThanOrEqual(numel(infos), 1);
            testCase.verifyClass(infos(1), "soapysdr.ArgInfo");
            testCase.verifyEqual(infos(1).Key, "OFFSET");
        end

        % --- Sample Rate ---

        function setAndGetSampleRate(testCase)
            testCase.Device.setSampleRate("RX", 0, 2.4e6);
            result = testCase.Device.getSampleRate("RX", 0);
            testCase.verifyEqual(result, 2.4e6, AbsTol=1);
        end

        function getSampleRateRangeReturnsRange(testCase)
            ranges = testCase.Device.getSampleRateRange("RX", 0);
            testCase.verifyGreaterThanOrEqual(numel(ranges), 1);
            testCase.verifyEqual(ranges(1).Minimum, 225e3);
            testCase.verifyEqual(ranges(1).Maximum, 3.2e6);
        end

        % --- Bandwidth ---

        function setAndGetBandwidth(testCase)
            testCase.Device.setBandwidth("RX", 0, 1.5e6);
            result = testCase.Device.getBandwidth("RX", 0);
            testCase.verifyEqual(result, 1.5e6, AbsTol=1);
        end

        function getBandwidthRangeReturnsRange(testCase)
            ranges = testCase.Device.getBandwidthRange("RX", 0);
            testCase.verifyEqual(ranges(1).Minimum, 200e3);
            testCase.verifyEqual(ranges(1).Maximum, 8e6);
        end

        % --- Clocking ---

        function setAndGetMasterClockRate(testCase)
            testCase.Device.setMasterClockRate(80e6);
            result = testCase.Device.getMasterClockRate();
            testCase.verifyEqual(result, 80e6, AbsTol=1);
        end

        function getMasterClockRatesReturnsRange(testCase)
            ranges = testCase.Device.getMasterClockRates();
            testCase.verifyEqual(ranges(1).Minimum, 10e6);
            testCase.verifyEqual(ranges(1).Maximum, 80e6);
        end

        function listClockSourcesReturnsExpected(testCase)
            result = testCase.Device.listClockSources();
            testCase.verifyEqual(result, ...
                ["internal", "external"]);
        end

        function setAndGetClockSource(testCase)
            testCase.Device.setClockSource("external");
            result = testCase.Device.getClockSource();
            testCase.verifyEqual(result, "external");
        end

        % --- Time ---

        function listTimeSourcesReturnsExpected(testCase)
            result = testCase.Device.listTimeSources();
            testCase.verifyEqual(result, ["none", "PPS"]);
        end

        function setAndGetTimeSource(testCase)
            testCase.Device.setTimeSource("PPS");
            result = testCase.Device.getTimeSource();
            testCase.verifyEqual(result, "PPS");
        end

        function hasHardwareTimeReturnsTrue(testCase)
            result = testCase.Device.hasHardwareTime();
            testCase.verifyTrue(result);
        end

        function setAndGetHardwareTime(testCase)
            testCase.Device.setHardwareTime(int64(123456789));
            result = testCase.Device.getHardwareTime();
            testCase.verifyEqual(result, int64(123456789));
        end

        % --- Sensors ---

        function listSensorsReturnsExpected(testCase)
            result = testCase.Device.listSensors();
            testCase.verifyEqual(result, ["temp", "voltage"]);
        end

        function getSensorInfoReturnsArgInfo(testCase)
            info = testCase.Device.getSensorInfo("temp");
            testCase.verifyClass(info, "soapysdr.ArgInfo");
            testCase.verifyEqual(info.Key, "temp");
            testCase.verifyEqual(info.Units, "C");
            testCase.verifyEqual(info.Type, "float");
        end

        function readSensorReturnsValue(testCase)
            result = testCase.Device.readSensor("temp");
            testCase.verifyEqual(result, "45.2");
        end

        function listChannelSensorsReturnsExpected(testCase)
            result = testCase.Device.listChannelSensors("RX", 0);
            testCase.verifyEqual(result, "rssi");
        end

        function readChannelSensorReturnsValue(testCase)
            result = testCase.Device.readChannelSensor( ...
                "RX", 0, "rssi");
            testCase.verifyEqual(result, "-60.5");
        end

        % --- Settings ---

        function getSettingInfoReturnsArgInfoArray(testCase)
            infos = testCase.Device.getSettingInfo();
            testCase.verifyGreaterThanOrEqual(numel(infos), 1);
            testCase.verifyEqual(infos(1).Key, "agc_mode");
            testCase.verifyEqual(infos(1).Type, "string");
        end

        function writeAndReadSetting(testCase)
            testCase.Device.writeSetting("agc_mode", "fast");
            result = testCase.Device.readSetting("agc_mode");
            testCase.verifyEqual(result, "fast");
        end

        function writeAndReadChannelSetting(testCase)
            testCase.Device.writeChannelSetting( ...
                "RX", 0, "biastee", "true");
            result = testCase.Device.readChannelSetting( ...
                "RX", 0, "biastee");
            testCase.verifyEqual(result, "true");
        end

        % --- GPIO ---

        function listGPIOBanksReturnsExpected(testCase)
            result = testCase.Device.listGPIOBanks();
            testCase.verifyEqual(result, "MAIN");
        end

        function writeAndReadGPIO(testCase)
            testCase.Device.writeGPIO("MAIN", uint32(170));
            result = testCase.Device.readGPIO("MAIN");
            testCase.verifyEqual(result, uint32(170));
        end

        function writeGPIOWithMask(testCase)
            testCase.Device.writeGPIO("MAIN", uint32(255));
            testCase.Device.writeGPIO( ...
                "MAIN", uint32(0), uint32(15));
            result = testCase.Device.readGPIO("MAIN");
            testCase.verifyEqual(result, uint32(240));
        end

        function writeAndReadGPIODir(testCase)
            testCase.Device.writeGPIODir("MAIN", uint32(255));
            result = testCase.Device.readGPIODir("MAIN");
            testCase.verifyEqual(result, uint32(255));
        end

        % --- Cross-channel isolation ---

        function rxChannelsAreIndependent(testCase)
            testCase.Device.setFrequency("RX", 0, 100e6);
            testCase.Device.setFrequency("RX", 1, 200e6);
            f0 = testCase.Device.getFrequency("RX", 0);
            f1 = testCase.Device.getFrequency("RX", 1);
            testCase.verifyEqual(f0, 100e6, AbsTol=1);
            testCase.verifyEqual(f1, 200e6, AbsTol=1);
        end

        function rxTxAreIndependent(testCase)
            testCase.Device.setGain("RX", 0, 30);
            testCase.Device.setGain("TX", 0, 10);
            rxGain = testCase.Device.getGain("RX", 0);
            txGain = testCase.Device.getGain("TX", 0);
            testCase.verifyEqual(rxGain, 30.0, AbsTol=1e-10);
            testCase.verifyEqual(txGain, 10.0, AbsTol=1e-10);
        end
    end

end
