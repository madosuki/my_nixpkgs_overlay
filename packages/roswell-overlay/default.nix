{ pkgs, stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "roswell";
  version = "26.02.116";
  buildInputs = [
    stdenv.cc.cc.lib
    pkgs.curl
    pkgs.gnutls
  ];
  nativeBuildInputs = [
    pkgs.gcc
    pkgs.libtool
    pkgs.pkg-config
    pkgs.automake
    pkgs.autoconf
  ];
  src = fetchFromGitHub {
    owner = "roswell";
    repo = "roswell";
    rev = "aac28aaeddfea5261190e5a26394a98c797bacc0";
    sha256 = "sha256-saKCLr1Nmzl+zcPbYSXt7o82hh6vYhACCfUUzEs/31E=";
  };

  postPatch = ''
  find lisp -name "*.ros" -exec chmod +x {} +
  patchShebangs lisp/*.ros
  '';

  preConfigure = ''
  patchShebangs bootstrap
  ./bootstrap
  '';

  meta = with pkgs.lib; {
    description = "roswell";
    homepage = "https://github.com/roswell/roswell";
    license = licenses.mit;
    platforms = platforms.linux;
  };

}
