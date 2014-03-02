#!/bin/bash
PCZIPNAME="MustachedNemesis_PC_"
OSXZIPNAME="MustachedNemesis_OSX_"
DATE=$(date +%m_%d_%Y)
echo "Bundling up PC build"
cat lib/love-0.9.0-win32/love.exe MustachedNemesis.love > lib/MustachedNemesis/MustachedNemesis.exe
zip -r bin/$PCZIPNAME$DATE lib/MustachedNemesis
echo "Bundling up OSX build"
cp MustachedNemesis.love lib/MustachedNemesis.app/Contents/Resources/
zip -r bin/$OSXZIPNAME$DATE lib/MustachedNemesis.app
echo "Finished creating Mustached Nemesis!"
