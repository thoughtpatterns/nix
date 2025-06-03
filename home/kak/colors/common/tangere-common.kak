# Vanilla Kakoune.

set-face global Prompt                       +b
set-face global StatusLine                   ,bright-white
set-face global StatusLineMode               +b
set-face global StatusLineInfo               +b
set-face global StatusLineValue              ,,
set-face global StatusCursor                 +u

set-face global Whitespace                   white
set-face global WrapMarker                   red+b

## Markup.

set-face global block                        distinct
set-face global bullet                       faded
set-face global header                       strong
set-face global link                         salient
set-face global list                         ,,
set-face global mono                         adjunct
set-face global title                        strong

# LSP.

set-face global DiagnosticError              ,,
set-face global DiagnosticHint               ,,
set-face global DiagnosticInfo               ,,
set-face global DiagnosticWarning            ,,

set-face global DiagnosticTagDeprecated      +s
set-face global DiagnosticTagUnnecessary     ,,

set-face global InlayDiagnosticError         comment
set-face global InlayDiagnosticHint          comment
set-face global InlayDiagnosticInfo          comment
set-face global InlayDiagnosticWarning       comment

set-face global InlayCodeLens                comment
set-face global InlayHint                    comment

set-face global LineFlagError                red+i
set-face global LineFlagHint                 magenta+i
set-face global LineFlagInfo                 blue+i
set-face global LineFlagWarning              yellow+i

set-face global Reference                    ,,
set-face global ReferenceBind                ,,

set-face global SnippetsNextPlaceholders     black,green
set-face global SnippetsOtherPlaceholders    black,yellow

set-face global InfoDefault                  ,,
set-face global InfoBlock                    block
set-face global InfoBlockQuote               block
set-face global InfoBullet                   bullet
set-face global InfoHeader                   header
set-face global InfoLink                     link
set-face global InfoLinkMono                 mono
set-face global InfoMono                     mono
set-face global InfoRule                     ,,

set-face global InfoDiagnosticError          red
set-face global InfoDiagnosticHint           magenta
set-face global InfoDiagnosticInformation    blue
set-face global InfoDiagnosticWarning        yellow

# Tree-sitter.

set-face global ts_attribute                 attribute
set-face global ts_comment                   comment
set-face global ts_conceal                   faded
set-face global ts_constant                  value
set-face global ts_constructor               function
set-face global ts_diff_plus                 black,yellow
set-face global ts_diff_minus                black,magenta
set-face global ts_diff_delta                black,bright-black
set-face global ts_error                     red
set-face global ts_function                  function
set-face global ts_function_builtin          builtin
set-face global ts_hint                      magenta
set-face global ts_info                      blue
set-face global ts_keyword                   keyword
set-face global ts_keyword_control_directive meta
set-face global ts_keyword_directive         meta
set-face global ts_label                     ,,
set-face global ts_markup_bold               strong
set-face global ts_markup_heading            header
set-face global ts_markup_italic             emphatic
set-face global ts_markup_list               list
set-face global ts_markup_link               link
set-face global ts_markup_quote              string
set-face global ts_markup_raw                mono
set-face global ts_markup_strikethrough      +s
set-face global ts_namespace                 module
set-face global ts_operator                  operator
set-face global ts_property                  attribute
set-face global ts_punctuation               ,,
set-face global ts_special                   ,,
set-face global ts_spell                     yellow+i
set-face global ts_string                    string
set-face global ts_tag                       ,,
set-face global ts_text                      ,,
set-face global ts_text_title                title
set-face global ts_type                      type
set-face global ts_unknown                   ,,
set-face global ts_variable                  variable
set-face global ts_warning                   yellow
