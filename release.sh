#!/bin/bash
PCZIPNAME="MustachedNemesis_PC_"
OSXZIPNAME="MustachedNemesis_OSX_"
DATE=$(date +%m_%d_%Y)
echo "======================================"
echo "Bundling up PC build"
echo "======================================"
cat lib/love-0.9.1-win32/love.exe MustachedNemesis.love > lib/MustachedNemesis/MustachedNemesis.exe
zip -9 -q -r $PCZIPNAME$DATE lib/MustachedNemesis/
mv $PCZIPNAME$DATE.zip bin/
echo "======================================"
echo "Bundling up OSX build"
echo "======================================"
cp MustachedNemesis.love lib/MustachedNemesis.app/Contents/Resources/
zip -9 -q -r $OSXZIPNAME$DATE lib/MustachedNemesis.app
mv $OSXZIPNAME$DATE.zip bin/
echo "======================================"
echo "Finished creating Mustached Nemesis!"
echo "======================================"
