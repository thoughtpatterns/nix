set -q fish_config_sourced
and exit
or set -g fish_config_sourced 1

@(when (string=? uname "Darwin") (display "set -gx PATH $PATH /opt/homebrew/bin /Library/Developer/CommandLineTools/usr/bin"))
set -gx SHELL (status fish-path)

status is-interactive
and begin
	set -l flake "$HOME/.config/nix"
	set -g fish_greeting

	set -gx LS_COLORS "$LS_COLORS:ow=0:tw=0"
	set -gx MANPATH '' "$__fish_data_dir/man" # See '/etc/man.conf'.
	set -gx TTY (tty)

	abbr --add g git
	abbr --command git a add
	abbr --command git c commit
	abbr --command git d diff
	abbr --command git e "commit --allow-empty-message -m ''"
	abbr --command git i init
	abbr --command git l log
	abbr --command git m merge
	abbr --command git o clone
	abbr --command git p push
	abbr --command git r remote
	abbr --command git s status
	abbr --command git u pull

	@(define rebuild (if (string=? uname "Darwin") "darwin-rebuild" "nixos-rebuild"))
	abbr --add r @(display rebuild)
	abbr --command @(display rebuild) b -- "--flake $flake build"
	abbr --command @(display rebuild) g -- --switch-generation
	abbr --command @(display rebuild) l -- --list-generations
	abbr --command @(display rebuild) r -- --rollback
	abbr --command @(display rebuild) s -- "--flake $flake @(display (if (string=? uname "Darwin") "build switch" "switch"))"

	abbr --add cp       'cp -r'
	abbr --add mkdir    'mkdir -p'
	abbr --add ncdu     'ncdu -t@(display threads)'
	abbr --add rm       'rm -rf'
	abbr --add tectonic 'tectonic -X'
	@(when (string=? uname "Darwin") (display "abbr --add pkill 'pkill -I'"))

	keychain --eval --quiet id_ed25519 | source
	direnv hook fish | source
end
