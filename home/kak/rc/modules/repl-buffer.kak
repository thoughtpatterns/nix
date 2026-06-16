declare-option -hidden str repl_buffer_workdir
declare-option -hidden int repl_buffer_last_chunk_stamp
declare-option -hidden str repl_buffer_last_chunk_end
declare-option \
    -docstring "List of active REPL buffers, oldest to newest." \
    str-list repl_buffer_list

define-command repl-buffer-new \
    -params .. \
    -shell-completion \
    -docstring "
        repl-buffer-new [<switches>] [--] <cmd>: run shell command in a buffer
        <cmd>                 A shell command, like 'ls -al'

        Switches:
            -name <name>      Set the name of the buffer capturing the output
    " \
%{
    evaluate-commands %sh{
        fail() { printf "%s\n" "fail -- %{$*}"; exit 1; }
        kakquote() {
            set -- "$*" ""
            while [ "${1#*\'}" != "$1" ]; do
                set -- "${1#*\'}" "$2${1%%\'*}''"
            done
            printf "'%s' " "$2$1"
        }
        kakquotecmd() {
            for arg; do
                kakquote "$arg"
            done
            printf '\n'
        }

        bufname=""
        while [ $# -gt 0 ]; do
            case "$1" in
                -name)
                    shift
                    if [ $# -eq 0 ]; then fail "name switch needs a value"; fi
                    bufname="$1"
                    ;;
                --)
                    shift || fail "shell command required"
                    break
                    ;;
                -*)
                    fail "Unrecognised switch $1"
                    ;;
                *)
                    break
                    ;;
            esac
            shift
        done
        if [ "$#" -eq 0 ]; then
            fail "shell command required"
        fi
        if [ -z "$bufname" ]; then
            bufname="*$1*"
        fi

        workdir=$(mktemp -d "${TMPDIR:-/tmp}"/kak-repl-buffer.XXXXXXXX)
        mkfifo "$workdir/input"
        mkfifo "$workdir/output"
        (
            repl-buffer-input "$workdir/input" | "$@" >"$workdir/output" 2>&1 &
        ) </dev/null >/dev/null 2>&1

        kakquotecmd edit! -fifo "$workdir/output" -scroll "$bufname"
        kakquotecmd set-option buffer repl_buffer_workdir "$workdir"
        kakquotecmd set-option -add global repl_buffer_list "$bufname"
    }
    hook -always -once -group repl-buffer-read-fifo buffer BufReadFifo .* %{
        repl-buffer-first-chunk %val{hook_param}
        hook -always -group repl-buffer-read-fifo buffer BufReadFifo .* %{
            repl-buffer-other-chunks %val{hook_param}
        }
    }
    hook -always -group repl-buffer-send-line buffer InsertKey <ret> %{
        repl-buffer-send-line
    }
    hook -always -once -group repl-buffer-buf-close buffer BufClose .* %{
        repl-buffer-close
    }
    hook -always -once -group repl-buffer-fifo-close buffer BufCloseFifo .* %{
        repl-buffer-close
    }
}

define-command repl-buffer-first-chunk \
    -hidden \
    -params 1 \
%{
    # Select the newly received chunk.
    select %arg{1}

    evaluate-commands -draft %{
        # Make sure it's at the beginning of the buffer,
        # before anything the user has typed.
        execute-keys dggP

        # Make a note of where we put it.
        set-option buffer repl_buffer_last_chunk_stamp %val{timestamp}
        set-option buffer repl_buffer_last_chunk_end \
            "%val{cursor_line}.%val{cursor_column}"
    }
}

define-command repl-buffer-other-chunks \
    -hidden \
    -params 1 \
%{
    evaluate-commands -draft -save-regs a %{
        # Cut the newly received chunk
        select %arg{1}
        execute-keys '"ad'

        # Select the end of the previously-received chunk
        select -timestamp %opt{repl_buffer_last_chunk_stamp} \
            "%opt{repl_buffer_last_chunk_end},%opt{repl_buffer_last_chunk_end}"

        # If we paste, and the selection ends with a newline,
        # Kakoune will do a line-wise paste and insert a newline
        # before the pasted text.
        # So we have to insert it from the register instead of pasting.
        execute-keys 'a<c-r>a<esc>'

        # Make a note of where we put it.
        set-option buffer repl_buffer_last_chunk_stamp %val{timestamp}
        set-option buffer repl_buffer_last_chunk_end \
            "%val{cursor_line}.%val{cursor_column}"
    }
}

define-command repl-buffer-send-line \
    -hidden \
%{
    evaluate-commands -save-regs lc %{
        evaluate-commands -draft %{
            # Record the current location of the end of the last chunk
            select -timestamp %opt{repl_buffer_last_chunk_stamp} \
                "%opt{repl_buffer_last_chunk_end},%opt{repl_buffer_last_chunk_end}"
            reg l %val{cursor_line}
            reg c %val{cursor_column}
        }

        evaluate-commands -draft %sh{
            last_chunk_line=$kak_reg_l
            last_chunk_column=$kak_reg_c

            # If <ret> was pressed above the last line of the last chunk,
            # we don't care.
            if [ "$kak_cursor_line" -lt "$last_chunk_line" ]; then
                return
            fi
            # If <ret> was pressed before the end of the last line
            # of the last chunk, we don't care.
            if [ "$kak_cursor_line" -eq "$last_chunk_line" ] &&
                [ "$kak_cursor_column" -lt "$last_chunk_column" ]; then
                return
            fi

            last_chunk_end="$last_chunk_line.$last_chunk_column"
            new_line_start="$kak_cursor_line.$kak_cursor_column"
            printf '%s' "
                # Select the from the last character of the last chunk,
                # to the first character of the new line.
                select $last_chunk_end,$new_line_start

                # We don't want to send the new, empty line,
                # so exclude it from the selection.
                execute-keys H

                # Pretend the line we just typed is actually
                # a chunk echoed back to us, and extend the last chunk
                # to cover it.
                set-option buffer repl_buffer_last_chunk_stamp %val{timestamp}
                set-option buffer repl_buffer_last_chunk_end \
                    %exp{%val{cursor_line}.%val{cursor_column}}

                # We don't want to send the last character of the
                # (real) last chunk, either.
                execute-keys <a-semicolon>L

                # Send the selected text to the REPL.
                repl-buffer-send-text-raw %val{bufname} %val{selection}
            "
        }
    }
}

define-command repl-buffer-close \
    -hidden \
    -params 0 \
%{
    evaluate-commands %sh{
        if [ -n "$kak_opt_repl_buffer_workdir" ]; then
            # We could use rm -rf, but for safety let's be explicit.
            rm "$kak_opt_repl_buffer_workdir"/input
            rm "$kak_opt_repl_buffer_workdir"/output
            rmdir "$kak_opt_repl_buffer_workdir"
        fi
    }
    unset buffer repl_buffer_workdir
    unset buffer repl_buffer_last_chunk_stamp
    unset buffer repl_buffer_last_chunk_end
    set-option -remove global repl_buffer_list %val{bufname}
    remove-hooks buffer repl-buffer-.*
}

define-command repl-buffer-send-text-raw \
    -params 2 \
    -docstring "
        repl-buffer-send-text-raw <buffer> <text>: Send <text> to REPL <buffer>
        <buffer> must be a buffer previously created by repl-buffer-new
    " \
%{
    eval -buffer %arg{1} %{
        echo -to-file "%opt{repl_buffer_workdir}/input" -- %arg{2}
    }
}

define-command repl-buffer-send-text \
    -params ..1 \
    -docstring "
        repl-buffer-send-text [<text>]: Send text to the current REPL's input.
        If <text> is not supplied, sends the current selection.
        If the current buffer is not a REPL, use the most recent REPL.
    " \
%{
    evaluate-commands %sh{
        kakquote() { printf "%s\n" "$*"|sed -e "s/'/''/g;1s/^/'/;\$s/\$/' /"; }

        # The text to send is the first parameter (if any)
        # or otherwise $kak_selection
        if [ $# -eq 0 ]; then
            text="%val{selection}"
        else
            text="%arg{1}"
        fi

        # If this is not an active repl buffer...
        if [ -z "$kak_opt_repl_buffer_workdir" ]; then
            # ...let's look for the most recently-launched repl
            eval set -- "$kak_quoted_opt_repl_buffer_list"
            if [ $# -eq 0 ]; then
                printf "fail %s\n" "No repl buffers to send to"
                exit 1
            fi
            shift $(( $# - 1 ))
            buffer="$1"
        else
            # This is an active repl buffer.
            buffer="$kak_bufname"
        fi

        # Now we have a buffer and text, send the text to the REPL buffer
        printf 'repl-buffer-send-text-raw %s %s\n' \
            "$(kakquote "$buffer")" "$text"
    }
}
