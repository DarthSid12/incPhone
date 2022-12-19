// ignore_for_file: use_build_context_synchronously

import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pusher_beams/pusher_beams.dart';

import 'package:inc_phone/loginPage.dart';

class MainScreen extends StatefulWidget {
  final String authToken;
  const MainScreen({
    Key? key,
    required this.authToken,
  }) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  WebViewController? _webViewController;
  @override
  void initState() {
    super.initState();
    // Enable virtual display.
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WebView(
        initialUrl: 'about:blank',
        // onPageStarted: (url) => print(url),
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (controller) {
          controller.loadUrl("https://app.incphone.com/dashboard",
              headers: {'Authorization': "Bearer ${widget.authToken}"});
          _webViewController = controller;
        },
        javascriptChannels: <JavascriptChannel>{
          JavascriptChannel(
            name: 'incPhoneLogOut',
            onMessageReceived: (JavascriptMessage message) async {
              await PusherBeams.instance.clearAllState();
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              _webViewController!.runJavascript("console.log('SUCCESS')");
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const LoginPage()));
              // getSecure(message.message);
            },
          )
        },
      ),
    );
  }
}
