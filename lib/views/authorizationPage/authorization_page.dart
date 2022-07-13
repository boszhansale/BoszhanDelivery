import 'package:boszhan_delivery_app/services/auth_api_provider.dart';
import 'package:boszhan_delivery_app/views/home_page.dart';
import 'package:boszhan_delivery_app/widgets/app_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    // emailController.text = 'driver1@foodkz.kz';
    // passwordController.text = '123456';

    getFCMToken();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                color: Colors.blue,
                playSound: true,
                icon: '@mipmap/ic_launcher',
              ),
            ));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(notification.title.toString()),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(notification.body.toString())],
                  ),
                ),
              );
            });
      }
    });

    checkLogIn();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60.0),
            child: buildAppBar('Авторизация')),
        body: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
              Image.asset("assets/images/logo.png",
                  width: MediaQuery.of(context).size.width * 0.5),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 80, vertical: 10),
                child: TextFormField(
                  controller: emailController,
                  style: const TextStyle(color: Colors.black, fontSize: 20),
                  decoration: const InputDecoration(
                      fillColor: Colors.red,
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red)),
                      hintText: 'Введите логин',
                      helperText: 'Your login to enter the app.',
                      labelText: 'Логин',
                      labelStyle:
                          TextStyle(color: Colors.black87, fontSize: 20),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red)),
                      prefixIcon: Icon(
                        Icons.person,
                        color: Colors.black87,
                      ),
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 20),
                      prefixText: ' ',
                      // suffixText: 'USD',
                      suffixStyle:
                          TextStyle(color: Colors.black, fontSize: 20)),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 80, vertical: 10),
                child: TextFormField(
                  controller: passwordController,
                  style: const TextStyle(color: Colors.black, fontSize: 20),
                  decoration: const InputDecoration(
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 20),
                      fillColor: Colors.red,
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red)),
                      hintText: 'Пароль',
                      helperText: 'Your password to enter the app.',
                      labelText: 'Пароль',
                      labelStyle:
                          TextStyle(color: Colors.black87, fontSize: 20),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red)),
                      prefixIcon: Icon(
                        Icons.vpn_key,
                        color: Colors.black87,
                      ),
                      prefixText: '',
                      suffixStyle:
                          TextStyle(color: Colors.black, fontSize: 20)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(30),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: MediaQuery.of(context).size.width * 0.07,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.login, color: Colors.white),
                    label: const Text('ВОЙТИ'),
                    onPressed: () {
                      login();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      textStyle:
                          const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              ),
            ])));
  }

  void login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var response = await AuthProvider()
        .login(emailController.text, passwordController.text);
    // TODO: Действие при авторизации пользователя...
    // print(response);
    if (response != 'Error') {
      print(response['access_token']);
      prefs.setString("token", response['access_token']);
      prefs.setInt("user_id", response['user']['id']);
      prefs.setString("full_name", response['user']['name']);
      prefs.setBool('isLogedIn', true);
      // print(response['token']);

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Something went wrong.", style: TextStyle(fontSize: 20)),
      ));
    }
  }

  void getFCMToken() {
    _firebaseMessaging.getToken().then((token) async {
      var response = await AuthProvider().sendDeviceToken(token!);
      // if (response != 'Error') print('Device token sent successfully!');
    });
  }

  void checkLogIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('isLogedIn') == true) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    }
  }
}
