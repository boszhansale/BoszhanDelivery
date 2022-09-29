import 'dart:convert';

import 'package:boszhan_delivery_app/components/order_card.dart';
import 'package:boszhan_delivery_app/models/order.dart';
import 'package:boszhan_delivery_app/views/map/map_page.dart';
import 'package:boszhan_delivery_app/widgets/app_bar.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/auth_api_provider.dart';

class CurrentOrdersPage extends StatefulWidget {
  @override
  _CurrentOrdersPageState createState() => _CurrentOrdersPageState();
}

class _CurrentOrdersPageState extends State<CurrentOrdersPage> {
  List<Order> orders = <Order>[];
  String name = '';

  @override
  void initState() {
    getOrders();
    getProfileInfo();
    super.initState();
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
          appBar: PreferredSize(
              preferredSize: Size.fromHeight(60.0),
              child: buildAppBar('Текущие заказы')),
          body: Column(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 160,
                child: ListView.separated(
                    itemCount: orders.length,
                    itemBuilder: (BuildContext context, int index) =>
                        OrderCard(orders[index]),
                    separatorBuilder: (context, index) {
                      return Divider();
                    }),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 70,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: ElevatedButton(
                    child: const Text("МАРШРУТ"),
                    onPressed: () {
                      if (orders.length > 0) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MapPage(orders)));
                      } else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Список заказов пуст.",
                              style: TextStyle(fontSize: 20)),
                        ));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      textStyle:
                          const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }

  void getOrders() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      downloadData();
    } else if (connectivityResult == ConnectivityResult.wifi) {
      downloadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Соединение с интернетом отсутствует.",
            style: TextStyle(fontSize: 20)),
      ));
    }
  }

  void downloadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('DownloadedData') != null) {
      List<dynamic> downloadedData =
          jsonDecode(prefs.getString('DownloadedData')!);
      List<Order> list = <Order>[];

      for (Map<String, dynamic> i in downloadedData) {
        Order order = Order.fromJson(i);
        list.add(order);
      }

      setState(() {
        orders = list;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Загрузите данные.", style: TextStyle(fontSize: 20)),
      ));
    }
  }

  void getProfileInfo() async {
    var response = await AuthProvider().getProfileInfo(1);
    if (response != 'Error') {
      setState(() {
        name = response['full_name'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Something went wrong.", style: TextStyle(fontSize: 20)),
      ));
    }
  }
}
