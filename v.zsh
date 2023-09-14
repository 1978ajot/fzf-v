#!/usr/bin/env zsh

v_alias_name="${V_ALIAS:-v}"
alias "${v_alias_name}"\="fzfv"

v_preview=${V_FZF_PREVIEW:-batcat --color=always --style=full -p {2}}
v_bindkeys=${V_FZF_BINDKEYS:---bind ctrl-T:toggle-preview --bind ctrl-S:toggle-sort}
v_tiebreak=${V_FZF_TIEBREAK:-end}
v_viminfo=${v_viminfo:-$HOME/.viminfo}
v_vimargs=${v_vimargs:--p}

_get_vim_history() {
	while IFS=" " read line; do
		if [[ "${line:0:1}" = ">" ]]; then
			fl=${line:2}
			_fl=$(echo ${fl} | sed -e "s|~|$HOME|")
			if [[ -f "$_fl" && ! -z $fl ]]; then
				i=$((i+1))
				files[$i]="$_fl"
			fi
		fi
	done < "$v_viminfo"

	if [ "$i" ]; then 
		while [[ $i -gt 0 ]]; do
			printf "%d\t%s\n" $i ${files[$i]}
			i=$((i-1))
		done
	fi
	return
}

function fzfv() {
	choosen_files=()
	for i file in `_get_vim_history | fzf \
		-0 -m --nth=2 --tac --no-sort --reverse \
		--tiebreak=${v_tiebreak} \
		--preview ${v_preview} \
		$(echo ${v_bindkeys}) \
		`
	do
		choosen_files+="$file"
	done

	if [[ ! -z $choosen_files ]]; then
		vim ${v_vimargs} $choosen_files
	fi
}
