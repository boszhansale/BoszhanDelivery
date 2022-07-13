import 'dart:convert';
import 'package:boszhan_delivery_app/components/history_order_card.dart';
import 'package:boszhan_delivery_app/models/history_order.dart';
import 'package:boszhan_delivery_app/widgets/app_bar.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrdersHistoryPage extends StatefulWidget {
  // OrdersHistoryPage(this.product);
  // final Product product;

  @override
  _OrdersHistoryPageState createState() => _OrdersHistoryPageState();
}

class _OrdersHistoryPageState extends State<OrdersHistoryPage> {

  List<HistoryOrder> orders = <HistoryOrder>[];
  int orderCount = 0;

  @override
  void initState() {
    getOrders();
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
              child: buildAppBar('Выполненные заказы')
          ),
          body: ListView.separated(itemCount: orderCount,
              itemBuilder: (BuildContext context, int index) => orders[index].status == 3 ? HistoryOrderCard(orders[index]) : Ink(color: Colors.red[50], child: HistoryOrderCard(orders[index])),
              separatorBuilder: (context, index){
                return const Divider();
              }
          ),
        )
    );
  }


  void getOrders() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      downloadData();
    } else if (connectivityResult == ConnectivityResult.wifi) {
      downloadData();
    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Соединение с интернетом отсутствует.", style: TextStyle(fontSize: 20)),
      ));
    }
  }

  void downloadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('DownloadedHistoryData') != null){
      List<dynamic> downloadedData = jsonDecode(prefs.getString('DownloadedHistoryData')!);
      List<HistoryOrder> list = <HistoryOrder>[];

      for (Map<String, dynamic> i in downloadedData){
        HistoryOrder order = HistoryOrder.fromJson(i);
        list.add(order);
      }

      setState(() {
        orders = list;
        orderCount = list.length;
      });
    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Загрузите данные.", style: TextStyle(fontSize: 20)),
      ));
    }
  }


}