classdef tConverters < matlab.unittest.TestCase
%TCONVERTERS Unit tests for struct-to-object converter functions.

    methods (Test)
        % --- structToRange ---

        function structToRangeBasic(testCase)
            s.Minimum = 10;
            s.Maximum = 100;
            s.Step = 5;
            r = soapysdr.internal.structToRange(s);
            testCase.verifyClass(r, "soapysdr.Range");
            testCase.verifyEqual(r.Minimum, 10);
            testCase.verifyEqual(r.Maximum, 100);
            testCase.verifyEqual(r.Step, 5);
        end

        function structToRangeZeroStep(testCase)
            s.Minimum = 70e6;
            s.Maximum = 6e9;
            s.Step = 0;
            r = soapysdr.internal.structToRange(s);
            testCase.verifyEqual(r.Step, 0);
        end

        % --- structToRangeArray ---

        function structToRangeArrayEmpty(testCase)
            s = struct("Minimum", {}, "Maximum", {}, "Step", {});
            r = soapysdr.internal.structToRangeArray(s);
            testCase.verifyEmpty(r);
            testCase.verifyClass(r, "soapysdr.Range");
        end

        function structToRangeArraySingle(testCase)
            s.Minimum = 1;
            s.Maximum = 2;
            s.Step = 0.5;
            r = soapysdr.internal.structToRangeArray(s);
            testCase.verifyEqual(numel(r), 1);
            testCase.verifyEqual(r(1).Minimum, 1);
            testCase.verifyEqual(r(1).Maximum, 2);
        end

        function structToRangeArrayMultiple(testCase)
            s(1).Minimum = 0;
            s(1).Maximum = 10;
            s(1).Step = 1;
            s(2).Minimum = 20;
            s(2).Maximum = 50;
            s(2).Step = 0;
            r = soapysdr.internal.structToRangeArray(s);
            testCase.verifyEqual(numel(r), 2);
            testCase.verifyEqual(r(1).Maximum, 10);
            testCase.verifyEqual(r(2).Minimum, 20);
            testCase.verifyEqual(r(2).Step, 0);
        end

        % --- structToArgInfo ---

        function structToArgInfoBasic(testCase)
            s.Key = "gain";
            s.Value = "30";
            s.Name = "Gain";
            s.Description = "Overall gain";
            s.Units = "dB";
            s.Type = "float";
            s.Range = struct("Minimum", 0, "Maximum", 73, "Step", 1);
            s.Options = ["low", "high"];
            s.OptionNames = ["Low", "High"];
            info = soapysdr.internal.structToArgInfo(s);
            testCase.verifyClass(info, "soapysdr.ArgInfo");
            testCase.verifyEqual(info.Key, "gain");
            testCase.verifyEqual(info.Value, "30");
            testCase.verifyEqual(info.Name, "Gain");
            testCase.verifyEqual(info.Description, "Overall gain");
            testCase.verifyEqual(info.Units, "dB");
            testCase.verifyEqual(info.Type, "float");
            testCase.verifyEqual(info.Range.Minimum, 0);
            testCase.verifyEqual(info.Range.Maximum, 73);
            testCase.verifyEqual(info.Range.Step, 1);
            testCase.verifyEqual(info.Options, ["low", "high"]);
            testCase.verifyEqual(info.OptionNames, ["Low", "High"]);
        end

        function structToArgInfoEmptyOptions(testCase)
            s.Key = "mode";
            s.Value = "auto";
            s.Name = "Mode";
            s.Description = "Operating mode";
            s.Units = "";
            s.Type = "string";
            s.Range = struct("Minimum", 0, "Maximum", 0, "Step", 0);
            s.Options = string.empty;
            s.OptionNames = string.empty;
            info = soapysdr.internal.structToArgInfo(s);
            testCase.verifyEmpty(info.Options);
            testCase.verifyEmpty(info.OptionNames);
        end

        function structToArgInfoBoolType(testCase)
            s.Key = "agc";
            s.Value = "true";
            s.Name = "AGC";
            s.Description = "Auto gain";
            s.Units = "";
            s.Type = "bool";
            s.Range = struct("Minimum", 0, "Maximum", 0, "Step", 0);
            s.Options = string.empty;
            s.OptionNames = string.empty;
            info = soapysdr.internal.structToArgInfo(s);
            testCase.verifyEqual(info.Type, "bool");
        end

        % --- structToArgInfoArray ---

        function structToArgInfoArrayEmpty(testCase)
            s = struct("Key", {}, "Value", {}, "Name", {}, ...
                "Description", {}, "Units", {}, "Type", {}, ...
                "Range", {}, "Options", {}, "OptionNames", {});
            result = soapysdr.internal.structToArgInfoArray(s);
            testCase.verifyEmpty(result);
            testCase.verifyClass(result, "soapysdr.ArgInfo");
        end

        function structToArgInfoArraySingle(testCase)
            s.Key = "freq";
            s.Value = "100e6";
            s.Name = "Frequency";
            s.Description = "Center freq";
            s.Units = "Hz";
            s.Type = "float";
            s.Range = struct("Minimum", 70e6, "Maximum", 6e9, "Step", 0);
            s.Options = string.empty;
            s.OptionNames = string.empty;
            result = soapysdr.internal.structToArgInfoArray(s);
            testCase.verifyEqual(numel(result), 1);
            testCase.verifyEqual(result(1).Key, "freq");
        end

        function structToArgInfoArrayMultiple(testCase)
            s(1).Key = "a";
            s(1).Value = "1";
            s(1).Name = "A";
            s(1).Description = "First";
            s(1).Units = "";
            s(1).Type = "int";
            s(1).Range = struct("Minimum", 0, "Maximum", 10, "Step", 1);
            s(1).Options = string.empty;
            s(1).OptionNames = string.empty;
            s(2).Key = "b";
            s(2).Value = "2";
            s(2).Name = "B";
            s(2).Description = "Second";
            s(2).Units = "V";
            s(2).Type = "float";
            s(2).Range = struct("Minimum", 0, "Maximum", 5, "Step", 0.1);
            s(2).Options = ["x", "y"];
            s(2).OptionNames = ["X", "Y"];
            result = soapysdr.internal.structToArgInfoArray(s);
            testCase.verifyEqual(numel(result), 2);
            testCase.verifyEqual(result(1).Key, "a");
            testCase.verifyEqual(result(1).Type, "int");
            testCase.verifyEqual(result(2).Key, "b");
            testCase.verifyEqual(result(2).Units, "V");
            testCase.verifyEqual(result(2).Options, ["x", "y"]);
        end

        % --- kwargsToDictionary ---

        function kwargsToDictionaryBasic(testCase)
            raw = ["key1", "val1"; "key2", "val2"];
            d = soapysdr.internal.kwargsToDictionary(raw);
            testCase.verifyClass(d, "dictionary");
            testCase.verifyEqual(d("key1"), "val1");
            testCase.verifyEqual(d("key2"), "val2");
        end

        function kwargsToDictionarySingleEntry(testCase)
            raw = ["serial", "ABC123"];
            d = soapysdr.internal.kwargsToDictionary(raw);
            testCase.verifyEqual(d("serial"), "ABC123");
        end

        function kwargsToDictionaryEmpty(testCase)
            raw = strings(0, 2);
            d = soapysdr.internal.kwargsToDictionary(raw);
            testCase.verifyClass(d, "dictionary");
            testCase.verifyEqual(d.numEntries, 0);
        end
    end

end
