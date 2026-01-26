#!/usr/bin/env bash

# 1. Exit on error
set -e

# 2. Download Flutter SDK
echo "Downloading Flutter..."
git clone https://github.com/flutter/flutter.git -b stable --depth 1

# 3. Add Flutter to Path
export PATH="$PATH:`pwd`/flutter/bin"

# 4. Enable Web Support (just in case)
flutter config --enable-web

# 5. Build the App for Web
echo "Building Flutter Web App..."
flutter build web --release --no-tree-shake-icons

# 6. Success
echo "Build successful! Output is in build/web"