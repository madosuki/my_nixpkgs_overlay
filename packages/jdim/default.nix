{ pkgs, stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "jdim";
  version = "0.14.0";
  buildInputs = [
    pkgs.mesa
    pkgs.gtkmm3
    pkgs.libxcrypt
    pkgs.gnutls
    pkgs.zlib
    stdenv.cc.cc.lib
  ];
  nativeBuildInputs = [
    pkgs.gcc
    pkgs.meson
    pkgs.libtool
    pkgs.pkg-config
    pkgs.cmake
    pkgs.gtest
    pkgs.ninja
  ];
  src = fetchFromGitHub {
    owner = "JDimproved";
    repo = "JDim";
    rev = "11a0e8c648092d51308acb67bc86cc44cf9b0e20";
    sha256 = "0n2i8pg71wb3a3hq91p4if1zs7f86wbjjakzp9615lylacwzjaip";
  };
}
