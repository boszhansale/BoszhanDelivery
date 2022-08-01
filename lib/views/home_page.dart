import 'dart:convert';

import 'package:boszhan_delivery_app/models/history_order.dart';
import 'package:boszhan_delivery_app/services/auth_api_provider.dart';
import 'package:boszhan_delivery_app/services/history_api_provider.dart';
import 'package:boszhan_delivery_app/services/orders_api_provider.dart';
import 'package:boszhan_delivery_app/views/currentPage/current_orders_page.dart';
import 'package:boszhan_delivery_app/views/historyPage/orders_history_page.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/version_check_provider.dart';
import '../utils/const.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String name = '';
  String nal = '';
  String bezNal = '';

  bool newVersion = false;
  String version = '0.1';

  @override
  void initState() {
    downloadAction();
    getProfileInfo();
    checkVersion();
    super.initState();

    // flutterLocalNotificationsPlugin.show(0, "Testing", "Hello user?",
    //   NotificationDetails(
    //       android: AndroidNotificationDetails(channel.id, channel.name,
    //           importance: Importance.high,
    //           color: Colors.blue,
    //           playSound: true,
    //           icon: '@mipmap/ic_launcher')
    //   )
    // );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Scaffold(
          appBar: AppBar(
              elevation: 0,
              centerTitle: true,
              title: Text('Доставка',
                  style: TextStyle(color: Colors.white, fontSize: 20)),
              automaticallyImplyLeading: true,
              backgroundColor: Colors.red,
              bottomOpacity: 1,
              iconTheme: IconThemeData(color: Colors.white)),
          body: SingleChildScrollView(
            child: Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    newVersion
                        ? Column(
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              Text("Доступна новая версия!"),
                              SizedBox(
                                height: 20,
                              ),
                              SizedBox(
                                width: 300,
                                height: 80,
                                child: ElevatedButton(
                                  child: const Text(
                                    'Скачать',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.black),
                                  ),
                                  onPressed: () {
                                    downloadNewVersion();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.red,
                                    textStyle: const TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : SizedBox(),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Text('Версия: $version',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 0),
                      child: Text('Имя водителя: ' + name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: Text('Наличные: ' + nal,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 0),
                      child: Text('Безналичные: ' + bezNal,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    Image.asset("assets/images/logo.png",
                        width: MediaQuery.of(context).size.width * 0.4),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 300,
                        height: 80,
                        child: ElevatedButton(
                          child: const Text("ТЕКУЩИЕ"),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CurrentOrdersPage()));
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.red,
                            textStyle: const TextStyle(
                                color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 300,
                        height: 80,
                        child: ElevatedButton(
                          child: const Text("ВЫПОЛНЕННЫЕ"),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => OrdersHistoryPage()));
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.red,
                            textStyle: const TextStyle(
                                color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 300,
                        height: 80,
                        child: ElevatedButton(
                          child: const Text("ЗАГРУЗИТЬ"),
                          onPressed: () {
                            downloadAction();
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.blue,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 60, vertical: 20),
                            textStyle: const TextStyle(
                                color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                    )
                  ],
                )),
          ),
        ));
  }

  void downloadAction() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      downloadProcess();
      downloadProcessForHistory();
    } else if (connectivityResult == ConnectivityResult.wifi) {
      downloadProcess();
      downloadProcessForHistory();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Соединение с интернетом отсутствует.",
            style: TextStyle(fontSize: 20)),
      ));
    }
  }

  void downloadProcess() async {
    var response = await OrdersProvider().getDeliveryOrders();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (response != 'Error') {
      var jsonString = jsonEncode(response);
      prefs.setString('DownloadedData', jsonString);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Something went wrong.", style: TextStyle(fontSize: 20)),
      ));
    }
  }

  void downloadProcessForHistory() async {
    var response = await HistoryProvider().getDeliveredOrders();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (response != 'Error') {
      List<HistoryOrder> list = <HistoryOrder>[];

      for (Map<String, dynamic> i in response) {
        HistoryOrder order = HistoryOrder.fromJson(i);
        list.add(order);
      }

      var jsonString = jsonEncode(response);
      prefs.setString('DownloadedHistoryData', jsonString);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Something went wrong.", style: TextStyle(fontSize: 20)),
      ));
    }
  }

  void getProfileInfo() async {
    var response = await AuthProvider().getProfileInfo(1);
    if (response != 'Error') {
      setState(() {
        name = response['full_name'];
        nal = response['cash'].toString() + ' тг.';
        bezNal = response['card'].toString() + ' тг.';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Something went wrong.", style: TextStyle(fontSize: 20)),
      ));
    }
  }

  void downloadNewVersion() async {
    launch(AppConstants.baseUrl + 'api/mobile-app/download?type=2');
  }

  void checkVersion() async {
    var result = await VersionCheckProvider().check();

    if (result != 'Error') {
      if (result['version'] != '0.6') {
        setState(() {
          newVersion = true;
          version = result['version'];
        });
      } else {
        setState(() {
          newVersion = false;
          version = result['version'];
        });
      }
    } else {
      print('Error');
    }
  }
}
