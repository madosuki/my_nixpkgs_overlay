{ pkgs,
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  libcap_ng
}:

let
  precompiled_binary = {
    "x86_64-linux" = {
      url = "https://github.com/superradcompany/microsandbox/releases/download/v0.4.6/microsandbox-linux-x86_64.tar.gz";
      hash = "sha256-gCb8yykJBNJ8Y0v19hhdOPu+UVyUEoHkZ2fQ93Jvbac=";
    };
    "aarch64-linux" = {
      url = "https://github.com/superradcompany/microsandbox/releases/download/v0.4.6/microsandbox-linux-aarch64.tar.gz";
      hash = "sha256-5LFHqCfSlbGJVPMJQkjaNLSdf+8neguahElpUkHNRtM=";
    };
    "aarch64-darwin" = {
      url = "https://github.com/superradcompany/microsandbox/releases/download/v0.4.6/microsandbox-darwin-aarch64.tar.gz";
      hash = "sha256-RmfFsU93f79q4sWw16FkLG1zbMbpufWBv+N7/gJd0d4=";
    };
  };

  krunfwVersion = "5.2.1";
  krunfwMjorVersion = "5";
  libExt = if stdenv.hostPlatform.isDarwin then "dylib" else "so";
  krunfwName = if stdenv.hostPlatform.isDarwin
                then "libkrunfw.${krunfwMjorVersion}.${libExt}"
                else "libkrunfw.${libExt}.${krunfwVersion}";
in
stdenv.mkDerivation rec {
  pname = "microsandbox";
  version = "v0.4.6";

  sourceRoot = ".";
  src = fetchurl precompiled_binary.${stdenv.hostPlatform.system};

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    libcap_ng
    stdenv.cc.cc.lib
  ];

  installPhase = ''
  runHook preInstall

  mkdir -p $out/bin
  install -Dm755 msb $out/bin/msb
  install -Dm755 ${krunfwName} $out/lib/${krunfwName}

  runHook postInsall
  '';


  meta = with pkgs.lib; {
    description = "microsandbox";
    homepage = "https://github.com/superradcompany/microsandbox";
    license = licenses.asl20;
    platforms = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
  };

}
