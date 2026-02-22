{ pkgs, stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "mirakc-arib";
  version = "0.24.28";
  buildInputs = [
    stdenv.cc.cc.lib
    pkgs.dos2unix
  ];
  nativeBuildInputs = [
    pkgs.gcc
    pkgs.libtool
    pkgs.pkg-config
    pkgs.cmake
    pkgs.ninja
    pkgs.gnumake
    pkgs.autoconf
    pkgs.automake
    pkgs.gnupatch
    pkgs.git
    pkgs.cppcodec
  ];
  src = fetchFromGitHub {
    owner = "mirakc";
    repo = "mirakc-arib";
    rev = "441a48b0777fa2129e689a5929425690849ea04e";
    sha256 = "sha256-SEmriNSBlHM5Bz1rG/FYYFjWTXTgj0D+jdSk3oBkd1Y=";
    fetchSubmodules = true;
  };

  dontUseCmakeConfigure = true;

  preBuild = ''
    patchShebangs .
    
    find . -type f \( -name "Makefile*" -o -name "*.mk" -o -name "*.cmake" \) \
      -exec sed -i 's:/bin/bash:${stdenv.shell}:g' {} +

    find . -type f \( -name "Makefile*" -o -name "*.mk" -o -name "*.cmake" -o -name "*.common" \) \
      -exec sed -i 's/-Werror//g' {} +
  '';

  buildPhase = ''
  runHook preBuild

  export CXXFLAGS="-Wno-error"
  export CFLAGS="-Wno-error"

  cmake -S . -B build -G Ninja -D CMAKE_BUILD_TYPE=Release

  find build -name "*.ninja" -exec sed -i 's/git checkout -f && //g' {} +
  find build -name "*-patch" -exec sed -i 's/git checkout -f && //g' {} +

  ninja -C build vendor
  ninja -C build
  runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp build/bin/mirakc-arib $out/bin/
    
    runHook postInstal
  '';

  meta = with pkgs.lib; {
    description = "mirakc-arib";
    homepage = "https://github.com/mirakc/mirakc-arib";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
  };

}
