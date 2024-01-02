import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class SensorsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sensors'), backgroundColor: Colors.transparent),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: Uri.parse('https://dr1-console.things.ph/dashboard-public/5Rzz9QVVZ3UHhTsx3ioPhzoW')),
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            javaScriptEnabled: true,
            useOnLoadResource: true,
          ),
        ),
        onReceivedServerTrustAuthRequest: (controller, challenge) async {
          // Bypass SSL certificate verification 
          return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
        },
        onLoadResource: (controller, response) {
          final url = response.url?.toString();
          if (url != null && url.startsWith('https://')) {
            controller.evaluateJavascript(source: "document.head.querySelector('meta[name=\"viewport\"]').setAttribute('content', 'width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no');");
            controller.evaluateJavascript(source: "document.head.querySelector('meta[http-equiv=\"Content-Security-Policy\"]').setAttribute('content', 'default-src *; img-src * data: https:; script-src * 'unsafe-inline' 'unsafe-eval' https:; style-src * 'unsafe-inline' https:;');");
          }
        },
      ),
    );
  }
}
