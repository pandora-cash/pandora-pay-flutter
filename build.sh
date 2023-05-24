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

  cd ../go-pandora-pay/ || exit
  ./scripts/build-wasm.sh main build
  ./scripts/build-wasm.sh helper build

  cd ../pandora-pay-flutter || exit
fi


if [[ "$*" == *wallet* ]]; then
  echo "Build Wallet"

  mkdir ./assets
  mkdir ./assets/wallet

  cd ../PandoraPay-wallet/ || exit

  npm run build-ui --skip-zip -- --mode=production

  cp -r ./dist/build/* ../pandora-pay-flutter/assets/wallet

  cd ../pandora-pay-flutter/assets || exit

  find . -name "*.gz" -type f -delete
  find . -name "*.br" -type f -delete

  cd .. || exit

fi

