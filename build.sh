flutter upgrade
flutter precache

flutter clean

rm web -rf
rm linux -rf
flutter create .

rm macos -rf
rm windows -rf
rm ios -rf

# convert icons/icon-512.png -resize 192x192  icons/icon-192.png
# convert icons/icon-512.png -resize 16x16    icons/icon-16.png

cp icons/icon-192.png web/favicon.png
cp icons/icon-512.png web/icons/Icon-512.png
cp icons/icon-192.png web/icons/Icon-192.png
cp icons/manifest.json web/manifest.json

flutter pub upgrade
flutter pub get

flutter build web
flutter build linux
flutter build appbundle

echo "DONE"


#cp build/web deployment/html -r
#cd deployment
#gcloud components update
#gcloud builds submit --tag gcr.io/strange-mason-272519/tictactoe
#gcloud run deploy --image gcr.io/strange-mason-272519/tictactoe --platform managed