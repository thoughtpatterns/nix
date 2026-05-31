{
  lib,
  pkgs,
  host,
  user,
  ...
}:

let
  home = "/Users/${user}";

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
        kak -C "$(pwd | sha1sum | cut -c1-8)" "$@"
      '';
    };
  };

  linkScript =
    let
      source = "${home}/.config/nix/home";
      targets =
        name:
        {
          kak-tree-sitter = "Library/Application Support/kak-tree-sitter";
          ssh = ".ssh";
        }
        .${name} or ".config/${name}";
    in
    lib.concatStrings (
      map (
        name:
        let
          target = targets name;
        in
        lib.concatStrings (
          lib.mapAttrsToList (entry: _: ''
            rm -rf '${home}/${target}/${entry}'
            sudo -u '${user}' mkdir -p '${home}/${target}'
            sudo -u '${user}' ln -sfn '${source}/${name}/${entry}' '${home}/${target}/${entry}'
          '') (builtins.readDir (./home + "/${name}"))
        )
      ) (builtins.attrNames (builtins.readDir ./home))
    );
in
{
  environment = {
    pathsToLink = [ "/Applications" ];

    systemPackages =
      with pkgs;
      [
        aerospace
        basedpyright
        clang
        clang-tools
        claude-code
        coreutils
        dash
        direnv
        docker
        ffmpeg
        flirt
        gh
        ghostty-bin
        git
        git-lfs
        gnumake
        gnupg
        janet
        janetPackages.spork
        kak-tree-sitter
        kakoune
        kakoune-lsp
        kakounePlugins.kak-ansi
        kakounePlugins.kakeidoscope
        keychain
        leccaper
        libiconv
        llvm
        luajit
        mawk
        mpv
        nil
        nix-direnv
        nixfmt
        openssh
        ruff
        rust-analyzer
        rust-bin.stable.latest.default
        sketchybar
        skimpdf
        stylua
        syncthing
        tectonic
        tex-fmt
        texpand
        tinymist
        tokei
        tree
        typst
        uv
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
      MAKEFLAGS = "-j12";
      MallocNanoZone = "0";
      NIX_DIRENV_RC = "${pkgs.nix-direnv}/share/nix-direnv/direnvrc";
      RUSTFLAGS = "-L${pkgs.libiconv}/lib";
    };
  };

  fonts.packages = with pkgs; [
    nerd-fonts.iosevka
    tex-gyre-math.pagella
    tex-gyre.cursor
    tex-gyre.pagella
  ];

  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";
    casks = [
      "adobe-creative-cloud"
      "anki"
      "beeper"
      "helium-browser"
      "microsoft-office"
      "nordvpn"
      "spotify"
      "zoom"
    ];
  };

  launchd =
    let
      service =
        {
          name,
          command,
          extra ? { },
        }:
        {
          inherit command;
          serviceConfig = {
            KeepAlive = true;
            RunAtLoad = true;
            StandardErrorPath = "/tmp/${name}/stderr.txt";
            StandardOutPath = "/tmp/${name}/stdout.txt";
          }
          // extra;
        };
    in
    {
      user.agents = {
        aerospace = service {
          name = "aerospace";
          command = "${pkgs.aerospace}/Applications/AeroSpace.app/Contents/MacOS/AeroSpace";
          extra.EnvironmentVariables.PATH = "${pkgs.dash}/bin:${pkgs.sketchybar}/bin:/bin:/usr/bin";
        };

        sketchybar = service {
          name = "sketchybar";
          command = "${pkgs.sketchybar}/bin/sketchybar";
          extra.EnvironmentVariables = {
            JANET_PATH = "${pkgs.janetPackages.spork}";
            PATH = "${pkgs.aerospace}/bin:${pkgs.janet}/bin:${pkgs.sketchybar}/bin:/bin:/usr/bin";
          };
        };
      };
    };

  networking.hostName = host;

  nix = {
    package = pkgs.nix;

    settings = {
      trusted-users = [
        "@admin"
        user
      ];

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
      interval = {
        Weekday = 0;
        Hour = 2;
        Minute = 0;
      };
    };
  };

  programs.fish.enable = true;

  system = {
    activationScripts.postActivation.text = ''
      ${linkScript}

      # Avoid a restart for user preference changes.
      sudo -u '${user}' /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';

    defaults.CustomUserPreferences = {
      "com.apple.symbolichotkeys" = {
        AppleSymbolicHotKeys =
          lib.genAttrs (map toString (lib.range 0 300)) (_: {
            enabled = false;
          })
          // {
            "187".enabled = true; # Spotlight ←  F4.
          };
      };
    };

    nixpkgsRelease = "unstable";
    primaryUser = user;
    startup.chime = false;
    stateVersion = 6;
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  time.timeZone = "America/Detroit";

  users.users.${user} = {
    inherit home;
    name = user;
    shell = pkgs.fish;
  };
}
