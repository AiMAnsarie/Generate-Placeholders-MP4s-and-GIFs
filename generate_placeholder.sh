#!/bin/bash

# Function to install ffmpeg using apt
install_ffmpeg_with_apt() {
    echo "Attempting to install ffmpeg using apt..."
    apt update && apt --fix-broken install -y
    apt install -y ffmpeg
    if [[ $? -eq 0 ]]; then
        echo "ffmpeg installed successfully using apt."
        return 0
    else
        echo "Failed to install ffmpeg using apt."
        return 1
    fi
}

# Function to install snapd if not present
install_snapd_if_missing() {
    if ! command -v snap &> /dev/null; then
        echo "snapd is not installed. Attempting to install it..."
        if [[ "$EUID" -ne 0 ]]; then
            echo "Please run the script as root (or use sudo) to install snapd."
            exit 1
        fi
        apt update && apt install -y snapd
        if [[ $? -ne 0 ]]; then
            echo "Failed to install snapd. Please install it manually and rerun the script."
            exit 1
        fi
        echo "snapd installed successfully."
    else
        echo "snapd is already installed."
    fi
}

# Function to install ffmpeg using snap
install_ffmpeg_with_snap() {
    echo "Attempting to install ffmpeg using snap..."
    install_snapd_if_missing
    snap install ffmpeg
    if [[ $? -eq 0 ]]; then
        echo "ffmpeg installed successfully using snap."
        return 0
    else
        echo "Failed to install ffmpeg using snap."
        exit 1
    fi
}

# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "ffmpeg is not installed. Installing it now..."
    if ! install_ffmpeg_with_apt; then
        install_ffmpeg_with_snap
    fi
else
    echo "ffmpeg is already installed."
fi

# Validate command-line arguments for resolution
if [[ $# -ne 2 ]]; then
    echo "Error: Incorrect number of arguments."
    echo "Usage: $0 WIDTH HEIGHT"
    echo "Example: sudo $0 728 90"
    exit 1
fi

# Extract WIDTH and HEIGHT from the arguments
WIDTH=$1
HEIGHT=$2

# Validate that WIDTH and HEIGHT are positive integers
if ! [[ $WIDTH =~ ^[0-9]+$ ]] || ! [[ $HEIGHT =~ ^[0-9]+$ ]]; then
    echo "Error: WIDTH and HEIGHT must be positive integers."
    echo "Usage: $0 WIDTH HEIGHT"
    echo "Example: sudo $0 728 90"
    exit 1
fi

# Create a fully transparent MP4 file
generate_mp4() {
    OUTPUT_NAME="${WIDTH}x${HEIGHT}.mp4"
    ffmpeg -y -f lavfi -i color=c=white@0.0:s=${WIDTH}x${HEIGHT}:d=3 \
           -r 24 -vcodec libx264 -pix_fmt yuva420p "$OUTPUT_NAME"
    echo "3-second fully transparent MP4 created: $OUTPUT_NAME"
}

# Create a fully transparent GIF file
generate_gif() {
    OUTPUT_NAME="${WIDTH}x${HEIGHT}.gif"
    ffmpeg -y -f lavfi -i color=c=white@0.0:s=${WIDTH}x${HEIGHT}:d=3 \
           -vframes 1 -pix_fmt rgba "$OUTPUT_NAME"
    echo "3-second fully transparent GIF created: $OUTPUT_NAME"
}

# Run the functions
generate_mp4
generate_gif