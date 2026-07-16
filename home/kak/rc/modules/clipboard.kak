define-command -params 1 -docstring 'yank selection(s)? to clipboard' yank-to-clipboard %{ nop %sh{
	case "$1" in
	('selection') set -- "$kak_selection" ;;
	('selections') eval set -- "$kak_quoted_selections" ;;
	esac

	printf %s "$@" | @(display (if (string=? uname "Darwin") "pbcopy" "wl-copy > /dev/null 2>&1"))
}}
