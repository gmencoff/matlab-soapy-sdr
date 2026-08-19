classdef StreamFlags
%STREAMFLAGS Bitmask constants for SoapySDR stream operations.
%   Combine flags with bitor:
%       flags = bitor(soapysdr.StreamFlags.HAS_TIME, ...
%                     soapysdr.StreamFlags.END_BURST);
%
%   See also: soapysdr.Device.readStream, soapysdr.Device.writeStream

    properties (Constant)
        HAS_TIME = int32(1)
        END_BURST = int32(2)
        ONE_PACKET = int32(4)
        MORE_FRAGMENTS = int32(8)
        WAIT_TRIGGER = int32(16)
    end

end
