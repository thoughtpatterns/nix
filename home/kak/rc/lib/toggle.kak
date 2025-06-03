define-command -params 4 -docstring 'define-toggle <name> <state> <on> <off>: define a toggle command' define-toggle %{
	try %{ evaluate-commands %sh{
		case "$2" in
		('true'|'false') ;;
		(*) printf 'echo -debug "%s"\n' "define-toggle: '<state>' must be in {true, false}"; exit 1 ;;
		esac

		name="$1"
		nameq="$(printf '%s' "$name" | tr '-' '_')"
		state="$2"
		on="$3"
		off="$4"

		printf '
			declare-option bool %s_state %s\n
			define-command -params 1 -hidden %s-on %%§ %s §\n
			define-command -params 1 -hidden %s-off %%§ %s §\n
		' "$nameq" "$state" "$name" "$on" "$name" "$off"

		printf '
			define-command -params 1 -docstring "%s <scope>: toggle an associated state" %s %%{
				try %%{ evaluate-commands %%sh{
					scope="$1"

					if "$kak_opt_%s_state"
					then
						printf "
							set-option %%s %s_state false
							%s-off %%s
						" "$scope" "$scope"
					else
						printf "
							set-option %%s %s_state true
							%s-on %%s
						" "$scope" "$scope"
					fi
				}} catch %%{
					fail %%exp{failed to call '"'"'%s'"'"': %%val{error}}
				}
			}
		' "$name" "$name" "$nameq" "$nameq" "$name" "$nameq" "$name" "$name"

		printf '
			complete-command -menu %s shell-script-candidates %%{
				case "$kak_token_to_complete" in
				(0) printf "%%s\n" buffer current global local window ;;
				esac
			}
		' "$name"
	}} catch %{
		echo -debug "failed to register toggle: %val{error}"
	}
}
