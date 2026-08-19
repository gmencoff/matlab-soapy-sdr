function result = structToArgInfoArray(s)
%STRUCTTOARGINFOARRAY Convert a MEX struct array to ArgInfo array.
%   result = structToArgInfoArray(s) converts a 1xN struct array to
%   a 1xN array of soapysdr.ArgInfo objects.

    n = numel(s);
    if n == 0
        result = soapysdr.ArgInfo.empty(1, 0);
        return
    end
    result(1, n) = soapysdr.ArgInfo();
    for i = 1:n
        result(i) = soapysdr.internal.structToArgInfo(s(i));
    end
end
