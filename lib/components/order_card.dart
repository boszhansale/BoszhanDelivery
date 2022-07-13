import 'package:boszhan_delivery_app/models/order.dart';
import 'package:boszhan_delivery_app/utils/const.dart';
import 'package:boszhan_delivery_app/views/currentPage/order_info_page.dart';
import 'package:boszhan_delivery_app/views/map/map_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

List<String> paymentTypeNames = [
  "💵Наличный",
  "💳Без наличный",
  "📆Отсрочка",
  "🏦Каспи"
];

class OrderCard extends StatelessWidget {
  const OrderCard(this.order);
  final Order order;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: const CircleAvatar(
            backgroundColor: Colors.amber,
            child: Icon(
              Icons.shopping_basket,
              color: Colors.white,
            )),
        title: Text('Название: ' + order.storeName,
            style: const TextStyle(fontSize: 20)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Адрес: ' + order.storeAddress,
                style: const TextStyle(fontSize: 20)),
            Text('Cпособ оплаты: ' + paymentTypeNames[order.paymentTypeId - 1],
                style: const TextStyle(fontSize: 20)),
            Text('ID: ' + order.id.toString(),
                style: const TextStyle(fontSize: 20)),
            Text('Количество: ' + order.basket.length.toString(),
                style: const TextStyle(fontSize: 20)),
          ],
        ),
        trailing: const Icon(Icons.keyboard_arrow_right),
        onTap: () {
          showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15.0),
                      topRight: Radius.circular(15.0))),
              builder: (context) {
                return Container(
                  height: MediaQuery.of(context).size.height / 2.5,
                  color: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('Что вы хотите сделать?',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: SizedBox(
                          width: 400,
                          height: 60,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.open_in_full,
                                color: Colors.white),
                            label: const Text("ОТКРЫТЬ ЗАКАЗ"),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          OrderInfoPage(order)));
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.green,
                              textStyle: const TextStyle(
                                  color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: SizedBox(
                          width: 400,
                          height: 60,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.print, color: Colors.white),
                            label: const Text("ПЕЧАТЬ"),
                            onPressed: () {
                              launch(AppConstants.baseUrl +
                                  'api/delivery-order/' +
                                  order.id.toString() +
                                  '/before/rnk');
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.blue,
                              textStyle: const TextStyle(
                                  color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: SizedBox(
                          width: 400,
                          height: 60,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.location_pin,
                                color: Colors.white),
                            label: const Text("ПОКАЗАТЬ НА КАРТЕ"),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const MapPage()));
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.grey,
                              textStyle: const TextStyle(
                                  color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              });
        });
  }
}
