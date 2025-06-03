add-highlighter global/columns     group
add-highlighter global/columns/80  column -ruler ║ 80  BufferPadding
add-highlighter global/columns/120 column -ruler ║ 120 BufferPadding

add-highlighter global/show-whitespaces show-whitespaces -tab ' ' -spc ' ' -lf ' ' -indent ' '
add-highlighter global/show-trailing-whitespaces regex '(\h+)$' 0:,bright-white

evaluate-commands %sh{
	kak-tree-sitter -dksvv --init "$kak_session"
	kakeidoscope init
}

set-option global kakeidoscope_faces green blue bright-cyan
set-option global kakeidoscope_regex '[()]'

hook global WinCreate '.*' %{
	kakeidoscope-enable-window
	swatch-enable-window
}
