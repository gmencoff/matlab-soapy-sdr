classdef tArgInfo < matlab.unittest.TestCase
%TARGINFO Unit tests for soapysdr.ArgInfo value class.

    methods (Test)
        function defaultConstruction(testCase)
            info = soapysdr.ArgInfo();
            testCase.verifyEqual(info.Key, "");
            testCase.verifyEqual(info.Value, "");
            testCase.verifyEqual(info.Name, "");
            testCase.verifyEqual(info.Description, "");
            testCase.verifyEqual(info.Units, "");
            testCase.verifyEqual(info.Type, "");
            testCase.verifyEqual(info.Range, soapysdr.Range());
            testCase.verifyEmpty(info.Options);
            testCase.verifyEmpty(info.OptionNames);
        end

        function fullConstruction(testCase)
            r = soapysdr.Range(0, 100, 1);
            info = soapysdr.ArgInfo( ...
                Key="gain", ...
                Value="50", ...
                Name="Gain", ...
                Description="Overall gain setting", ...
                Units="dB", ...
                Type="float", ...
                Range=r, ...
                Options=["low", "medium", "high"], ...
                OptionNames=["Low", "Medium", "High"]);

            testCase.verifyEqual(info.Key, "gain");
            testCase.verifyEqual(info.Value, "50");
            testCase.verifyEqual(info.Name, "Gain");
            testCase.verifyEqual(info.Description, "Overall gain setting");
            testCase.verifyEqual(info.Units, "dB");
            testCase.verifyEqual(info.Type, "float");
            testCase.verifyEqual(info.Range.Minimum, 0);
            testCase.verifyEqual(info.Range.Maximum, 100);
            testCase.verifyEqual(info.Range.Step, 1);
            testCase.verifyEqual(info.Options, ["low", "medium", "high"]);
            testCase.verifyEqual(info.OptionNames, ...
                ["Low", "Medium", "High"]);
        end

        function partialConstruction(testCase)
            info = soapysdr.ArgInfo(Key="freq", Type="float");
            testCase.verifyEqual(info.Key, "freq");
            testCase.verifyEqual(info.Type, "float");
            testCase.verifyEqual(info.Value, "");
        end

        function validTypes(testCase)
            types = ["bool", "int", "float", "string"];
            for i = 1:numel(types)
                info = soapysdr.ArgInfo(Type=types(i));
                testCase.verifyEqual(info.Type, types(i));
            end
        end

        function invalidTypeThrows(testCase)
            testCase.verifyError( ...
                @() soapysdr.ArgInfo(Type="complex"), ...
                "MATLAB:validators:mustBeMember");
        end

        function embeddedRange(testCase)
            r = soapysdr.Range(-20, 60, 0.5);
            info = soapysdr.ArgInfo(Range=r);
            testCase.verifyEqual(info.Range.Minimum, -20);
            testCase.verifyEqual(info.Range.Maximum, 60);
            testCase.verifyEqual(info.Range.Step, 0.5);
        end

        function emptyOptionsAndOptionNames(testCase)
            info = soapysdr.ArgInfo(Key="test");
            testCase.verifyEmpty(info.Options);
            testCase.verifyEmpty(info.OptionNames);
            testCase.verifyClass(info.Options, "string");
            testCase.verifyClass(info.OptionNames, "string");
        end

        function arrayOfArgInfo(testCase)
            info(1) = soapysdr.ArgInfo(Key="a", Type="int");
            info(2) = soapysdr.ArgInfo(Key="b", Type="string");
            testCase.verifySize(info, [1, 2]);
            testCase.verifyEqual(info(1).Key, "a");
            testCase.verifyEqual(info(2).Key, "b");
        end

        function emptyArray(testCase)
            info = soapysdr.ArgInfo.empty();
            testCase.verifyEmpty(info);
            testCase.verifyClass(info, "soapysdr.ArgInfo");
        end

        function propertiesAreImmutable(testCase)
            info = soapysdr.ArgInfo(Key="test");
            testCase.verifyError(@() setField(info, "Key", "other"), ...
                "MATLAB:class:SetProhibited");
        end
    end

end

function setField(obj, field, value)
    obj.(field) = value;
end
