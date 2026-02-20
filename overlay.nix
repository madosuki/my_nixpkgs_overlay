self: super: {
  jdim = super.callPackage ./packages/jdim/default.nix {};
  libaribb25-tsukumijima = super.callPackage ./packages/libaribb25-tsukumijima/default.nix {};
  recisdb = super.callPackage ./packages/recisdb/default.nix {};
  edcb = super.callPackage ./packages/edcb/default.nix {};
  mirakc = super.callPackage ./packages/mirakc/default.nix {};
}
