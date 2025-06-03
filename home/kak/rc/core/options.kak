declare-option -docstring 'client in which to display documentation' str docsclient
declare-option -docstring 'client in which to execute source code jumps' str jumpclient
declare-option -docstring 'client in which to display utility information' str toolsclient

set-option global indentwidth 0
set-option global tabstop 8
set-option global ui_options terminal_assistant=cat terminal_set_title=false

set-option global modelinefmt "{{context_info}} %%opt{fmt_info}{{mode_info}} %%val{bufname}:%%val{cursor_line}:%%val{cursor_char_column} [%%val{session}]"
