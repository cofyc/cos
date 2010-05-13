#!/bin/bash

version=$(grep 'CFBundleVersion' Info.plist  -A 1 | tail -n 1 | sed -nr 's/.*<string>(.*)<\/string>.*/\1/p')

hdiutil create -srcfolder build/Release/CoStats.app CoStats-"$version".dmg
