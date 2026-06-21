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
      url = "https://github.com/superradcompany/microsandbox/releases/download/v0.5.7/microsandbox-linux-x86_64.tar.gz";
      hash = "sha256-qOir/lvdOoHIWuXyaOzbwW/pbv1sdzJDUa2nN2YyT+Q=";
    };
    "aarch64-linux" = {
      url = "https://github.com/superradcompany/microsandbox/releases/download/v0.5.7/microsandbox-linux-aarch64.tar.gz";
      hash = "sha256-VHOPFn3PW3wxxUGX4RldD0kbtJJwE71D2slXBdcbBKQ=;B";
    };
    "aarch64-darwin" = {
      url = "https://github.com/superradcompany/microsandbox/releases/download/v0.5.7/microsandbox-darwin-aarch64.tar.gz";
      hash = "sha256-13k15/T0Whwrml4/6sC106SF5rlwKhJz/y4AKNFvP1s=";
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
  version = "v0.5.7";

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
