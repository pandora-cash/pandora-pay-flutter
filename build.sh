if [ $# -eq 0 ]; then
  echo "arguments missing"
fi

if [[ "$*" == "help" ]]; then
    echo "wallet, wasm"
    exit 1
fi

echo "Running build"

if [[ "$*" == *wasm* ]]; then
  echo "Build Wasm"
  (cd ../PandoraPay-wallet/; bash build.sh build)  
fi


if [[ "$*" == *wallet* ]]; then
  echo "Build Wallet"

  mkdir -p ./assets
  mkdir -p ./assets/wallet

  cd ../PandoraPay-wallet/ || exit

  npm run build-webworker-wasm --skip-zip -- --mode=production
  npm run build-ui --skip-zip -- --mode=production

  cp -r ./dist/build/* ../pandora-pay-flutter/assets/wallet

  cd ../pandora-pay-flutter/assets || exit

  find . -name "*.gz" -type f -delete
  find . -name "*.br" -type f -delete

  cd .. || exit

fi

