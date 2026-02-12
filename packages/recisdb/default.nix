{ pkgs ? import <nixpkgs> {} }:

pkgs.rustPlatform.buildRustPackage rec {
  pname = "recisdb";
  version = "0.2.4";

  src = pkgs.fetchFromGitHub {
    owner = "kazuki0824";
    repo = "recisdb-rs";
    rev = "5fb4051c368ceb0595eed6273b7d9e13b0eed759"; 
    fetchSubmodules = true;
    sha256 = "sha256-hjTMb2LWD7mN3ci83v+NxQW9wBdI9LnG6o2PmKlSakU=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = {
      "cryptography-00-0.1.0" = "sha256-JnoAGUxaJPLW1lIKoce5Djly6rZXYw8Yck9nqr8iRP8=";
      "cryptography-40-0.1.0" = "sha256-JnoAGUxaJPLW1lIKoce5Djly6rZXYw8Yck9nqr8iRP8=";
      "dvbv5-sys-0.2.1" = "sha256-0GuMo41kXSVQY6How4gWC6uwWVSjilE7GZCK7ByZTUk=";
      "dvbv5-0.2.6" = "sha256-sJH85caEMJ92EyryupoVoqK3jYmhTS30STIl0Q3qnqQ=";
    };
  };

  nativeBuildInputs = with pkgs; [
    pkg-config
    cmake
    clang
    gcc
    rustPlatform.bindgenHook
  ];

  buildInputs = with pkgs; [
    v4l-utils
    pcsclite
    systemd.dev
  ];

  # cargo build -F dvb --release
  buildFeatures = [ "dvb" ];

  # bindgenがlibclangを見つけられるように設定
  LIBCLANG_PATH = "${pkgs.libclang.lib}/lib";

  # ビルド中のユニットテストをスキップ（デバイスが必要なテストがある場合）
  doCheck = false;

  meta = with pkgs.lib; {
    description = "A Rust-based tool for recisdb";
    homepage = "https://github.com/kazuki0824/recisdb-rs";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
