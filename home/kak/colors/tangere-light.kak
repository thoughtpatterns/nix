# Vanilla Kakoune.

set-face global PrimaryCursor              black,bright-cyan+bfg
set-face global PrimaryCursorEol           black,bright-cyan+bfg
set-face global SecondaryCursor            black,white+bfg
set-face global SecondaryCursorEol         black,white+bfg
set-face global PrimarySelection           ,bright-white+g
set-face global SecondarySelection         ,rgb:e6e4d3+g

set-face global BufferPadding              white+bf
set-face global Error                      black,red
set-face global Information                ,bright-white+i
set-face global InlineInformation          ,bright-white
set-face global LineNumberCursor           +b
set-face global LineNumbers                white
set-face global LineNumbersWrapped         white
set-face global MatchingChar               +biu
set-face global MenuBackground             ,bright-white
set-face global MenuForeground             black,cyan+fg
set-face global MenuInfo                   ,bright-white+i

## Markup.

set-face global adjunct                    cyan
set-face global distinct                   bright-cyan+i
set-face global emphatic                   +i
set-face global faded                      white
set-face global salient                    yellow+ab
set-face global strong                     +b

## Code.

set-face global attribute                  ,,
set-face global builtin                    +i
set-face global comment                    cyan+i
set-face global documentation              bright-yellow+i
set-face global function                   green+b
set-face global keyword                    blue+bi
set-face global meta                       +i
set-face global module                     blue+b
set-face global operator                   ,,
set-face global string                     bright-yellow
set-face global type                       cyan+bi
set-face global value                      cyan+b
set-face global variable                   ,,

# Mode changes.

remove-hooks global 'tangere-.*'

hook -group tangere-light global ModeChange 'push:.*:insert' %{
	set-face window PrimaryCursor      black,red+bfgu
	set-face window PrimaryCursorEol   black,red+bfgu
	set-face window SecondaryCursor    black,red+bfg
	set-face window SecondaryCursorEol black,red+bfg
	set-face window PrimarySelection   ,rgb:e6e4d3+g
	set-face window MatchingChar       ,,
}

hook -group tangere-light global ModeChange 'pop:insert:.*' %{
	set-face window PrimaryCursor      black,bright-cyan+bfg
	set-face window PrimaryCursorEol   black,bright-cyan+bfg
	set-face window SecondaryCursor    black,white+bfg
	set-face window SecondaryCursorEol black,white+bfg
	set-face window PrimarySelection   ,bright-white+g
	set-face window MatchingChar       +biu
}

# Vanilla Kakoune (cont.), LSP, Tree-sitter.

source "%val{config}/colors/common/tangere-common.kak"
