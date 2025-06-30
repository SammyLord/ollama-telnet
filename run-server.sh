ncat -l -p 8444 --keep-open -e $PWD/restricted_ollama_shell.sh >/dev/null 2>&1 &
