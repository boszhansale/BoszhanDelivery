// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:sqflite/sqflite.dart';
// import 'package:boszhan_delivery_app/models/order.dart';
// import 'package:boszhan_delivery_app/models/basket.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart';
//
//
// class DatabaseHelper {
//   DatabaseHelper._privateConstructor();
//   static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
//
//   static Database? _database;
//   Future<Database> get database async => _database ??= await _initDatabase();
//
//
//   Future<Database> _initDatabase() async {
//     Directory documentsDirectory = await getApplicationDocumentsDirectory();
//     String path = join(documentsDirectory.path, 'orders.db');
//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: _onCreate,
//     );
//   }
//
//   Future _onCreate(Database db, int version) async {
//     await db.execute('''
//       CREATE TABLE orders(
//           id INTEGER PRIMARY KEY,
//           orderId INTEGER ,
//           name TEXT,
//       )
//       ''');
//   }
//
//
//   // Future<List<Order>> getGroceries() async {
//   //   Database db = await instance.database;
//   //   var orders = await db.query('orders', orderBy: 'name');
//   //   List<Order> orderList = orders.isNotEmpty
//   //       ? orders.map((e) => Order.fromMap(e)).toList()
//   //       : [];
//   //   return orderList;
//   // }
//   //
//   // Future<int> add(Grocery grocery) async {
//   //   Database db = await instance.database;
//   //   return await db.insert('groceries', grocery.toMap());
//   // }
//
//   // Future<int> remove(int id) async {
//   //   Database db = await instance.database;
//   //   return await db.delete('groceries', where: 'id = ?', whereArgs: [id]);
//   // }
//   //
//   // Future<int> update(Grocery grocery) async {
//   //   Database db = await instance.database;
//   //   return await db.update('groceries', grocery.toMap(),
//   //       where: "id = ?", whereArgs: [grocery.id]);
//   // }
//
// }