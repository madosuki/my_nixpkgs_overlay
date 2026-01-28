{ pkgs, stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "jdim";
  version = "0.15.0";
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
    rev = "95c8d64c60e607aebb9097b9dd4b865670b1844c";
    sha256 = "sha256-ztbSsKPN+UasuYa033pJRGhQCZTEsUSkpa27tdjG7tM=";
  };
}
