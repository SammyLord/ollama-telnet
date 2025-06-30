#!/bin/bash
# restricted_ollama_shell.sh

echo "Welcome to the Ollama Shell"

# Optional: Add a check to see if the 'ollama' Docker container is running.
if ! docker ps --format '{{.Names}}' | grep -q '^ollama$'; then
    echo "Error: 'ollama' Docker container is not running."
    exit 1
fi

while true; do
    # Print the prompt without a newline
    echo -n "ollama> "
    
    # Read the entire line from standard input
    read -r line
    
    # --- THIS IS THE KEY FIX ---
    # Use parameter expansion to remove leading/trailing whitespace and the carriage return (`\r`)
    line=$(echo "$line" | tr -d '\r' | xargs)
    # --- END OF FIX ---
    
    # Skip empty lines
    if [[ -z "$line" ]]; then
        continue
    fi

    # Use a here string to split the line into an array
    read -r -a input_array <<< "$line"
    
    # Extract the command and arguments from the array
    cmd="${input_array[0]}"
    
    # Get all arguments except the first one
    args="${input_array[@]:1}"
    
    case "$cmd" in
        ls|ps)
            # These commands should not take any arguments
            if [[ -n "$args" ]]; then
                echo "Usage: $cmd"
            else
                docker exec -i ollama ollama "$cmd"
            fi
            ;;
        run)
            # This command requires a model name as an argument
            if [[ -n "$args" ]]; then
                # Use quoted args to handle multi-word prompts
                docker exec -i ollama ollama run "$args"
            else
                echo "Usage: run <model_name>"
            fi
            ;;
        exit|quit)
            echo "Goodbye!"
            exit 0
            ;;
        *)
            echo "Command not allowed. Available commands: ls, ps, run <model>, exit"
            ;;
    esac
done
