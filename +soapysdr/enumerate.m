function devices = enumerate()
%ENUMERATE Discover available SoapySDR devices.
%   DEVICES = soapysdr.enumerate() returns a cell array of dictionary
%   objects, one per discovered SoapySDR device. Each dictionary maps
%   string keys to string values describing the device (e.g., "driver",
%   "label", "serial").
%
%   Use the returned dictionary to construct a device:
%       devices = soapysdr.enumerate();
%       dev = soapysdr.Device(devices{1});

    devices = soapysdr.internal.enumerate();

end
