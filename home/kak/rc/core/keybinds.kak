map global normal > 'i <a-;><gt><backspace><esc>'

map global normal '#'     ': comment-line<ret>'
map global normal '<a-#>' ': comment-block<ret>'

define-command -hidden keybinds-align-indent-with-previous-line %{ execute-keys -draft 'K<a-&>' }
map global insert <tab>   '<a-;><a-gt>'
map global insert <c-tab> '<tab>'
map global insert <s-tab> '<a-;><lt>'
map global insert <a-tab> '<a-;>: keybinds-align-indent-with-previous-line<ret>'

# See <https://www.gnu.org/software/bash/manual/html_node/Commands-For-Moving.html>.
map global insert <c-a> '<home>'
map global insert <c-e> '<end>'
map global insert <c-f> '<right>'
map global insert <c-b> '<left>'
map global insert <a-f> '<esc><a-w>;i'
map global insert <a-b> '<esc><a-b>;i'

# See <https://www.gnu.org/software/bash/manual/html_node/Commands-For-Text.html>.
map global insert <c-d> '<del>'

# See <https://www.gnu.org/software/bash/manual/html_node/Commands-For-Killing.html>.
define-command -hidden keybinds-kill-line                        %{ execute-keys -draft ';Gld' }
define-command -hidden keybinds-unix-line-discard                %{ execute-keys -draft 'hGhd' }
define-command -hidden keybinds-unix-line-discard-without-indent %{ execute-keys -draft 'hGid' }
define-command -hidden keybinds-kill-word                        %{ execute-keys -draft '<a-W>d' }
define-command -hidden keybinds-unix-word-rubout          %{ try %{ execute-keys -draft 'h<a-B>d' } }
map global insert <c-k>         '<a-;>: keybinds-kill-line<ret>'
map global insert <c-x>         '<a-;>: keybinds-unix-line-discard<ret>'
map global insert <c-y>         '<a-;>: keybinds-unix-line-discard-without-indent<ret>'
map global insert <a-d>         '<a-;>: keybinds-kill-word<ret>'
map global insert <a-backspace> '<a-;>: keybinds-unix-word-rubout<ret>'

# Rebind completion requests, since `<c-x>` is taken by `keybinds-unix-line-discard`.
map global insert <c-l> '<c-x>'

define-command -hidden keybinds-texpand-word %{ evaluate-commands -draft -save-regs 'e|' -no-hooks %{
	set-register e 'nop'
	set-register | %{
		root="$(mktemp -d)" ; stdin="$root/stdin" ; stdout="$root/stdout"
		tee "$stdin" | texpand > "$stdout"

		if [ "$?" -eq 0 ]
		then cat "$stdout"
		else printf 'set-register e fail "%s"\n' "failed to expand macro" > "$kak_command_fifo" ; cat "$stdin"
		fi

		rm -rf "$root"
	}

	execute-keys 'h<a-f>\|<ret>'
	%reg{e}
}}

map global insert <c-t> '<a-;>: keybinds-texpand-word<ret>'

declare-user-mode client

map -docstring 'set docs'    global client d ': set global docsclient %val{client}<ret>'
map -docstring 'set jump'    global client j ': set global jumpclient %val{client}<ret>'
map -docstring 'set tools'   global client t ': set global toolsclient %val{client}<ret>'
map -docstring 'unset docs'  global client D ': set global docsclient ""<ret>'
map -docstring 'unset jump'  global client J ': set global jumpclient ""<ret>'
map -docstring 'unset tools' global client T ': set global toolsclient ""<ret>'

define-command -params 1 -hidden keybinds-doc %{ edit -readonly "%val{runtime}/doc/%arg{1}.asciidoc" }

declare-user-mode doc

map -docstring 'buffers'         global doc b     ': keybinds-doc buffers<ret>'
map -docstring 'changelog'       global doc c     ': keybinds-doc changelog<ret>'
map -docstring 'command-parsing' global doc C     ': keybinds-doc command-parsing<ret>'
map -docstring 'commands'        global doc <a-c> ': keybinds-doc commands<ret>'
map -docstring 'execeval'        global doc e     ': keybinds-doc execeval<ret>'
map -docstring 'expansions'      global doc E     ': keybinds-doc expansions<ret>'
map -docstring 'faces'           global doc f     ': keybinds-doc faces<ret>'
map -docstring 'faq'             global doc F     ': keybinds-doc faq<ret>'
map -docstring 'highlighters'    global doc h     ': keybinds-doc highlighters<ret>'
map -docstring 'hooks'           global doc H     ': keybinds-doc hooks<ret>'
map -docstring 'keymap'          global doc k     ': keybinds-doc keymap<ret>'
map -docstring 'keys'            global doc K     ': keybinds-doc keys<ret>'
map -docstring 'mapping'         global doc m     ': keybinds-doc mapping<ret>'
map -docstring 'modes'           global doc M     ': keybinds-doc modes<ret>'
map -docstring 'options'         global doc o     ': keybinds-doc options<ret>'
map -docstring 'regex'           global doc r     ': keybinds-doc regex<ret>'
map -docstring 'registers'       global doc R     ': keybinds-doc registers<ret>'
map -docstring 'scopes'          global doc s     ': keybinds-doc scopes<ret>'

declare-user-mode exec

define-command -params 1 -hidden keybinds-select-indent-paragraph-intersection %{
	execute-keys -save-regs 's^' %exp'"sZ%arg{1}pZ"sz%arg{1}i<a-z>i'
}

map -docstring 'i ∩ p [i]' global exec i ': keybinds-select-indent-paragraph-intersection "<lt>a-i<gt>"<ret>'
map -docstring 'i ∩ p [a]' global exec I ': keybinds-select-indent-paragraph-intersection "<lt>a-a<gt>"<ret>'

declare-user-mode lsp-toggle

map -docstring 'diagnostics'  global lsp-toggle d ': toggle-lsp-inlay-diagnostics global<ret>'
map -docstring 'hover'        global lsp-toggle h ': toggle-lsp-auto-hover global<ret>'
map -docstring 'hover buffer' global lsp-toggle H ': toggle-lsp-auto-hover-buffer global<ret>'
map -docstring 'hints'        global lsp-toggle i ': toggle-lsp-inlay-hints global<ret>'

declare-user-mode repl

map -docstring 'new'   global repl n ': repl-buffer-new '
map -docstring 'send'  global repl s ': repl-buffer-send-text<ret>'

declare-user-mode filetype

map -docstring 'client'            global user c     ': enter-user-mode client<ret>'
map -docstring 'doc'               global user d     ': enter-user-mode doc<ret>'
map -docstring 'exec'              global user e     ': enter-user-mode exec<ret>'
map -docstring 'fmt'               global user f     ': fmt<ret>'
map -docstring 'autofmt'           global user F     ': fmt-toggle-window<ret>'
map -docstring 'file'              global user i     ': enter-user-mode filetype<ret>'
map -docstring 'lsp'               global user l     ': enter-user-mode lsp<ret>'
map -docstring 'lsp toggle'        global user L     ': enter-user-mode lsp-toggle<ret>'
map -docstring 'sort'              global user o     ': sort-selections<ret>'
map -docstring 'sort...'           global user O     ': sort-selections '
map -docstring 'character sort'    global user <a-o> ': sort-characters<ret>'
map -docstring 'character sort...' global user <a-O> ': sort-characters '
map -docstring 'repl'              global user r     ': enter-user-mode repl<ret>'
map -docstring 'tree-sitter'       global user t     ': enter-user-mode tree-sitter<ret>'
map -docstring 'yank [1]'          global user y     ': yank-to-clipboard selection<ret>'
map -docstring 'yank [@]'          global user Y     ': yank-to-clipboard selections<ret>'
