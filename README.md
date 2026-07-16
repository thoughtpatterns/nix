# nix

My NixOS + nix-darwin configurations. Commit history not for the faint of heart.

Two hosts share this repo:

- **`x230`** — a ThinkPad X230 running NixOS. Root is a two-SSD striped ZFS pool
  (`zroot`); the compositor is [niri](https://github.com/YaLTeR/niri).
- **`imac`** — an Apple-silicon iMac running nix-darwin, with Homebrew casks
  managed by [nix-homebrew](https://github.com/zhaofengli/nix-homebrew).

Configuration is layered: [`configuration.nix`](configuration.nix) is shared
by every host; under [`modules/`](modules), [`darwin.nix`](modules/darwin.nix)
holds the macOS pieces while [`linux-cli.nix`](modules/linux-cli.nix) (base
system) and [`linux-gui.nix`](modules/linux-gui.nix) (niri/Wayland desktop)
split the Linux pieces; and the slim files under [`hosts/`](hosts) add only
what's machine-specific. A new headless Linux host imports `configuration.nix` +
`modules/linux-cli.nix`; a graphical one layers on `modules/linux-gui.nix` too.

Dotfiles under [`home/`](home) are templates for [`tpp`](https://git.sr.ht/~orchid/tpp):
`@(…)` escapes evaluate Gambit Scheme against the keys `uname` (`Darwin`/`Linux`),
`hostname`, and `home`, so one source renders differently per host. The manifest
[`home/ttpd.jdn`](home/ttpd.jdn) maps each directory to its destination under `$HOME` and
restricts OS-specific configs to the right machine. `tppd` (a Janet program,
[`packages/tppd`](packages/tppd), invoked only by this config — not on `PATH`)
renders the templates into **copies** (not symlinks); it runs once on activation
and then continuously via a `watchexec` user service (`tppd --daemon`) that
re-renders on any change to `home/`. Keep this repo checked out at
`~/.config/nix`.

## Install (x230)

Boot the NixOS installer, then, as root:

```sh
# 1. Partition, format, and create the striped ZFS pool (wipes BOTH SSDs).
nix --experimental-features "nix-command flakes" run github:nix-community/disko -- \
  --mode disko /path/to/this/repo/hosts/x230/disko.nix

# 2. Install.
nixos-install --flake /path/to/this/repo#x230

# 3. Reboot, log in (initial password: changeme), then `passwd`.
```

Rebuild afterwards with `sudo nixos-rebuild switch --flake ~/.config/nix#x230`.

## Install (imac)

Install nix-darwin, then build the config:

```sh
sudo darwin-rebuild switch --flake ~/.config/nix#imac
```
