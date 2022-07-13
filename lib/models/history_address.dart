class Address {
  String latitude = '';
  String longitude = '';
  String deliveryTime = '';

  Address({
    required this.latitude,
    required this.longitude,
    required this.deliveryTime
  });

  Address.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'];
    longitude = json['longitude'];
    deliveryTime = json['delivery_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['delivery_time'] = deliveryTime;
    return data;
  }
}