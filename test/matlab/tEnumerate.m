classdef tEnumerate < matlab.unittest.TestCase
%TENUMERATE Unit tests for soapysdr.internal.enumerate.
%   Tests the MATLAB conversion layer using a mock MexInterface,
%   independent of any compiled MEX or SoapySDR installation.

    methods (Test)
        function singleDevice(testCase)
            raw = {
                ["driver" "rtlsdr"
                 "label"  "Generic RTL2832U"
                 "serial" "00000001"]
            };
            mock = MockMexInterface(raw);

            devices = soapysdr.internal.enumerate(mock);

            testCase.verifyNumElements(devices, 1);
            testCase.verifyEqual(devices{1}("driver"), "rtlsdr");
            testCase.verifyEqual( ...
                devices{1}("label"), "Generic RTL2832U");
            testCase.verifyEqual( ...
                devices{1}("serial"), "00000001");
        end

        function multipleDevices(testCase)
            raw = {
                ["driver" "rtlsdr"
                 "serial" "TEST001"]

                ["driver" "uhd"
                 "serial" "TEST002"]
            };
            mock = MockMexInterface(raw);

            devices = soapysdr.internal.enumerate(mock);

            testCase.verifyNumElements(devices, 2);
            testCase.verifyEqual( ...
                devices{1}("driver"), "rtlsdr");
            testCase.verifyEqual( ...
                devices{1}("serial"), "TEST001");
            testCase.verifyEqual( ...
                devices{2}("driver"), "uhd");
            testCase.verifyEqual( ...
                devices{2}("serial"), "TEST002");
        end

        function zeroDevices(testCase)
            mock = MockMexInterface({});

            devices = soapysdr.internal.enumerate(mock);

            testCase.verifyEmpty(devices);
        end

        function arbitraryKeys(testCase)
            raw = {
                ["driver"               "custom"
                 "special_vendor_option" "vendor_value_42"
                 "another.weird.key"    "value with spaces"]
            };
            mock = MockMexInterface(raw);

            devices = soapysdr.internal.enumerate(mock);

            testCase.verifyEqual( ...
                devices{1}("special_vendor_option"), ...
                "vendor_value_42");
            testCase.verifyEqual( ...
                devices{1}("another.weird.key"), ...
                "value with spaces");
        end

        function emptyValues(testCase)
            raw = {
                ["driver" "test"
                 "serial" ""]
            };
            mock = MockMexInterface(raw);

            devices = soapysdr.internal.enumerate(mock);

            testCase.verifyEqual(devices{1}("serial"), "");
        end

        function errorPropagation(testCase)
            mock = MockMexInterface({}, ...
                ShouldError=true, ...
                ErrorIdentifier= ...
                    "soapysdr:mex:EnumerationFailed", ...
                ErrorMessage= ...
                    "SoapySDR enumeration failed");

            testCase.verifyError( ...
                @() soapysdr.internal.enumerate(mock), ...
                "soapysdr:mex:EnumerationFailed");
        end
    end

end
