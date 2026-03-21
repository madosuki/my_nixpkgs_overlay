{ pkgs, stdenv, fetchFromGitHub
# , bitrateIni ? null
# , bonCtrlIni ? null
# , contentTypeText ? null
# , epgTimerSrvIni ? null
}:

stdenv.mkDerivation rec {
  pname = "edcb";
  version = "251101";
  buildInputs = [
    pkgs.openssl
    pkgs.zlib
    pkgs.lua52Packages.lua
    pkgs.lua52Packages.lua-zlib
    stdenv.cc.cc.lib
  ];
  nativeBuildInputs = [
    pkgs.gcc
    pkgs.pkg-config
    pkgs.curl
    pkgs.makeWrapper
  ];
  src = fetchFromGitHub {
    owner = "xtne6f";
    repo = "EDCB";
    rev = "d21fa8a8fa36c8366e366fcd200e01232a9a8d60";
    sha256 = "sha256-VfhXRinvlN/n54NsqsNn/rhlohxY91zoV92nMi82AvU=";
  };

  bonDriverLinuxMirakc = fetchFromGitHub {
    owner = "matching";
    repo = "BonDriver_LinuxMirakc";
    rev = "cfbefc6d21dab4009db5f124984c1b720b76d869";
    sha256 = "sha256-nEWCuA0BRY7qFNASV4jj0BKRpFXIyJzgI1ch1nyoSQ0=";
    fetchSubmodules = true;
  };

  postPatch = ''
    # replace hard coding lib path to out
    sed -i 's|#define EDCB_LIB_ROOT L"/usr/local/lib/edcb"|#define EDCB_LIB_ROOT L"'${placeholder "out"}'/lib/edcb"|' Common/PathUtil.h
  '';

  preBuild = ''
    export NIX_LDFLAGS="-rpath $out/lib -rpath ${pkgs.lua52Packages.lua}/lib $NIX_LDFLAGS -L${pkgs.lua5_2}/lib -llua"
    
    # replace -llua5.2 in Makefile.
    find . -name Makefile -exec sed -i 's/-llua5.2/-llua/g' {} +
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/lib/edcb

    # cp ./EpgDataCap3/EpgDataCap3/EpgDataCap3.so $out/lib/
    cp ./EpgDataCap3/EpgDataCap3/EpgDataCap3_Unicode.so $out/lib/edcb/EpgDataCap3.so
    cp ./RecName_Macro/RecName_Macro/RecName_Macro.so $out/lib/edcb/
    cp ./SendTSTCP/SendTSTCP/SendTSTCP.so $out/lib/edcb/
    cp ./Write_Default/Write_Default/Write_Default.so $out/lib/edcb/

    cp ./EpgDataCap_Bon/EpgDataCap_Bon/EpgDataCap_Bon $out/bin/
    cp ./EpgTimerSrv/EpgTimerSrv/EpgTimerSrv $out/bin/

    cp ./BonDriver_LinuxMirakc/BonDriver_LinuxMirakc.so $out/lib/edcb/
    cp ./BonDriver_LinuxMirakc/BonDriver_LinuxMirakc.so.ini_sample $out/lib/edcb/BonDriver_LinuxMirakc.so.ini
    # sed -i 's|SERVER_SOCKPATH="/var/run/mirakc.sock"|SERVER_SOCKPATH="/var/local/run/mirakc.sock"|' $out/lib/edcb/BonDriver_LinuxMirakc.so.ini
    # sed -i 's/^SERVER_TYPE="http"/SERVER_TYPE="unix"/' $out/lib/edcb/BonDriver_LinuxMirakc.so.ini
    sed -i 's/^DECODE_B25=1/DECODE_B25=0/' $out/lib/edcb/BonDriver_LinuxMirakc.so.ini

    # below process is place setting files but not working; because EDCB is require write permission setting dir.
    # therefore shoud manually place setting files refer to https://github.com/xtne6f/EDCB/blob/work-plus-s/Document/HowToBuild.txt
    # install setting files
    # mkdir -p $out/etc/edcb

    # iconv -f CP932 -t UTF-8 ./ini/Bitrate.ini | tr -d '\r' > $out/etc/edcb/Bitrate.ini
    # iconv -f CP932 -t UTF-8 ./ini/BonCtrl.ini | tr -d '\r' | sed 's/\.dll$$/.so/' > $out/etc/edcb/BonCtrl.ini

    # tr -d '\r' < ./ini/ContentTypeText.txt > $out/etc/edcb/ContentTypeText.txt


    # mkdir -p $out/etc/edcb/HttpPublic
    # cp -Rn ./ini/HttpPublic/index.html ./ini/HttpPublic/favicon.ico ./ini/HttpPublic/legacy $out/etc/edcb/HttpPublic/
    # echo '[SET]' > $out/etc/edcb/EpgTimerSrv.ini
    # echo 'EnableHttpSrv=2' > $out/etc/edcb/EpgTimerSrv.ini
    # echo 'HttpAccessControlList=+127.0.0.1,+::1,+::ffff:127.0.0.1' >> $out/etc/edcb/EpgTimerSrv.ini

    runHook postInstall
  '';

  posInstall = ''
  wrapProgram $out/bin/EpgTimerSrv --prefix LD_LIBRARY_PATH : "$out/lib:${pkgs.lua52Packages.lua}/lib"
  wrapProgram $out/bin/EpgDataCap_Bon --prefix LD_LIBRARY_PATH : "$out/lib:${pkgs.lua52Packages.lua}/lib"
  '';

  buildPhase = ''
    runHook preBuild
    cd Document/Unix
    make NOPCH=1 -j $NIX_BUILD_CORES

    cd ../../

    cp -r ${bonDriverLinuxMirakc} BonDriver_LinuxMirakc
    chmod -R u+w ./BonDriver_LinuxMirakc
    cd ./BonDriver_LinuxMirakc
    make
    cd ../

    runHook postBuild
  '';

  meta = with pkgs.lib; {
    description = "EDCB (EpgDataCap_Bon) forked by xtne6f";
    homepage = "https://github.com/xtne6f/EDCB";
    # license = licenses.mit; # 実際のライセンスを確認してください
    platforms = platforms.linux;
  };
}
