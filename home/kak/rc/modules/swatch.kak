### public:

declare-option str swatch_face_body 'Aa'
declare-option str swatch_face_pad ' '
declare-option str swatch_hex_body '██'
declare-option str swatch_hex_pad ' '

### private:

declare-option -hidden str-list swatch_strcmp_buffer
define-command -params 0 -hidden swatch-assert-empty nop
define-command -params 2 -hidden swatch-streq %{
	set global swatch_strcmp_buffer %arg{1}
	set -remove global swatch_strcmp_buffer %arg{2}
	swatch-assert-empty %opt{swatch_strcmp_buffer}
}

declare-option -hidden str swatch_face_regex
evaluate-commands -save-regs 'fdnrcpabioegtsz' %{
	# Search components.
	set-register f '(?:\w+)' # A face name.
	set-register d "(?:(?:set-)?face\h+(?:buffer|global|local|window)\h+%reg:f:\h+)" # The declaration, bar the face itself.
	set-register n '(?:(?:bright-)?(?:black|red|green|yellow|blue|magenta|cyan|white)|default)' # A named color.
	set-register r '(?:rgb:[A-Fa-f0-9]{6}|rgba:[A-Fa-f0-9]{6}(?:1[A-Fa-f1-9]|[A-Fa-f2-9][A-Fa-f0-9]))' # A hexadecimal color. If alpha is given, it must be greater than 16.
	set-register c "(?:%reg{n}|%reg{r})" # A named color or a hexadecimal color.
	set-register p "(?:,%reg{c})" # A comma-prefixed named color or a hexadecimal color.

	# A set of attributes. The inclusion of `U` can crash Kakoune prior to commit `a0a0009`, so we check `%val{version}`.
	set-register a '(?:\+[abBcdfFgirsu]+)'
	try %{
		swatch-streq %val{version} 'v2025.06.03' # This will be made more robust once a new Kakoune version releases.
		set-register a '(?:\+[abBcdfFgirsuU]+)'
	}

	set-register b "(?:@%reg{f})" # A base face.

	# Assembled search components for `<fg>[,<bg>[,<underline>]]`.
	set-register i "(?:%reg{c}%reg{p}{0,2})" # `<fg>[,<bg>[,<underline>]]`, where no face has been omitted. Note that this requires `<fg>`.
	set-register o "(?:%reg{c},%reg{c},|%reg{c},,%reg{c}|%reg{c},,|,%reg{c},%reg{c}|,%reg{c},|,%reg{c}|,,%reg{c}|,,)" # `<fg>[,<bg>[,<underline>]]`, where at least one face has been omitted.
	set-register e "(?:%reg{i}|%reg{o})" # `<fg>[,<bg>[,<underline>]]`.

	# Search cases.
	set-register g "(?:%reg{e}%reg{a}?%reg{b}?)" # The case in which `<fg>[,<bg>[,<underline>]]` is present.
	set-register t "(?:%reg{a}%reg{b}?)" # The case in which `<fg>[,<bg>[,<underline>]]` is _not_ present, and `+<attr>` is, i.e., `+<attr>[@base]`.
	set-register s "(?:%reg{f})" # The case in which `<fg>[,<bg>[,<underline>]]` _nor_ `+<attr>` is present, but `[base]` is, i.e., `[base]`.
	set-register z "(?:%reg{g}|%reg{t}|%reg{s})" # Any of the prior three cases.

	set-option global swatch_face_regex "%reg{d}(%reg{z})"
}

declare-option -hidden int swatch_timestamp 0
declare-option -hidden range-specs swatch_range 0

define-command -docstring 'enable swatch at window scope' swatch-enable-window %{
	add-highlighter window/swatch replace-ranges swatch_range
	hook -group swatch window NormalIdle '.*' swatch-highlight
	hook -group swatch window InsertIdle '.*' swatch-highlight
}

define-command -docstring 'disable swatch at window scope' swatch-disable-window %{
	remove-hooks window swatch
	remove-highlighter window/swatch
	unset-option window swatch_timestamp
	unset-option window swatch_range
}

define-command -docstring 'generate a face & color highlighter for the active buffer' swatch-highlight %{
	set-option window swatch_range %val{timestamp}

	evaluate-commands -draft %{
		execute-keys 'gtGbx'

		# Handle forms `[<fg>][,<bg>[,<underline>]][+<attr>][@base]` and `[base]` in face declarations.
		evaluate-commands -draft -verbatim try %{
			execute-keys "s%opt{swatch_face_regex}<ret>;<a-b>"
			evaluate-commands -itersel %{
				set-option -add window swatch_range "%val{cursor_line}.%val{cursor_column}+0|{%reg{1}}%opt{swatch_face_body}{default,default}%opt{swatch_face_pad}"
			}
		}

		# Handle forms `#RGB` and `#RGBA`.
		evaluate-commands -draft -verbatim try %{
			execute-keys 's\B#([A-Fa-f0-9])([A-Fa-f0-9])([A-Fa-f0-9])[A-Fa-f0-9]?\b<ret><a-;>'
			evaluate-commands -itersel %{
				set-option -add window swatch_range "%val{cursor_line}.%val{cursor_column}+0|{rgb:%reg{1}%reg{1}%reg{2}%reg{2}%reg{3}%reg{3}+fg}%opt{swatch_hex_body}{default,default}%opt{swatch_hex_pad}"
			}
		}

		# Handle forms `#RRGGBB` and `#RRGGBBAA`.
		evaluate-commands -draft -verbatim try %{
			execute-keys 's\B#([A-Fa-f0-9]{6})(?:[A-Fa-f0-9]{2})?\b<ret><a-;>'
			evaluate-commands -itersel %{
				set-option -add window swatch_range "%val{cursor_line}.%val{cursor_column}+0|{rgb:%reg{1}+fg}%opt{swatch_hex_body}{default,default}%opt{swatch_hex_pad}"
			}
		}
	}

	set-option window swatch_timestamp %val{timestamp}
}
