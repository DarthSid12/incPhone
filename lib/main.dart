// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:pusher_beams/pusher_beams.dart';

import 'package:inc_phone/loginPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PusherBeams.instance.start('9de8aad5-899d-4332-9101-35400d929ac7');
  runApp(const MaterialApp(
    home: LoginPage(),
  ));
}
