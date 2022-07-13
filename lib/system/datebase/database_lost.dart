// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
//
// import 'package:boszhan_delivery_app/models/order.dart';
// import 'package:boszhan_delivery_app/models/basket.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:sqflite/sqflite.dart';
//
// class DBProvider {
//   DBProvider._();
//   static final DBProvider db = DBProvider._();
//
//   Database _database;
//
//   Future<Database> get database async {
//     if (_database != null) return _database;
//     // if _database is null we instantiate it
//     _database = await initDB();
//     return _database;
//   }
//
//   initDB() async {
//     Directory documentsDirectory = await getApplicationDocumentsDirectory();
//     String path = join(documentsDirectory.path, "TestDB.db");
//     return await openDatabase(path, version: 1, onOpen: (db) {}, onCreate: (Database db, int version) async {
//       await db.execute("CREATE TABLE Products ("
//           "id INTEGER PRIMARY KEY,"
//           "id_1c TEXT,"
//           "article INTEGER,"
//           "brand_id INTEGER,"
//           "category_id INTEGER,"
//           "measure_id INTEGER,"
//           "name_1c TEXT,"
//           "name TEXT,"
//           "price INTEGER,"
//           "remainder INTEGER,"
//           "enabled BOOLEAN,"
//           "rating INTEGER,"
//           "presale_id INTEGER,"
//           "image_big TEXT,"
//           "image TEXT"
//           ")");
//       await db.execute("CREATE TABLE Orders ("
//           "mobile_id TEXT,"
//           "basket TEXT,"
//           "shop_addr TEXT,"
//           "shop_name TEXT,"
//           "shop_phone TEXT,"
//           "shop_bin TEXT,"
//           "latitude TEXT,"
//           "longitude TEXT,"
//           "price INTEGER,"
//           "status INTEGER DEFAULT 0,"
//           "time String,"
//           "return_price INTEGER"
//           ")");
//     });
//   }
// //
// //   Future<List<Product>> getAllProducts() async {
// //     final db = await database;
// //     var res = await db.query("Products");
// //     List<Product> products = [];
// //     products = res.isNotEmpty ? res.map((c) => Product.fromMap(c)).toList() : [];
// //     return products;
// //   }
// //
// //
// //   Future getAllOrders() async {
// //     final db = await database;
// //     var res = await db.query(
// //       "Orders",
// //       orderBy: "time DESC",
// //     );
// //     List<Order> orders = [];
// //     orders = res.isNotEmpty ? res.map((c) => Order.fromMap(c)).toList() : [];
// //     List<dynamic> allDates = [];
// //
// //     orders.forEach((order) {
// //       allDates.add(order.time);
// //     });
// //     // allDates = allDates.toSet().toList();
// //     allDates = allDates.toSet().toList();
// //     List<dynamic> finalList = [];
// //     allDates.forEach((date) {
// //       List<dynamic> dateOrders = [];
// //       dateOrders = orders.where((order) => order.time == date).toList();
// //       int sumOrders = 0;
// //       int sumReturnOrders = 0;
// //       dateOrders.forEach((order) {
// //         sumOrders += order.price;
// //         sumReturnOrders += order.return_price;
// //       });
// //       finalList.add({"date": date, "sum": sumOrders, "return_sum": sumReturnOrders, "orders": dateOrders});
// //
// //       // dateOrders.add([sumOrders]);
// //       print("1241dateOrders");
// //       print(dateOrders);
// //       // finalList[];
// //     });
// //     print("finalList");
// //     print(finalList);
// //     print("finalList");
// //
// //     return finalList;
// //   }
// //
// //   Future<List<Order>> getAllOrderNotSendToServer() async {
// //     final db = await database;
// //     var res = await db.rawQuery("SELECT * FROM Orders where status=?", [0]);
// //     List<Order> orders = [];
// //     orders = res.isNotEmpty ? res.map((c) => Order.fromMap(c)).toList() : [];
// //     return orders;
// //   }
// //
// //   Future getOrderById(String orderId) async {
// //     final db = await database;
// //     var res = await db.rawQuery("SELECT * FROM Orders where mobile_id=?", [orderId]);
// //     List<Order> orders = [];
// //     orders = res.isNotEmpty ? res.map((c) => Order.fromMap(c)).toList() : [];
// //     return orders;
// //   }
// //
// //   newOrder(Order order) async {
// //     final db = await database;
// //     var raw = await db.rawInsert(
// //         "INSERT OR REPLACE INTO Orders (mobile_id,basket,shop_addr,shop_name,shop_phone,shop_bin,latitude,longitude,price,status,time,return_price)"
// //             " VALUES (?,?,?,?,?,?,?,?,?,?,?,?)",
// //         [
// //           order.mobile_id,
// //           jsonEncode(order.basket),
// //           order.shop_addr,
// //           order.shop_name,
// //           order.shop_phone,
// //           order.shop_bin,
// //           order.latitude,
// //           order.longitude,
// //           order.price,
// //           0,
// //           DateFormat('MM-dd-yy').format(DateTime.now()),
// //           order.return_price
// //         ]);
// //     return raw;
// //   }
// //
// //   updateOrder(Order order) async {
// //     final db = await database;
// //     var res = await db.update("Orders", order.toMap(), where: "mobile_id = ?", whereArgs: [order.mobile_id]);
// //     return res;
// //   }
// //
// //   removeOrderByPhone(String shop_phone) async {
// //     final db = await database;
// //     await db.rawDelete("DELETE FROM Orders WHERE shop_phone = $shop_phone");
// //   }
// //
// //   removeOrderByMobileId(String mobileId) async {
// //     final db = await database;
// //     await db.rawQuery("DELETE FROM Orders WHERE mobile_id=?", [mobileId]);
// //   }
//
//
//
// //   getProductsByFilters(int brandId, int categoryId, int page) async {
// //     final db = await database;
// //     var res = await db.rawQuery("SELECT * FROM Products WHERE brand_id=? AND category_id=?", [brandId, categoryId]);
// //     List<Product> products = [];
// //     products = res.isNotEmpty ? res.map((c) => Product.fromMap(c)).toList() : [];
// //     return products;
// //   }
// //
// }
