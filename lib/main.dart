import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:inc_phone/PushNotificationService.dart';
import 'dart:io';

import 'package:webview_flutter/webview_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PushNotificationService().setupInteractedMessage();
  runApp(MaterialApp(
    home: MainScreen(),
  ));
  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    // App received a notification when it was killed
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String? token;
  @override
  void initState() {
    super.initState();
    // Enable virtual display.
    if (Platform.isAndroid) WebView.platform = AndroidWebView();

    FirebaseMessaging.instance.getToken().then((value) {
      token = value;
      print(token);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: token == null
          ? Container()
          : WebView(
              initialUrl:
                  'https://app.incphone.com/register?device_token=' + token!,
              onPageStarted: (url) => print(url),
              javascriptMode: JavascriptMode.unrestricted,
            ),
    );
  }
}
