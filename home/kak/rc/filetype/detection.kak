define-command -params 0 -hidden filetype-empty nop # To check for empty strings.

define-command -params 2 -hidden filetype-map %{
	execute-keys "<a-k>%arg{2}<ret>"
	set-register t "%arg{1}"
}

define-command -hidden filetype-set %{ try %{ "filetype-empty%opt{filetype}" # HACK: this check prevents a KTS(?) crash.
	evaluate-commands -draft -save-regs "bfst" %{
		set-register b %reg{percent}

		execute-keys 'gkx'
		set-register s %val{selection}

		evaluate-commands -no-hooks %{ edit -scratch }
		set-register f %reg{percent}

		try %{
			execute-keys '"sP<a-k>#!<ret>'
			try   %{ filetype-map awk          '\bawk\b'                                    } \
			catch %{ filetype-map bash         '\bbash\b'                                   } \
			catch %{ filetype-map fish         '\bfish\b'                                   } \
			catch %{ filetype-map ghostty      '\bghostty\b'                                } \
			catch %{ filetype-map janet        '\bjanet\b'                                  } \
			catch %{ filetype-map julia        '\bjulia\b'                                  } \
			catch %{ filetype-map ksh          '\bksh\b'                                    } \
			catch %{ filetype-map nu           '\bnu\b'                                     } \
			catch %{ filetype-map objc         '\bobjc\b'                                   } \
			catch %{ filetype-map python       '\bpython[23]?\b'                            } \
			catch %{ filetype-map sh           '\b(d?a)?sh\b'                               } \
			catch %{ filetype-map wolfram      '\bwolframscript\b'                          } \
			catch %{ filetype-map zsh          '\bzsh\b'                                    }
		}                                                                                         \
                                                                                                          \
		catch %{
			execute-keys '%d"bPx'
			try   %{ filetype-map awk         '\.awk$'                                      } \
			catch %{ filetype-map asciidoc    '\.asciidoc$'                                 } \
			catch %{ filetype-map bash        '(\.bash(_profile|env|rc)?|\.envrc)$'         } \
			catch %{ filetype-map bazel       '\.bazel$'                                    } \
			catch %{ filetype-map bibtex      '\.bib$'                                      } \
			catch %{ filetype-map c           '\.[ch]$'                                     } \
			catch %{ filetype-map c-sharp     '\.cs$'                                       } \
			catch %{ filetype-map cmake       '\.cmake$|\bCMakeLists.txt$'                  } \
			catch %{ filetype-map cpp         '\.(C|cc|cpp|cxx|H|hh|hpp|hxx|T|tpp|tt|txx)$' } \
			catch %{ filetype-map css         '\.css$'                                      } \
			catch %{ filetype-map csv         '\.csv$'                                      } \
			catch %{ filetype-map diff        '\.(diff|patch)$'                             } \
			catch %{ filetype-map dockerfile  '\bDockerfile$'                               } \
			catch %{ filetype-map elixir      '\.exs?$'                                     } \
			catch %{ filetype-map fish        '\.fish$'                                     } \
			catch %{ filetype-map git-commit  '^(COMMIT_EDITMSG|MERGE_MSG)$'                } \
			catch %{ filetype-map glsl        '\.(comp|frag|geom|tesc|tese|vert)$'          } \
			catch %{ filetype-map go          '\.go$'                                       } \
			catch %{ filetype-map haskell     '\.l?hs$'                                     } \
			catch %{ filetype-map html        '\.html$'                                     } \
			catch %{ filetype-map hyprlang    '\.hypr$'                                     } \
			catch %{ filetype-map ini         '\.ini$'                                      } \
			catch %{ filetype-map janet       '\.janet$'                                    } \
			catch %{ filetype-map java        '\.java$'                                     } \
			catch %{ filetype-map javascript  '\.(ps)?js$'                                  } \
			catch %{ filetype-map json        '\.json$'                                     } \
			catch %{ filetype-map jsx         '\.jsx$'                                      } \
			catch %{ filetype-map julia       '\.jl$'                                       } \
			catch %{ filetype-map kakrc       '(\.kak|\.?kakrc)$'                           } \
			catch %{ filetype-map koka        '\.kk$'                                       } \
			catch %{ filetype-map kotlin      '\.k(lib|ts?)$'                               } \
			catch %{ filetype-map ksh         '\.[mo]?ksh(_profile|env|rc)?$'               } \
			catch %{ filetype-map latex       '\.tex$'                                      } \
			catch %{ filetype-map lc2k        '\.(lc2k|nohaz)$'                             } \
			catch %{ filetype-map llvm        '\.llvm$'                                     } \
			catch %{ filetype-map lua         '\.lua$'                                      } \
			catch %{ filetype-map make        '\.mk$|\b[mM]akefile$'                        } \
			catch %{ filetype-map markdown    '\.md$'                                       } \
			catch %{ filetype-map nim         '\.nim$'                                      } \
			catch %{ filetype-map nix         '\.nix$'                                      } \
			catch %{ filetype-map nu          '\.nu$'                                       } \
			catch %{ filetype-map objc        '\.m$'                                        } \
			catch %{ filetype-map odin        '\.odin$'                                     } \
			catch %{ filetype-map purescript  '\.purs$'                                     } \
			catch %{ filetype-map python      '\.pyi?$'                                     } \
			catch %{ filetype-map ruby        '\.r[bu]$'                                    } \
			catch %{ filetype-map rust        '\.rs$'                                       } \
			catch %{ filetype-map scheme      '\.s(cm|s)$'                                  } \
			catch %{ filetype-map scss        '\.scss$'                                     } \
			catch %{ filetype-map sh          '\.(env|profile|rc)$'                         } \
			catch %{ filetype-map task        '\.task(rc)?$'                                } \
			catch %{ filetype-map todotxt     '\.?todo\.txt$'                               } \
			catch %{ filetype-map toml        '\.toml$'                                     } \
			catch %{ filetype-map tsv         '\.tsv$'                                      } \
			catch %{ filetype-map tsx         '\.tsx$'                                      } \
			catch %{ filetype-map typescript  '\.ts$'                                       } \
			catch %{ filetype-map typst       '\.typ(st)?$'                                 } \
			catch %{ filetype-map unison      '\.u$'                                        } \
			catch %{ filetype-map verilog     '\.vh?$'                                      } \
			catch %{ filetype-map vue         '\.vue$'                                      } \
			catch %{ filetype-map wolfram     '\.wls$'                                      } \
			catch %{ filetype-map xml         '\.(plist|svg|tmTheme|xml)$'                  } \
			catch %{ filetype-map yaml        '\.(clang(-(format|tidy)|d)|ya?ml)$'          } \
			catch %{ filetype-map zig         '\.zig$'                                      } \
			catch %{ filetype-map zsh         '\.z(profile|sh(env|rc))?$'                   }
		}                                                                                         \
                                                                                                          \
		catch nop

		delete-buffer %reg{f}
		buffer %reg{b}

		set-option buffer filetype "%reg{t}"
	}
}}

hook global BufCreate    '.*' filetype-set
hook global BufWritePost '.*' filetype-set
