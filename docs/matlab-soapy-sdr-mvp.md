# MATLAB SoapySDR MVP Implementation Plan

## 1. Objective

Create the first working vertical slice of a MATLAB add-on that interfaces with SoapySDR.

The first supported user-visible operation is:

```matlab
devices = soapysdr.internal.enumerate();
```

This function must enumerate devices known to the user's installed SoapySDR runtime and return them as MATLAB data.

The implementation should establish the architecture that later supports:

```matlab
soapysdr.find()
soapysdr.Device(...)
device.rx(...)
device.tx(...)
```

but **do not implement those APIs yet**.

The MVP targets:

- MATLAB R2026a
- Windows x64
- SoapySDR installed independently of the MATLAB add-on
- C++ MEX bridge
- SoapySDR C API
- vcpkg for reproducible native development dependencies
- MATLAB unit tests with dependency injection
- hardware-independent integration tests using a fake SoapySDR plugin
- Windows GitHub Actions CI

Do not bundle SoapySDR with the MATLAB add-on.

---

# 2. Architecture

Use the following boundary:

```text
MATLAB
  |
  | soapysdr.internal.enumerate()
  v
MexInterface
  |
  | enumerate()
  v
soapysdr_mex.mexw64
  |
  | SoapySDR C API
  v
User-installed SoapySDR
  |
  | plugin discovery
  v
Soapy device modules
  |
  v
SDR hardware
```

The MEX layer should be deliberately thin.

MATLAB owns:

- MATLAB-facing data types
- conversion to `dictionary`
- input validation
- MATLAB error semantics
- higher-level API design

The MEX layer owns:

- calls into the SoapySDR C API
- conversion between native Soapy data and simple MATLAB-native data
- native resource cleanup
- translation of native failures into errors that MATLAB can catch

SoapySDR owns:

- device discovery
- device-driver/plugin loading
- hardware abstraction
- eventual SoapyRemote support

Do not add MATLAB-specific local-vs-remote device logic. A future SoapyRemote module should remain below the SoapySDR abstraction.

---

# 3. Repository Layout

Start with approximately:

```text
matlab-soapysdr/
│
├── +soapysdr/
│   └── +internal/
│       ├── enumerate.m
│       ├── MexInterface.m
│       └── soapysdr_mex.mexw64       # generated, ignored by Git
│
├── src/
│   └── soapysdr_mex.cpp
│
├── build/
│   └── generated build artifacts     # ignored by Git
│
├── buildtools/
│   ├── buildMex.m
│   └── buildTestDriver.m
│
├── test/
│   ├── matlab/
│   │   ├── tEnumerate.m
│   │   └── tMexIntegration.m
│   │
│   └── soapy/
│       ├── CMakeLists.txt
│       └── MatlabTestDevice.cpp
│
├── triplets/
│   └── x64-windows-dynamic.cmake     # only if required
│
├── .github/
│   └── workflows/
│       └── windows.yml
│
├── vcpkg.json
├── .gitignore
├── README.md
└── LICENSE
```

Exact folder naming can change where MATLAB/package conventions make another structure clearly better, but preserve the architectural separation.

---

# 4. `soapysdr.internal.enumerate`

Implement:

```matlab
devices = soapysdr.internal.enumerate()
```

with an optional dependency-injection argument:

```matlab
devices = soapysdr.internal.enumerate(mexInterface)
```

The second form is an internal testing seam and does not need to be documented as user-facing API.

Suggested implementation:

```matlab
function devices = enumerate(mexInterface)

arguments
    mexInterface = soapysdr.internal.MexInterface()
end

raw = mexInterface.enumerate();

devices = cellfun( ...
    @(x) dictionary(x(:,1), x(:,2)), ...
    raw, ...
    UniformOutput=false);

end
```

The normal call remains:

```matlab
devices = soapysdr.internal.enumerate();
```

Return a cell array because each discovered device is a separate arbitrary Soapy key/value mapping.

Example:

```matlab
devices{1}

ans =

  dictionary with entries:

    "driver"    "rtlsdr"
    "label"     "Generic RTL2832U"
    "serial"    "00000001"
```

Do not convert Soapy arguments to MATLAB structs because Soapy keys are arbitrary strings and should not be constrained by MATLAB struct-field naming rules.

---

# 5. `MexInterface`

Create:

```matlab
soapysdr.internal.MexInterface
```

The purpose of this class is to isolate MATLAB code from the command-dispatch mechanism used by the underlying MEX file.

Initial implementation:

```matlab
classdef MexInterface

    methods
        function raw = enumerate(~)
            raw = soapysdr.internal.soapysdr_mex("enumerate");
        end
    end

end
```

Higher-level MATLAB code should call semantic operations:

```matlab
mexInterface.enumerate()
```

rather than:

```matlab
mexInterface.call("enumerate")
```

The fact that the native implementation uses command strings should remain encapsulated inside `MexInterface`.

This gives future room for methods such as:

```text
enumerate
makeDevice
unmakeDevice
getFrequency
setFrequency
setupStream
readStream
```

without exposing MEX command dispatch throughout the MATLAB package.

---

# 6. MEX Contract

For milestone 1, the native interface supports exactly one operation:

```matlab
raw = soapysdr.internal.soapysdr_mex("enumerate");
```

The returned data must be:

```text
cell array
    |
    +-- device 1: N x 2 MATLAB string array
    |
    +-- device 2: M x 2 MATLAB string array
    |
    ...
```

Example:

```matlab
raw = {
    ["driver" "rtlsdr"
     "label"  "RTL-SDR"
     "serial" "000001"]

    ["driver" "uhd"
     "label"  "USRP B210"
     "serial" "ABC123"]
};
```

Do **not** construct MATLAB `dictionary` objects inside C++.

The native boundary should only expose primitive MATLAB data.

---

# 7. MEX Implementation

Implement:

```text
src/soapysdr_mex.cpp
```

using MATLAB's modern C++ MEX API.

MEX files give native C++ code direct control over data conversion and memory management while being callable like MATLAB functions.

Use the SoapySDR **C API** rather than the C++ `Device` API.

The relevant enumeration call is:

```c
SoapySDRDevice_enumerate(...)
```

which returns a list of Soapy keyword-argument structures describing uniquely discovered devices. This function is part of SoapySDR's official C API.

Conceptually:

```cpp
size_t length = 0;

SoapySDRKwargs* devices =
    SoapySDRDevice_enumerate(nullptr, &length);
```

Pass `nullptr` for the initial implementation so enumeration is unfiltered.

Convert each returned `SoapySDRKwargs` into an `N x 2` MATLAB string array:

```text
key | value
----|------
... | ...
```

Place each string array into a MATLAB cell.

Ensure all memory returned by SoapySDR is released with the appropriate SoapySDR cleanup API.

Error handling must cover at least:

- invalid MEX operation name
- wrong number/type of MEX inputs
- failure returned by SoapySDR
- malformed/unexpected native data
- allocation failure where practical

Prefer MATLAB-specific error identifiers, for example:

```text
soapysdr:mex:InvalidOperation
soapysdr:mex:EnumerationFailed
```

Do not implement any device configuration or streaming yet.

---

# 8. Native Development Dependency Management

Use **vcpkg manifest mode** to define SoapySDR as a repository dependency.

vcpkg manifest mode allows dependencies and a baseline to be declared in a checked-in `vcpkg.json`, providing reproducible dependency resolution for development and CI.

Create:

```text
vcpkg.json
```

containing approximately:

```json
{
  "name": "matlab-soapysdr",
  "version-string": "0.1.0",
  "builtin-baseline": "<PINNED-VCPKG-COMMIT>",
  "dependencies": [
    "soapysdr"
  ]
}
```

Use a real pinned `builtin-baseline`, not a placeholder, when implementing. vcpkg baselines are intended to lock dependency resolution to a specific registry state.

Do not rely on:

```text
C:\Program Files\...
```

or an arbitrary developer-installed SoapySDK for compiling the MEX.

Both local development and CI should consume SoapySDR through the same checked-in vcpkg manifest.

Conceptually:

```text
Git repository
    |
    | vcpkg.json
    v
pinned vcpkg dependency graph
    |
    v
SoapySDR development files
    |
    +-- headers
    +-- import library
    +-- runtime DLL for tests
```

vcpkg is cross-platform, so this same dependency approach can later be extended to Linux and macOS. Triplets represent target platform/build configurations.

For MVP, support only:

```text
x64-windows
```

If the standard vcpkg SoapySDR package does not produce the shared-library layout needed by the project, create a custom dynamic triplet such as:

```text
triplets/x64-windows-dynamic.cmake
```

Do not statically embed SoapySDR into the released MEX.

---

# 9. Build-Time vs Runtime SoapySDR

Keep these concepts separate.

## Build environment

The developer/CI environment needs:

```text
SoapySDR headers
SoapySDR import/link library
SoapySDR DLL
C++ compiler supported by MATLAB R2026a
MATLAB R2026a
```

These should come from the pinned development setup.

## End-user environment

The user should only need:

```text
MATLAB add-on
precompiled soapysdr_mex.mexw64
user-installed SoapySDR runtime
user-installed Soapy hardware module(s)
```

The user does **not** need:

```text
C++ compiler
Soapy headers
Soapy import libraries
vcpkg
CMake
```

Do not bundle SoapySDR itself.

At runtime, Windows must be able to resolve the user-installed SoapySDR shared library when MATLAB loads the MEX.

For the MVP, rely on normal Windows DLL discovery.

If loading fails, provide a useful diagnostic rather than asking every user for an installation directory up front.

A future diagnostics API might include:

```matlab
soapysdr.version()
soapysdr.internal.diagnostics()
```

but do not implement those unless required to make enumeration robust.

---

# 10. SoapySDR Version Policy

The development environment should build and test against one pinned SoapySDR dependency.

Do **not** require end users to have exactly byte-for-byte the same package.

The eventual compatibility policy should be based on supported SoapySDR ABI/API compatibility.

Device modules themselves register against a Soapy ABI version; the official registry API accepts `SOAPY_SDR_ABI_VERSION` when registering device find/make functions.

For this MVP:

- pin the Soapy version used during development/CI
- document that runtime compatibility is initially validated against that version
- do not promise compatibility with arbitrary Soapy releases yet
- add broader compatibility testing later

---

# 11. MEX Build Script

Create:

```text
buildtools/buildMex.m
```

The build script should:

1. Locate the vcpkg-installed SoapySDR development files.
2. Determine include directory.
3. Determine import-library directory.
4. Invoke MATLAB `mex`.
5. Place the resulting MEX in the correct package location.
6. Fail clearly if dependencies are missing.

Conceptually:

```matlab
function buildMex(options)

arguments
    options.VcpkgRoot
    options.Triplet = "x64-windows"
end

% Resolve installed include/lib locations from vcpkg.
% Compile src/soapysdr_mex.cpp.
% Link against SoapySDR.
% Place soapysdr_mex.mexw64 under +soapysdr/+internal.

end
```

Avoid hard-coded machine-specific absolute paths.

The developer workflow should eventually be approximately:

```matlab
buildtools.buildMex(...)
```

followed by:

```matlab
soapysdr.internal.enumerate()
```

---

# 12. MATLAB Unit Tests

Use the MATLAB unit testing framework. MATLAB provides class/function-based unit testing and qualification APIs appropriate for this layer.

The unit tests for `enumerate.m` must **not require**:

- a compiled MEX
- SoapySDR
- hardware

Mock the `MexInterface` dependency.

Because `enumerate` accepts the interface as an optional argument:

```matlab
devices = soapysdr.internal.enumerate(mockMex);
```

tests can supply deterministic behavior.

Example mock result:

```matlab
raw = {
    ["driver" "matlab_test"
     "label"  "Test Device 1"
     "serial" "TEST001"]
};
```

Test at least:

### Single device

Verify:

```matlab
devices{1}("driver") == "matlab_test"
devices{1}("label") == "Test Device 1"
devices{1}("serial") == "TEST001"
```

### Multiple devices

Return two or more cells and verify each becomes a dictionary.

### Zero devices

Mock:

```matlab
{}
```

and verify:

```matlab
isempty(devices)
```

### Arbitrary keys

Use a key not known by the MATLAB package:

```text
special_vendor_option
```

and verify it is preserved.

This is important because the MATLAB layer must not impose a fixed Soapy discovery schema.

### Empty values

Verify empty Soapy values are preserved appropriately.

### MEX/interface error propagation

Mock `MexInterface.enumerate()` throwing an error and verify `enumerate()` does not silently suppress it.

Do not add tests for frequency/sample-rate/etc. yet.

---

# 13. Fake SoapySDR Device Module

Create a native SoapySDR plugin used only for integration testing.

Directory:

```text
test/soapy/
```

Use CMake for this component.

SoapySDR's registry API is explicitly intended for registering device `find` and `make` functions.

Create a fake driver named:

```text
matlab_test
```

The discovery function should deterministically return two devices:

```text
driver=matlab_test
label=MATLAB Test Device 1
serial=TEST001
```

and:

```text
driver=matlab_test
label=MATLAB Test Device 2
serial=TEST002
```

The test plugin must:

- link against the exact same vcpkg SoapySDR dependency used by the MEX
- register through the normal Soapy plugin mechanism
- be discoverable only when explicitly put on the plugin search path for tests
- never be shipped as part of the MATLAB add-on

For milestone 1, the fake device does **not** need to implement:

```text
frequency
gain
sample rate
streaming
```

unless Soapy requires minimal factory implementation for plugin registration.

Its purpose is to test enumeration.

A future extension can make it generate deterministic IQ samples.

---

# 14. Integration Tests

Integration tests should exercise:

```text
MATLAB
  ↓
real enumerate.m
  ↓
real MexInterface
  ↓
real MEX
  ↓
real SoapySDR
  ↓
fake matlab_test Soapy module
```

This verifies the actual abstraction boundary without requiring physical SDR hardware.

Configure Soapy's plugin search path for the test process so the fake driver can be loaded. SoapySDR supports custom plugin/module search paths, including through `SOAPY_SDR_PLUGIN_PATH`.

The integration test should call:

```matlab
devices = soapysdr.internal.enumerate();
```

and locate entries containing:

```text
driver = matlab_test
```

Do not assume that these are the only devices returned, because the CI machine or developer environment might contain other Soapy modules.

Instead, filter the result:

```matlab
testDevices = devices(cellfun(@(d) ...
    isKey(d,"driver") && d("driver") == "matlab_test", ...
    devices));
```

Then verify:

```text
exactly two matlab_test devices exist
serial TEST001 exists
serial TEST002 exists
labels are correct
```

This keeps the integration test deterministic even if other plugins are present.

---

# 15. Optional Manual Hardware Test

Do not make hardware testing part of CI.

Provide a developer-only smoke test or instructions:

```matlab
devices = soapysdr.internal.enumerate()
```

Compare its output with:

```text
SoapySDRUtil --find
```

when a known SDR is attached.

This is for manual validation only.

---

# 16. `.gitignore`

Generated MEX binaries and build artifacts must not be committed.

Include at least:

```gitignore
# MATLAB MEX binaries
*.mexw64
*.mexa64
*.mexmaca64
*.mexmaci64

# Native build output
build/
out/
CMakeFiles/
CMakeCache.txt
cmake_install.cmake

# vcpkg generated install state
vcpkg_installed/

# MATLAB-generated files where appropriate
*.asv
```

Do not use an overly broad ignore rule that could hide legitimate source files unnecessarily.

The released add-on will contain generated MEX binaries, but they should be produced by CI/release tooling rather than stored as normal source-controlled build output.

---

# 17. GitHub Actions CI

Initial CI is Windows-only.

GitHub Actions can run MATLAB on hosted/self-hosted runners, and MathWorks provides dedicated setup/test actions for MATLAB workflows.

Create:

```text
.github/workflows/windows.yml
```

Trigger on:

```yaml
push:
pull_request:
```

Use a Windows runner:

```yaml
runs-on: windows-latest
```

The workflow should perform these logical stages:

```text
checkout repository
       ↓
set up vcpkg
       ↓
install pinned manifest dependencies
       ↓
set up MATLAB R2026a
       ↓
build fake Soapy module
       ↓
build MEX
       ↓
configure Soapy plugin path
       ↓
run MATLAB unit tests
       ↓
run MATLAB integration tests
```

Use the current supported `matlab-actions` versions when implementing the workflow rather than copying an older version number from examples. Current MathWorks GitHub actions support setting up MATLAB and running MATLAB test suites on CI.

Pin MATLAB to:

```text
R2026a
```

rather than `latest`.

The CI job must fail if:

- MEX compilation fails
- fake plugin compilation fails
- MATLAB unit tests fail
- integration tests fail
- Soapy fails to discover the fake test devices

The CI job does not need physical SDR hardware.

---

# 18. Build Ordering

Use this order:

```text
1. vcpkg dependency restore
2. fake Soapy plugin build
3. MATLAB MEX build
4. MATLAB unit tests
5. MATLAB integration tests
```

The MATLAB unit tests technically do not require steps 1–3, but keeping a straightforward initial pipeline is preferable.

Optimization/caching can be added later.

---

# 19. First Implementation Milestones

## Milestone 1 — MATLAB unit-testable API shell

Implement:

```text
enumerate.m
MexInterface.m
tEnumerate.m
```

Use a mock `MexInterface`.

Acceptance:

```matlab
soapysdr.internal.enumerate(mockMex)
```

correctly converts mocked raw string data into dictionaries.

No native code required yet.

---

## Milestone 2 — Native Soapy enumeration

Implement:

```text
soapysdr_mex.cpp
buildMex.m
vcpkg.json
```

Call:

```c
SoapySDRDevice_enumerate(...)
```

and return:

```text
cell of N x 2 string arrays
```

Acceptance:

```matlab
raw = soapysdr.internal.MexInterface().enumerate();
```

runs without crashing against a valid Soapy installation.

---

## Milestone 3 — End-to-end `enumerate`

Connect:

```text
enumerate.m
    ↓
MexInterface
    ↓
MEX
    ↓
SoapySDR
```

Acceptance:

```matlab
devices = soapysdr.internal.enumerate();
```

returns a cell array of dictionaries.

Zero discovered devices must be a valid result, not an error.

---

## Milestone 4 — Fake Soapy driver

Implement:

```text
MatlabTestDevice.cpp
CMakeLists.txt
```

Register two deterministic fake devices.

Acceptance:

```text
SoapySDR enumeration discovers:
TEST001
TEST002
```

through the real Soapy runtime.

---

## Milestone 5 — MATLAB integration test

Run the real stack from MATLAB.

Acceptance:

```matlab
devices = soapysdr.internal.enumerate();
```

contains exactly the expected two `matlab_test` devices after filtering for that driver.

---

## Milestone 6 — Windows CI

Implement the GitHub Actions workflow.

Acceptance:

A clean GitHub Windows runner can:

```text
restore pinned Soapy dependency
build fake plugin
build MEX
run MATLAB tests
```

without manual configuration or physical SDR hardware.

---

# 20. Explicit Non-Goals

Do not implement these in the first task:

```text
soapysdr.find
soapysdr.Device
RX/TX objects
frequency
sample rate
bandwidth
gain
antenna selection
stream setup
readStream
writeStream
SoapyRemote configuration
Raspberry Pi support code
Linux MEX
macOS MEX
MATLAB Online transport
cloud transport
automatic Soapy installation
bundling SoapySDR
add-on packaging/release publishing
```

The architecture should not prevent these later, but do not expand MVP scope to include them.

---

# 21. Remote Devices / SoapyRemote Architectural Constraint

Do not add special remote-device concepts to the MEX interface.

A future architecture should remain:

```text
MATLAB computer

MATLAB
  ↓
MATLAB-Soapy package
  ↓
MEX
  ↓
local SoapySDR
  ↓
SoapyRemote client module
  ↓ network
Raspberry Pi
  ↓
SoapyRemote server
  ↓
SoapySDR
  ↓
hardware-specific Soapy module
  ↓
SDR
```

The same MATLAB-facing enumeration/device APIs should work for local and remote devices wherever Soapy itself provides that abstraction.

This is a design constraint only; do not implement SoapyRemote in this milestone.

---

# 22. Code Quality Requirements

Keep the native layer thin.

Do not:

- expose Soapy C structs directly to MATLAB
- introduce global state for testing
- monkey-patch package functions
- use path shadowing as the unit-testing strategy
- encode assumptions about specific SDR vendors
- enumerate a fixed list of Soapy argument keys
- put SoapyRemote networking logic in MATLAB/MEX
- bundle native Soapy libraries into the repository
- commit generated MEX files

Prefer:

- explicit dependency injection
- narrow native contracts
- deterministic tests
- arbitrary key/value preservation
- RAII/native cleanup where possible
- clear MATLAB error IDs
- small functions
- platform-independent MATLAB code

---

# 23. Definition of Done

The first implementation is complete when all of the following are true.

On a clean Windows development/CI environment:

```text
vcpkg restores the pinned SoapySDR development dependency.
```

The fake Soapy module builds successfully.

The MEX builds successfully under MATLAB R2026a.

MATLAB unit tests can mock the MEX dependency completely.

The integration test exercises:

```text
MATLAB
→ enumerate.m
→ MexInterface
→ soapysdr_mex.mexw64
→ SoapySDR
→ fake Soapy module
```

The command:

```matlab
devices = soapysdr.internal.enumerate();
```

returns a cell array of dictionaries.

Each dictionary preserves all key/value pairs returned by SoapySDR.

The fake devices:

```text
TEST001
TEST002
```

are discovered and verified by automated integration tests.

No compiled MEX files are committed to Git.

GitHub Actions runs the full build and test workflow automatically on Windows for pushes and pull requests.

At that point, stop.

Do not begin implementing `soapysdr.find()` or device configuration until this vertical slice is reviewed.