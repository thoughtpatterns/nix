# Vanilla Kakoune.

set-face global PrimaryCursor              black,white+bfg
set-face global PrimaryCursorEol           black,white+bfg
set-face global SecondaryCursor            black,bright-black+bfg
set-face global SecondaryCursorEol         black,bright-black+bfg
set-face global PrimarySelection           ,rgb:663d52+g
set-face global SecondarySelection         ,bright-white+g

set-face global BufferPadding              bright-white+bf
set-face global Error                      black,red
set-face global Information                ,bright-white+i
set-face global InlineInformation          ,bright-white
set-face global LineNumberCursor           +b
set-face global LineNumbers                bright-black
set-face global LineNumbersWrapped         bright-white
set-face global MatchingChar               +biu
set-face global MenuBackground             ,bright-white
set-face global MenuForeground             black,bright-black+fg
set-face global MenuInfo                   ,bright-white+i

## Markup.

set-face global adjunct                    white
set-face global distinct                   bright-cyan+i
set-face global emphatic                   +i
set-face global faded                      bright-black
set-face global salient                    yellow+ab
set-face global strong                     +b

## Code.

set-face global attribute                  ,,
set-face global builtin                    +i
set-face global comment                    cyan+i
set-face global documentation              bright-yellow+i
set-face global function                   green+b
set-face global keyword                    cyan+bi
set-face global meta                       +i
set-face global module                     cyan+b
set-face global operator                   ,,
set-face global string                     bright-yellow
set-face global type                       blue+b
set-face global value                      cyan+b
set-face global variable                   ,,

# Mode changes.

remove-hooks global 'tangere-.*'

hook -group tangere-dark global ModeChange 'push:.*:insert' %{
	set-face window PrimaryCursor      black,red+bfgu
	set-face window PrimaryCursorEol   black,red+bfgu
	set-face window SecondaryCursor    black,red+bfg
	set-face window SecondaryCursorEol black,red+bfg
	set-face window SecondarySelection ,rgb:663d52+g
	set-face window MatchingChar       ,,
}

hook -group tangere-dark global ModeChange 'pop:insert:.*' %{
	set-face window PrimaryCursor      black,white+bfg
	set-face window PrimaryCursorEol   black,white+bfg
	set-face window SecondaryCursor    black,bright-black+bfg
	set-face window SecondaryCursorEol black,bright-black+bfg
	set-face window SecondarySelection ,bright-white+g
	set-face window MatchingChar       +biu
}

# Vanilla Kakoune (cont.), LSP, Tree-sitter.

source "%val{config}/colors/common/tangere-common.kak"
