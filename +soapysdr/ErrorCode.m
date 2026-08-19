classdef (Hidden) ErrorCode
%ERRORCODE Error code constants returned by SoapySDR stream operations.
%   Check return values from readStream/writeStream against these:
%       [data, numRead, flags, timeNs] = dev.readStream(h, 1024);
%       if numRead == soapysdr.ErrorCode.TIMEOUT
%           disp("Read timed out");
%       end
%
%   See also: soapysdr.Device.readStream, soapysdr.Device.writeStream

    properties (Constant)
        TIMEOUT = int32(-1)
        STREAM_ERROR = int32(-2)
        CORRUPTION = int32(-3)
        OVERFLOW = int32(-4)
        UNDERFLOW = int32(-5)
        NOT_SUPPORTED = int32(-6)
        TIME_ERROR = int32(-7)
    end

end
