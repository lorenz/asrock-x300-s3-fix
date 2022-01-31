let
  overlay = (self: super: rec {
    acpica-tools = super.acpica-tools.overrideAttrs (attrs: {
        patches = [ ./iasl/iasl-accept-duplicates.patch ];
    });
  });
in
{ pkgs ? import (fetchTarball https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz) { overlays = [ overlay ]; } }:
let
    geninitcpio = pkgs.stdenv.mkDerivation {
        name = "geninitcpio";
        version = "5.14.1";
        src = pkgs.fetchurl {
            url = "https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.14.1.tar.xz";
            sha256 = "1iq8s031fviccc4710biwl7gxqdimm3nhlvxd0m3fykvhhmcanq0";
        };
        buildPhase = "gcc -o gen_init_cpio usr/gen_init_cpio.c";
        installPhase = ''
            mkdir -p $out/bin
            cp gen_init_cpio $out/bin/
        '';
    };
in
pkgs.stdenv.mkDerivation {
  name = "acpi-s3-fix";
  buildInputs = with pkgs; [
    acpica-tools
    patch
    geninitcpio
  ];
}
