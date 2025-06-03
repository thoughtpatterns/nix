### public:

declare-option -docstring 'characters to insert at the start of a commented line' str comment_line '#'
declare-option -docstring 'characters to insert at the start of a commented block' str comment_block_begin
declare-option -docstring 'characters to insert at the end of a commented block' str comment_block_end

### private:

define-command -hidden comment-align-anchors %{ evaluate-commands %sh{
	eval set -- "$kak_quoted_selections_desc"

	if [ "$#" -eq 0 ]
	then exit
	fi

	anchor="${1%%,*}"
	minimum="${anchor##*.}"

	for selection
	do
		anchor="${selection%%,*}"
		column="${anchor##*.}"

		if [ "$column" -lt "$minimum" ]
		then minimum="$column"
		fi
	done

	printf 'select'

	for selection
	do
		anchor="${selection%%,*}"
		cursor="${selection#*,}"
		line="${anchor%.*}"

		printf ' %s.%s,%s' "$line" "$minimum" "$cursor"
	done
}}

define-command -docstring '{un,}-block-comment selections' comment-block %{
	evaluate-commands %sh{
		if [ -z "$kak_opt_comment_block_begin" -o -z "$kak_opt_comment_block_end" ]
		then printf 'fail "%s"' "'comment-block': options 'comment_block_{begin,end}' are empty"
		fi
	}

	evaluate-commands -draft -save-regs '"/' %{
		try %{ execute-keys '<a-K>\A\s*\z<ret>' }

		try %{
			set-register / "\A\Q%opt{comment_block_begin}\E.*\Q%opt{comment_block_end}\E\n*\z"
			execute-keys 's<ret>'
			set-register / "\A\Q%opt{comment_block_begin}\E\s?|\s?\Q%opt{comment_block_end}\E\n*\z"
			execute-keys 's<ret>d'
		} catch %{
			set-register '"' "%opt{comment_block_begin} "
			execute-keys -draft 'P'
			set-register '"' " %opt{comment_block_end}"
			execute-keys 'p'
		} catch %{}
	}
}

define-command -docstring '{un,}-line-comment selections' comment-line %{
	evaluate-commands %sh{
		if [ -z "$kak_opt_comment_line" ]
		then printf 'fail "%s"' "'comment-line': option 'comment_line' is empty"
		fi
	}

	evaluate-commands -draft -save-regs '"/' %{
		execute-keys '<a-s>gi<a-l>'
		try %{ execute-keys '<a-K>\A\s*\z<ret>' }
		set-register / "\A\Q%opt{comment_line}\E\h?"

		try %{
			execute-keys -draft '<a-K><ret>'
			set-register '"' "%opt{comment_line} "
			comment-align-anchors
			execute-keys 'P'
		} catch %{
			execute-keys 's<ret>d'
		} catch %{}
	}
}
