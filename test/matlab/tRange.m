classdef tRange < matlab.unittest.TestCase
%TRANGE Unit tests for soapysdr.Range value class.

    methods (Test)
        function defaultConstruction(testCase)
            r = soapysdr.Range();
            testCase.verifyEqual(r.Minimum, 0);
            testCase.verifyEqual(r.Maximum, 0);
            testCase.verifyEqual(r.Step, 0);
        end

        function fullConstruction(testCase)
            r = soapysdr.Range(1.5, 100.0, 0.5);
            testCase.verifyEqual(r.Minimum, 1.5);
            testCase.verifyEqual(r.Maximum, 100.0);
            testCase.verifyEqual(r.Step, 0.5);
        end

        function twoArgConstruction(testCase)
            r = soapysdr.Range(0, 50);
            testCase.verifyEqual(r.Minimum, 0);
            testCase.verifyEqual(r.Maximum, 50);
            testCase.verifyEqual(r.Step, 0);
        end

        function negativeValues(testCase)
            r = soapysdr.Range(-10, 10, 0.1);
            testCase.verifyEqual(r.Minimum, -10);
            testCase.verifyEqual(r.Maximum, 10);
            testCase.verifyEqual(r.Step, 0.1);
        end

        function arrayOfRanges(testCase)
            r(1) = soapysdr.Range(0, 100, 1);
            r(2) = soapysdr.Range(200, 500, 5);
            testCase.verifySize(r, [1, 2]);
            testCase.verifyEqual(r(1).Minimum, 0);
            testCase.verifyEqual(r(2).Maximum, 500);
        end

        function emptyArray(testCase)
            r = soapysdr.Range.empty();
            testCase.verifyEmpty(r);
            testCase.verifyClass(r, "soapysdr.Range");
        end

        function propertiesAreImmutable(testCase)
            r = soapysdr.Range(1, 2, 3);
            testCase.verifyError(@() setField(r, "Minimum", 5), ...
                "MATLAB:class:SetProhibited");
        end
    end

end

function setField(obj, field, value)
    obj.(field) = value;
end
