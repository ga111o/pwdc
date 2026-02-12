#!/bin/bash
# Installation script for pwdc

set -e

echo "==================================="
echo "    pwdc Installation Script"
echo "==================================="
echo ""

# Detect possible environments
HAS_WSL=false
HAS_WAYLAND=false
HAS_X11=false

if grep -qi microsoft /proc/version 2>/dev/null || [ -n "$WSL_DISTRO_NAME" ]; then
    HAS_WSL=true
fi
if [ -n "$WAYLAND_DISPLAY" ] || command -v wl-copy &> /dev/null; then
    HAS_WAYLAND=true
fi
if [ -n "$DISPLAY" ] || command -v xclip &> /dev/null; then
    HAS_X11=true
fi

echo "The pwdc script now automatically detects your environment (Local, SSH, WSL, etc.)"
echo "Installing necessary dependencies for a universal experience..."
echo ""

# Install appropriate clipboard utilities
if command -v apt-get &> /dev/null; then
    echo "Using apt-get to install dependencies..."
    DEPS="coreutils"
    [ "$HAS_WAYLAND" = true ] && DEPS="$DEPS wl-clipboard"
    [ "$HAS_X11" = true ] && DEPS="$DEPS xclip"
    sudo apt-get update
    sudo apt-get install -y $DEPS
elif command -v dnf &> /dev/null; then
    echo "Using dnf to install dependencies..."
    DEPS="coreutils"
    [ "$HAS_WAYLAND" = true ] && DEPS="$DEPS wl-clipboard"
    [ "$HAS_X11" = true ] && DEPS="$DEPS xclip"
    sudo dnf install -y $DEPS
elif command -v pacman &> /dev/null; then
    echo "Using pacman to install dependencies..."
    DEPS="coreutils"
    [ "$HAS_WAYLAND" = true ] && DEPS="$DEPS wl-clipboard"
    [ "$HAS_X11" = true ] && DEPS="$DEPS xclip"
    sudo pacman -S --noconfirm $DEPS
elif command -v zypper &> /dev/null; then
    echo "Using zypper to install dependencies..."
    DEPS="coreutils"
    [ "$HAS_WAYLAND" = true ] && DEPS="$DEPS wl-clipboard"
    [ "$HAS_X11" = true ] && DEPS="$DEPS xclip"
    sudo zypper install -y $DEPS
fi


echo ""
echo "==================================="
echo "   Installing pwdc Command"
echo "==================================="
echo ""

# Install directory
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"

# Create install directory if it doesn't exist
mkdir -p "$INSTALL_DIR"

# Copy pwdc script
echo "Installing pwdc to $INSTALL_DIR/pwdc..."
cp pwdc "$INSTALL_DIR/pwdc"
chmod +x "$INSTALL_DIR/pwdc"

# Detect current shell
CURRENT_SHELL=$(basename "$SHELL")
if [ "$CURRENT_SHELL" = "zsh" ]; then
    RC_FILE="$HOME/.zshrc"
    RC_NAME="~/.zshrc"
else
    RC_FILE="$HOME/.bashrc"
    RC_NAME="~/.bashrc"
fi

# Check if install directory is in PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo ""
    echo "Warning: $INSTALL_DIR is not in your PATH"
    echo ""
    echo "Add the following line to your $RC_NAME:"
    echo ""
    echo "    export PATH="\$PATH:$INSTALL_DIR""
    echo ""
    read -p "Would you like to add it automatically to $RC_NAME? [y/N]: " add_path
    if [[ "$add_path" =~ ^[Yy]$ ]]; then
        echo "" >> "$RC_FILE"
        echo "# Added by pwdc installer" >> "$RC_FILE"
        echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$RC_FILE"
        echo "Added to $RC_NAME"
        echo "  Run 'source $RC_NAME' or restart your terminal to apply changes."
    fi
fi

echo ""
echo "==================================="
echo "   Installation Complete!"
echo "==================================="
echo ""
echo "pwdc has been installed successfully!"
echo ""
echo "Usage:"
echo "  pwdc           - Copy the full current directory path to clipboard"
echo "  pwdc .         - Copy only the current directory name to clipboard"
echo "  pwdc ./path    - Copy current directory + path to clipboard"
echo ""
echo "If the command is not found, run:"
echo "  source $RC_NAME  (or restart your terminal)"
echo ""
