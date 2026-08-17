function mltbxFile = packageToolbox(options)
%PACKAGETOOLBOX Package the SoapySDR for MATLAB toolbox as .mltbx.
%   mltbxFile = packageToolbox() packages using the default version from
%   toolboxMetadata.
%
%   mltbxFile = packageToolbox(Version="1.2.3") sets the toolbox version.
%
%   mltbxFile = packageToolbox(OutputDir="path") overrides the output
%   directory (default: artifacts/ in the repo root).

    arguments
        options.Version string {mustBeTextScalar} = ""
        options.OutputDir string {mustBeTextScalar} = ""
    end

    repoRoot = fileparts(fileparts(mfilename("fullpath")));
    meta = toolboxMetadata();

    if options.Version == ""
        version = meta.DefaultVersion;
    else
        version = options.Version;
    end

    if options.OutputDir == ""
        outputDir = fullfile(repoRoot, "artifacts");
    else
        outputDir = options.OutputDir;
    end

    toolboxFolder = fullfile(repoRoot, "+soapysdr");
    mexFile = fullfile(toolboxFolder, "+internal", "soapysdr_mex." + mexext);
    if ~isfile(mexFile)
        error("soapysdr:package:MissingMex", ...
            "MEX binary not found: %s\nRun buildtool mex first.", mexFile);
    end

    opts = matlab.addons.toolbox.ToolboxOptions(toolboxFolder, meta.UUID);
    opts.ToolboxName = meta.ToolboxName;
    opts.ToolboxVersion = version;
    opts.Summary = meta.Summary;
    opts.Description = meta.Summary;
    opts.MinimumMatlabRelease = meta.MinimumMatlabRelease;
    opts.ToolboxMatlabPath = repoRoot;

    licenseFile = fullfile(repoRoot, "LICENSE");
    if isfile(licenseFile)
        opts.ToolboxFiles = [string(toolboxFolder); string(licenseFile)];
    end

    if ~isfolder(outputDir)
        mkdir(outputDir);
    end

    outputFile = fullfile(outputDir, ...
        sprintf("SoapySDR-for-MATLAB-%s.mltbx", version));

    matlab.addons.toolbox.packageToolbox(opts, outputFile);

    assert(isfile(outputFile), "soapysdr:package:OutputMissing", ...
        "Expected .mltbx not produced at: %s", outputFile);

    mltbxFile = outputFile;
    fprintf("Toolbox packaged: %s\n", mltbxFile);

end
