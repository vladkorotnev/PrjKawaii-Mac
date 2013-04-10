cd "$( dirname "$0" )"
xcodebuild
cd build/Release
zip -vr gbb-osx.zip GelbooruViewer.app
../Sparkle\ 1.5b6/Extras/Signing\ Tools/sign_update.rb gbb-osx.zip ../Sparkle\ 1.5b6/Extras/Signing\ Tools/dsa_priv.pem > sign.txt
ls -l gbb-osx.zip >> sign.txt
rm -r *.app
rm *.dSYM
open .
