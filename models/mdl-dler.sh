#!/bin/bash

#This is a simple model downloader.

#Place this in the models folder

YAML_DIR="../config.yaml"

# Function to draw a line across the full window width
draw_line() {
    # Default to a dash if no character is provided
    local char="${1:-#}"
    
    # Get terminal columns, default to 80 if undetectable
    local width=$(tput cols 2>/dev/null || echo 80)
    
    # Generate and print the line
    printf '%*s\n' "$width" '' | tr ' ' "$char"
}

read -p "Enter model URL (ending with \".gguf\"): " url

echo ""
draw_line "-"
echo ""
curl  -JLO $url
echo ""
draw_line "-"
echo ""
echo "Finished download!"
echo ""

seconds=5

while [ $seconds -gt 0 ]; do
    # Format seconds into MM:SS
    echo "Exiting in $seconds..."
    
    # Wait for 1 second before next update
    sleep 1
    
    # Decrease the countdown tracker
    ((seconds--))
done

exit 1
