function plan = buildfile
%BUILDFILE MATLAB Build Tool build file for SoapySDR for MATLAB.

    plan = buildplan(localfunctions);

    plan("test").Dependencies = "mex";
    plan("package").Dependencies = ["mex", "test"];
    plan("smokeTest").Dependencies = "package";

    plan("clean").Description = "Remove build artifacts and MEX binary";
    plan("mex").Description = "Build soapysdr_mex MEX binary";
    plan("test").Description = "Run MATLAB unit and integration tests";
    plan("package").Description = "Package .mltbx toolbox";
    plan("smokeTest").Description = "Install and verify packaged toolbox";

end

function cleanTask(~)
    repoRoot = pwd;
    artifactsDir = fullfile(repoRoot, "artifacts");
    if isfolder(artifactsDir)
        rmdir(artifactsDir, "s");
    end
    mexFile = fullfile(repoRoot, "+soapysdr", "+internal", ...
        "soapysdr_mex." + mexext);
    if isfile(mexFile)
        delete(mexFile);
    end
end

function mexTask(~)
    repoRoot = pwd;
    addpath(fullfile(repoRoot, "buildtools"));

    installedDir = getenv("VCPKG_INSTALLED_DIR");
    if ~isempty(installedDir) && strlength(installedDir) > 0
        buildMex(InstalledDir=installedDir);
    else
        buildMex();
    end
end

function testTask(~)
    import matlab.unittest.TestSuite
    import matlab.unittest.TestRunner
    import matlab.unittest.plugins.XMLPlugin

    repoRoot = pwd;
    addpath(repoRoot);
    suite = TestSuite.fromFolder(fullfile(repoRoot, "test", "matlab"));

    runner = TestRunner.withTextOutput;

    resultsDir = fullfile(repoRoot, "artifacts", "test-results");
    if ~isfolder(resultsDir)
        mkdir(resultsDir);
    end
    runner.addPlugin(XMLPlugin.producingJUnitFormat( ...
        fullfile(resultsDir, "test-results.xml")));

    results = runner.run(suite);
    assertSuccess(results);
end

function packageTask(~)
    repoRoot = pwd;
    addpath(fullfile(repoRoot, "toolbox"));

    version = getenv("TOOLBOX_VERSION");
    if ~isempty(version) && strlength(version) > 0
        packageToolbox(Version=version);
    else
        packageToolbox();
    end
end

function smokeTestTask(~)
    repoRoot = pwd;
    addpath(fullfile(repoRoot, "toolbox"));
    smokeTest();
end
