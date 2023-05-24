# Pandora Pay Mobile Wallet 

Mobile Wallet built using Flutter
Android Mobile Wallet supports Proxy.

## Installation

`flutter packages get`

### run
Deploy `flutter -v -d android_device_id run`
List of all devices `flutter devices`

### set custom icon

`flutter pub run flutter_launcher_icons:main`

### clean

`flutter clean`

## Troubleshooting installations

Some countries are blocked by Google. You need a proxy in case your machine can't download the required dependencies.

run commands
```
set http_proxy=https://109.167.128.51:8000
set https_proxy=https://109.167.128.51:443
set no_proxy=localhost,127.0.0.1,::1
```

edit android/gradle.properties
```
systemProp.http.proxyHost=109.167.128.51
systemProp.http.proxyPort=8000
systemProp.https.proxyHost=109.167.128.51
systemProp.https.proxyPort=443
```