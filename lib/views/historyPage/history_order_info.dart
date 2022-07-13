import 'package:boszhan_delivery_app/components/history_product_card.dart';
import 'package:boszhan_delivery_app/models/history_order.dart';
import 'package:boszhan_delivery_app/services/orders_api_provider.dart';
import 'package:boszhan_delivery_app/utils/const.dart';
import 'package:boszhan_delivery_app/views/historyPage/printing_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../home_page.dart';

class HistoryOrderInfoPage extends StatefulWidget {
  const HistoryOrderInfoPage(this.order);
  final HistoryOrder order;

  @override
  _HistoryOrderInfoPageState createState() => _HistoryOrderInfoPageState();
}

class _HistoryOrderInfoPageState extends State<HistoryOrderInfoPage> {
  bool isContainsReturns = false;
  bool isContainsDeliveryBasket = false;

  @override
  void initState() {
    for (var i in widget.order.basket) {
      if (i.type == 1) {
        setState(() {
          isContainsReturns = true;
        });
      } else {
        isContainsDeliveryBasket = true;
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            title: const Text('Выполненные заказы',
                style: TextStyle(color: Colors.white, fontSize: 20)),
            actions: <Widget>[
              widget.order.status == 3 || widget.order.status == 5
                  ? Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(15.0),
                                      topRight: Radius.circular(15.0))),
                              builder: (context) {
                                return Container(
                                  height:
                                      MediaQuery.of(context).size.height / 2,
                                  color: Colors.transparent,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.all(20),
                                        child: Text('Что вы хотите сделать?',
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: SizedBox(
                                          width: 400,
                                          height: 60,
                                          child: ElevatedButton.icon(
                                            icon: const Icon(
                                                Icons.my_library_books_rounded,
                                                color: Colors.white),
                                            label:
                                                const Text("Вернуть в текущие"),
                                            onPressed: () {
                                              changeStatus();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              primary: Colors.blue,
                                              textStyle: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18),
                                            ),
                                          ),
                                        ),
                                      ),
                                      isContainsDeliveryBasket
                                          ? Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: SizedBox(
                                                width: 400,
                                                height: 60,
                                                child: ElevatedButton.icon(
                                                  icon: const Icon(
                                                      Icons
                                                          .my_library_books_rounded,
                                                      color: Colors.white),
                                                  label: const Text(
                                                      "Расходная накладная"),
                                                  onPressed: () {
                                                    launch(AppConstants
                                                            .baseUrl +
                                                        'api/delivery-order/' +
                                                        widget.order.id
                                                            .toString() +
                                                        '/rnk');
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    primary: Colors.green,
                                                    textStyle: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Container(),
                                      isContainsReturns
                                          ? Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: SizedBox(
                                                width: 400,
                                                height: 60,
                                                child: ElevatedButton.icon(
                                                  icon: const Icon(
                                                      Icons
                                                          .assignment_return_sharp,
                                                      color: Colors.white),
                                                  label: const Text("Возвраты"),
                                                  onPressed: () {
                                                    launch(AppConstants
                                                            .baseUrl +
                                                        'api/delivery-order/' +
                                                        widget.order.id
                                                            .toString() +
                                                        '/vozvrat');
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    primary: Colors.red,
                                                    textStyle: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Container(),
                                      widget.order.paymentType == 1
                                          ? Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: SizedBox(
                                                width: 400,
                                                height: 60,
                                                child: ElevatedButton.icon(
                                                  icon: const Icon(
                                                      Icons.fact_check,
                                                      color: Colors.white),
                                                  label: const Text("ПКО"),
                                                  onPressed: () {
                                                    launch(AppConstants
                                                            .baseUrl +
                                                        'api/delivery-order/' +
                                                        widget.order.id
                                                            .toString() +
                                                        '/pko');
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    primary: Colors.grey,
                                                    textStyle: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Container(),
                                    ],
                                  ),
                                );
                              });
                        },
                        child: const Icon(Icons.print),
                      ))
                  : const SizedBox(),
            ],
            automaticallyImplyLeading: true,
            backgroundColor: Colors.red,
            shadowColor: Colors.white,
            bottomOpacity: 1,
            iconTheme: const IconThemeData(color: Colors.white)),
        body: ListView.separated(
            itemCount: widget.order.basket.length,
            itemBuilder: (BuildContext context, int index) =>
                widget.order.basket[index].type == 0
                    ? HistoryProductCard(widget.order.basket[index])
                    : Ink(
                        color: Colors.red[50],
                        child: HistoryProductCard(widget.order.basket[index])),
            separatorBuilder: (context, index) {
              return const Divider();
            }));
  }

  void toPrint() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => Print(widget.order.basket)));
  }

  void changeStatus() async {
    OrdersProvider()
        .changeStatus(widget.order.id.toString(), 2)
        .whenComplete(() => Navigator.pushAndRemoveUntil<dynamic>(
            context,
            MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => HomePage(),
            ),
            (route) => false));
  }
}
