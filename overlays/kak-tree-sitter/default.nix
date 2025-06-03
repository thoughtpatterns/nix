# TinyCC is broken on aarch64-darwin, so we use the standard compiler.

self: super:

let
  lib = super.lib;
  cc = super.stdenv.cc;
in
{
  kak-tree-sitter =
    (super.kak-tree-sitter.override {
      tinycc = cc;
    }).overrideAttrs
      (attrs: {
        postBuild = ''
          mkdir -p "$out/libexec/kts-compiler/bin"
          ln -s "${lib.getExe cc}" "$out/libexec/kts-compiler/bin/cc"
          wrapProgram "$out/bin/ktsctl" --suffix PATH : "$out/libexec/kts-compiler/bin"
        '';
      });
}
