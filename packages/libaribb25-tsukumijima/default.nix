{ pkgs, stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "libaribb25-tsukumijima";
  version = "0.2.10";
  buildInputs = [
    stdenv.cc.cc.lib
    pkgs.pcsclite
  ];
  nativeBuildInputs = [
    pkgs.gcc
    pkgs.git
    pkgs.pkg-config
    pkgs.cmake
  ];
  cmakeFlags = [
    "-DOPT_PCSC=ON"
  ];
  src = fetchFromGitHub {
    owner = "tsukumijima";
    repo = "libaribb25";
    rev = "c30cbd1357f08129da59c2fcd01a0b1be50220c5";
    hash = "sha256-3lxHRAxGkXMIsc+mGMDk3g7Gl1kbAVWyHLmDGnRe8aw=";
  };
}
