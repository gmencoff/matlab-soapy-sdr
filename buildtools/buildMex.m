function buildMex(options)
%BUILDMEX Build the soapysdr_mex MEX file against vcpkg SoapySDR.
%   buildtools.buildMex() builds using the default vcpkg root and
%   triplet.
%
%   buildtools.buildMex(VcpkgRoot="path") specifies the vcpkg root.
%
%   buildtools.buildMex(Triplet="x64-windows") specifies the triplet.

    arguments
        options.VcpkgRoot string {mustBeTextScalar} = ...
            defaultVcpkgRoot()
        options.Triplet string {mustBeTextScalar} = ...
            "x64-windows"
    end

    repoRoot = fileparts(fileparts(mfilename("fullpath")));
    srcFile = fullfile(repoRoot, "src", "soapysdr_mex.cpp");
    outputDir = fullfile(repoRoot, "+soapysdr", "+internal");

    installedDir = fullfile(options.VcpkgRoot, "installed", ...
        options.Triplet);
    includeDir = fullfile(installedDir, "include");
    libDir = fullfile(installedDir, "lib");

    validateDependencies(srcFile, includeDir, libDir);

    fprintf("Building soapysdr_mex...\n");
    fprintf("  Source:  %s\n", srcFile);
    fprintf("  Include: %s\n", includeDir);
    fprintf("  Lib:     %s\n", libDir);
    fprintf("  Output:  %s\n", outputDir);

    mex("-R2018a", ...
        "-outdir", outputDir, ...
        "-I" + includeDir, ...
        "-L" + libDir, ...
        "-lSoapySDR", ...
        srcFile);

    fprintf("Build complete.\n");

end

function root = defaultVcpkgRoot()
    root = getenv("VCPKG_ROOT");
    if root == ""
        error("soapysdr:build:NoVcpkgRoot", ...
            "VCPKG_ROOT environment variable is not set. " + ...
            "Set it or pass VcpkgRoot explicitly.");
    end
end

function validateDependencies(srcFile, includeDir, libDir)
    if ~isfile(srcFile)
        error("soapysdr:build:MissingSource", ...
            "Source file not found: %s", srcFile);
    end
    if ~isfolder(includeDir)
        error("soapysdr:build:MissingInclude", ...
            "Include directory not found: %s\n" + ...
            "Run vcpkg install first.", includeDir);
    end
    if ~isfolder(libDir)
        error("soapysdr:build:MissingLib", ...
            "Library directory not found: %s\n" + ...
            "Run vcpkg install first.", libDir);
    end
    headerFile = fullfile(includeDir, "SoapySDR", "Device.h");
    if ~isfile(headerFile)
        error("soapysdr:build:MissingSoapySDR", ...
            "SoapySDR headers not found at: %s\n" + ...
            "Run vcpkg install first.", headerFile);
    end
end
