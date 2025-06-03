function fish_user_key_bindings
	bind ctrl-s '
		printf "\n"
		ls -AFhl --color=always
		commandline --function repaint
	'

	bind ctrl-t '
		set -l selected (flirt -x)

		if test $status -eq 0
			commandline --append $selected
			commandline -f end-of-line
		end

		commandline --function repaint
	'
end
