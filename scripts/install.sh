#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Repository information
REPO_OWNER="SiFiLabs"
REPO_NAME="sifi-bridge-pub"
BINARY_NAME="sifibridge"

# Installation directory
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"

# Function to print colored messages
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1" >&2
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1" >&2
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Function to detect OS and architecture
detect_platform() {
    local os arch

    # Detect OS
    case "$(uname -s)" in
        Linux*)
            os="unknown-linux-gnu"
            ;;
        Darwin*)
            os="apple-darwin"
            ;;
        *)
            print_error "Unsupported operating system: $(uname -s)"
            exit 1
            ;;
    esac

    # Detect architecture
    case "$(uname -m)" in
        x86_64|amd64)
            arch="x86_64"
            ;;
        aarch64|arm64)
            arch="aarch64"
            ;;
        *)
            print_error "Unsupported architecture: $(uname -m)"
            exit 1
            ;;
    esac

    echo "${arch}-${os}"
}

# Function to fetch latest release version
get_latest_version() {
    print_info "Fetching latest release version..."

    local version
    version=$(curl -s "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest" \
        | grep '"tag_name":' \
        | sed -E 's/.*"tag_name": *"([^"]+)".*/\1/')

    if [ -z "$version" ]; then
        print_error "Failed to fetch latest version"
        exit 1
    fi

    echo "$version"
}

# Function to download and install binary
install_binary() {
    local platform="$1"
    local version="$2"
    local asset_name="${BINARY_NAME}-${version}-${platform}.tar.gz"
    local download_url="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/${version}/${asset_name}"
    local temp_dir
    temp_dir=$(mktemp -d)

    print_info "Downloading ${BINARY_NAME} ${version} for ${platform}..."

    # Download the asset
    if ! curl -L -o "${temp_dir}/${asset_name}" "$download_url"; then
        print_error "Failed to download ${asset_name}"
        rm -rf "$temp_dir"
        exit 1
    fi

    print_info "Extracting archive..."

    # Extract the tarball
    if ! tar -xzf "${temp_dir}/${asset_name}" -C "$temp_dir"; then
        print_error "Failed to extract archive"
        rm -rf "$temp_dir"
        exit 1
    fi

    # Find the binary in the extracted directory
    local binary_path
    binary_path=$(find "$temp_dir" -name "$BINARY_NAME" -type f | head -n 1)

    if [ -z "$binary_path" ]; then
        print_error "Binary not found in archive"
        rm -rf "$temp_dir"
        exit 1
    fi

    # Create installation directory if it doesn't exist
    mkdir -p "$INSTALL_DIR"

    # Install the binary
    print_info "Installing to ${INSTALL_DIR}/${BINARY_NAME}..."

    if ! mv "$binary_path" "${INSTALL_DIR}/${BINARY_NAME}"; then
        print_error "Failed to install binary to ${INSTALL_DIR}"
        rm -rf "$temp_dir"
        exit 1
    fi

    # Make it executable
    chmod +x "${INSTALL_DIR}/${BINARY_NAME}"

    # Clean up
    rm -rf "$temp_dir"

    print_info "Installation complete!"
}

# Function to verify installation
verify_installation() {
    if [ -x "${INSTALL_DIR}/${BINARY_NAME}" ]; then
        print_info "${BINARY_NAME} installed successfully at ${INSTALL_DIR}/${BINARY_NAME}"

        # Check if installation directory is in PATH
        if [[ ":$PATH:" != *":${INSTALL_DIR}:"* ]]; then
            print_warning "${INSTALL_DIR} is not in your PATH"
            echo ""
            echo "Add the following line to your shell configuration file (~/.bashrc, ~/.zshrc, etc.):"
            echo ""
            echo "    export PATH=\"${INSTALL_DIR}:\$PATH\""
            echo ""
        else
            print_info "You can now run: ${BINARY_NAME} --help"
        fi

        # Show version
        echo ""
        print_info "Installed version:"
        "${INSTALL_DIR}/${BINARY_NAME}" --version 2>/dev/null || echo "Unable to determine version"
    else
        print_error "Installation verification failed"
        exit 1
    fi
}

# Main installation flow
main() {
    echo "=================================="
    echo "  SiFi Bridge Installer"
    echo "=================================="
    echo ""

    # Detect platform
    platform=$(detect_platform)
    print_info "Detected platform: ${platform}"

    # Get latest version
    version=$(get_latest_version)
    print_info "Latest version: ${version}"

    # Install binary
    install_binary "$platform" "$version"

    # Verify installation
    verify_installation

    echo ""
    echo "=================================="
    echo "  Installation Successful!"
    echo "=================================="
}

# Run main function
main
