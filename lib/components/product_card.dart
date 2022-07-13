import 'package:boszhan_delivery_app/models/basket.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  const ProductCard(this.basket, this.index);
  final int index;
  final Basket basket;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: const CircleAvatar(
            backgroundColor: Colors.amber,
            child: Icon(
              Icons.shopping_cart_outlined,
              color: Colors.white,
            )),
        title: Text(
          (index + 1).toString() + '. ' + basket.name,
          style: TextStyle(fontSize: 20),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                Text(
                    'Количество: ' +
                        basket.count.toString() +
                        (basket.measureId == 1 ? ' шт' : ' кг'),
                    style: TextStyle(fontSize: 18)),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('Цена(шт,кг):  ' + basket.price.toString() + ' ₸',
                      style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('Общая сумма:  ' + basket.allPrice.toString() + ' ₸',
                  style: TextStyle(fontSize: 18)),
            )
          ],
        ),
        onTap: () {});
  }
}
