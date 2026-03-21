
{ pkgs, stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "jdim";
  version = "0.16.0";
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
    rev = "cc9878799dc5f5b5351516944291e77d2425cc4e";
    sha256 = "sha256-XflYZyukPANNSLsmP9ZWVpVdYiMzTyHvvdso9ay2VBQ=";
  };

  meta = with pkgs.lib; {
    description = "JDim";
    homepage = "https://github.com/JDimproved/JDim";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
  };

}
