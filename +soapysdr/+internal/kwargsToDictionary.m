function dict = kwargsToDictionary(raw)
%KWARGSTODICTIONARY Convert an N-by-2 string array to a dictionary.
%   DICT = kwargsToDictionary(RAW) converts an N-by-2 string array of
%   key-value pairs (as returned by the MEX layer) into a MATLAB
%   dictionary mapping string keys to string values.
%
%   If RAW is empty, returns an empty dictionary.

    if isempty(raw)
        dict = dictionary(string.empty, string.empty);
    else
        dict = dictionary(raw(:,1), raw(:,2));
    end

end
