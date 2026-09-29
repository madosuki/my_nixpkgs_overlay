{ pkgs, stdenv, lib, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "jdim";
  version = "0.17.0";
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
    rev = "3d20eba5565e8c7b2bf70aaaad3d5b97794c66e0";
    sha256 = "sha256-8gfEwgpJUaVq/EkHCT3Xf3NasEYn6q7yl86G0onjh+E=";
  };

  meta = with pkgs.lib; {
    description = "JDim";
    homepage = "https://github.com/JDimproved/JDim";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
  };

}
