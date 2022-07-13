import 'package:boszhan_delivery_app/models/history_basket.dart';
import 'package:flutter/material.dart';

class HistoryProductCard extends StatelessWidget{
  const HistoryProductCard(this.basket);
  final HistoryBasket basket;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: const CircleAvatar(
            backgroundColor: Colors.amber,
            child: Icon(Icons.shopping_cart_outlined, color: Colors.white,)
        ),
        title: Text(basket.name, style: TextStyle(fontSize: 20),),
        subtitle: Row(
          children: [
            Text('Количество: ' + basket.count.toString(), style: TextStyle(fontSize: 18)),
            Spacer(),
            Text('Сумма:  ' + basket.price.toString() + ' ₸', style: TextStyle(fontSize: 18))
          ],
        ),
        onTap: (){}
    );
  }
}