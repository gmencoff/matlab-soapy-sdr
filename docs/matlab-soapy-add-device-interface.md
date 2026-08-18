# MATLAB SoapySDR – Public API and Device Wrapper Implementation Plan

## Objective

Extend the existing MATLAB SoapySDR MVP from device enumeration and packaging into the initial public MATLAB API.

This phase should add:

- `soapysdr.enumerate`
- `soapysdr.getAPIVersion`
- `soapysdr.getABIVersion`
- `soapysdr.getLibVersion`
- `soapysdr.Device`
- `soapysdr.Range`
- `soapysdr.ArgInfo`

The primary goal is to expose essentially the complete public SoapySDR `Device` capability/configuration API while establishing an architecture that:

1. keeps the MATLAB-facing API independent from MEX implementation details,
2. supports dependency injection for testing,
3. allows a future remote-device backend without changing the public `soapysdr.Device` API,
4. cleanly manages native SoapySDR resource lifetime, and
5. remains faithful to SoapySDR capability semantics.

Use the repository's existing structure and conventions where they differ from examples in this document. Do not perform unnecessary restructuring.

Use the current upstream SoapySDR headers as the authoritative API references:

- `include/SoapySDR/Device.hpp`
- `include/SoapySDR/Types.hpp`
- `include/SoapySDR/Version.hpp`

Do not infer public methods from this plan alone if the checked-in/pinned SoapySDR version differs. Reconcile the implementation against the version actually supplied through the project's dependency management.

---

# 1. Public MATLAB API

The intended public MATLAB package should expose approximately:

```text
+soapysdr/
    enumerate.m
    getAPIVersion.m
    getABIVersion.m
    getLibVersion.m
    Device.m
    Range.m
    ArgInfo.m
```

Internal implementation classes/functions should live under an internal/private namespace appropriate to the existing repository.

Do not expose implementation-specific MEX handles or native pointers through the public API.

---

# 2. Preserve the Existing `enumerate` MVP

Retain the existing enumeration behavior unless a change is necessary to support `Device` construction.

The canonical public API should remain:

```matlab
devices = soapysdr.enumerate();
```

and allow the existing supported filtering mechanism.

Do **not** add `soapysdr.Device.enumerate`.

Enumeration is conceptually a package-level operation performed before a device exists.

Ensure that an enumeration result contains enough information to construct a device later:

```matlab
devices = soapysdr.enumerate();
dev = soapysdr.Device(devices(1));
```

Use the existing MATLAB representation for Soapy `Kwargs` if one has already been established.

---

# 3. Add Version Functions

Implement:

```matlab
soapysdr.getAPIVersion()
soapysdr.getABIVersion()
soapysdr.getLibVersion()
```

These should call the corresponding SoapySDR namespace functions:

```cpp
SoapySDR::getAPIVersion()
SoapySDR::getABIVersion()
SoapySDR::getLibVersion()
```

Return MATLAB string scalars.

These functions are defined by SoapySDR's `Version.hpp`; `getAPIVersion` returns an API-version string, `getABIVersion` the ABI the library was built against, and `getLibVersion` the library/build version string.

Keep these wrappers very thin.

---

# 4. Implement `soapysdr.Range`

Implement `soapysdr.Range` as a MATLAB **value class**, not as a native-backed handle object.

It represents `SoapySDR::Range`, which consists only of:

- minimum
- maximum
- step

Expose MATLAB-style immutable/read-only properties:

```matlab
r.Minimum
r.Maximum
r.Step
```

Preferred conceptual interface:

```matlab
classdef Range
    properties (SetAccess = immutable)
        Minimum
        Maximum
        Step
    end
end
```

Adapt property validation to repository MATLAB-version requirements.

A C++:

```cpp
SoapySDR::RangeList
```

should map to an array of `soapysdr.Range`.

An empty `RangeList` should map naturally to an empty `soapysdr.Range` array.

Do not retain native `Range` objects after conversion.

---

# 5. Implement `soapysdr.ArgInfo`

Implement `soapysdr.ArgInfo` as a MATLAB **value class**.

Map the fields of `SoapySDR::ArgInfo`:

```text
key
value
name
description
units
type
range
options
optionNames
```

to MATLAB properties:

```matlab
info.Key
info.Value
info.Name
info.Description
info.Units
info.Type
info.Range
info.Options
info.OptionNames
```

Use MATLAB strings/string arrays where appropriate.

Represent `Type` initially using strings:

```text
"bool"
"int"
"float"
"string"
```

Do not introduce an additional public enum class during this phase unless the existing repository conventions strongly justify it.

`Range` should contain a `soapysdr.Range`.

`Options` and `OptionNames` should be string arrays.

A C++ `ArgInfoList` should map to a MATLAB `soapysdr.ArgInfo` array.

Do not retain native `ArgInfo` objects after conversion.

---

# 6. Device Architecture

Implement `soapysdr.Device` as a MATLAB **handle class**.

The public `Device` object must **not directly depend on a MEX handle**.

Instead, introduce an internal device-backend abstraction and have `Device` delegate device operations to it.

Conceptually:

```text
soapysdr.Device
       |
       v
internal Device Backend Interface
       |
       +---- Native Soapy/MEX Backend
       |
       +---- Test/Mock Backend
       |
       +---- Future Remote Backend
```

The exact class names are not mandated. Use naming appropriate to the repository.

The important design requirement is separation between:

- the public `soapysdr.Device` API, and
- the mechanism used to execute the operation.

The default production backend in this phase should call the SoapySDR MEX implementation.

---

# 7. Dependency Injection

Provide a non-public mechanism for tests/internal code to construct a `Device` around an injected backend.

For example, the design may internally support something analogous to:

```matlab
dev = soapysdr.Device(...backend...);
```

but the backend-injection entry point does not need to be publicly documented.

Use whichever MATLAB testing/access-control pattern best fits the repository.

Tests should be able to inject a mock backend and verify that:

```matlab
dev.setFrequency("RX", 0, 1e9)
```

delegates the correct arguments without requiring physical SDR hardware or a real Soapy device.

The backend contract should remain transport-agnostic. Avoid exposing native pointer concepts in the backend interface if they are not inherently required by the public operation.

This is intended to allow a future implementation such as:

```text
NativeSoapyBackend
RemoteDeviceBackend
```

behind the same `soapysdr.Device`.

---

# 8. Device Construction and Lifetime

Normal public construction should create a native Soapy device through the default backend.

Internally this ultimately maps to:

```cpp
SoapySDR::Device::make(...)
```

Device ownership must be explicit.

`soapysdr.Device` must implement:

```matlab
delete(obj)
```

and deletion must delegate to the backend.

For the native backend, destruction must ultimately call:

```cpp
SoapySDR::Device::unmake(...)
```

exactly once for each successfully-created device.

Make deletion idempotent so repeated cleanup paths cannot double-free the native device.

The native/MEX implementation should also perform resource cleanup on MEX unload as a final safety mechanism, but that should not replace normal `Device.delete` behavior.

---

# 9. Direction Representation

The Soapy C++ API uses integer constants:

```cpp
SOAPY_SDR_RX
SOAPY_SDR_TX
```

for direction.

The MATLAB public API should instead accept:

```matlab
"RX"
"TX"
```

case handling may follow normal MATLAB API conventions, but use one documented canonical form.

Convert these to Soapy constants at the backend/native boundary.

Do not require MATLAB users to know Soapy's integer constants.

---

# 10. Channel Indexing

Preserve **Soapy's zero-based channel numbering**.

Examples:

```matlab
dev.getFrequency("RX", 0)
dev.getFrequency("RX", 1)
```

correspond directly to Soapy channels `0` and `1`.

Do not translate these hardware channel identifiers to MATLAB one-based indexing.

Clearly document that channel IDs are zero-based.

---

# 11. Device Method Coverage

Implement all current **public, non-deprecated, ordinary `SoapySDR::Device` methods** in this phase, with the exceptions described below.

Use the pinned/current `Device.hpp` as the definitive method list.

Broad functional groups include:

- device identification,
- frontend/channel mapping,
- channel capability queries,
- antenna configuration,
- DC correction,
- IQ correction,
- frequency correction,
- gain,
- frequency,
- sample rate,
- bandwidth,
- clock configuration,
- time/synchronization,
- sensors,
- register access,
- arbitrary settings,
- GPIO,
- I²C,
- SPI,
- UART,
- stream capability discovery.

Do not silently omit a non-deprecated API merely because it is uncommon.

---

# 12. Methods Not Exposed Directly

Do not mirror C++ lifecycle/static operations where MATLAB already has a better abstraction.

Map:

```text
SoapySDR::Device::enumerate -> soapysdr.enumerate
SoapySDR::Device::make      -> Device construction/backend creation
SoapySDR::Device::unmake    -> Device.delete/backend destruction
```

Do not expose parallel/bulk `make`/`unmake` APIs during this phase unless required by existing code.

Do not implement deprecated methods.

For example, if present in the pinned Soapy version:

```text
listSampleRates
listBandwidths
deprecated register overloads
other methods explicitly tagged deprecated
```

should not become public MATLAB APIs.

The current Soapy header marks `listSampleRates` deprecated in favor of `getSampleRateRange`, so the MATLAB API should expose the latter rather than perpetuating the deprecated method.

---

# 13. Stream Capability Discovery

Implement the non-streaming stream-query methods now:

```text
getStreamFormats
getNativeStreamFormat
getStreamArgsInfo
```

These are ordinary device capability methods and do not require a running stream.

For APIs returning multiple values, use natural MATLAB multiple-output behavior.

For example:

```matlab
[format, fullScale] = dev.getNativeStreamFormat("RX", 0);
```

Return stream argument metadata as `soapysdr.ArgInfo` arrays.

---

# 14. Actual Streaming Is Stage 2

Do **not** require full data streaming to be completed before the rest of this phase can land.

Treat normal streaming as the immediately-following implementation stage.

The eventual public methods are expected to include:

```text
setupStream
closeStream
getStreamMTU
activateStream
deactivateStream
readStream
writeStream
readStreamStatus
```

Structure the backend/native layer now so these can be added without redesigning `Device`.

Do not expose native `SoapySDR::Stream *` pointers to MATLAB.

---

# 15. Stream Handle Design

When normal streaming is implemented, `setupStream` should return an **opaque backend-specific stream token**.

For the native backend, it is acceptable and recommended for the MEX layer to maintain a mapping such as:

```text
stream ID -> SoapySDR::Stream*
```

For example:

```text
1 -> native stream pointer A
2 -> native stream pointer B
```

MATLAB may internally receive a `uint64` ID or equivalent opaque value.

However:

- `soapysdr.Device` should not depend on the token being numeric.
- the token should be interpreted only by the backend that created it.
- a future remote backend may use a server-side stream ID/UUID instead.

The native backend must track streams per device sufficiently to prevent:

- use after close,
- double close,
- stream/device ownership confusion.

When a native device is deleted, any still-open streams belonging to that device should be closed/cleaned safely before or as part of device destruction.

Do not introduce a public `soapysdr.Stream` class in this phase unless implementation experience shows a clear need.

---

# 16. Time Units

Preserve SoapySDR's units.

Hardware and scheduled stream timestamps use **nanoseconds**.

Represent nanosecond timestamps using MATLAB `int64` where appropriate.

Examples include:

```text
getHardwareTime
setHardwareTime
stream timeNs values
scheduled activation/transmission times
```

Do not automatically convert these values to MATLAB double seconds.

Stream blocking timeouts use Soapy's native timeout unit, which is **microseconds** for the relevant stream calls.

Document units clearly rather than normalizing unrelated Soapy timing concepts into one MATLAB unit during this phase.

---

# 17. Gain and Frequency Overloads

Preserve the distinction between whole-chain settings and named elements.

For gain, support forms conceptually equivalent to:

```matlab
dev.setGain("RX", 0, 30)
dev.setGain("RX", 0, "LNA", 20)

gain = dev.getGain("RX", 0)
gain = dev.getGain("RX", 0, "LNA")

range = dev.getGainRange("RX", 0)
range = dev.getGainRange("RX", 0, "LNA")
```

For frequency, support both overall and named frequency components:

```matlab
dev.setFrequency("RX", 0, 2.4e9)
dev.setFrequency("RX", 0, "RF", 2.4e9)

f = dev.getFrequency("RX", 0)
f = dev.getFrequency("RX", 0, "RF")

ranges = dev.getFrequencyRange("RX", 0)
ranges = dev.getFrequencyRange("RX", 0, "RF")
```

Preserve Soapy driver-specific tuning arguments.

Use MATLAB-native name/value or key/value input conventions where appropriate, while maintaining the ability to pass arbitrary driver-defined keys.

---

# 18. Capability Semantics

Do not invent a separate MATLAB support model for device features.

Soapy's `Device` base class intentionally allows drivers to implement only the capabilities they support.

The MATLAB wrapper should preserve Soapy behavior:

- empty capability/list results remain empty,
- `has*` methods return their Soapy boolean values,
- ordinary getters return whatever Soapy returns,
- setters preserve Soapy behavior,
- Soapy exceptions become MATLAB errors,
- stream return/error codes retain their semantic distinction from thrown exceptions.

Do not preemptively turn all unsupported operations into a MATLAB `NotSupported` exception.

Capability discovery methods such as:

```text
has*
list*
get*Range
get*Info
```

are part of the intended user workflow.

---

# 19. Sensors and Settings

Implement both device-level and channel-level sensor APIs supported by `Device.hpp`.

Typical methods include:

```text
listSensors
getSensorInfo
readSensor
```

`getSensorInfo` should return `soapysdr.ArgInfo`.

Initially preserve Soapy's string representation for `readSensor` rather than automatically converting according to `ArgInfo.Type`.

Implement arbitrary device/channel settings fully:

```text
getSettingInfo
readSetting
writeSetting
```

Support both global and channel-specific variants.

Preserve setting values as strings for the initial implementation, matching the underlying Soapy interface.

These APIs are important because they provide access to device/vendor functionality that is not represented by standardized `Device` methods.

---

# 20. Clock and Hardware Time

Implement the current non-deprecated clock/time APIs from `Device.hpp`, including as applicable:

```text
setMasterClockRate
getMasterClockRate
getMasterClockRates

setReferenceClockRate
getReferenceClockRate
getReferenceClockRates

listClockSources
setClockSource
getClockSource

listTimeSources
setTimeSource
getTimeSource

hasHardwareTime
getHardwareTime
setHardwareTime
```

Map `RangeList` outputs to `soapysdr.Range` arrays.

Preserve optional Soapy `what` arguments for hardware time operations.

---

# 21. Register, GPIO, I²C, SPI, and UART APIs

Implement the current non-deprecated versions of these APIs.

For register access, prefer the modern named-register-interface APIs.

Use MATLAB integer types where this prevents accidental precision loss.

For raw byte-oriented APIs such as I²C and potentially UART, use MATLAB `uint8` vectors for payload data rather than treating arbitrary binary data as MATLAB text.

Strings should still be used for identifiers such as interface names, bank names, or UART names.

Do not add convenience conversions that change the underlying byte semantics.

---

# 22. Direct Buffer API: Explicitly Excluded

Do not expose the Soapy direct-buffer API in this implementation.

This includes methods such as:

```text
getNumDirectAccessBuffers
getDirectAccessBufferAddrs
acquireReadBuffer
releaseReadBuffer
acquireWriteBuffer
releaseWriteBuffer
```

These APIs expose driver-owned/direct DMA buffers and explicit acquire/release lifetime semantics.

The current Soapy API describes these separately from normal streaming and includes support for scatter/gather DMA memory.

MATLAB's normal streaming API should return MATLAB arrays, so exposing native buffer addresses and ownership would add significant complexity without a clear initial user benefit.

The MEX implementation may use direct-buffer APIs internally in the future if profiling shows that they materially improve streaming performance.

Do not commit the public MATLAB API to direct native-buffer semantics now.

---

# 23. Native Backend / MEX Design

Reuse the existing MEX architecture where practical.

Prefer a centralized MEX gateway/native layer rather than creating a distinct MEX binary for every MATLAB method.

The exact dispatch mechanism is implementation-dependent.

Conceptually, the backend may perform calls resembling:

```text
create device
destroy device
get frequency
set frequency
...
```

against an internal native device registry.

Maintain native resource ownership on the C++ side.

A device handle should resolve to:

```cpp
SoapySDR::Device *
```

but the pointer itself must never be surfaced as a meaningful public MATLAB value.

When streaming is added, maintain a corresponding native stream registry or per-device stream registry.

---

# 24. Shared C++/MATLAB Conversion Utilities

Avoid implementing ad-hoc conversion logic separately for every Device method.

Create/reuse centralized conversion helpers for at least:

```text
MATLAB string          <-> std::string
MATLAB string arrays   <-> std::vector<std::string>
MATLAB key/value data  <-> SoapySDR::Kwargs
MATLAB complex double  <-> std::complex<double>
MATLAB numeric vectors <-> std::vector<T>

SoapySDR::Range        -> soapysdr.Range
SoapySDR::RangeList    -> soapysdr.Range array

SoapySDR::ArgInfo      -> soapysdr.ArgInfo
SoapySDR::ArgInfoList  -> soapysdr.ArgInfo array

SoapySDR::Kwargs       -> existing MATLAB enumeration representation
```

Where practical, keep native methods thin:

1. validate/obtain MATLAB arguments,
2. convert to native types,
3. call the corresponding Soapy method,
4. convert return values,
5. translate exceptions.

---

# 25. MATLAB-Level Validation

Perform validation where it improves MATLAB usability, but do not duplicate the hardware capability rules already owned by Soapy.

Examples of appropriate MATLAB validation:

- direction must be `"RX"` or `"TX"`,
- channel IDs must be nonnegative integer-valued identifiers,
- obvious type/shape requirements,
- invalid/closed backend handles,
- invalid stream tokens.

Do not reject device-dependent values such as frequencies, gains, sample rates, or bandwidths merely because they do not appear in locally inferred ranges unless Soapy itself would reject them.

Let the underlying driver remain authoritative.

---

# 26. Error Handling

Catch C++ exceptions before they cross the MEX boundary.

Convert them into MATLAB errors while preserving the original Soapy message wherever possible.

Use stable error identifiers following repository conventions.

Potential categories include:

```text
soapysdr:SoapyError
soapysdr:InvalidArgument
soapysdr:InvalidDevice
soapysdr:InvalidStream
```

Do not over-classify if the native exception does not provide enough information to do so reliably.

Never allow a C++ exception to escape through the MEX boundary.

Streaming error/status codes should remain distinct from exceptions where that distinction exists in Soapy.

---

# 27. Testing Strategy

## MATLAB unit tests without hardware

Use the injected backend architecture to test the public `soapysdr.Device` class without an SDR.

Create a mock/fake backend implementing the internal contract.

Test:

- constructor/backend ownership,
- delegation of each public method,
- correct argument order,
- zero-based channels remain unchanged,
- `"RX"` / `"TX"` semantics,
- overload selection,
- multiple outputs,
- return-value propagation,
- `delete` calls backend cleanup exactly once,
- failures from backend propagate correctly.

Avoid writing dozens of near-identical tests manually if parameterized/shared test utilities can provide the same coverage clearly.

## Value-object tests

Test `Range`:

- property mapping,
- empty arrays,
- arrays of ranges,
- step values.

Test `ArgInfo`:

- all fields,
- type conversion,
- embedded `Range`,
- options and option names,
- empty lists.

## Native integration tests without SDR hardware

Where possible, test:

- version functions,
- enumeration,
- creation failure paths,
- conversion utilities,
- error translation.

If Soapy provides a suitable null/test device available through the project's dependency setup, use it for broader integration tests.

Do not make the default CI test suite depend on physical SDR hardware.

## Hardware integration tests

If hardware tests already exist or are added later, keep them separately tagged/configured so they are not required for ordinary CI.

---

# 28. Documentation

Add MATLAB help text for all public functions/classes.

Public `Device` method documentation should state:

- direction uses `"RX"` / `"TX"`,
- channel IDs are zero-based,
- support for a method depends on the underlying Soapy driver/device,
- capability discovery should be used where relevant,
- timestamps use nanoseconds where specified by Soapy,
- settings/sensor values initially preserve Soapy string representations.

Where practical, follow terminology from the Soapy documentation so users can translate directly between Soapy examples and MATLAB.

Avoid documenting MEX/backend implementation details as public behavior.

---

# 29. Implementation Order

Implement in roughly this order:

### Step 1 — Inspect and reconcile repository state

Before changing code:

- inspect the current `enumerate` implementation,
- inspect existing MEX/build conventions,
- inspect package layout,
- identify the exact SoapySDR version supplied through the dependency configuration,
- compare that version's `Device.hpp`, `Types.hpp`, and `Version.hpp` against this plan.

Do not overwrite existing architectural decisions without a clear reason.

### Step 2 — Add reusable native conversion infrastructure

Implement/refactor shared conversions for strings, kwargs, ranges, ArgInfo, numeric vectors, complex values, and relevant integer types.

### Step 3 — Add `Range` and `ArgInfo`

Implement value classes plus native-to-MATLAB conversion.

### Step 4 — Add version functions

Implement and test the three package-level version calls.

### Step 5 — Establish backend abstraction

Create the internal backend contract.

Move/encapsulate existing native device interaction behind the default backend as needed.

Make sure enumeration itself does not become unnecessarily coupled to `Device`.

### Step 6 — Implement `Device` lifecycle

Implement:

- handle-class behavior,
- construction,
- injected backend path,
- `delete`,
- native `make`/`unmake`.

Verify deterministic cleanup.

### Step 7 — Implement ordinary Device APIs

Implement all current non-deprecated Device capability/configuration methods, grouped by functional area.

Prefer completing one category including tests before moving to the next.

### Step 8 — Implement stream capability discovery

Implement:

- `getStreamFormats`
- `getNativeStreamFormat`
- `getStreamArgsInfo`

### Step 9 — Prepare streaming internals

Add only the infrastructure needed so later stream handles can be opaque/backend-specific.

Do not implement direct-buffer access.

### Step 10 — Documentation and CI

Finish public help text, tests, and ensure the normal package build/CI continues to work.

---

# 30. Definition of Done

This phase is complete when:

- `soapysdr.enumerate` remains the canonical discovery function.
- `soapysdr.getAPIVersion`, `getABIVersion`, and `getLibVersion` work.
- `soapysdr.Range` exists as a MATLAB value object.
- `soapysdr.ArgInfo` exists as a MATLAB value object.
- `soapysdr.Device` is a MATLAB handle class.
- `Device` owns/delegates to an injected backend abstraction.
- the production backend calls the existing/new Soapy MEX native layer.
- `Device.delete` ultimately calls `SoapySDR::Device::unmake`.
- device cleanup is safe and idempotent.
- channels use zero-based Soapy channel IDs.
- directions are exposed to MATLAB as `"RX"` and `"TX"`.
- essentially all current non-deprecated ordinary public `Device.hpp` methods are exposed.
- deprecated methods are intentionally omitted.
- direct-buffer access APIs are intentionally omitted.
- stream capability discovery is implemented.
- full sample streaming is architecturally prepared for but may be completed in the immediately-following streaming phase.
- no native pointers are exposed through the public MATLAB API.
- public `Device` behavior can be unit tested with an injected fake backend.
- native integration tests do not require physical SDR hardware.
- CI and packaging continue to function.

---

# 31. Follow-On Phase

The next implementation phase should focus specifically on normal Soapy streaming:

```text
setupStream
activateStream
readStream
writeStream
readStreamStatus
deactivateStream
closeStream
getStreamMTU
```

That phase should settle:

- exact MATLAB representation returned by `setupStream`,
- RX output shape,
- multi-channel data representation,
- TX input shape,
- mapping of Soapy stream formats to MATLAB numeric types,
- timeout/error/status behavior,
- burst/timestamp/flag handling,
- stream lifecycle and cleanup,
- performance/copying strategy.

Do not expand this current phase to solve those design questions unless doing so is necessary to avoid an architectural dead end.