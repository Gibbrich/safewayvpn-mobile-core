#!/bin/sh
set -e

# Configuration
OUTPUT_DIR="build/android"

# This script builds the Android AAR library
#
# Usage:
#   ./build-android.sh [architectures...]
#
# Options:
#   architectures    Optional. Space-separated list of Android architectures to build for
#
# Supported architectures:
#   arm64-v8a       ARM64 architecture
#   armeabi-v7a     ARM v7 architecture
#   x86_64          x86_64 architecture
#   x86             x86 architecture
#
# Examples:
#   ./build-android.sh                            # Build for all architectures
#   ./build-android.sh arm64-v8a armeabi-v7a     # Build only for ARM architectures
#   ./build-android.sh x86_64                     # Build only for x86_64

# Get Go arch for Android ABI
get_go_arch() {
    case "$1" in
        "arm64-v8a")   echo "arm64" ;;
        "armeabi-v7a") echo "arm" ;;
        "x86_64")      echo "amd64" ;;
        "x86")         echo "386" ;;
        *)             echo "" ;;
    esac
}

# Get all supported Android ABIs
get_supported_abis() {
    echo "arm64-v8a armeabi-v7a x86_64 x86"
}

# Convert Android ABIs to gomobile target string
build_target() {
    local targets=""
    for android_arch in "$@"; do
        go_arch=$(get_go_arch "$android_arch")
        [ -n "$targets" ] && targets="$targets,"
        targets="$targets""android/$go_arch"
    done
    echo "$targets"
}

# Function to build
build_archs() {
    local archs="$@"
    [ -z "$archs" ] && archs=$(get_supported_abis)  # If no archs specified, build all
    
    echo "Building XrayCore for: $archs"
    local target=$(build_target $archs)
    
    gomobile bind \
        -target "$target" \
        -androidapi 26 \
        -ldflags "-buildid=" \
        -trimpath \
        -o "$OUTPUT_DIR/XrayCore.aar" \
        -v .
}

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Check if gomobile is installed
if ! command -v gomobile &> /dev/null; then
    echo "Installing gomobile..."
    go install golang.org/x/mobile/cmd/gomobile@latest
    go install golang.org/x/mobile/cmd/gobind@latest
    gomobile init
fi

# Build
if [ $# -eq 0 ]; then
    build_archs
else
    # Validate architectures
    for arch in "$@"; do
        if [ -z "$(get_go_arch "$arch")" ]; then
            echo "Error: Unsupported architecture '$arch'"
            echo "Supported architectures: $(get_supported_abis)"
            exit 1
        fi
    done
    build_archs "$@"
fi

echo "Build complete. Artifacts are in $OUTPUT_DIR/" 