import 'history_basket.dart';

class HistoryOrder {
  String name = '';
  String storeAddress = '';
  int id = 0;
  int userId = 0;
  String deliveryTime = '';
  List<HistoryBasket> basket = [];
  // Address address = Address(latitude: '', longitude: '', deliveryTime: '');
  String createdAt = '';
  // String updatedAt = '';
  int storeId = 0;
  var deliveredAt;
  // var deletedAt;
  int status = 0;
  int paymentType = 0;
  int paymentStatus = 0;
  String driverName = '';
  double purchasePrice = 0;
  double returnPrice = 0;
  int salesRepId = 0;
  String salesRepName = '';

  HistoryOrder(
      {required this.name,
      required this.storeAddress,
      required this.id,
      required this.userId,
      required this.deliveryTime,
      required this.basket,
      // required this.address,
      required this.createdAt,
      // required this.updatedAt,
      required this.storeId,
      this.deliveredAt,
      // this.deletedAt,
      required this.status,
      required this.paymentType,
      required this.paymentStatus,
      required this.driverName,
      required this.purchasePrice,
      required this.returnPrice,
      required this.salesRepId,
      required this.salesRepName});

  HistoryOrder.fromJson(Map<String, dynamic> json) {
    name = json['store']['name'];
    storeAddress = json['store']['address'];
    id = json['id'];
    userId = json['salesrep']['id'];
    deliveryTime = json['delivery_date'];
    if (json['baskets'] != null) {
      basket = <HistoryBasket>[];
      json['baskets'].forEach((v) {
        basket.add(HistoryBasket.fromJson(v));
      });
    }
    // address =
    //     (json['address'] != null ? Address.fromJson(json['address']) : null)!;
    createdAt = json['created_at'];
    // updatedAt = json['updated_at'];
    storeId = json['store']['id'];
    deliveredAt = json['delivered_at'];
    // deletedAt = json['deleted_at'];
    status = json['status']['id'];
    paymentType = json['payment_type']['id'];
    paymentStatus = json['payment_status']['id'];
    driverName = json['driver']['name'];
    purchasePrice = double.parse(json['purchase_price'].toString());
    returnPrice = double.parse(json['return_price'].toString());
    salesRepId = json['salesrep']['id'];
    salesRepName = json['salesrep']['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['store_name'] = name;
    data['store_address'] = storeAddress;
    data['id'] = id;
    data['user_id'] = userId;
    data['delivery_time'] = deliveryTime;
    data['basket'] = basket.map((v) => v.toJson()).toList();
    // data['address'] = address.toJson();
    data['created_at'] = createdAt;
    // data['updated_at'] = updatedAt;
    data['store_id'] = storeId;
    data['delivered_at'] = deliveredAt;
    // data['deleted_at'] = deletedAt;
    data['status'] = status;
    data['payment_type'] = paymentType;
    data['payment_status'] = paymentStatus;
    return data;
  }
}
