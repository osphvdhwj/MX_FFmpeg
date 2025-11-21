#!/bin/bash

# Update script for modernizing MX_FFmpeg
# Run this to download latest versions of all dependencies

set -e

SCRIPT_DIR="$(cd \"$(dirname \"$0\"); pwd)"
cd "$SCRIPT_DIR"

echo "Updating FFmpeg to latest version..."
if [ -d "ffmpeg" ]; then
    cd ffmpeg
    git fetch origin
    git checkout release/7.1  # Latest stable
    cd ..
else
    git clone --depth 1 --branch release/7.1 https://github.com/FFmpeg/FFmpeg.git ffmpeg
fi

echo "Updating dav1d (AV1 decoder)..."
if [ -d "dav1d" ]; then
    cd dav1d
    git fetch origin
    git checkout 1.5.0  # Latest stable
    cd ..
else
    git clone --depth 1 --branch 1.5.0 https://code.videolan.org/videolan/dav1d.git
fi

echo "Updating OpenSSL to 3.x..."
if [ ! -d "openssl-3.4.0" ]; then
    wget https://www.openssl.org/source/openssl-3.4.0.tar.gz
    tar -xzf openssl-3.4.0.tar.gz
    rm openssl-3.4.0.tar.gz
fi

echo "Updating LAME MP3 encoder..."
if [ ! -d "lame-3.100" ]; then
    wget https://sourceforge.net/projects/lame/files/lame/3.100/lame-3.100.tar.gz
    tar -xzf lame-3.100.tar.gz
    rm lame-3.100.tar.gz
fi

echo "Updating Opus..."
if [ ! -d "opus-1.5.2" ]; then
    wget https://downloads.xiph.org/releases/opus/opus-1.5.2.tar.gz
    tar -xzf opus-1.5.2.tar.gz
    rm opus-1.5.2.tar.gz
fi

echo "All dependencies updated!"
