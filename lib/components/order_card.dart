import 'dart:io';

import 'package:boszhan_delivery_app/models/order.dart';
import 'package:boszhan_delivery_app/views/currentPage/order_info_page.dart';
import 'package:boszhan_delivery_app/views/map/order_map_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

List<String> paymentTypeNames = [
  "💵Наличный",
  "💳Без наличный",
  "📆Отсрочка",
  "🏦Каспи"
];

class OrderCard extends StatelessWidget {
  const OrderCard(this.order);
  final Order order;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: const CircleAvatar(
            backgroundColor: Colors.amber,
            child: Icon(
              Icons.shopping_basket,
              color: Colors.white,
            )),
        title: Text('Название: ' + order.storeName,
            style: const TextStyle(fontSize: 20)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Адрес: ' + order.storeAddress,
                style: const TextStyle(fontSize: 20)),
            Text('Cпособ оплаты: ' + paymentTypeNames[order.paymentTypeId - 1],
                style: const TextStyle(fontSize: 20)),
            Text('ID: ' + order.id.toString(),
                style: const TextStyle(fontSize: 20)),
            Text('Количество: ' + order.basket.length.toString(),
                style: const TextStyle(fontSize: 20)),
          ],
        ),
        trailing: const Icon(Icons.keyboard_arrow_right),
        onTap: () {
          showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15.0),
                      topRight: Radius.circular(15.0))),
              builder: (context) {
                return Container(
                  height: MediaQuery.of(context).size.height / 2.5,
                  color: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('Что вы хотите сделать?',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: SizedBox(
                          width: 400,
                          height: 60,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.open_in_full,
                                color: Colors.white),
                            label: const Text("ОТКРЫТЬ ЗАКАЗ"),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          OrderInfoPage(order)));
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.green,
                              textStyle: const TextStyle(
                                  color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: SizedBox(
                          width: 400,
                          height: 60,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.print, color: Colors.white),
                            label: const Text("ПЕЧАТЬ"),
                            onPressed: () {
                              // launch(AppConstants.baseUrl +
                              //     'api/delivery-order/' +
                              //     order.id.toString() +
                              //     '/before/rnk');
                              createRNK();
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.blue,
                              textStyle: const TextStyle(
                                  color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: SizedBox(
                          width: 400,
                          height: 60,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.location_pin,
                                color: Colors.white),
                            label: const Text("ПОКАЗАТЬ НА КАРТЕ"),
                            onPressed: () {
                              if (order.storeLat != '' &&
                                  order.storeLng != '') {
                                // launch(
                                //     'dgis://2gis.ru/routeSearch/rsType/car/to/${order.storeLng},${order.storeLat}');

                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            OrderMapPage(order)));
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text("Отсутствуют координаты!",
                                      style: TextStyle(fontSize: 20)),
                                ));
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.grey,
                              textStyle: const TextStyle(
                                  color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              });
        });
  }

  void createRNK() async {
    print(order.basket);
    final pdf = pw.Document();
    // final Uint8List fontRegular = File(aw()).readAsBytesSync();

    double fontSize = 6;
    double mediumFontSize = 7;
    double bigFontSize = 8;

    final font = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(font);

    final fontThin = await rootBundle.load("assets/fonts/Roboto-Thin.ttf");
    final ttfThin = pw.Font.ttf(fontThin);

    // final fontBold = await rootBundle.load("assets/fonts/Roboto-Bold.ttf");
    // final ttfBold = pw.Font.ttf(fontBold);

    double totalCount = 0;
    double totalPrice = 0;
    double totalCost = 0;

    int num = 0;

    for (int i = 0; i < order.basket.length; i++) {
      totalCount += order.basket[i].count;
      if (order.basket[i].type == 0) {
        totalPrice += order.basket[i].price;
        totalCost += order.basket[i].price * order.basket[i].count;
      } else {
        totalPrice -= order.basket[i].price;
        totalCost -= order.basket[i].price * order.basket[i].count;
      }
    }

    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("№${order.id} от ${order.deliveryAt}",
                  style: pw.TextStyle(
                      font: ttf,
                      fontSize: bigFontSize,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Table(border: pw.TableBorder.all(), columnWidths: {
                0: pw.FixedColumnWidth(10),
                1: pw.FixedColumnWidth(150),
                2: pw.FixedColumnWidth(35),
                3: pw.FixedColumnWidth(20),
                4: pw.FixedColumnWidth(30),
                5: pw.FixedColumnWidth(30),
                // 6: pw.FixedColumnWidth(30),
              }, children: [
                pw.TableRow(children: [
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(" № ",
                            style: pw.TextStyle(font: ttf, fontSize: fontSize)),
                      ]),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(" Наименование",
                            style: pw.TextStyle(font: ttf, fontSize: fontSize)),
                      ]),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text("Артикул",
                            style: pw.TextStyle(font: ttf, fontSize: fontSize)),
                      ]),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text("Ед.",
                            style: pw.TextStyle(font: ttf, fontSize: fontSize)),
                      ]),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text("Кол",
                            style: pw.TextStyle(font: ttf, fontSize: fontSize)),
                      ]),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text("Цена",
                            style: pw.TextStyle(font: ttf, fontSize: fontSize)),
                      ]),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text("Сумма с НДС",
                            style: pw.TextStyle(font: ttf, fontSize: fontSize)),
                      ]),
                ]),
                for (var i = 0; i < order.basket.length; i++)
                  order.basket[i].type == 1
                      ? pw.TableRow(children: [
                          pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              children: [
                                pw.Text((num += 1).toString(),
                                    style: pw.TextStyle(
                                        fontSize: fontSize, font: ttfThin)),
                              ]),
                          pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                                pw.Text(order.basket[i].name,
                                    style: pw.TextStyle(
                                        fontSize: fontSize, font: ttfThin)),
                              ]),
                          pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                                pw.Text(order.basket[i].article,
                                    style: pw.TextStyle(
                                        fontSize: fontSize, font: ttfThin)),
                              ]),
                          pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                                pw.Text(
                                    order.basket[i].measureId == 1
                                        ? "шт"
                                        : "кг",
                                    style: pw.TextStyle(
                                        fontSize: fontSize, font: ttfThin)),
                              ]),
                          pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                                pw.Text(order.basket[i].count.toString(),
                                    style: pw.TextStyle(
                                        fontSize: fontSize, font: ttfThin)),
                              ]),
                          pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              children: [
                                pw.Text(order.basket[i].price.toString(),
                                    style: pw.TextStyle(
                                        fontSize: fontSize, font: ttfThin)),
                              ]),
                          pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              children: [
                                pw.Text(
                                    (order.basket[i].count *
                                            order.basket[i].price)
                                        .toInt()
                                        .toString(),
                                    style: pw.TextStyle(
                                        fontSize: fontSize, font: ttfThin)),
                              ]),
                        ])
                      : pw.TableRow(children: []),
                pw.TableRow(children: [
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text("",
                            style: pw.TextStyle(
                                fontSize: fontSize, font: ttfThin)),
                      ]),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("Итог",
                            style: pw.TextStyle(
                                fontSize: fontSize, font: ttfThin)),
                      ]),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text("",
                            style: pw.TextStyle(
                                fontSize: fontSize, font: ttfThin)),
                      ]),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text("",
                            style: pw.TextStyle(
                                fontSize: fontSize, font: ttfThin)),
                      ]),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(totalCount.toString(),
                            style: pw.TextStyle(
                                fontSize: fontSize, font: ttfThin)),
                      ]),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(totalPrice.toString(),
                            style: pw.TextStyle(
                                fontSize: fontSize, font: ttfThin)),
                      ]),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(totalCost.toString(),
                            style: pw.TextStyle(
                                fontSize: fontSize, font: ttfThin)),
                      ]),
                ])
              ]),
              pw.SizedBox(height: mediumFontSize),
              pw.Text("Всего отпущено количество запасов: $num",
                  style: pw.TextStyle(
                      font: ttfThin,
                      fontSize: 6,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: mediumFontSize),
              pw.Text("на сумму: ${order.purchasePrice} KZT",
                  style: pw.TextStyle(
                      font: ttfThin,
                      fontSize: 6,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: mediumFontSize),
            ],
          );
        }));

    Directory directory = (await getApplicationDocumentsDirectory());
    final file = File("${directory.path}/file.pdf");
    await file.writeAsBytes(await pdf.save());

    OpenFile.open('${directory.path}/file.pdf');
  }
}
