# MATLAB-Soapy-SDR Add-On Packaging and Release Plan

## Objective

Extend the existing MATLAB-Soapy-SDR repository so that it can be built, tested, packaged, and distributed as a MATLAB toolbox (`.mltbx`) using an automated GitHub Actions workflow.

The implementation must preserve the existing working MVP and adapt to the repository's current structure rather than imposing a new source layout unnecessarily.

The completed workflow should support two distribution paths:

1. Every successful merge/push to `main` produces a downloadable `.mltbx` GitHub Actions artifact.
2. Every valid version tag such as `v0.1.0` produces a GitHub Release containing a versioned `.mltbx` installer.

Generated `.mltbx` files must **not** be committed back into the repository.

MATLAB R2026a is the initial supported MATLAB release. Windows is the initial supported operating system.

---

# Design Principles

## SoapySDR remains external

Do not package SoapySDR, Soapy device modules, vendor libraries, or device drivers inside the MATLAB toolbox.

The user is responsible for installing a compatible SoapySDR distribution and the device-specific Soapy modules required for their hardware.

The MATLAB toolbox contains:

- MATLAB source code required by users
- the compiled MATLAB MEX interface
- documentation/examples intended for users
- toolbox metadata

It should not contain:

- `SoapySDR.dll`
- Soapy device modules
- vcpkg build trees
- C/C++ development headers or libraries
- intermediate build products
- repository-only development infrastructure

The existing vcpkg dependency management should continue to provide SoapySDR for compilation and CI.

Do not replace the existing vcpkg strategy unless required to make the build work.

---

# 1. Inspect the Existing Repository

Before modifying anything, inspect the repository and identify:

- MATLAB source locations
- C/C++ MEX source locations
- the existing MEX build script/function
- existing unit tests
- existing GitHub Actions workflows
- vcpkg configuration
- generated/build directories
- documentation and examples
- current path assumptions
- current MEX output location
- how tests currently locate the MEX binary

Preserve existing conventions wherever practical.

Do not rename or move working source files merely to match a preconceived toolbox layout.

The packaging configuration should adapt to the repository where possible.

---

# 2. Introduce a MATLAB Project

Create a MATLAB Project rooted appropriately for the repository.

The project should primarily provide:

- project metadata
- toolbox packaging configuration
- project path configuration if required
- integration with MATLAB's toolbox packaging system

Do not rely on users opening the project to use the installed toolbox.

The installed `.mltbx` must configure its own MATLAB paths correctly.

## Toolbox task

Add exactly one MATLAB toolbox task to the project.

Configure it to package only files required at runtime or intentionally included for users.

At minimum, determine and include:

- public MATLAB API
- package/private MATLAB implementation files required at runtime
- MEX binary
- intended examples
- intended user documentation
- license files as appropriate

Exclude:

- native source code unless intentionally distributed
- vcpkg installed/build directories
- CI files
- internal development scripts not required by users
- test outputs
- temporary files
- generated build intermediates

The toolbox should initially declare Windows 64-bit support and MATLAB R2026a compatibility unless the existing implementation clearly supports something broader.

---

# 3. Create and Persist the Toolbox UUID

The MATLAB toolbox must have a single persistent UUID identifying MATLAB-Soapy-SDR.

When implementing the MATLAB Project/toolbox task:

1. Generate one valid RFC 4122 UUID.
2. Store that UUID in the MATLAB toolbox/project metadata.
3. Commit that metadata to the repository as part of this change.
4. Reuse the same UUID for all future toolbox versions and builds.

The UUID must **not** be:

- regenerated during CI
- regenerated for each release
- derived from a Git tag
- derived from a Git commit
- derived from the toolbox version

Conceptually:

```text
Toolbox UUID: constant for the lifetime of the product

Version 0.1.0 ─┐
Version 0.2.0 ─┼── same toolbox UUID
Version 1.0.0 ─┘
```

The UUID establishes toolbox identity. Git tags establish toolbox version.

The implementation should make the UUID part of normal source-controlled project metadata so there is no separate manual persistence mechanism.

---

# 4. Introduce `buildfile.m`

Add a MATLAB Build Tool build file at the repository level.

The purpose of `buildfile.m` is to provide a single build interface that works both locally and in CI.

Do not unnecessarily rewrite the current MEX build implementation.

If an existing MATLAB function/script correctly builds the MEX, have the build task invoke or refactor that existing code rather than creating a second independent build implementation.

Expose logical tasks similar to:

```text
clean
mex
test
package
smokeTest
```

Names may be adjusted to fit MATLAB Build Tool conventions.

Define task dependencies so that top-level packaging/release validation automatically performs its prerequisites.

Conceptually:

```text
package
 ├── mex
 └── test
```

The complete CI validation sequence should ultimately execute:

```text
build MEX
→ run tests
→ package .mltbx
→ install packaged toolbox
→ run installed-toolbox smoke tests
```

Avoid placing detailed build logic directly in GitHub Actions YAML. GitHub Actions should primarily invoke repository-owned build tasks.

---

# 5. Preserve vcpkg as the Native Dependency Manager

Continue using the repository's existing `vcpkg.json` manifest and pinned baseline.

The CI build should restore/install dependencies through vcpkg before compiling the MEX.

Do not separately introduce an unrelated SoapySDR installation mechanism for compilation if vcpkg already provides the required dependency.

Inspect the current MEX build mechanism to determine how the existing vcpkg installation is located and preserve that behavior.

Use caching for vcpkg artifacts in GitHub Actions where practical, but correctness must not depend on a warm cache.

---

# 6. Separate Build-Time Soapy from Packaged Content

SoapySDR is a build/runtime dependency, but it is not part of the MATLAB toolbox artifact.

The packaging workflow must ensure Soapy binaries from vcpkg are not accidentally copied into the `.mltbx`.

After packaging, verify sufficiently that the artifact does not contain items such as:

```text
SoapySDR.dll
Soapy device module DLLs
vcpkg/
packages/
buildtrees/
installed/
```

Adapt the checks to the actual repository and vcpkg directory layout.

The toolbox should contain the MEX binary but not the Soapy runtime.

---

# 7. Versioning from Git Tags

Git tags are the authoritative source of official toolbox versions.

Release tags should follow:

```text
vMAJOR.MINOR.PATCH
```

For example:

```text
v0.1.0
v0.2.0
v1.0.0
```

For a tag:

```text
v0.2.1
```

the MATLAB toolbox version must be:

```text
0.2.1
```

Strip only the leading `v`.

Do not use the `version-string` in `vcpkg.json` as the authoritative MATLAB toolbox release version.

Do not derive release versions from Git commit hashes.

## Tagged release builds

For a tagged build:

1. Parse and validate the Git tag.
2. Remove the leading `v`.
3. Set the MATLAB toolbox version to the resulting numeric version.
4. Build the MEX.
5. Run source-tree tests.
6. Package the toolbox.
7. Install and smoke-test the packaged toolbox.
8. Verify the packaged toolbox reports the expected version.
9. Create the GitHub Release.
10. Upload the versioned `.mltbx` as a GitHub Release asset.

For example:

```text
tag:
v0.2.1

release asset:
MATLAB-SoapySDR-0.2.1.mltbx
```

Use the project's established canonical product name if one already exists.

## Main branch builds

Main-branch builds need a valid toolbox version even when no release tag exists.

Keep a valid development/default version in the committed MATLAB project metadata.

Do not attempt to encode arbitrary Git commit hashes directly in the MATLAB toolbox version field.

The GitHub Actions run itself already identifies the commit that produced the artifact.

---

# 8. Do Not Commit Generated Toolbox Artifacts

Generated `.mltbx` files must remain outside Git history.

Do not create CI commits containing generated toolbox artifacts.

Do not modify `main` when creating a release.

Do not modify the commit pointed to by a release tag.

The intended lifecycle is:

```text
source commit on main
        ↓
tag v0.2.0 points to that commit
        ↓
CI checks out tagged commit
        ↓
build/test/package
        ↓
GitHub Release v0.2.0
        ↓
MATLAB-SoapySDR-0.2.0.mltbx
```

The `.mltbx` lives as a GitHub Release asset, not as a tracked repository file.

Similarly, `main` builds should upload `.mltbx` files as GitHub Actions artifacts rather than committing them.

Generated package/output directories should be added to `.gitignore` if appropriate.

---

# 9. Package the Toolbox Programmatically

Create build logic that packages the MATLAB Project into an `.mltbx` without requiring UI interaction.

The package task should:

1. ensure required build outputs exist
2. prepare an output directory such as `artifacts/`, `dist/`, or another repository-appropriate location
3. set release metadata when applicable
4. invoke MATLAB toolbox packaging
5. verify that the expected `.mltbx` was produced

The output directory should not be committed.

---

# 10. Add Source-Tree Tests to the Build

Preserve all existing tests.

Make them accessible from the MATLAB build system so CI can execute them consistently.

The tests should continue validating the MATLAB/MEX implementation before packaging.

Do not weaken existing tests to make the packaging workflow pass.

If existing tests rely on execution from the source tree, preserve those tests and add separate installed-toolbox smoke tests.

---

# 11. Add Installed-Toolbox Smoke Tests

Add a small test specifically for the produced `.mltbx`.

The goal is to validate the artifact users actually install rather than repeating the entire unit-test suite.

The smoke-test flow should approximately be:

```text
produce .mltbx

→ ensure source-tree paths cannot satisfy imports

→ install .mltbx programmatically

→ confirm toolbox metadata/version

→ confirm public MATLAB API can be resolved

→ invoke a minimal native/MEX operation

→ uninstall toolbox if appropriate
```

The test must ensure MATLAB is exercising the installed toolbox rather than silently finding repository source files.

Use a fresh MATLAB process or carefully reset MATLAB path/state as appropriate.

## Native smoke test

CI should not require SDR hardware.

Use an existing public/native operation that verifies one or more of:

- the MEX binary loads
- SoapySDR can be resolved externally
- the Soapy version can be queried
- the Soapy ABI can be queried
- Soapy device enumeration executes successfully even when zero devices are present

Adapt this to the actual API already implemented.

Do not add hardware requirements to CI.

---

# 12. Validate External Soapy Behavior

The CI smoke test should reflect the product architecture accurately:

```text
.mltbx contains MATLAB code + MEX

SoapySDR exists externally

→ installed toolbox loads MEX
→ MEX resolves external Soapy
→ Soapy API operation succeeds
```

The test should fail if the toolbox only works because `SoapySDR.dll` was accidentally packaged inside the add-on.

---

# 13. Create Main-Branch GitHub Actions Workflow

Create or extend a GitHub Actions workflow triggered by pushes to `main`.

Prefer extending existing CI when doing so keeps responsibilities clear. A dedicated packaging workflow is acceptable if it produces a cleaner design.

Use a Windows GitHub-hosted runner.

Set up MATLAB R2026a using MathWorks-supported GitHub Actions tooling.

Perform approximately:

```text
checkout
↓
set up MATLAB R2026a
↓
set up vcpkg/cache
↓
restore/build native dependencies
↓
invoke MATLAB build
↓
build MEX
↓
run source tests
↓
package .mltbx
↓
install/smoke-test .mltbx
↓
upload .mltbx as GitHub Actions artifact
```

The workflow should fail if any build, test, package, or smoke-test step fails.

Use a clear artifact name, for example:

```text
MATLAB-SoapySDR-main
```

or an equivalent matching repository conventions.

The uploaded artifact should contain the `.mltbx`, not an entire build tree.

---

# 14. Create Tag-Based Release Workflow

Support tags matching:

```text
v*.*.*
```

Validate the tag format before publishing anything.

The tag workflow should perform the complete build independently rather than relying on a prior `main` workflow.

Conceptually:

```text
push tag v0.2.0
↓
checkout tagged commit
↓
setup MATLAB/vcpkg
↓
derive toolbox version = 0.2.0
↓
build MEX
↓
run source tests
↓
package
↓
install/smoke-test .mltbx
↓
verify embedded toolbox version
↓
create GitHub Release v0.2.0
↓
attach MATLAB-SoapySDR-0.2.0.mltbx
```

Do not create the GitHub Release until every validation step succeeds.

The release workflow must not:

- make commits
- push generated artifacts to `main`
- modify the tagged commit
- commit the `.mltbx`

Use the built-in GitHub token and minimum permissions required to create releases and upload assets.

---

# 15. Avoid Duplicate CI Logic

Main and tag builds share almost all build/test/package behavior.

Factor shared behavior appropriately.

Possible approaches include:

- one workflow triggered by both `main` and tags with conditional publication steps
- a reusable GitHub workflow
- shared scripts/build tasks

Prefer the simplest maintainable solution for the current repository.

The actual build/test/package logic should live primarily in MATLAB/build scripts rather than duplicated YAML.

---

# 16. Documentation

Update existing user-facing documentation without rewriting unrelated material.

Add installation information explaining that users need:

1. MATLAB R2026a or another explicitly supported release
2. a compatible SoapySDR installation
3. the appropriate Soapy device module for their hardware
4. the MATLAB-Soapy-SDR `.mltbx`

Clearly state:

> SoapySDR is not bundled with MATLAB-Soapy-SDR.

Document where users obtain builds:

- current `main` builds: GitHub Actions artifacts
- stable versions: GitHub Releases

Document normal `.mltbx` installation and programmatic installation where appropriate.

Do not claim support for operating systems, MATLAB releases, Soapy versions, or devices that existing tests do not substantiate.

---

# 17. Developer Documentation

Add brief developer instructions for reproducing CI locally.

A developer should be able to determine how to run equivalents of:

```text
buildtool mex
buildtool test
buildtool package
buildtool smokeTest
```

using the actual task names selected during implementation.

Document required prerequisites, including as applicable:

- MATLAB R2026a
- supported compiler
- vcpkg setup
- repository-specific environment requirements

Avoid requiring developers to understand GitHub Actions YAML to build the toolbox locally.

---

# 18. Failure Behavior

CI failures should be easy to diagnose.

Ensure failures distinguish at least:

- vcpkg dependency setup failure
- MEX compilation failure
- MATLAB unit-test failure
- toolbox packaging failure
- toolbox installation failure
- external Soapy load failure
- installed-toolbox API failure
- invalid Git tag
- toolbox version/tag mismatch
- GitHub Release publication failure

Do not suppress useful MATLAB, compiler, or test output.

---

# 19. Acceptance Criteria

## Project identity

- The repository contains a MATLAB Project with exactly one toolbox task.
- The toolbox has one persistent RFC 4122 UUID.
- That UUID is committed to source control.
- Repeated builds and releases use the same UUID.

## Local packaging

From a clean checkout with development prerequisites installed:

- the MEX can be built through the standardized build entry point
- existing tests pass
- an `.mltbx` can be generated without MATLAB UI interaction

## Package contents

The generated toolbox contains:

- required MATLAB runtime files
- the MEX binary
- intended documentation/examples

The generated toolbox does not contain:

- SoapySDR runtime binaries
- Soapy device plugins
- vcpkg build/install trees
- unrelated development artifacts

## Installation

The generated `.mltbx` can be installed programmatically.

After installation:

- the public MATLAB API is available without manual `addpath`
- the installed MEX loads
- a basic Soapy operation succeeds against an externally installed Soapy runtime
- no SDR hardware is required

## Main branch CI

A successful push/merge to `main`:

- builds native dependencies
- builds the MEX
- runs tests
- creates an `.mltbx`
- installs and smoke-tests it
- uploads it as a GitHub Actions artifact
- does not commit the `.mltbx` to the repository

## Tagged release

A tag such as:

```text
v0.1.0
```

causes CI to:

- check out the tagged commit
- set toolbox version to `0.1.0`
- preserve the existing toolbox UUID
- run the complete build/test/package/smoke-test workflow
- verify the packaged version
- create GitHub Release `v0.1.0`
- attach a versioned `.mltbx`
- make no source-control commits

The version embedded in the `.mltbx` must equal the Git tag with the leading `v` removed.

The release `.mltbx` must not be present as a tracked repository file.

---

# 20. Non-Goals

Do not add these as part of this change unless required to accomplish the goals above:

- bundling SoapySDR
- bundling device-specific Soapy modules
- automatically installing SoapySDR on user machines
- automatically installing vendor SDR drivers
- macOS packaging
- Linux packaging
- publishing to MATLAB File Exchange/Add-On Explorer
- MATLAB support-package infrastructure
- automatic hardware testing
- redesigning the existing MATLAB API
- redesigning the existing MEX interface
- replacing vcpkg
- broad repository restructuring
- committing generated `.mltbx` files

These can be handled separately later.

---

# 21. Implementation Philosophy

Prefer small adaptations of the existing MVP over large restructuring.

Where this plan uses conceptual names such as:

```text
buildMex
package
smokeTest
artifacts/
```

inspect the repository and choose names and locations consistent with the existing codebase.

If there is tension between this plan and a working existing implementation, preserve the existing architecture unless it prevents an acceptance criterion from being satisfied.

At the end of implementation, summarize:

- files added
- files modified
- MATLAB Project/toolbox metadata added
- the generated toolbox UUID and where it is stored
- build tasks introduced
- CI workflows introduced or modified
- toolbox package contents
- how Git-tag versioning works
- how to build/package locally
- how `main` artifacts are produced
- how tagged GitHub Releases are produced
- confirmation that `.mltbx` files are not committed
- any remaining limitations or follow-up work