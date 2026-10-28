#!/usr/bin/env bash
# One-time (WSL): the toolchain tools/HeliBoard/build.sh expects.
#   ~/tools/jdk-17  -> Ubuntu's OpenJDK 17
#   ~/android-sdk   -> Android cmdline-tools, accepted licenses, NDK 28.0.13004108
# Gradle fetches the platform and build-tools it needs on the first build.
set -euo pipefail

NDK=${NDK:-28.0.13004108}
SDK=${ANDROID_HOME:-$HOME/android-sdk}

# Ubuntu's sdkmanager (a Python reimplementation) only bootstraps Google's
# cmdline-tools; Google's own sdkmanager then handles licenses and the NDK.
sudo apt-get update
sudo apt-get install -y openjdk-17-jdk-headless sdkmanager unzip

mkdir -p ~/tools
ln -sfn /usr/lib/jvm/java-17-openjdk-amd64 ~/tools/jdk-17
export JAVA_HOME=$HOME/tools/jdk-17
export PATH=$JAVA_HOME/bin:$PATH

mkdir -p "$SDK"
[ -x "$SDK/cmdline-tools/latest/bin/sdkmanager" ] || sdkmanager --sdk_root="$SDK" "cmdline-tools;latest"
SM="$SDK/cmdline-tools/latest/bin/sdkmanager"

yes | "$SM" --sdk_root="$SDK" --licenses >/dev/null
"$SM" --sdk_root="$SDK" "ndk;$NDK" "platform-tools"

java -version 2>&1 | head -1
ls "$SDK/ndk"
echo "Toolchain ready. Next: tools/HeliBoard/build.sh"
