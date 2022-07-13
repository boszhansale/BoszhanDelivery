class Basket {
  int id = 0;
  int categoryId = 0;
  int measureId = 0;
  String name = '';
  int price = 0;
  int productId = 0;
  int type = 0;
  double allPrice = 0;
  double count = 0;
  bool isChecked = false;

  Basket(
      {required this.id,
      required this.categoryId,
      required this.measureId,
      required this.name,
      required this.price,
      required this.productId,
      required this.type,
      required this.allPrice,
      required this.count});

  Basket.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    categoryId = json['product']['category_id'];
    measureId = json['product']['measure'];
    name = json['product']['name'];
    price = json['price'];
    productId = json['product_id'];
    type = json['type'];
    allPrice = double.parse(json['all_price'].toString());
    count = double.parse(json['count'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['category_id'] = categoryId;
    data['measure_id'] = measureId;
    data['name'] = name;
    data['price'] = price;
    data['product_id'] = productId;
    data['type'] = type;
    data['all_price'] = allPrice;
    data['count'] = count;
    return data;
  }
}
