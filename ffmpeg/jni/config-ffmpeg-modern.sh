#!/bin/bash

# Modern FFmpeg configuration for MX Player (NDK r27+, FFmpeg 7.x)
# Usage: ./config-ffmpeg-modern.sh <arch>

tolower(){
    echo "$@" | tr ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz
}

function probe_host_platform(){
    local host_os=$(tolower $(uname -s))
    local host_platform=linux-x86_64;
    case $host_os in
      linux)        host_platform=linux-x86_64 ;;
      darwin)       host_platform=darwin-x86_64;;
      *)        ;;
    esac
    echo $host_platform;
}

HOST_PLATFORM=$(probe_host_platform)
NDK=${NDK:-/path/to/android-ndk-r27}  # SET your NDK path!

case $1 in
    arm64)
        ARCH=arm64
        CPU=armv8-a
        TARGET_API=35
        TOOLCHAIN_PREFIX=aarch64-linux-android
        LIB_MX="../libs/arm64-v8a"
        EXTRA_CFLAGS="-march=armv8-a"
        ;;
    neon)
        ARCH=arm
        CPU=armv7-a
        TARGET_API=35
        TOOLCHAIN_PREFIX=armv7a-linux-androideabi
        LIB_MX="../libs/armeabi-v7a/neon"
        EXTRA_CFLAGS="-march=armv7-a -mfloat-abi=softfp -mfpu=neon"
        EXTRA_LDFLAGS="-Wl,--fix-cortex-a8"
        ;;
    x86_64)
        ARCH=x86_64
        CPU=x86-64
        TARGET_API=35
        TOOLCHAIN_PREFIX=x86_64-linux-android
        LIB_MX="../libs/x86_64"
        EXTRA_CFLAGS="-march=x86-64 -msse4.2 -mpopcnt -mtune=intel"
        ;;
    x86)
        ARCH=x86
        CPU=i686
        TARGET_API=35
        TOOLCHAIN_PREFIX=i686-linux-android
        LIB_MX="../libs/x86"
        EXTRA_CFLAGS="-march=i686 -msse3 -mssse3 -mfpmath=sse"
        ;;
    *)
        echo "Unknown target: $1"
        echo "Usage: $0 {arm64|neon|x86_64|x86}"
        exit 1
esac

TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/$HOST_PLATFORM
SYSROOT=$TOOLCHAIN/sysroot
CC="$TOOLCHAIN/bin/${TOOLCHAIN_PREFIX}${TARGET_API}-clang"
CXX="$TOOLCHAIN/bin/${TOOLCHAIN_PREFIX}${TARGET_API}-clang++"
AR="$TOOLCHAIN/bin/llvm-ar"
NM="$TOOLCHAIN/bin/llvm-nm"
RANLIB="$TOOLCHAIN/bin/llvm-ranlib"
STRIP="$TOOLCHAIN/bin/llvm-strip"

INC_OPENSSL=../openssl-3.4.0/include
INC_OPUS=../opus-1.5.2/include
INC_DAV1D=../dav1d/include
INC_LAME=../lame-3.100/include

EXTRA_CFLAGS+=" -O3 -fPIC -DANDROID -D__ANDROID_API__=${TARGET_API}"
EXTRA_CFLAGS+=" -ffunction-sections -fdata-sections -funwind-tables"
EXTRA_CFLAGS+=" -fno-omit-frame-pointer -fno-strict-aliasing"
EXTRA_CFLAGS+=" -I$INC_OPENSSL -I$INC_OPUS -I$INC_DAV1D -I$INC_LAME"
EXTRA_LDFLAGS+=" -L$LIB_MX -Wl,--gc-sections -Wl,--as-needed"
EXTRA_LIBS="-lm -lc++_shared -lOpenSLES -llog"

./configure \
    --target-os=android \
    --arch=$ARCH \
    --cpu=$CPU \
    --enable-cross-compile \
    --cross-prefix=$TOOLCHAIN/bin/llvm- \
    --cc="$CC" \
    --cxx="$CXX" \
    --ar="$AR" \
    --nm="$NM" \
    --ranlib="$RANLIB" \
    --strip="$STRIP" \
    --sysroot=$SYSROOT \
    --prefix=$LIB_MX \
    --disable-shared \
    --enable-static \
    --enable-pic \
    --disable-debug \
    --disable-doc \
    --disable-programs \
    --disable-symver \
    --enable-optimizations \
    --enable-asm \
    --enable-neon \
    --enable-inline-asm \
    --enable-pthreads \
    --disable-avdevice \
    --disable-postproc \
    --enable-avfilter \
    --enable-decoder=ac3 \
    --enable-decoder=eac3 \
    --enable-decoder=dts \
    --enable-decoder=mlp \
    --enable-decoder=truehd \
    --enable-decoder=aac \
    --enable-decoder=libopus \
    --enable-decoder=libdav1d \
    --enable-encoder=aac \
    --enable-encoder=libmp3lame \
    --enable-parser=ac3 \
    --enable-parser=dca \
    --enable-parser=mlp \
    --enable-openssl \
    --enable-libopus \
    --enable-libdav1d \
    --enable-libmp3lame \
    --enable-zlib \
    --extra-cflags="$EXTRA_CFLAGS" \
    --extra-ldflags="$EXTRA_LDFLAGS" \
    --extra-libs="$EXTRA_LIBS"

echo "Configuration complete for $ARCH"
