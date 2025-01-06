#!/bin/sh
set -e

# Configuration
OUTPUT_DIR="build/ios"

# This script builds the iOS framework
#
# Usage:
#   ./build-ios.sh [options]
#
# Options:
#   -d, --debug        Keep debug symbols in the framework
#
# Examples:
#   ./build-ios.sh              # Build the framework
#   ./build-ios.sh --debug      # Build with debug symbols

# Check if gomobile is installed
if ! command -v gomobile &> /dev/null; then
    echo "Installing gomobile..."
    go install golang.org/x/mobile/cmd/gomobile@latest
    go install golang.org/x/mobile/cmd/gobind@latest
    gomobile init
fi

# Parse command line arguments
STRIP_DEBUG=true

while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--debug)
            STRIP_DEBUG=false
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Set up build flags
LDFLAGS=""
if [ "$STRIP_DEBUG" = "true" ]; then
    LDFLAGS="-s -w"
fi

echo "Building iOS framework..."
gomobile bind \
    -target=ios \
    -ldflags="$LDFLAGS" \
    -trimpath \
    -o "$OUTPUT_DIR/XrayCore.xcframework" \
    -v .

echo "Build complete. Artifacts are in $OUTPUT_DIR/" 