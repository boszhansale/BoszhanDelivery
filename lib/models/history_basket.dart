class HistoryBasket {
  int productId = 0;
  String name = '';
  int price = 0;
  double allPrice = 0;
  int measureId = 0;
  double count = 0;
  int type = 0;

  HistoryBasket({
    required this.productId,
    required this.name,
    required this.price,
    required this.allPrice,
    required this.measureId,
    required this.count,
    required this.type
  });

  HistoryBasket.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'];
    name = json['name'];
    price = json['price'];
    allPrice = double.parse(json['all_price'].toString());
    measureId = json['measure_id'];
    count = double.parse(json['count'].toString());
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['product_id'] = productId;
    data['name'] = name;
    data['price'] = price;
    data['all_price'] = allPrice;
    data['measure_id'] = measureId;
    data['count'] = count;
    data['type'] = type;
    return data;
  }
}