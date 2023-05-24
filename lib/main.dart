import 'dart:convert';
import 'dart:async'; //remove it

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

final InAppLocalhostServer localhostServer = new InAppLocalhostServer(documentRoot: 'assets/wallet');

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb &&
      kDebugMode &&
      defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  if (!kIsWeb) {
    // start the localhost server
    await localhostServer.start();
  }

  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // detect Android back button click
        final controller = webViewController;
        if (controller != null) {
          if (await controller.canGoBack()) {
            controller.goBack();
            return false;
          }
        }
        return true;
      },
      child: Scaffold(
          // appBar: AppBar(
          //   title: const Text("Pandora Pay wallet"),
          // ),
          body: Column(children: <Widget>[
            Expanded(
              child: InAppWebView(

                key: webViewKey,

                initialUrlRequest:
                URLRequest(url: WebUri("http://localhost:8080/index.html")),
                initialSettings: InAppWebViewSettings(
                    allowsBackForwardNavigationGestures: true),

                onLoadStart: (controller, url) async {

                  bool proxySupport = false;
                  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
                    var proxyAvailable = await WebViewFeature.isFeatureSupported(WebViewFeature.PROXY_OVERRIDE);
                    proxySupport = proxyAvailable;
                  }

                  await controller.evaluateJavascript(source: """
console.log("Pandora Wallet Flutter App")

PandoraPayWalletOptions = {
    intro: {
        loadWasmHelper: true,
        compression: "gz",
    },
    setup: {
        enabled: ${proxySupport.toString()},
        resultCb: data => {
            window.flutter_inappwebview.callHandler('setup', JSON.stringify(data) );
        }
    },
}
                  """);

                },
                onWebViewCreated: (controller) {
                  webViewController = controller;

                  // define our "setup" event
                  controller.addJavaScriptHandler(
                    handlerName: "setup",
                    callback: (List<dynamic> payload) async {

                      //print("RECEIVED SETUP MESSAGE");

                      final data = jsonDecode(payload[0] as String);

                      String proxyAddress = "";
                      if (data["connectionProxyType"] == "tor"){
                        proxyAddress = "socks5://127.0.0.1:9050";
                      }else if (data["connectionProxyType"] == "i2p"){
                        proxyAddress = "socks5://127.0.0.1:4444";
                      }else if (data["connectionProxyType"] == "proxy"){
                        proxyAddress = data["connectionProxyAddress"] as String;
                      }

                      if ( proxyAddress.isNotEmpty){

                        ProxyController proxyController = ProxyController.instance();

                        await proxyController.clearProxyOverride();
                        await proxyController.setProxyOverride(
                            settings: ProxySettings(
                                proxyRules: [
                                  //example: socks4://109.167.128.51:32000
                                  ProxyRule(url: proxyAddress)
                                ],
                                bypassRules: []
                            ));

                        print("PROXY SET");
                        print(proxyAddress);

                      }

                      // testing
                      // await ( new Future.delayed(const Duration(seconds: 30), () => "2") );
                      // await controller.loadUrl(urlRequest: URLRequest(url: WebUri("https://api.ipify.org/") ));
                      // print("redirected");

                    },
                  );

                },
                //print console.log messages
                onConsoleMessage: (controller, consoleMessage) {
                  print(consoleMessage);
                },


              ),
            ),
          ])),
    );
  }
}