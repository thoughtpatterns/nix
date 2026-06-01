# Helper commands.

define-command -override -params 1 -hidden set-width %{
	try %{ set buffer fmt_width %arg{1} }
	hook -once -always buffer BufSetOption 'filetype=.*' %{ try %{ set buffer fmt_width 80 } }
}

# Filetype modules.

provide-module asciidoc %{
	# From `/rc/filetype/asciidoc.kak`.
	add-highlighter shared/asciidoc  group
	add-highlighter shared/asciidoc/ regex '(\A|\n\n)[^\n]+\n={2,}\h*$'                       0:title
	add-highlighter shared/asciidoc/ regex '(\A|\n\n)[^\n]+\n-{2,}\h*$'                       0:header
	add-highlighter shared/asciidoc/ regex '(\A|\n\n)[^\n]+\n~{2,}\h*$'                       0:header
	add-highlighter shared/asciidoc/ regex '(\A|\n\n)[^\n]+\n\^{2,}\h*$'                      0:header
	add-highlighter shared/asciidoc/ regex '(\A|\n\n)=\h+[^\n]+$'                             0:title
	add-highlighter shared/asciidoc/ regex '(\A|\n\n)={2,}\h+[^\n]+$'                         0:header
	add-highlighter shared/asciidoc/ regex '^//(?:[^\n/][^\n]*|)$'                            0:comment
	add-highlighter shared/asciidoc/ regex '^(/{4,}).*?\n(/{4,})$'                            0:comment
	add-highlighter shared/asciidoc/ regex '^\.[^\h\W][^\n]*$'                                0:title
	add-highlighter shared/asciidoc/ regex '^\h*(?<bullet>[-\*])\h+[^\n]+$'                   0:list bullet:bullet
	add-highlighter shared/asciidoc/ regex '^\h*(?<bullet>[-\*]+)\h+[^\n]+(\n\h+[^-\*\n]*)?$' 0:list bullet:bullet
	add-highlighter shared/asciidoc/ regex '^(-{4,})\n[^\n\h].*?\n(-{4,})$'                   0:block
	add-highlighter shared/asciidoc/ regex '^(={4,})\n[^\n\h].*?\n(={4,})$'                   0:block
	add-highlighter shared/asciidoc/ regex '^(~{4,})\n[^\n\h].*?\n(~{4,})$'                   0:block
	add-highlighter shared/asciidoc/ regex '^(\*{4,})\n[^\n\h].*?\n(\*{4,})$'                 0:block
	add-highlighter shared/asciidoc/ regex '\B(?:\+[^\n]+?\+|`[^\n]+?`)\B'                    0:mono
	add-highlighter shared/asciidoc/ regex '\s\*[^\n\*]+\*\B'                                 0:+b
	add-highlighter shared/asciidoc/ regex '\h\*[^\n\*]+\*\B'                                 0:+b
	add-highlighter shared/asciidoc/ regex '\*{2}(?!\h)[^\n\*]+\*{2}'                         0:+b
	add-highlighter shared/asciidoc/ regex '\h\*{2}[^\n\*]+\*{2}'                             0:+b
	add-highlighter shared/asciidoc/ regex '\b_[^\n]+?_\b'                                    0:+i
	add-highlighter shared/asciidoc/ regex '__[^\n]+?__'                                      0:+i
	add-highlighter shared/asciidoc/ regex '^:(?:(?<neg>!?)[-\w]+|[-\w]+(?<neg>!?)):'         0:meta neg:operator
	add-highlighter shared/asciidoc/ regex '[^\\](\{[-\w]+\})[^\\]?'                          1:meta
	add-highlighter shared/asciidoc/ regex '^\[[^\n]+\]$'                                     0:operator
	add-highlighter shared/asciidoc/ regex '^(NOTE|TIP|IMPORTANT|CAUTION|WARNING):'           0:block
	add-highlighter shared/asciidoc/ regex '^\[(NOTE|TIP|IMPORTANT|CAUTION|WARNING)\]$'       0:block
	add-highlighter shared/asciidoc/ regex '\b((?:https?|ftp|irc://)[^\h\[]+)\[([^\n]*)?\]'   1:link 2:+i
	add-highlighter shared/asciidoc/ regex '(link|mailto):([^\n]+)(?:\[([^\n]*)\])'           1:keyword 2:link 3:+i
	add-highlighter shared/asciidoc/ regex '(xref):([^\n]+)(?:\[([^\n]*)\])'                  1:keyword 2:meta 3:+i
	add-highlighter shared/asciidoc/ regex '(<<([^\n><]+)>>)'                                 1:link 2:meta
}

provide-module css %{
	define-command -docstring "yank an '!important'-ified buffer to clipboard" css-yank-important-to-clipboard %{
		evaluate-commands -draft -save-regs 'bsf|' %{
			set-register b %reg{percent}
			execute-keys '%"sy'

			evaluate-commands -no-hooks %{ edit -scratch }
			set-register f %reg{percent}

			set-register | %{
				mawk -v 'RS=;' '{
					if (/:/ && !/!important/ && !/!unimportant/ && !/@[ \t]*(charset|import|namespace)/) {
						sub(/[[:space:]]*$/, "")
						$0 = $0 " !important"
					}

					if (NR > 1)
						printf ";"

					printf "%s", $0
				}'
			}

			execute-keys '"sP|<ret>'
			yank-to-clipboard selection

			delete-buffer %reg{f}
			buffer %reg{b}
		}
	}
}

provide-module diff %{
	add-highlighter shared/diff group
	add-highlighter shared/diff/ regex '^@@[^\n]*@@' 0:ts_diff_delta
}

provide-module janet %{
	# From `/rc/filetype/janet.kak`.
	add-highlighter shared/janet regions
	add-highlighter shared/janet/code                     default-region                                                                                                    group
	add-highlighter shared/janet/comment                  region                '(?<!\\)(?:\\\\)*\K#' '$'                                                                   fill comment
	add-highlighter shared/janet/comment-form             region -recurse       '\(' '(?<!\\)(?:\\\\)*\K\(comment ' '\)'                                                    fill comment
	add-highlighter shared/janet/string                   region                '(?<!\\)(?:\\\\)*\K"' '(?<!\\)(?:\\\\)*"'                                                   fill string
	add-highlighter shared/janet/raw-string               region -match-capture '(`+)' '(`+)'                                                                               fill string
	add-highlighter shared/janet/code/                    regex                 '\b(true|false|nil)\b'                                                                      0:value
	add-highlighter shared/janet/code/number              regex                 '\W\K(?:[\-+]?\dx?[\der._+a-f]*)\b'                                                         0:value
	add-highlighter shared/janet/code/function-definition regex                 '\((?:defn-?|fn)\s([!@$%\^&*\-_+=:<>.?\w/]+)'                                               1:function
	add-highlighter shared/janet/code/function-call       regex                 '\(([!@$%\^&*\-_+=:<>.?\w/]+)'                                                              1:function
	add-highlighter shared/janet/code/keyword             regex                 '\W\K:[!@$%\^&*\-_+=:<>.?\w/]+'                                                             0:attribute
	add-highlighter shared/janet/code/special             regex                 '\((def-?|defn-?|var-?|break|do|fn|if|quasiquote|quote|set|splice|unquote|upscope|while)\s' 1:builtin
	add-highlighter shared/janet/code/                    regex                 '\W\K(&|&keys|&named|&opt)\W'                                                               1:builtin

}

provide-module lc2k %{
	add-highlighter shared/lc2k group
	add-highlighter shared/lc2k/ regex '^(?<l0>\w*)\h+(?<f>add|nor)\h+(?<v0>[0-7])\h+(?<v1>[0-7])\h+(?<v2>[0-7])\h*(?<c>.*?)$'                  l0:variable f:function v0:value v1:value v2:value c:comment
	add-highlighter shared/lc2k/ regex '^(?<l0>\w*)\h+(?<f>[ls]w|beq)\h+(?<v0>[0-7])\h+(?<v1>[0-7])\h+(?:(?<v2>-?\d+)|(?<l1>\w+))\h*(?<c>.*?)$' l0:variable f:function v0:value v1:value v2:value l1:variable c:comment
	add-highlighter shared/lc2k/ regex '^(?<l0>\w*)\h+(?<f>jalr)\h+(?<v0>[0-7])\h+(?<v1>[0-7])\h*(?<c>.*?)$'                                    l0:variable f:function v0:value v1:value c:comment
	add-highlighter shared/lc2k/ regex '^(?<l0>\w*)\h+(?<f>noop|halt)\h*(?<c>.*?)$'                                                             l0:variable f:function c:comment
	add-highlighter shared/lc2k/ regex '^(?<l0>\w*)\h+(?<b>.fill)\h+(?:(?<v0>-?\d+)|(?<l1>\w+))\h*(?<c>.*?)$'                                   l0:variable b:builtin v0:value l1:variable c:comment
}

provide-module todotxt %{
	set-face global TodoTxtCompletion red
	set-face global TodoTxtPriority   yellow
	set-face global TodoTxtDate       green
	set-face global TodoTxtProjectTag blue
	set-face global TodoTxtContextTag magenta
	set-face global TodoTxtKeyTag     cyan
	set-face global TodoTxtValueTag   cyan

	add-highlighter shared/todotxt group

	# The status elements --- completion, priority, and date(s) --- must be ordered, so we highlight them as one.
	evaluate-commands -save-regs "xpd" %{
		set-register x '(?:^x)' # Completion.
		set-register p '(?:\([A-Z]\))' # Priority.

		# Completion/creation dates.
		set-register d '(?:\d{4}-\d{2}-\d{2})'
		set-register d "(?:%reg{d}(?:\h+%reg{d})?)"

		add-highlighter shared/todotxt/status regex "(%reg|x|)?(?:\h*(%reg|p|))?(?:\h*(%reg|d|)\b)?" 1:TodoTxtCompletion 2:TodoTxtPriority 3:TodoTxtDate
	}

	add-highlighter shared/todotxt/project regex '\+[^\s]+'     0:TodoTxtProjectTag
	add-highlighter shared/todotxt/context regex '@[^\s]+'      0:TodoTxtContextTag
	add-highlighter shared/todotxt/key     regex '[^\s]+(?=:)'  0:TodoTxtKeyTag
	add-highlighter shared/todotxt/value   regex '(?<=:)[^\s]+' 0:TodoTxtValueTag
}

provide-module typst %{
	define-command -docstring 'start the preview server' typst-start-preview %{
		lsp-execute-command tinymist.startDefaultPreview ""
	}
}

# Tree-sitter alias filetype hooks.

hook global BufSetOption '(filetype|tree_sitter_lang)=(kakrc|ksh|sh|zsh)' %{ set-option buffer tree_sitter_lang bash   }
hook global BufSetOption '(filetype|tree_sitter_lang)=ghostty'            %{ set-option buffer tree_sitter_lang ini }
hook global BufSetOption '(filetype|tree_sitter_lang)=bazel'              %{ set-option buffer tree_sitter_lang python }

# LSP filetype hooks.

hook global WinSetOption 'filetype=(c|cpp|javascript|julia|lua|nix|objc|python|rust|typescript|typst)' %{
	lsp-enable-window
	hook -once -always window WinSetOption 'filetype=.*' %{ try lsp-disable-window }
}

# Comment filetype hooks.

hook global BufSetOption 'filetype=(c|cpp|go|java|javascript|rust|scss|typescript|typst)' %{ set-option buffer comment_line '//' ; set-option buffer comment_block_begin '/*'        ; set-option buffer comment_block_end '*/'    }
hook global BufSetOption 'filetype=(haskell|purescript)'                                  %{ set-option buffer comment_line '--' ; set-option buffer comment_block_begin '{-'        ; set-option buffer comment_block_end '-}'    }
hook global BufSetOption 'filetype=(html|xml)'                                            %{ set-option buffer comment_line ''   ; set-option buffer comment_block_begin '<!--'      ; set-option buffer comment_block_end '-->'   }
hook global BufSetOption 'filetype=asciidoc'                                              %{ set-option buffer comment_line '//' ; set-option buffer comment_block_begin '////'      ; set-option buffer comment_block_end '////'  }
hook global BufSetOption 'filetype=css'                                                   %{ set-option buffer comment_line ''   ; set-option buffer comment_block_begin '/*'        ; set-option buffer comment_block_end '*/'    }
hook global BufSetOption 'filetype=ini'                                                   %{ set-option buffer comment_line ';'                                                                                                    }
hook global BufSetOption 'filetype=julia'                                                 %{                                       set-option buffer comment_block_begin '#='        ; set-option buffer comment_block_end '=#'    }
hook global BufSetOption 'filetype=latex'                                                 %{ set-option buffer comment_line '%'                                                                                                    }
hook global BufSetOption 'filetype=lua'                                                   %{ set-option buffer comment_line '--' ; set-option buffer comment_block_begin '--[['      ; set-option buffer comment_block_end ']]'    }
hook global BufSetOption 'filetype=markdown'                                              %{ set-option buffer comment_line ''   ; set-option buffer comment_block_begin '[//]: # "' ; set-option buffer comment_block_end '"'     }
hook global BufSetOption 'filetype=python'                                                %{                                       set-option buffer comment_block_begin "'''"       ; set-option buffer comment_block_end "'''"   }
hook global BufSetOption 'filetype=ruby'                                                  %{                                       set-option buffer comment_block_begin '^begin='   ; set-option buffer comment_block_end '^=end' }
hook global BufSetOption 'filetype=scheme'                                                %{ set-option buffer comment_line ';'  ; set-option buffer comment_block_begin '#|'        ; set-option buffer comment_block_end '|#'    }
hook global BufSetOption 'filetype=zig'                                                   %{ set-option buffer comment_line '//'                                                                                                   }

# Broad filetype hooks.

hook global BufSetOption 'filetype=(css|dockerfile|html|janet|markdown|nix|scheme|typst|xml|yaml)' %{ set-option buffer indentwidth 2 }

hook global BufSetOption 'filetype=(bazel|javascript|latex|lua|nu|python|toml|typescript)' %{ set-option buffer indentwidth 4 }

hook global BufSetOption 'filetype=(html|janet|latex|lua)' %{
	map -docstring 'format buffer'     buffer filetype f ': format-buffer<ret>'
	map -docstring 'format selections' buffer filetype = ': format-selections<ret>'
}

# Narrow filetype hooks (i.e., module loads).

hook global BufSetOption 'filetype=asciidoc' %{
	require-module asciidoc
	add-highlighter buffer/asciidoc ref asciidoc
	hook -once -always buffer BufSetOption 'filetype=.*' %{ remove-highlighter buffer/asciidoc }
}

hook global BufSetOption 'filetype=c(pp)?' %{ set-width 120 }

hook global BufSetOption 'filetype=css' %{
	require-module css
	map -docstring 'yank [!important]' buffer filetype y ': css-yank-important-to-clipboard<ret>'
}

hook global BufSetOption 'filetype=diff' %{
	require-module diff
	add-highlighter buffer/diff ref diff
	hook -once -always buffer BufSetOption 'filetype=.*' %{ remove-highlighter buffer/diff }
}

hook global BufSetOption 'filetype=html' %{ set-option buffer format_command 'tidyw' }

hook global BufSetOption 'filetype=janet' %{
	require-module janet
	add-highlighter buffer/janet ref janet
	hook -once -always buffer BufSetOption 'filetype=.*' %{ remove-highlighter buffer/janet }
	set-option buffer format_command 'janet-format'
}

hook global BufSetOption 'filetype=latex' %{ set-option buffer format_command 'tex-fmt --stdin --tabsize 4 --wraplen 180' }

hook global BufSetOption 'filetype=lc2k' %{
	require-module lc2k
	add-highlighter buffer/lc2k ref lc2k
	hook -once -always buffer BufSetOption 'filetype=.*' %{ remove-highlighter buffer/lc2k }
}

hook global BufSetOption 'filetype=lua' %{ set-option buffer format_command 'stylua --search-parent-directories -' }

hook global BufSetOption 'filetype=python' %{ set-width 120 }

hook global BufSetOption 'filetype=todotxt' %{
	require-module todotxt
	add-highlighter buffer/todotxt ref todotxt
	hook -once -always buffer BufSetOption 'filetype=.*' %{ remove-highlighter buffer/todotxt }
}

hook global BufSetOption 'filetype=typst' %{
	require-module typst
	map -docstring 'preview' buffer filetype p ': typst-start-preview<ret>'
}

# Filetype-adjacent hooks (i.e., file extension hooks).

hook global BufNewFile '.*\.(h|H|hh|hpp|hxx)' %{ evaluate-commands -save-regs p %{
	set-register p '
	#ifndef FILENAME_INCLUDED
	#define FILENAME_INCLUDED



	#endif /* FILENAME_INCLUDED */
	'

	# Delete extra whitespace, then replace "FILENAME" with the filename, stripped of special characters.
	execute-keys -draft '"pPs\t<ret>d,dgkd%sFILENAME<ret>c<c-r>%<esc><a-b>s[^\w]<ret>r_'
	execute-keys '4g'
}}
