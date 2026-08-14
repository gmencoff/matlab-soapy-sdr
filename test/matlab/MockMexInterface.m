classdef MockMexInterface < soapysdr.internal.MexInterface
%MOCKMEXINTERFACE Test double for soapysdr.internal.MexInterface.
%   Provides configurable return values or error behavior for unit
%   testing the enumerate function without requiring a compiled MEX.

    properties
        EnumerateResult cell = {}
        ShouldError (1,1) logical = false
        ErrorIdentifier string = "soapysdr:mex:EnumerationFailed"
        ErrorMessage string = "Mock enumeration error"
    end

    methods
        function obj = MockMexInterface(result, options)
        %MOCKMEXINTERFACE Construct mock with predetermined output.
            arguments
                result cell = {}
                options.ShouldError (1,1) logical = false
                options.ErrorIdentifier string = ...
                    "soapysdr:mex:EnumerationFailed"
                options.ErrorMessage string = ...
                    "Mock enumeration error"
            end
            obj.EnumerateResult = result;
            obj.ShouldError = options.ShouldError;
            obj.ErrorIdentifier = options.ErrorIdentifier;
            obj.ErrorMessage = options.ErrorMessage;
        end

        function raw = enumerate(obj)
        %ENUMERATE Return canned data or throw configured error.
            if obj.ShouldError
                error(obj.ErrorIdentifier, obj.ErrorMessage);
            end
            raw = obj.EnumerateResult;
        end
    end

end
