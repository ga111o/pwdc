#!/bin/bash
# Installation script for pwdc

set -e

echo "==================================="
echo "    pwdc Installation Script"
echo "==================================="
echo ""

# Detect environment
IS_WSL=false
IS_WAYLAND=false
IS_X11=false

if grep -qi microsoft /proc/version 2>/dev/null || [ -n "$WSL_DISTRO_NAME" ]; then
    IS_WSL=true
    echo "✓ Detected: WSL2 environment"
elif [ -n "$WAYLAND_DISPLAY" ]; then
    IS_WAYLAND=true
    echo "✓ Detected: Wayland environment"
elif [ -n "$DISPLAY" ]; then
    IS_X11=true
    echo "✓ Detected: X11 environment"
else
    echo "⚠ Could not auto-detect display environment"
fi

echo ""
echo "Please confirm your environment:"
echo "1) WSL2 (Windows Subsystem for Linux)"
echo "2) Wayland"
echo "3) X11"
echo "4) Auto-detect (recommended)"
echo ""
read -p "Choose [1-4] (default: 4): " choice
choice=${choice:-4}

case $choice in
    1)
        IS_WSL=true
        IS_WAYLAND=false
        IS_X11=false
        echo "Selected: WSL2"
        ;;
    2)
        IS_WSL=false
        IS_WAYLAND=true
        IS_X11=false
        echo "Selected: Wayland"
        ;;
    3)
        IS_WSL=false
        IS_WAYLAND=false
        IS_X11=true
        echo "Selected: X11"
        ;;
    4)
        echo "Using auto-detected environment"
        ;;
    *)
        echo "Invalid choice. Using auto-detect."
        ;;
esac

echo ""
echo "==================================="
echo "   Installing Dependencies"
echo "==================================="
echo ""

# Install appropriate clipboard utility
if [ "$IS_WSL" = true ]; then
    echo "✓ WSL2 uses clip.exe (already available in Windows)"
    if ! command -v clip.exe &> /dev/null; then
        echo "⚠ Warning: clip.exe not found. Make sure Windows is accessible."
    fi
elif [ "$IS_WAYLAND" = true ]; then
    echo "Installing wl-clipboard for Wayland..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y wl-clipboard
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y wl-clipboard
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm wl-clipboard
    elif command -v zypper &> /dev/null; then
        sudo zypper install -y wl-clipboard
    else
        echo "⚠ Warning: Could not detect package manager. Please install wl-clipboard manually."
    fi
elif [ "$IS_X11" = true ]; then
    echo "Installing clipboard utility for X11..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y xclip
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y xclip
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm xclip
    elif command -v zypper &> /dev/null; then
        sudo zypper install -y xclip
    else
        echo "⚠ Warning: Could not detect package manager. Please install xclip manually."
    fi
else
    echo "⚠ Could not determine environment. Attempting to install multiple clipboard utilities..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y xclip wl-clipboard
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y xclip wl-clipboard
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm xclip wl-clipboard
    elif command -v zypper &> /dev/null; then
        sudo zypper install -y xclip wl-clipboard
    fi
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
    echo "⚠ Warning: $INSTALL_DIR is not in your PATH"
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
        echo "✓ Added to $RC_NAME"
        echo "  Run 'source $RC_NAME' or restart your terminal to apply changes."
    fi
fi

echo ""
echo "==================================="
echo "   Installation Complete!"
echo "==================================="
echo ""
echo "✓ pwdc has been installed successfully!"
echo ""
echo "Usage:"
echo "  pwdc           - Copy the full current directory path to clipboard"
echo "  pwdc .         - Copy only the current directory name to clipboard"
echo "  pwdc ./path    - Copy current directory + path to clipboard"
echo ""
echo "If the command is not found, run:"
echo "  source $RC_NAME  (or restart your terminal)"
echo ""
