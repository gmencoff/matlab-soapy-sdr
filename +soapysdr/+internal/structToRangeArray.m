function result = structToRangeArray(s)
%STRUCTTORANGEARRAY Convert a MEX struct array to soapysdr.Range array.
%   result = structToRangeArray(s) converts a 1xN struct array with
%   fields Minimum, Maximum, Step to a 1xN array of soapysdr.Range.

    n = numel(s);
    if n == 0
        result = soapysdr.Range.empty(1, 0);
        return
    end
    result(1, n) = soapysdr.Range();
    for i = 1:n
        result(i) = soapysdr.Range( ...
            s(i).Minimum, s(i).Maximum, s(i).Step);
    end
end
