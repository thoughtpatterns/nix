### public:

declare-option int fmt_width 80

### private:

declare-option -hidden str fmt_command %{ fmt "--goal=$kak_opt_fmt_width" "--width=$kak_opt_fmt_width" }
declare-option -hidden str fmt_mode fail

define-command -docstring 'run fmt for each selection' fmt %{
	evaluate-commands -save-regs | %{
		set-register | %opt{fmt_command}
		execute-keys -itersel '|<ret>'
	}
}

define-command -docstring 'disable autofmt at window scope' fmt-disable-window %{
	set-option window fmt_mode fail
	trigger-user-hook fmt-disable-window
	remove-hooks window fmt
}

define-command -docstring 'enable autofmt at window scope' fmt-enable-window %{
	set-option window fmt_mode nop
	trigger-user-hook fmt-enable-window
	hook -group fmt window InsertChar '[^\s]' fmt-impl-window
}

# Machinery for loops without a shell fork.
define-command fmt-loop-2t1 -params .. -hidden %{
	%arg{@}
	%arg{@}
}

define-command fmt-loop-2t2 -params .. -hidden %{ fmt-loop-2t1 fmt-loop-2t1 %arg{@} }
define-command fmt-loop-2t3 -params .. -hidden %{ fmt-loop-2t2 fmt-loop-2t2 %arg{@} }
define-command fmt-loop-2t4 -params .. -hidden %{ fmt-loop-2t3 fmt-loop-2t3 %arg{@} }
define-command fmt-loop-2t5 -params .. -hidden %{ fmt-loop-2t4 fmt-loop-2t4 %arg{@} }
define-command fmt-loop     -params .. -hidden %{ fmt-loop-2t5 fmt-loop-2t5 %arg{@} }

# Machinery to compare strings without a shell fork.
declare-option -hidden str-list fmt_strcmp_buffer
define-command -params 1.. -hidden fmt-assert-nonempty nop
define-command -params 2 -hidden fmt-strne %{
	set global fmt_strcmp_buffer %arg{1}
	set -remove global fmt_strcmp_buffer %arg{2}
	fmt-assert-nonempty %opt{fmt_strcmp_buffer}
}

define-command -hidden fmt-impl-window %{
	evaluate-commands -save-regs "c|s" %{
		evaluate-commands -draft %{
			# Yank all cursors to `%reg{c}`.
			evaluate-commands -draft %{
				execute-keys ';'

				# If we were to yank newlines (to paste later), we would end up
				# typing in reverse, as the newline would be repeatedly pasted and
				# removed before the typed content. So, we remove them.
				evaluate-commands %exp{ set-register c %sh{
					printf %s "$kak_quoted_selections" | tr -d "\n"
				}}

				# Replace all cursors with `` (U+E000), as save-and-restore markers.
				evaluate-commands -itersel %{
					try %{     execute-keys '<a-k>\n<ret>i<esc>'
					} catch %{ execute-keys 'c<esc>' }
				}
			}

			# Select blocks of like indentation.
			execute-keys 'x'
			evaluate-commands -itersel -save-regs i %{
				# Save the line's indentation, to check for like indentations.
				try %{ execute-keys -draft 's^\h+<ret>"iy' }

				# If the selected line is not empty, expand to a block of like indentation.
				try %{ execute-keys '<a-k>^$<ret>' } catch %{
					# Move the selection upward until we reach any of:
					# - an empty line,
					# - a line with a unique indent,
					# - or the start of the buffer.
					try %{ fmt-loop evaluate-commands %{
						evaluate-commands -draft -save-regs "l/" %{
							set-register l %val{cursor_line}
							execute-keys 'kx'
							fmt-strne %reg{l} %val{cursor_line}
							set-register / "^%reg{i}[^\h]"
							execute-keys '<a-k><ret><a-K>^$<ret>'
						}

						execute-keys 'k'
					}}

					execute-keys 'x'

					# Extend the selection downward until we reach any of:
					# - an empty line,
					# - a line with a unique indent,
					# - or the end of the buffer.
					try %{ fmt-loop evaluate-commands %{
						evaluate-commands -draft -save-regs "l/" %{
							set-register l %val{cursor_line}
							execute-keys 'jx'
							fmt-strne %reg{l} %val{cursor_line}
							set-register / "^%reg{i}[^\h]"
							execute-keys '<a-k><ret><a-K>^$<ret>'
						}

						execute-keys 'J'
					}}
				}
			}

			# If two cursors were in the same block, we'd select the same block twice; merge them.
			execute-keys '<a-_>'

			# Call `fmt`, restore contents of selections saved with `` (U+E000), then
			# save selections to be saved outside the draft context.
			set-register | %opt{fmt_command}
			execute-keys '|<ret>s<ret>d"cP'
			set-register s "%val{selections_desc}"
		}

		evaluate-commands %exp{ select %reg{s} }
	}
}

define-command -docstring 'toggle autofmt at window scope' fmt-toggle-window %{
	try %{
		evaluate-commands %opt{fmt_mode}
		fmt-disable-window
	} catch fmt-enable-window
}

declare-option str fmt_info
hook global User fmt-enable-window  %{ set-option window fmt_info "fmt " }
hook global User fmt-disable-window %{ set-option window fmt_info "" }
