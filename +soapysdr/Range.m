classdef Range
%RANGE Represents a numeric range with minimum, maximum, and step.
%   A Range object holds the minimum, maximum, and step size for a
%   SoapySDR parameter range (e.g., gain, frequency, sample rate).
%
%   r = soapysdr.Range(minimum, maximum, step) creates a Range with the
%   specified bounds and step size.
%
%   r = soapysdr.Range(minimum, maximum) creates a Range with step = 0.
%
%   r = soapysdr.Range() creates a Range with all fields set to 0.
%
%   Properties:
%       Minimum - Lower bound of the range (double)
%       Maximum - Upper bound of the range (double)
%       Step    - Step size within the range (double), 0 means continuous

    properties (SetAccess = immutable)
        Minimum (1,1) double
        Maximum (1,1) double
        Step (1,1) double
    end

    methods
        function obj = Range(minimum, maximum, step)
            arguments
                minimum (1,1) double = 0
                maximum (1,1) double = 0
                step (1,1) double = 0
            end
            obj.Minimum = minimum;
            obj.Maximum = maximum;
            obj.Step = step;
        end
    end

end
