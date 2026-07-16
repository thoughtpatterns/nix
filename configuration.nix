# Shared configuration for every host, regardless of OS. Per-OS pieces live in
# ./modules/darwin.nix, ./modules/linux-cli.nix, and ./modules/linux-gui.nix;
# per-host pieces live under ./hosts.
{
  lib,
  pkgs,
  inputs,
  host,
  user,
  home,
  ...
}:

let
  dashScript =
    {
      name,
      inputs ? [ ],
      text,
    }:
    pkgs.writeScriptBin name ''
      #!${pkgs.dash}/bin/dash -eu
      export PATH="${lib.makeBinPath inputs}:$PATH"
      ${text}
    '';

  pythonScript =
    {
      name,
      python,
      libs ? [ ],
      text,
    }:
    let
      environment = python.withPackages (_: libs);
    in
    pkgs.writeScriptBin name ''
      #!${environment}/bin/python
      ${text}
    '';

  scripts = {
    c =
      let
        python = pkgs.python314;
      in
      pythonScript {
        name = "c";
        inherit python;
        libs = with python.pkgs; [
          ipython
          numpy
        ];
        text = ''
          #!python
          from numpy import *
          from sys import stdin

          if stdin.isatty():
              from IPython import start_ipython
              start_ipython(argv=[], user_ns=locals())
          else:
              print(eval(stdin.read().strip()))
        '';
      };

    e = dashScript {
      name = "e";
      inputs = with pkgs; [
        coreutils
        kakoune
      ];
      text = ''
        #!bash
        kak -C "$(pwd | sha1sum | cut -c1-8)" "$@"
      '';
    };

    # NOTE: temporary, until we rewrite repl-buffer.kak.
    repl-buffer-input =
      let
        python = pkgs.python314;
      in
      pythonScript {
        name = "repl-buffer-input";
        inherit python;
        text = ''
          #!python
          import signal
          import sys

          TIMEOUT = 5
          signal.setitimer(signal.ITIMER_REAL, TIMEOUT, TIMEOUT)
          signal.siginterrupt(signal.SIGALRM, False)
          signal.signal(signal.SIGALRM, lambda _signum, _stack: None)
          BUFFER = bytearray(4096)

          while True:
              try:
                  with open(sys.argv[1], "rb", buffering=0) as handle:
                      while True:
                          count = handle.readinto(BUFFER)
                          if count > 0:
                              valid_data = memoryview(BUFFER)[:count]
                              sys.stdout.buffer.write(valid_data)
                              sys.stdout.buffer.flush()
                          else:
                              break
              except FileNotFoundError:
                  break
        '';
      };
  };
in
{
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      inputs.rust-overlay.overlays.default
    ]
    ++ builtins.map (name: import (./overlays + "/${name}")) (
      builtins.attrNames (builtins.readDir ./overlays)
    );
  };

  environment = {
    # TODO: move compilers and LSPs to project flakes.
    systemPackages =
      with pkgs;
      [
        basedpyright
        clang
        clang-tools
        claude-code
        coreutils
        dash
        direnv
        ffmpeg
        flirt
        gambit
        git
        git-lfs
        gnumake
        gnupg
        janet
        janetPackages.spork
        kakoune
        kakoune-lsp
        kakounePlugins.kak-ansi
        kakounePlugins.kakeidoscope
        kak-tree-sitter
        keychain
        leccaper
        llvm
        luajit
        mitscheme-svm
        mpv
        ncdu
        nil
        nix-direnv
        nixfmt
        odin
        ols
        openssh
        ruff
        rust-analyzer
        rust-bin.stable.latest.default
        stylua
        tectonic
        tex-fmt
        texpand
        tinymist
        tpp
        typst
        uv
        vidir
        vipe
        watchexec
        zotero
      ]
      ++ builtins.attrValues scripts;

    variables = {
      EDITOR = "e";
      PAGER = "e";
      VISUAL = "e";

      JANET_PATH = "${pkgs.janetPackages.spork}";
      JULIA_DEPOT_PATH = "${home}/.julia";
      KAKOUNE_POSIX_SHELL = "${pkgs.dash}/bin/dash";
    };
  };

  fonts.packages = with pkgs; [ nerd-fonts.iosevka ];

  networking.hostName = host;

  nix = {
    package = pkgs.nix;

    settings = {
      trusted-users = [ user ];
      substituters = [ "https://cache.nixos.org" ];
      trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };

    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
  };

  programs = {
    fish.enable = true;
    nix-index-database.comma.enable = true;
  };

  time.timeZone = "America/Detroit";

  users.users.${user} = {
    inherit home;
    shell = pkgs.fish;
  };
}
