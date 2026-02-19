{ pkgs, stdenv, fetchFromGitHub
, bitrateIni ? null
, bonCtrlIni ? null
, contentTypeText ? null
, epgTimerSrvIni ? null }:

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

  postPatch = ''
    # replace /var/local/edcb to $out/etc/edcb; edcb is hard-coding use /var/local/edcb.
    # find . -type f \( -name "*.cpp" -o -name "*.h" \) -exec sed -i 's|/var/local/edcb|/etc/edcb|g' {} +
  '';

  preBuild = ''
    export NIX_LDFLAGS="-rpath $out/lib -rpath ${pkgs.lua52Packages.lua}/lib $NIX_LDFLAGS -L${pkgs.lua5_2}/lib -llua"
    
    # replace -llua5.2 in Makefile.
    find . -name Makefile -exec sed -i 's/-llua5.2/-llua/g' {} +
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/lib
    cd ../../

    # cp ./EpgDataCap3/EpgDataCap3/EpgDataCap3.so $out/lib/
    cp ./EpgDataCap3/EpgDataCap3/EpgDataCap3_Unicode.so $out/lib/libEpgDataCap3.so
    cp ./RecName_Macro/RecName_Macro/RecName_Macro.so $out/lib/
    cp ./SendTSTCP/SendTSTCP/SendTSTCP.so $out/lib/
    cp ./Write_Default/Write_Default/Write_Default.so $out/lib/

    cp ./EpgDataCap_Bon/EpgDataCap_Bon/EpgDataCap_Bon $out/bin/
    cp ./EpgTimerSrv/EpgTimerSrv/EpgTimerSrv $out/bin/

    # install setting files
    mkdir -p $out/etc/edcb

    ${if bitrateIni != null
      then "cp ${bitrateIni} $out/etc/edcb/Bitrate.ini"
      else "iconv -f CP932 -t UTF-8 ./ini/Bitrate.ini | tr -d '\r' > $out/etc/edcb/Bitrate.ini"
     }
    ${if bonCtrlIni != null
      then "cp ${bonCtrlIni} $out/etc/edcb/BonCtrl.ini"
      else "iconv -f CP932 -t UTF-8 ./ini/BonCtrl.ini | tr -d '\r' | sed 's/\.dll$$/.so/' > $out/etc/edcb/BonCtrl.ini"
     }

    ${if contentTypeText != null
      then "cp ${contentTypeText} $out/etc/edcb/ContentTypeText.txt"
      else "tr -d '\r' < ./ini/ContentTypeText.txt > $out/etc/edcb/ContentTypeText.txt"
     }


    mkdir -p $out/etc/edcb/HttpPublic
    cp -Rn ./ini/HttpPublic/index.html ./ini/HttpPublic/favicon.ico ./ini/HttpPublic/legacy $out/etc/edcb/HttpPublic/
    ${if epgTimerSrvIni != null
      then "cp ${epgTimerSrvIni} $out/etc/edcb/"
      else "echo '[SET]' > $out/etc/edcb/EpgTimerSrv.ini; \
      	    echo 'EnableHttpSrv=2' > $out/etc/edcb/EpgTimerSrv.ini; \
	          echo 'HttpAccessControlList=+127.0.0.1,+::1,+::ffff:127.0.0.1' >> $out/etc/edcb/EpgTimerSrv.ini"
     }

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
    runHook postBuild
  '';

  meta = with pkgs.lib; {
    description = "EDCB (EpgDataCap_Bon) forked by xtne6f";
    homepage = "https://github.com/xtne6f/EDCB";
    # license = licenses.mit; # 実際のライセンスを確認してください
    platforms = platforms.linux;
  };
}
