# for debug
{ pkgs ? import <nixpkgs> {} }:
pkgs.callPackage ./default.nix {}
