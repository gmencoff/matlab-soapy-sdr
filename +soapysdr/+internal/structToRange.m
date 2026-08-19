function result = structToRange(s)
%STRUCTTORANGE Convert a MEX struct to a soapysdr.Range object.
%   result = structToRange(s) converts a scalar struct with fields
%   Minimum, Maximum, Step to a soapysdr.Range.

    result = soapysdr.Range(s.Minimum, s.Maximum, s.Step);
end
