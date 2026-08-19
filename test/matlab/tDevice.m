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
        % --- Construction ---

        function constructWithEmptyArgs(testCase)
            dev = soapysdr.Device(BackendConstructor=@(kwargs)testCase.ConstructMockBackend(kwargs));
            testCase.verifyNotEmpty(dev);
            testCase.verifyEmpty(testCase.Mock.ConstructorArgs);
        end

        function constructWithDictArgs(testCase)
            dictin = dictionary(["key1","key2"],["val1","val2"]);
            dev = soapysdr.Device(dictin,BackendConstructor=@(kwargs)testCase.ConstructMockBackend(kwargs));
            testCase.verifyNotEmpty(dev);
            testCase.verifyEqual(testCase.Mock.ConstructorArgs,["key1","val1";"key2","val2"]);
        end

        function constructWithKvArgsLast(testCase)
            dev = soapysdr.Device(BackendConstructor=@(kwargs)testCase.ConstructMockBackend(kwargs),key1='val1');
            testCase.verifyNotEmpty(dev);
            testCase.verifyEqual(testCase.Mock.ConstructorArgs,["key1" "val1"]);
        end

        function constructWithKvArgsMid(testCase)
            dev = soapysdr.Device(key1='val1',BackendConstructor=@(kwargs)testCase.ConstructMockBackend(kwargs),key2='val2');
            testCase.verifyNotEmpty(dev);
            testCase.verifyEqual(testCase.Mock.ConstructorArgs,["key1" "val1";"key2" "val2"]);
        end

        function constructWithKvArgslast(testCase)
            dev = soapysdr.Device(key1='val1',key2='val2',BackendConstructor=@(kwargs)testCase.ConstructMockBackend(kwargs));
            testCase.verifyNotEmpty(dev);
            testCase.verifyEqual(testCase.Mock.ConstructorArgs,["key1" "val1";"key2" "val2"]);
        end

        % --- Identification ---

        function getDriverKeyDelegates(testCase)
            dev = testCase.makeDevice();
            result = dev.getDriverKey();
            testCase.verifyEqual(result, "mock_driver");
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"getDriverKey"});
        end

        function getHardwareKeyDelegates(testCase)
            dev = testCase.makeDevice();
            result = dev.getHardwareKey();
            testCase.verifyEqual(result, "mock_hw");
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"getHardwareKey"});
        end

        function getHardwareInfoDelegates(testCase)
            dev = testCase.makeDevice();
            result = dev.getHardwareInfo();
            testCase.verifyEqual(result("serial"), "MOCK001");
            testCase.verifyEqual(result("revision"), "v2");
        end

        function deleteBackend(testCase)
            dev = soapysdr.Device(BackendConstructor=@(kwargs)testCase.ConstructMockBackend(kwargs));
            delete(dev);
            testCase.verifyTrue(~isvalid(testCase.Mock));
        end

        % --- Channels ---

        function setFrontendMappingDelegates(testCase)
            dev = testCase.makeDevice();
            dev.setFrontendMapping("RX", "0:0 1:1");
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"setFrontendMapping", "RX", "0:0 1:1"});
        end

        function getFrontendMappingDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.getFrontendMapping = "0:0";
            result = dev.getFrontendMapping("TX");
            testCase.verifyEqual(result, "0:0");
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"getFrontendMapping", "TX"});
        end

        function getNumChannelsDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.getNumChannels = 2;
            result = dev.getNumChannels("RX");
            testCase.verifyEqual(result, 2);
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"getNumChannels", "RX"});
        end

        function getChannelInfoDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.getChannelInfo = ...
                dictionary("name", "ch0");
            result = dev.getChannelInfo("RX", 0);
            testCase.verifyEqual(result("name"), "ch0");
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"getChannelInfo", "RX", 0});
        end

        function getFullDuplexDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.getFullDuplex = true;
            result = dev.getFullDuplex("RX", 0);
            testCase.verifyTrue(result);
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"getFullDuplex", "RX", 0});
        end

        % --- Stream Discovery ---

        function getStreamFormatsDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.getStreamFormats = ...
                ["CF32", "CS16"];
            result = dev.getStreamFormats("RX", 0);
            testCase.verifyEqual(result, ["CF32", "CS16"]);
        end

        function getNativeStreamFormatDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.getNativeStreamFormat = ...
                {"CS16", 32767.0};
            [fmt, fs] = dev.getNativeStreamFormat("RX", 0);
            testCase.verifyEqual(fmt, "CS16");
            testCase.verifyEqual(fs, 32767.0);
        end

        function getStreamArgsInfoDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.getStreamArgsInfo = ...
                soapysdr.ArgInfo.empty(1, 0);
            result = dev.getStreamArgsInfo("RX", 0);
            testCase.verifyEmpty(result);
        end

        % --- Antenna ---

        function listAntennasDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.listAntennas = ["RX1", "RX2"];
            result = dev.listAntennas("RX", 0);
            testCase.verifyEqual(result, ["RX1", "RX2"]);
        end

        function setAntennaDelegates(testCase)
            dev = testCase.makeDevice();
            dev.setAntenna("RX", 0, "RX2");
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"setAntenna", "RX", 0, "RX2"});
        end

        function getAntennaDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.getAntenna = "RX1";
            result = dev.getAntenna("RX", 0);
            testCase.verifyEqual(result, "RX1");
        end

        % --- Frontend Corrections ---

        function hasDCOffsetModeDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.hasDCOffsetMode = true;
            result = dev.hasDCOffsetMode("RX", 0);
            testCase.verifyTrue(result);
        end

        function setDCOffsetModeDelegates(testCase)
            dev = testCase.makeDevice();
            dev.setDCOffsetMode("RX", 0, true);
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"setDCOffsetMode", "RX", 0, true});
        end

        function getDCOffsetModeDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.getDCOffsetMode = false;
            result = dev.getDCOffsetMode("RX", 0);
            testCase.verifyFalse(result);
        end

        function setDCOffsetDelegates(testCase)
            dev = testCase.makeDevice();
            dev.setDCOffset("RX", 0, complex(0.1, -0.2));
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"setDCOffset", "RX", 0, complex(0.1, -0.2)});
        end

        function getDCOffsetDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.getDCOffset = ...
                complex(0.01, -0.02);
            result = dev.getDCOffset("RX", 0);
            testCase.verifyEqual(result, complex(0.01, -0.02));
        end

        function setIQBalanceDelegates(testCase)
            dev = testCase.makeDevice();
            dev.setIQBalance("RX", 0, complex(1.0, 0.01));
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"setIQBalance", "RX", 0, complex(1.0, 0.01)});
        end

        function getIQBalanceDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.getIQBalance = ...
                complex(1.0, 0.0);
            result = dev.getIQBalance("RX", 0);
            testCase.verifyEqual(result, complex(1.0, 0.0));
        end

        function hasFrequencyCorrectionDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.hasFrequencyCorrection = true;
            result = dev.hasFrequencyCorrection("RX", 0);
            testCase.verifyTrue(result);
        end

        function setFrequencyCorrectionDelegates(testCase)
            dev = testCase.makeDevice();
            dev.setFrequencyCorrection("RX", 0, 5.5);
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"setFrequencyCorrection", "RX", 0, 5.5});
        end

        function getFrequencyCorrectionDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.getFrequencyCorrection = 3.2;
            result = dev.getFrequencyCorrection("RX", 0);
            testCase.verifyEqual(result, 3.2);
        end

        % --- Gain (with overload dispatch) ---

        function listGainsDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.listGains = ["LNA", "VGA"];
            result = dev.listGains("RX", 0);
            testCase.verifyEqual(result, ["LNA", "VGA"]);
        end

        function hasGainModeDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.hasGainMode = true;
            result = dev.hasGainMode("RX", 0);
            testCase.verifyTrue(result);
        end

        function setGainModeDelegates(testCase)
            dev = testCase.makeDevice();
            dev.setGainMode("RX", 0, true);
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"setGainMode", "RX", 0, true});
        end

        function getGainModeDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.getGainMode = false;
            result = dev.getGainMode("RX", 0);
            testCase.verifyFalse(result);
        end

        function setGainOverallDelegates(testCase)
            dev = testCase.makeDevice();
            dev.setGain("RX", 0, 30);
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"setGain", "RX", 0, 30});
        end

        function setGainElementDelegates(testCase)
            dev = testCase.makeDevice();
            dev.setGain("RX", 0, "LNA", 20);
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"setGainElement", "RX", 0, "LNA", 20});
        end

        function getGainOverallDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.getGain = 42.0;
            result = dev.getGain("RX", 0);
            testCase.verifyEqual(result, 42.0);
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"getGain", "RX", 0});
        end

        function getGainElementDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.getGainElement = 15.0;
            result = dev.getGain("RX", 0, "LNA");
            testCase.verifyEqual(result, 15.0);
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"getGainElement", "RX", 0, "LNA"});
        end

        function getGainRangeOverallDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.getGainRange = ...
                soapysdr.Range(0, 50, 1);
            result = dev.getGainRange("RX", 0);
            testCase.verifyEqual(result.Minimum, 0);
            testCase.verifyEqual(result.Maximum, 50);
            testCase.verifyEqual(result.Step, 1);
        end

        function getGainRangeElementDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.getGainElementRange = ...
                soapysdr.Range(0, 30, 0.5);
            result = dev.getGainRange("RX", 0, "LNA");
            testCase.verifyEqual(result.Maximum, 30);
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"getGainElementRange", "RX", 0, "LNA"});
        end

        % --- Frequency (with overload dispatch) ---

        function setFrequencyOverallDelegates(testCase)
            dev = testCase.makeDevice();
            dev.setFrequency("RX", 0, 1e9);
            call = testCase.Mock.Calls{1};
            testCase.verifyEqual(call{1}, "setFrequency");
            testCase.verifyEqual(call{2}, "RX");
            testCase.verifyEqual(call{3}, 0);
            testCase.verifyEqual(call{4}, 1e9);
        end

        function setFrequencyOverallWithArgsDelegates(testCase)
            dev = testCase.makeDevice();
            args = dictionary("OFFSET", "0");
            dev.setFrequency("RX", 0, 1e9, args);
            call = testCase.Mock.Calls{1};
            testCase.verifyEqual(call{1}, "setFrequency");
            testCase.verifyEqual(call{4}, 1e9);
            testCase.verifyEqual(call{5}("OFFSET"), "0");
        end

        function setFrequencyComponentDelegates(testCase)
            dev = testCase.makeDevice();
            dev.setFrequency("RX", 0, "RF", 900e6);
            call = testCase.Mock.Calls{1};
            testCase.verifyEqual(call{1}, "setFrequencyComponent");
            testCase.verifyEqual(call{4}, "RF");
            testCase.verifyEqual(call{5}, 900e6);
        end

        function setFrequencyComponentWithArgsDelegates(testCase)
            dev = testCase.makeDevice();
            args = dictionary("OFFSET", "1000");
            dev.setFrequency("RX", 0, "RF", 900e6, args);
            call = testCase.Mock.Calls{1};
            testCase.verifyEqual(call{1}, "setFrequencyComponent");
            testCase.verifyEqual(call{5}, 900e6);
            testCase.verifyEqual(call{6}("OFFSET"), "1000");
        end

        function getFrequencyOverallDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.getFrequency = 1.5e9;
            result = dev.getFrequency("RX", 0);
            testCase.verifyEqual(result, 1.5e9);
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"getFrequency", "RX", 0});
        end

        function getFrequencyComponentDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.getFrequencyComponent = 100e6;
            result = dev.getFrequency("RX", 0, "BB");
            testCase.verifyEqual(result, 100e6);
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"getFrequencyComponent", "RX", 0, "BB"});
        end

        function listFrequenciesDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.listFrequencies = ["RF", "BB"];
            result = dev.listFrequencies("RX", 0);
            testCase.verifyEqual(result, ["RF", "BB"]);
        end

        function getFrequencyRangeOverallDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.getFrequencyRange = ...
                soapysdr.Range(70e6, 6e9, 0);
            result = dev.getFrequencyRange("RX", 0);
            testCase.verifyEqual(result.Minimum, 70e6);
            testCase.verifyEqual(result.Maximum, 6e9);
        end

        function getFrequencyRangeComponentDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.getFrequencyComponentRange = ...
                soapysdr.Range(0, 50e6, 0);
            result = dev.getFrequencyRange("RX", 0, "BB");
            testCase.verifyEqual(result.Maximum, 50e6);
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"getFrequencyComponentRange", "RX", 0, "BB"});
        end

        function getFrequencyArgsInfoDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.getFrequencyArgsInfo = ...
                soapysdr.ArgInfo.empty(1, 0);
            result = dev.getFrequencyArgsInfo("RX", 0);
            testCase.verifyEmpty(result);
        end

        % --- Sample Rate ---

        function setSampleRateDelegates(testCase)
            dev = testCase.makeDevice();
            dev.setSampleRate("RX", 0, 2.4e6);
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"setSampleRate", "RX", 0, 2.4e6});
        end

        function getSampleRateDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.getSampleRate = 1e6;
            result = dev.getSampleRate("RX", 0);
            testCase.verifyEqual(result, 1e6);
        end

        function getSampleRateRangeDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.getSampleRateRange = ...
                soapysdr.Range(225e3, 3.2e6, 0);
            result = dev.getSampleRateRange("RX", 0);
            testCase.verifyEqual(result.Minimum, 225e3);
            testCase.verifyEqual(result.Maximum, 3.2e6);
        end

        % --- Bandwidth ---

        function setBandwidthDelegates(testCase)
            dev = testCase.makeDevice();
            dev.setBandwidth("RX", 0, 1.5e6);
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"setBandwidth", "RX", 0, 1.5e6});
        end

        function getBandwidthDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.getBandwidth = 2e6;
            result = dev.getBandwidth("RX", 0);
            testCase.verifyEqual(result, 2e6);
        end

        function getBandwidthRangeDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.getBandwidthRange = ...
                soapysdr.Range(200e3, 8e6, 0);
            result = dev.getBandwidthRange("RX", 0);
            testCase.verifyEqual(result.Minimum, 200e3);
        end

        % --- Clocking ---

        function setMasterClockRateDelegates(testCase)
            dev = testCase.makeDevice();
            dev.setMasterClockRate(40e6);
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"setMasterClockRate", 40e6});
        end

        function getMasterClockRateDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.getMasterClockRate = 40e6;
            result = dev.getMasterClockRate();
            testCase.verifyEqual(result, 40e6);
        end

        function getMasterClockRatesDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.getMasterClockRates = ...
                soapysdr.Range(10e6, 80e6, 0);
            result = dev.getMasterClockRates();
            testCase.verifyEqual(result.Maximum, 80e6);
        end

        function listClockSourcesDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.listClockSources = ...
                ["internal", "external"];
            result = dev.listClockSources();
            testCase.verifyEqual(result, ["internal", "external"]);
        end

        function setClockSourceDelegates(testCase)
            dev = testCase.makeDevice();
            dev.setClockSource("external");
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"setClockSource", "external"});
        end

        function getClockSourceDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.getClockSource = "internal";
            result = dev.getClockSource();
            testCase.verifyEqual(result, "internal");
        end

        % --- Time ---

        function listTimeSourcesDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.listTimeSources = ...
                ["none", "PPS"];
            result = dev.listTimeSources();
            testCase.verifyEqual(result, ["none", "PPS"]);
        end

        function setTimeSourceDelegates(testCase)
            dev = testCase.makeDevice();
            dev.setTimeSource("PPS");
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"setTimeSource", "PPS"});
        end

        function getTimeSourceDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.getTimeSource = "none";
            result = dev.getTimeSource();
            testCase.verifyEqual(result, "none");
        end

        function hasHardwareTimeDefaultDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.hasHardwareTime = true;
            result = dev.hasHardwareTime();
            testCase.verifyTrue(result);
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"hasHardwareTime", ""});
        end

        function hasHardwareTimeNamedDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.hasHardwareTime = false;
            result = dev.hasHardwareTime("PPS");
            testCase.verifyFalse(result);
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"hasHardwareTime", "PPS"});
        end

        function getHardwareTimeDefaultDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.getHardwareTime = int64(123456789);
            result = dev.getHardwareTime();
            testCase.verifyEqual(result, int64(123456789));
        end

        function setHardwareTimeDefaultDelegates(testCase)
            dev = testCase.makeDevice();
            dev.setHardwareTime(int64(999));
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"setHardwareTime", int64(999), ""});
        end

        function setHardwareTimeNamedDelegates(testCase)
            dev = testCase.makeDevice();
            dev.setHardwareTime(int64(500), "PPS");
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"setHardwareTime", int64(500), "PPS"});
        end

        % --- Sensors ---

        function listSensorsDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.listSensors = ...
                ["temp", "voltage"];
            result = dev.listSensors();
            testCase.verifyEqual(result, ["temp", "voltage"]);
        end

        function getSensorInfoDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.getSensorInfo = ...
                soapysdr.ArgInfo(Key="temp", Type="float", ...
                    Units="C");
            result = dev.getSensorInfo("temp");
            testCase.verifyEqual(result.Key, "temp");
            testCase.verifyEqual(result.Units, "C");
        end

        function readSensorDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.readSensor = "45.2";
            result = dev.readSensor("temp");
            testCase.verifyEqual(result, "45.2");
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"readSensor", "temp"});
        end

        function listChannelSensorsDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.listChannelSensors = ...
                ["rssi"];
            result = dev.listChannelSensors("RX", 0);
            testCase.verifyEqual(result, "rssi");
        end

        function readChannelSensorDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.readChannelSensor = "-60";
            result = dev.readChannelSensor("RX", 0, "rssi");
            testCase.verifyEqual(result, "-60");
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"readChannelSensor", "RX", 0, "rssi"});
        end

        % --- Settings ---

        function getSettingInfoDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.getSettingInfo = ...
                soapysdr.ArgInfo.empty(1, 0);
            result = dev.getSettingInfo();
            testCase.verifyEmpty(result);
        end

        function writeSettingDelegates(testCase)
            dev = testCase.makeDevice();
            dev.writeSetting("agc_mode", "slow");
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"writeSetting", "agc_mode", "slow"});
        end

        function readSettingDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.readSetting = "fast";
            result = dev.readSetting("agc_mode");
            testCase.verifyEqual(result, "fast");
        end

        function writeChannelSettingDelegates(testCase)
            dev = testCase.makeDevice();
            dev.writeChannelSetting("RX", 0, "biastee", "true");
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"writeChannelSetting", "RX", 0, ...
                "biastee", "true"});
        end

        function readChannelSettingDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.readChannelSetting = "false";
            result = dev.readChannelSetting("RX", 0, "biastee");
            testCase.verifyEqual(result, "false");
        end

        % --- GPIO (with mask overload) ---

        function listGPIOBanksDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.listGPIOBanks = ["MAIN"];
            result = dev.listGPIOBanks();
            testCase.verifyEqual(result, "MAIN");
        end

        function writeGPIOWithoutMaskDelegates(testCase)
            dev = testCase.makeDevice();
            dev.writeGPIO("MAIN", uint32(255));
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"writeGPIO", "MAIN", uint32(255), []});
        end

        function writeGPIOWithMaskDelegates(testCase)
            dev = testCase.makeDevice();
            dev.writeGPIO("MAIN", uint32(1), uint32(1));
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"writeGPIO", "MAIN", uint32(1), uint32(1)});
        end

        function readGPIODelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.readGPIO = uint32(170);
            result = dev.readGPIO("MAIN");
            testCase.verifyEqual(result, uint32(170));
        end

        function writeGPIODirWithoutMaskDelegates(testCase)
            dev = testCase.makeDevice();
            dev.writeGPIODir("MAIN", uint32(15));
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"writeGPIODir", "MAIN", uint32(15), []});
        end

        function writeGPIODirWithMaskDelegates(testCase)
            dev = testCase.makeDevice();
            dev.writeGPIODir("MAIN", uint32(1), uint32(3));
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"writeGPIODir", "MAIN", uint32(1), uint32(3)});
        end

        function readGPIODirDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.readGPIODir = uint32(255);
            result = dev.readGPIODir("MAIN");
            testCase.verifyEqual(result, uint32(255));
        end

        % --- Register ---

        function listRegisterInterfacesDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.listRegisterInterfaces = ...
                ["SPI0"];
            result = dev.listRegisterInterfaces();
            testCase.verifyEqual(result, "SPI0");
        end

        function writeRegisterDelegates(testCase)
            dev = testCase.makeDevice();
            dev.writeRegister("SPI0", uint32(16), uint32(42));
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"writeRegister", "SPI0", uint32(16), uint32(42)});
        end

        function readRegisterDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.readRegister = uint32(99);
            result = dev.readRegister("SPI0", uint32(16));
            testCase.verifyEqual(result, uint32(99));
        end

        function writeRegistersDelegates(testCase)
            dev = testCase.makeDevice();
            dev.writeRegisters("SPI0", uint32(0), ...
                uint32([1, 2, 3]));
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"writeRegisters", "SPI0", uint32(0), ...
                uint32([1, 2, 3])});
        end

        function readRegistersDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.readRegisters = ...
                uint32([10, 20, 30]);
            result = dev.readRegisters("SPI0", uint32(0), 3);
            testCase.verifyEqual(result, uint32([10, 20, 30]));
        end

        % --- I2C ---

        function writeI2CDelegates(testCase)
            dev = testCase.makeDevice();
            dev.writeI2C(int32(80), uint8([1, 2, 3]));
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"writeI2C", int32(80), uint8([1, 2, 3])});
        end

        function readI2CDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.readI2C = uint8([4, 5]);
            result = dev.readI2C(int32(80), 2);
            testCase.verifyEqual(result, uint8([4, 5]));
        end

        % --- SPI ---

        function transactSPIDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.transactSPI = uint32(255);
            result = dev.transactSPI(int32(0), uint32(100), 8);
            testCase.verifyEqual(result, uint32(255));
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"transactSPI", int32(0), uint32(100), 8});
        end

        % --- UART ---

        function listUARTsDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.listUARTs = ["GPS"];
            result = dev.listUARTs();
            testCase.verifyEqual(result, "GPS");
        end

        function writeUARTDelegates(testCase)
            dev = testCase.makeDevice();
            dev.writeUART("GPS", "hello");
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"writeUART", "GPS", "hello"});
        end

        function readUARTDelegates(testCase)
            dev = testCase.makeDevice();
            testCase.Mock.Returns.readUART = "OK";
            result = dev.readUART("GPS", int64(5000));
            testCase.verifyEqual(result, "OK");
            testCase.verifyEqual(testCase.Mock.Calls{1}, ...
                {"readUART", "GPS", int64(5000)});
        end
    end

    methods (Access=private)
        function be = ConstructMockBackend(testCase, kwargs)
            testCase.Mock.setConstructorArgs(kwargs);
            be = testCase.Mock;
        end

        function dev = makeDevice(testCase)
            dev = soapysdr.Device( ...
                BackendConstructor=@(kwargs) ...
                    testCase.ConstructMockBackend(kwargs));
        end
    end

end
