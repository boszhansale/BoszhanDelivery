import 'package:boszhan_delivery_app/models/history_order.dart';
import 'package:boszhan_delivery_app/views/historyPage/history_order_info.dart';
import 'package:flutter/material.dart';

class HistoryOrderCard extends StatelessWidget {
  const HistoryOrderCard(this.order);
  final HistoryOrder order;

  @override
  Widget build(BuildContext context) {
    List<String> paymentsList = [
      'Наличный',
      'Без наличный',
      'Отсрочка платежа',
      'Kaspi.kz',
    ];

    List<String> paymentStatus = ['Оплачено', 'Не оплачено', 'Отменен'];

    // return _buildTiles(entry);
    return ListTile(
        leading: const CircleAvatar(
            backgroundColor: Colors.amber,
            child: Icon(
              Icons.shopping_basket,
              color: Colors.white,
            )),
        title: Text('Название: ' + order.name,
            style: const TextStyle(fontSize: 20)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Адрес: ' + order.storeAddress,
                style: const TextStyle(fontSize: 20)),
            Text('Способ оплаты: ' + paymentsList[order.paymentType - 1],
                style: const TextStyle(fontSize: 20)),
            Text('Статус оплаты: ' + paymentStatus[order.paymentStatus - 1],
                style: const TextStyle(fontSize: 20)),
          ],
        ),
        trailing: const Icon(Icons.keyboard_arrow_right),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HistoryOrderInfoPage(order)));
        });
  }
}
