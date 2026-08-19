classdef (Hidden) ArgInfo
%ARGINFO Metadata describing a device argument or setting.
%   An ArgInfo object describes a configurable parameter exposed by a
%   SoapySDR device driver, including its key, default value, human-
%   readable name, description, units, data type, valid range, and
%   enumerated options.
%
%   info = soapysdr.ArgInfo(Key=key, Value=value, ...) creates an ArgInfo
%   with the specified fields.
%
%   Properties:
%       Key         - Unique identifier for this argument (string)
%       Value       - Default or current value as a string (string)
%       Name        - Human-readable display name (string)
%       Description - Longer description of the argument (string)
%       Units       - Units for the value, e.g. "dB", "Hz" (string)
%       Type        - Data type: "bool", "int", "float", or "string"
%       Range       - Valid numeric range (soapysdr.Range)
%       Options     - Enumerated valid option values (string array)
%       OptionNames - Human-readable names for Options (string array)

    properties (SetAccess = immutable)
        Key (1,1) string
        Value (1,1) string
        Name (1,1) string
        Description (1,1) string
        Units (1,1) string
        Type (1,1) string {mustBeMember(Type, ...
            ["", "bool", "int", "float", "string"])}
        Range (1,1) soapysdr.Range
        Options (1,:) string
        OptionNames (1,:) string
    end

    methods
        function obj = ArgInfo(options)
            arguments
                options.Key (1,1) string = ""
                options.Value (1,1) string = ""
                options.Name (1,1) string = ""
                options.Description (1,1) string = ""
                options.Units (1,1) string = ""
                options.Type (1,1) string {mustBeMember(options.Type, ...
                    ["", "bool", "int", "float", "string"])} = ""
                options.Range (1,1) soapysdr.Range = soapysdr.Range()
                options.Options (1,:) string = string.empty
                options.OptionNames (1,:) string = string.empty
            end
            obj.Key = options.Key;
            obj.Value = options.Value;
            obj.Name = options.Name;
            obj.Description = options.Description;
            obj.Units = options.Units;
            obj.Type = options.Type;
            obj.Range = options.Range;
            obj.Options = options.Options;
            obj.OptionNames = options.OptionNames;
        end
    end

end
