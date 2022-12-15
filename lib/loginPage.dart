// ignore_for_file: avoid_print
// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:inc_phone/main.dart';
import 'package:pusher_beams/pusher_beams.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late SharedPreferences prefs;
  String? token;
  @override
  void initState() {
    super.initState();
    // getSecure('10', '20|iPqdjYMy56cSSylPkgbjqWflyFM6fYTNccDsusZd');
    initSharedPrefs();
  }

  initSharedPrefs() async {
    // await PusherBeams.instance.clearAllState();   //Uncommenting this line logs you out from pusher.
    prefs = await SharedPreferences.getInstance();
    // token = prefs.getString("token");
    // if (token != null) {
    //   Navigator.pushReplacement(
    //       context,
    //       MaterialPageRoute(
    //           builder: (context) => MainScreen(
    //                 authToken: token!,
    //               )));
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.all(10),
          child: ListView(
            children: <Widget>[
              Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),
                  child: RichText(
                    text: const TextSpan(children: [
                      TextSpan(
                        text: 'inc',
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                            fontSize: 30),
                      ),
                      TextSpan(
                        text: 'Phone',
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w900,
                            fontSize: 30),
                      ),
                    ]),
                  )),
              Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),
                  child: const Text(
                    'Sign in',
                    style: TextStyle(fontSize: 20),
                  )),
              Container(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: [AutofillHints.email],
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: TextField(
                  obscureText: true,
                  controller: passwordController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  //forgot password screen
                },
                child: const Text(
                  'Forgot Password',
                ),
              ),
              Container(
                  height: 50,
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: ElevatedButton(
                    child: const Text('Login'),
                    onPressed: () async {
                      print(emailController.text);
                      print(passwordController.text);
                      http.Response response = await http.post(
                          Uri.parse("https://app.incphone.com/sanctum/token"),
                          body: {
                            'email': emailController.text,
                            'device_name': "DarthSid12's device",
                            "password": passwordController.text
                          });
                      print(response.statusCode);
                      print(response.body);
                      if (response.statusCode == 200) {
                        String token = jsonDecode(response.body)['token'];
                        String userId =
                            jsonDecode(response.body)['user_id'].toString();

                        prefs.setString('token', token);

                        await getSecure(userId, token);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MainScreen(
                                      authToken: token,
                                    )));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: Colors.red,
                          content:
                              Text("Login error:" + response.body.toString()),
                        ));
                      }
                    },
                  )),
              Row(
                children: <Widget>[
                  const Text('Does not have account?'),
                  TextButton(
                    child: const Text(
                      'Sign in',
                      style: TextStyle(fontSize: 20),
                    ),
                    onPressed: () {
                      //signup screen
                    },
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              ),
            ],
          )),
    );
  }

  getSecure(String userId, String token) async {
    print(token);
    final BeamsAuthProvider provider = BeamsAuthProvider()
      ..authUrl = 'https://app.incphone.com/pusher/beams-auth'
      ..headers = {
        'Content-Type': 'application/json',
        'Authorization': "Bearer " + token,
      }
      ..queryParams = {
        'page': '1',
      }
      ..credentials = 'omit';
    print(userId);
    await PusherBeams.instance.setUserId(
        userId,
        provider,
        (error) => {
              if (error != null)
                {print("Pusher beam error: " + error)}
              // Success! Do something...
              else
                {print("Secure success " + userId)}
            });
  }
}
