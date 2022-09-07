import 'basket.dart';

class Order {
  int id = 0;
  // int orderId = 0;
  int status = 0;
  List<Basket> basket = [];
  String deliveryAt = '';
  String storeName = '';
  int storeId = 0;
  String storeAddress = '';
  var storeLat = '';
  var storeLng = '';
  double totalCost = 0;
  double totalReturnsCost = 0;
  // String counterpartyName = '';
  String driverName = '';
  int bonusGameSum = 0;
  int paymentTypeId = 1;
  double purchasePrice = 0;
  double returnPrice = 0;

  Order(
      {required this.id,
      // required this.orderId,
      required this.status,
      required this.basket,
      required this.deliveryAt,
      required this.storeName,
      required this.storeId,
      required this.storeAddress,
      required this.storeLat,
      required this.storeLng,
      required this.totalCost,
      required this.totalReturnsCost,
      // required this.counterpartyName,
      required this.driverName,
      required this.bonusGameSum,
      required this.paymentTypeId,
      required this.purchasePrice,
      required this.returnPrice});

  Order.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    // orderId = json['order_id'];
    status = json['status']['id'];
    if (json['baskets'] != null) {
      basket = <Basket>[];
      json['baskets'].forEach((v) {
        basket.add(Basket.fromJson(v));
      });
    }
    deliveryAt = json['delivery_date'];
    storeName = json['store']['name'];
    storeId = json['store']['id'];
    storeAddress = json['store']['address'];
    if (json['store']['lat'] != null) {
      storeLat = json['store']['lat'];
    }
    if (json['store']['lng'] != null) {
      storeLng = json['store']['lng'];
    }
    totalCost = double.parse(json['purchase_price'].toString());
    totalReturnsCost = double.parse(json['return_price'].toString());
    // counterpartyName = json['counterparty_name'];
    driverName = json['driver']['name'];
    bonusGameSum = json['bonus_game_sum'];
    paymentTypeId = json['payment_type']['id'];
    purchasePrice = double.parse(json['purchase_price'].toString());
    returnPrice = double.parse(json['return_price'].toString());
  }

  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = <String, dynamic>{};
  //   data['id'] = id;
  //   // data['order_id'] = orderId;
  //   data['status_id'] = status;
  //   data['basket'] = basket.map((v) => v.toJson()).toList();
  //   data['delivery_date'] = deliveryAt;
  //   data['store_name'] = storeName;
  //   data['store_id'] = storeId;
  //   data['store_address'] = storeAddress;
  //   data['purchase_price'] = totalCost;
  //   data['return_price'] = totalReturnsCost;
  //   // data['counterparty_name'] = counterpartyName;
  //   data['bonus_game_sum'] = bonusGameSum;
  //   data['payment_status_name'] = paymentTypeId;
  //   return data;
  // }
}
