define-command -params 1 -docstring 'yank selection(s)? to clipboard' yank-to-clipboard %{ nop %sh{
	case "$1" in
	('selection') set -- "$kak_selection" ;;
	('selections') eval set -- "$kak_quoted_selections" ;;
	esac

	printf %s "$@" | pbcopy
}}
