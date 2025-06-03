### public:

declare-option str format_command

### private:

define-command -docstring 'format the active buffer' format-buffer %{
	evaluate-commands -draft %{
		execute-keys '%'
		format-selections
	}
}

define-command -docstring 'format each selection' format-selections %{
	evaluate-commands %sh{
		if [ -z "$kak_opt_format_command" ]
		then printf 'fail "%s"' "'comment-block': options 'comment_block_{begin,end}' are empty"
		fi
	}

	evaluate-commands -draft -save-regs 'e|' -no-hooks %{
		set-register e 'nop'
		set-register | %{
			root="$(mktemp -d)" ; stdin="$root/stdin" ; stdout="$root/stdout"
			tee "$stdin" | eval "$kak_opt_format_command" > "$stdout"

			if [ "$?" -eq 0 ]
			then cat "$stdout"
			else printf 'set-register e fail "%s"\n' "failed to format buffer" > "$kak_command_fifo" ; cat "$stdin"
			fi

			rm -rf "$root"
		}

		execute-keys '|<ret>'
		%reg{e}
	}
}
