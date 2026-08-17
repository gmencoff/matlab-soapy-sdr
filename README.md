# SoapySDR for MATLAB

MATLAB interface to [SoapySDR](https://github.com/pothosware/SoapySDR) for software-defined radio device access.

## Prerequisites

- MATLAB R2026a (Windows 64-bit)
- A compatible [SoapySDR](https://github.com/pothosware/SoapySDR) installation
- The appropriate SoapySDR device module for your hardware (e.g., SoapyRTLSDR, SoapyHackRF)

SoapySDR is **not** bundled with this toolbox. You must install SoapySDR and the required device modules separately.

## Installation

1. Download the latest `.mltbx` from [GitHub Releases](../../releases).
2. Open the file in MATLAB or install programmatically:

```matlab
matlab.addons.toolbox.installToolbox("SoapySDR-for-MATLAB-0.1.0.mltbx")
```

### Development Builds

Development builds from the latest `main` branch are available as GitHub Actions artifacts on successful workflow runs.

## License

[MIT](LICENSE)
