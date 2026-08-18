function smokeTest()
%SMOKETEST Verify the packaged .mltbx installs and works correctly.
%   Installs the toolbox, verifies MEX loads, runs zero-device enumerate,
%   checks version metadata, then uninstalls.

    repoRoot = pwd;
    artifactsDir = fullfile(repoRoot, "artifacts");

    mltbxFiles = dir(fullfile(artifactsDir, "*.mltbx"));
    assert(~isempty(mltbxFiles), "soapysdr:smokeTest:NoMltbx", ...
        "No .mltbx found in artifacts/");
    mltbxFile = fullfile(artifactsDir, mltbxFiles(1).name);

    pathEntries = strsplit(path, pathsep);
    entriesToRemove = pathEntries(contains(pathEntries, repoRoot));
    for i = 1:numel(entriesToRemove)
        rmpath(entriesToRemove{i});
    end

    fprintf("Installing toolbox: %s\n", mltbxFile);
    tbx = matlab.addons.toolbox.installToolbox(mltbxFile);
    cleanupObj = onCleanup(@() uninstallAndRestorePath(tbx, entriesToRemove)); %#ok<NASGU>

    fprintf("Installed: %s v%s\n", tbx.Name, tbx.Version);
    fprintf("Toolbox install path: %s\n", tbx.InstalledLocation);

    rehash toolboxcache

    pathAfterInstall = strsplit(path, pathsep);
    toolboxPathEntries = pathAfterInstall(contains(pathAfterInstall, "soapysdr", IgnoreCase=true));
    fprintf("Path entries containing 'soapysdr' after install:\n");
    for i = 1:numel(toolboxPathEntries)
        fprintf("  %s\n", toolboxPathEntries{i});
    end
    if isempty(toolboxPathEntries)
        fprintf("  (none found)\n");
        fprintf("Full MATLAB path:\n%s\n", path);
    end

    expectedVersion = getenv("TOOLBOX_VERSION");
    if ~isempty(expectedVersion) && strlength(expectedVersion) > 0
        assert(string(tbx.Version) == string(expectedVersion), ...
            "soapysdr:smokeTest:VersionMismatch", ...
            "Expected version %s but got %s", expectedVersion, tbx.Version);
        fprintf("Version verified: %s\n", tbx.Version);
    end

    assert(exist("soapysdr.internal.enumerate", "file") > 0, ...
        "soapysdr:smokeTest:APINotFound", ...
        "soapysdr.internal.enumerate not found after toolbox install");
    fprintf("API resolvable: soapysdr.internal.enumerate\n");

    originalPluginPath = getenv("SOAPY_SDR_PLUGIN_PATH");
    setenv("SOAPY_SDR_PLUGIN_PATH", "");

    try
        devices = soapysdr.internal.enumerate();
    catch ex
        setenv("SOAPY_SDR_PLUGIN_PATH", originalPluginPath);
        rethrow(ex);
    end

    setenv("SOAPY_SDR_PLUGIN_PATH", originalPluginPath);

    assert(iscell(devices), "soapysdr:smokeTest:BadReturn", ...
        "enumerate() did not return a cell array");
    fprintf("enumerate() returned %d devices (expected 0)\n", numel(devices));

    fprintf("Smoke test PASSED\n");

end

function uninstallAndRestorePath(tbx, entriesToRestore)
    matlab.addons.toolbox.uninstallToolbox(tbx);
    fprintf("Toolbox uninstalled.\n");
    for i = 1:numel(entriesToRestore)
        addpath(entriesToRestore{i});
    end
end
