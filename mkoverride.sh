#!/usr/bin/env nix-shell
#!nix-shell ./default.nix -i bash
set -e
TMPDIR=$(mktemp -d)
SELF_DIR=$(dirname "$(readlink -f "$0")")
ORIG_PWD=$PWD
cp *.aml $TMPDIR/
cd $TMPDIR
iasl -e ssdt1.aml -e ssdt6.aml -d dsdt.aml
for i in $SELF_DIR/dsdt/*.patch; do patch -p1 < $i; done
# Bump OEM revision so Linux picks it up over the built-in table
sed -i 's/\(DefinitionBlock \(.*\), \)\(.*\)/\10x0FFFFFFF)/' dsdt.dsl
iasl -tc dsdt.dsl
gen_init_cpio $SELF_DIR/override_cpio_spec > $ORIG_PWD/acpi_dsdt_override.cpio
cd / && rm -Rf $TMPDIR