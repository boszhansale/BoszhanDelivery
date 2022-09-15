class HistoryBasket {
  int productId = 0;
  String name = '';
  int price = 0;
  double allPrice = 0;
  int measureId = 0;
  double count = 0;
  int type = 0;
  String article = '';
  String refundReason = '';

  HistoryBasket({
    required this.productId,
    required this.name,
    required this.price,
    required this.allPrice,
    required this.measureId,
    required this.count,
    required this.type,
    required this.article,
    required this.refundReason,
  });

  HistoryBasket.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'];
    name = json['product']['name'];
    price = json['price'];
    allPrice = double.parse(json['all_price'].toString());
    measureId = json['product']['measure'];
    count = double.parse(json['count'].toString());
    type = json['type'];
    article = json['product']['article'];
    if (json['type'] == 1) {
      refundReason = json['reason_refund']['title'];
    } else {
      refundReason = '';
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['product_id'] = productId;
    data['product']['name'] = name;
    data['price'] = price;
    data['all_price'] = allPrice;
    data['product']['measure'] = measureId;
    data['count'] = count;
    data['type'] = type;
    return data;
  }
}
