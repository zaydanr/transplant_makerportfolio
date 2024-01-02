import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class Camera extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera Stream'), backgroundColor: Colors.transparent),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: Uri.parse('http://192.168.8.160:5000')),
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            javaScriptEnabled: true,
            useOnLoadResource: true,
          ),
        ),
        onReceivedServerTrustAuthRequest: (controller, challenge) async {
          // Bypass SSL certificate verification (not recommended for production)
          return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
        },
        onLoadResource: (controller, response) {
          // This is a workaround to allow JavaScript to access the camera in the WebView.
          // Replace 'http' with 'https' in the 'Content-Security-Policy' header.
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
