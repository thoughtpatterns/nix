# We use a NUL character to delimit lines for sort.
declare-option -hidden str sort_nul %sh{ printf %b "\0" }

define-command -params .. -docstring 'sort selections, with parameters passed to `sort`' sort-selections %{
	evaluate-commands -save-regs "bfns|" %{
		set-register b %reg{percent}
		execute-keys '"sy'

		edit -scratch
		set-register f %reg{percent}
		set-register n %opt{sort_nul}
		execute-keys '"s<a-P>"np' # Paste selections, separated by newlines.
		set-register | %exp{ sort --zero-terminated %arg{@} }
		execute-keys '%H|<ret>S\u000000<ret>"sy' # Execute `H` after `%` to unselect the terminating newline from `sort`.

		delete-buffer %reg{f}
		buffer %reg{b}

		execute-keys '"sR'
	}
}

define-command -params .. -docstring 'sort the characters of each selection, with parameters passed to `sort`' sort-characters %{
	evaluate-commands -save-regs | %{
		set-register | %exp{ sed 's/./&\n/g' | sort %arg{@} | tr -d "\n" }
		execute-keys '|<ret>'
	}
}
