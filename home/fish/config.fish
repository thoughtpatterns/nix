set -q fish_config_sourced
and exit
or set -g fish_config_sourced 1

set -gx PATH $PATH /opt/homebrew/bin /Library/Developer/CommandLineTools/usr/bin
set -gx SHELL (status fish-path)

status is-interactive
and begin
	set -l flake "$HOME/.config/nix"
	set -g fish_greeting

	set -gx MANPATH '' "$__fish_data_dir/man" # See '/etc/man.conf'.
	set -gx TTY (tty)

	abbr --add d darwin-rebuild
	abbr --command darwin-rebuild b -- "--flake $flake build"
	abbr --command darwin-rebuild g -- --switch-generation
	abbr --command darwin-rebuild l -- --list-generations
	abbr --command darwin-rebuild r -- --rollback
	abbr --command darwin-rebuild s -- "--flake $flake build switch"

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

	abbr --add cp       'cp -r'
	abbr --add mkdir    'mkdir -p'
	abbr --add pkill    'pkill -I'
	abbr --add rm       'rm -r'
	abbr --add tectonic 'tectonic -X'

	keychain --eval --quiet id_ed25519 | source
	direnv hook fish | source
end
