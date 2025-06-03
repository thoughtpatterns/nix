declare-option str ansi_regex '^\*(?!debug)(?!scratch)(.*)\*$'

declare-option -hidden range-specs ansi_color_ranges
declare-option -hidden str ansi_command_file

define-command -docstring 'clear highlighter for current buffer' ansi-clear %{
	set-option buffer ansi_color_ranges %val{timestamp}
}

define-command -docstring 'stop render of new FIFO content in current buffer' ansi-disable %{
	remove-hooks buffer ansi
}

define-command -docstring 'start render of new FIFO data in current buffer' ansi-enable %{
	try ansi-setup-buffer
	ansi-render
	remove-hooks buffer ansi
	hook -group ansi buffer BufReadFifo '.*' %{
		evaluate-commands -draft %{
			select %val{hook_param}
			ansi-render-selection-impl
		}
	}
}

define-command -docstring 'substitute ANSI codes for highlighters in current buffer' ansi-render %{
	evaluate-commands -draft %{
		execute-keys '%'
		ansi-render-selection
	}
}

define-command -docstring 'substitute ANSI codes for highlighters within selection' ansi-render-selection %{
	try ansi-setup-buffer
	ansi-render-selection-impl
}

define-command -hidden ansi-render-selection-impl %{
	evaluate-commands -save-regs | %{
		set-register | "kak-ansi-filter -range %val{selection_desc} 2> %opt{ansi_command_file}"
		execute-keys '|<ret>'
		update-option buffer ansi_color_ranges
		source %opt{ansi_command_file}
	}
}

define-command -hidden ansi-setup-buffer %{
	add-highlighter buffer/ansi ranges ansi_color_ranges
	set-option buffer ansi_color_ranges %val{timestamp}
	set-option buffer ansi_command_file %sh{ mktemp }
	hook -always -once buffer BufClose '.*' %{
		nop %sh{ rm "$kak_opt_ansi_command_file" }
		set-option buffer ansi_command_file /dev/null
	}
}

hook -group ansi global BufCreate %opt{ansi_regex} ansi-enable
