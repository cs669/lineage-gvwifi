#!/usr/bin/env bash
# One-time (WSL): the toolchain tools/HeliBoard/build.sh expects.
#   ~/tools/jdk-17  -> Ubuntu's OpenJDK 17
#   ~/android-sdk   -> Android cmdline-tools, accepted licenses, NDK 28.0.13004108
# Gradle fetches the platform and build-tools it needs on the first build.
set -euo pipefail

NDK=${NDK:-28.0.13004108}
SDK=${ANDROID_HOME:-$HOME/android-sdk}

# Ubuntu 24.04's google-android-cmdline-tools installer fetches Google's
# cmdline-tools under /usr/lib/android-sdk; that sdkmanager then installs into ~/android-sdk.
sudo apt-get update
sudo apt-get install -y openjdk-17-jdk-headless google-android-cmdline-tools-13.0-installer unzip

mkdir -p ~/tools
ln -sfn /usr/lib/jvm/java-17-openjdk-amd64 ~/tools/jdk-17
export JAVA_HOME=$HOME/tools/jdk-17
export PATH=$JAVA_HOME/bin:$PATH

SM=$(find /usr/lib/android-sdk/cmdline-tools -path '*/bin/sdkmanager' 2>/dev/null | sort | tail -1) || true
[ -x "$SM" ] || { echo "!! sdkmanager not found under /usr/lib/android-sdk/cmdline-tools"; exit 1; }

mkdir -p "$SDK"
yes | "$SM" --sdk_root="$SDK" --licenses >/dev/null || true
"$SM" --sdk_root="$SDK" "cmdline-tools;latest" "ndk;$NDK" "platform-tools"

java -version 2>&1 | head -1
ls "$SDK/ndk"
echo "Toolchain ready. Next: tools/HeliBoard/build.sh"
