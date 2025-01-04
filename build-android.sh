#!/bin/sh

# Configuration
OUTPUT_DIR="../app/libs"

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
        .
}

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Install and init gomobile
echo "Setting up gomobile..."
go install golang.org/x/mobile/cmd/gomobile@latest
gomobile init

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