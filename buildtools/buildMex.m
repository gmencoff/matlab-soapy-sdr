function buildMex(options)
%BUILDMEX Build the soapysdr_mex MEX file against vcpkg SoapySDR.
%   buildMex() builds using the default vcpkg installed directory
%   (vcpkg_installed/ in the repo root) and triplet.
%
%   buildMex(InstalledDir="path") specifies the vcpkg installed tree.
%
%   buildMex(Triplet="x64-windows") specifies the triplet.

    arguments
        options.InstalledDir string {mustBeTextScalar} = ...
            defaultInstalledDir()
        options.Triplet string {mustBeTextScalar} = ...
            "x64-windows"
    end

    repoRoot = fileparts(fileparts(mfilename("fullpath")));
    srcFile = fullfile(repoRoot, "src", "soapysdr_mex.cpp");
    outputDir = fullfile(repoRoot, "+soapysdr", "+internal");

    tripletDir = fullfile(options.InstalledDir, options.Triplet);
    includeDir = fullfile(tripletDir, "include");
    libDir = fullfile(tripletDir, "lib");

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

function dir = defaultInstalledDir()
    repoRoot = fileparts(fileparts(mfilename("fullpath")));
    dir = fullfile(repoRoot, "vcpkg_installed");
    if ~isfolder(dir)
        error("soapysdr:build:NoInstalledDir", ...
            "vcpkg_installed directory not found at: %s\n" + ...
            "Run vcpkg install first.", dir);
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
