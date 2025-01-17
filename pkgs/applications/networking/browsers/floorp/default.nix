{ stdenv
, lib
, fetchFromGitHub
, buildMozillaMach
, nixosTests
}:

((buildMozillaMach rec {
  pname = "floorp";
  packageVersion = "11.10.2";
  applicationName = "Floorp";
  binaryName = "floorp";
  branding = "browser/branding/official";

  # Must match the contents of `browser/config/version.txt` in the source tree
  version = "115.8.0";

  src = fetchFromGitHub {
    owner = "Floorp-Projects";
    repo = "Floorp";
    fetchSubmodules = true;
    rev = "v${packageVersion}";
    hash = "sha256-fjLYR59AZaR6S1zcAT+DNpdsCdrW+3NdkRQBoVNdwYw=";
  };

  extraConfigureFlags = [
    "--with-app-name=${pname}"
    "--with-app-basename=${applicationName}"
    "--with-distribution-id=one.ablaze.floorp"
    "--with-unsigned-addon-scopes=app,system"
    "--allow-addon-sideload"
  ];

  meta = {
    description = "A fork of Firefox, focused on keeping the Open, Private and Sustainable Web alive, built in Japan";
    homepage = "https://floorp.app/";
    maintainers = with lib.maintainers; [ christoph-heiss ];
    platforms = lib.platforms.unix;
    badPlatforms = lib.platforms.darwin;
    broken = stdenv.buildPlatform.is32bit; # since Firefox 60, build on 32-bit platforms fails with "out of memory".
                                           # not in `badPlatforms` because cross-compilation on 64-bit machine might work.
    maxSilent = 14400; # 4h, double the default of 7200s (c.f. #129212, #129115)
    license = lib.licenses.mpl20;
    mainProgram = "floorp";
  };
  tests = [ nixosTests.floorp ];
}).override {
  # Upstream build configuration can be found at
  # .github/workflows/src/linux/shared/mozconfig_linux_base
  privacySupport = true;
  webrtcSupport = true;
  enableOfficialBranding = false;
  googleAPISupport = true;
  mlsAPISupport = true;
}).overrideAttrs (prev: {
  MOZ_DATA_REPORTING = "";
  MOZ_REQUIRE_SIGNING = "";
  MOZ_TELEMETRY_REPORTING = "";
})
