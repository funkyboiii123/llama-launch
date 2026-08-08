#!/bin/bash

# Function to draw a line across the full window width
draw_line() {
    # Default to a dash if no character is provided
    local char="${1:-#}"
    
    # Get terminal columns, default to 80 if undetectable
    local width=$(tput cols 2>/dev/null || echo 80)
    
    # Generate and print the line
    printf '%*s\n' "$width" '' | tr ' ' "$char"
}

model_select() {
    # Check if directory exists
    if [ ! -d "$MODELS_DIR" ]; then
      echo "Models directory not found: $MODELS_DIR"
      exit 1
    fi

    # Read models into array
    mapfile -t models < <(find "$MODELS_DIR" -maxdepth 1 -type f | sort)

    # Check if any models found
    if [ ${#models[@]} -eq 0 ]; then
      echo "No model files found in $MODELS_DIR"
      exit 1
    fi

    draw_line "="

    # Display model selection menu
    echo "Select a model:"
    for i in "${!models[@]}"; do
      draw_line "-"
      echo "$((i+1))) $(basename "${models[$i]}")"
    done

    draw_line "-"
    draw_line "="

    read -p "Enter choice (1-${#models[@]}): " model_choice
    echo ""

    # Validate model selection
    if ! [[ "$model_choice" =~ ^[0-9]+$ ]] || [ "$model_choice" -lt 1 ] || [ "$model_choice" -gt "${#models[@]}" ]; then
      echo "Invalid choice"
      exit 1
    fi

    SELECTED_MODEL="${models[$((model_choice-1))]}"

    SELECTED_MODEL2="$SELECTED_MODEL"

    LAUNCH_ARGS="$LAUNCH_ARGS --model $SELECTED_MODEL2"
}

YAML_DIR="./config.yaml"

#When changing "WORKING_DIR", please do not add a slash after the directory.
WORKING_DIR=$(yq '.dir' $YAML_DIR)

MODELS_DIR=$(yq '.mdl' $YAML_DIR)

ctx=$(yq '.ctx' $YAML_DIR)

GPU_YAML=$(yq '.gpu' $YAML_DIR)

BAT_YAML=$(yq '.bat' $YAML_DIR)

THRD_YAML=$(yq '.thrd' $YAML_DIR)

FLSH_YAML=$(yq '.flsh' $YAML_DIR)

DCTX_YAML=$(yq '.flsh' $YAML_DIR)

case $DCTX_YAML in
  1)
  draw_line "-"
  echo "Use custom context length?:"
  echo "1) No"
  echo "2) Yes"
  echo ""
  read -p "Enter choice (n-y): " ctx_choice



case $ctx_choice in
  1) 
    ;;

  2)
   draw_line "-"
   read -p 'Enter context length (2048, 4096, 8192, 16384, etc,.) (type nothing for 4096): ' ctx
   echo ""

   if [ -z "$ctx" ]; then
    ctx="4096"
   fi
    ;;

  *) echo "Invalid choice"; exit 1 ;;
esac
  ;;
  0)
  ;;
esac

LAUNCH_ARGS="-ngl $GPU_YAML -b $BAT_YAML -ub $BAT_YAML -t $THRD_YAML --ctx-size $ctx -fa $FLSH_YAML --context-shift"


draw_line "-"
echo "Select a program:"
echo "1) Llama.cpp Server (GUI)"
echo "2) Llama.cpp Client (in this window)"
echo ""
read -p "Enter choice (1-2): " choice

case $choice in
  1) 


draw_line "-"
echo "Use Router Mode?:"
echo "1) No"
echo "2) Yes"
echo ""
read -p "Enter choice (1-2): " model_choice2

case $model_choice2 in
  1) 
   model_select ""
    ;;

  2)
    ;;

  *) echo "Invalid choice"; exit 1 ;;
esac

    case $model_choice2 in
      1) 
        ;;
      2)
        LAUNCH_ARGS="$LAUNCH_ARGS --models-dir $MODELS_DIR --models-max 1"
        ;;
      *) echo "Invalid choice"; exit 1 ;;
    esac


    ./llama-server.exe \
    --host 127.0.0.1 --port 8080 $LAUNCH_ARGS
    ;;
  2)

    model_select ""

    ./llama-cli.exe \
    -cnv $LAUNCH_ARGS
    ;;

  *) echo "Invalid choice"; exit 1 ;;
esac
