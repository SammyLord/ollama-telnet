#!/bin/bash
# restricted_ollama_shell.sh

echo "Welcome to the Ollama Shell"

# Optional: Add a check to see if 'ollama' is in the PATH
# if ! command -v ollama &> /dev/null; then
#     echo "Error: 'ollama' command not found. Please ensure Ollama is installed and in your PATH."
#     exit 1
# fi

while true; do
    echo -n "ollama> "
    
    # Read the entire line into a variable
    read -r line
    
    # Trim leading/trailing whitespace from the line and normalize internal spaces
    line=$(echo "$line" | xargs)
    
    # Skip empty lines
    if [[ -z "$line" ]]; then
        continue
    fi

    # Use a here string to split the line into an array
    # This is more robust than `cut` and handles multiple spaces better
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
                docker exec -it ollama ollama "$cmd"
            fi
            ;;
        run)
            # This command requires a model name as an argument
            if [[ -n "$args" ]]; then
                # Execute 'ollama run' with the rest of the line as arguments
                # Note: 'run' can take a model and then a prompt.
                # This passes the rest of the line as arguments.
                docker exec -it ollama ollama $args
            else
                echo "Usage: run <model>"
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
