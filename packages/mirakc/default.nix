{ pkgs ? import <nixpkgs> {} }:

pkgs.rustPlatform.buildRustPackage rec {
  pname = "mirakc";
  version = "3.4.67";

  swaggerUiZip = pkgs.fetchurl {
    url = " https://github.com/swagger-api/swagger-ui/archive/refs/tags/v5.17.14.zip";
    hash = "sha256-SBJE0IEgl7Efuu73n3HZQrFxYX+cn5UU5jrL4T5xzNw=";
  };

  src = pkgs.fetchFromGitHub {
    owner = "mirakc";
    repo = "mirakc";
    rev = "669e96bcbc942743e3780a7a2ce12a9386478632";
    fetchSubmodules = true;
    sha256 = "sha256-HuuM8GeBEMau/sBa74OlufsNraHfQiJUXxMobrGkJDw=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
  };

  nativeBuildInputs = with pkgs; [
    curl
    rustPlatform.bindgenHook
    git
  ];

  buildInputs = with pkgs; [
  ];
  
  postPatch = ''
    substituteInPlace mirakc-core/src/config.rs \
      --replace "/etc/mirakc/strings.yml" "/var/local/mirakc/config/strings.yml"
  '';

  preBuild = ''
  cp ${swaggerUiZip} ./swagger-ui.zip
  chmod 755 ./swagger-ui.zip
  export SWAGGER_UI_DOWNLOAD_URL="file://$(pwd)/swagger-ui.zip"
  '';

  checkFlags = [
    "--skip=config::tests::test_load"
  ];

  meta = with pkgs.lib; {
    description = "mirakc";
    homepage = "https://github.com/mirakc/mirakc";
    license = with licenses; [
      asl20
      mit
    ];
    platforms = platforms.linux;
  };
}
