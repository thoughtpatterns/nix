evaluate-commands %sh{ kak-lsp }

set-option global lsp_file_watch_support true

hook -group lsp-filetype-julia global BufSetOption filetype=julia %{
	set-option buffer lsp_servers %{
		[julials]
		root_globs = ["Project.toml", ".JuliaFormatter.toml", ".git", ".hg"]
	}
}

hook -group lsp-filetype-nix global BufSetOption 'filetype=nix' %{
	set-option buffer lsp_servers %{
		[nil]
		root_globs = ["flake.nix", "shell.nix", ".git", ".hg"]
		settings_section = "_"
		[nil.settings._]
		formatting.command = ["nixfmt"]
	}
}

hook -group lsp-filetype-python global BufSetOption 'filetype=python' %{
	set-option buffer lsp_servers %{
		[basedpyright-langserver]
		root_globs = ["requirements.txt", "pyproject.toml", ".git", ".hg"]
		args = ["--stdio"]
		settings_section = "_"

		[ruff]
		root_globs = ["requirements.txt", "pyproject.toml", ".git", ".hg"]
		args = ["server"]
	}
}

hook -group lsp-filetype-typst global BufSetOption 'filetype=typst' %{
	set-option buffer lsp_servers %{
		[tinymist]
		root_globs = [".git", ".hg"]
		args = ["lsp"]
		settings_section = "_"
		[tinymist.settings._]
		formatterMode = "typstyle"
		[tinymist.settings._.preview]
		browsing.args = ["--data-plane-host=127.0.0.1:0", "--invert-colors=never", "--open"]
	}
}

hook global BufCreate '\*hover\*' %{ hook buffer BufOpenFifo '\*hover\*' %{ hook -once buffer BufCloseFifo '.*' %{
	try %{ execute-keys -draft '%s\h+$<ret>d' }
}}}

define-toggle toggle-lsp-auto-hover        false 'lsp-auto-hover-enable'                'lsp-auto-hover-disable'
define-toggle toggle-lsp-auto-hover-buffer false 'lsp-auto-hover-buffer-enable'         'lsp-auto-hover-buffer-disable'
define-toggle toggle-lsp-inlay-diagnostics false 'lsp-inlay-diagnostics-enable %arg{1}' 'lsp-inlay-diagnostics-disable %arg{1}'
define-toggle toggle-lsp-inlay-hints       false 'lsp-inlay-hints-enable %arg{1}'       'lsp-inlay-hints-disable %arg{1}'
