import 'dart:io';

import 'package:boszhan_delivery_app/components/history_product_card.dart';
import 'package:boszhan_delivery_app/models/history_order.dart';
import 'package:boszhan_delivery_app/services/orders_api_provider.dart';
import 'package:boszhan_delivery_app/views/historyPage/printing_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../home_page.dart';

class HistoryOrderInfoPage extends StatefulWidget {
  const HistoryOrderInfoPage(this.order);
  final HistoryOrder order;

  @override
  _HistoryOrderInfoPageState createState() => _HistoryOrderInfoPageState();
}

class _HistoryOrderInfoPageState extends State<HistoryOrderInfoPage> {
  bool isContainsReturns = false;
  bool isContainsDeliveryBasket = false;

  @override
  void initState() {
    for (var i in widget.order.basket) {
      if (i.type == 1) {
        setState(() {
          isContainsReturns = true;
        });
      } else {
        isContainsDeliveryBasket = true;
      }
    }
    print(widget.order.salesRepId);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            title: Text('Выполненные заказы, ID = ${widget.order.id}',
                style: TextStyle(color: Colors.white, fontSize: 20)),
            actions: <Widget>[
              widget.order.status == 3 || widget.order.status == 5
                  ? Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(15.0),
                                      topRight: Radius.circular(15.0))),
                              builder: (context) {
                                return Container(
                                  height:
                                      MediaQuery.of(context).size.height / 2,
                                  color: Colors.transparent,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.all(20),
                                        child: Text('Что вы хотите сделать?',
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: SizedBox(
                                          width: 400,
                                          height: 60,
                                          child: ElevatedButton.icon(
                                            icon: const Icon(
                                                Icons.my_library_books_rounded,
                                                color: Colors.white),
                                            label:
                                                const Text("Вернуть в текущие"),
                                            onPressed: () {
                                              changeStatus();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              primary: Colors.blue,
                                              textStyle: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18),
                                            ),
                                          ),
                                        ),
                                      ),
                                      isContainsDeliveryBasket
                                          ? Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: SizedBox(
                                                width: 400,
                                                height: 60,
                                                child: ElevatedButton.icon(
                                                  icon: const Icon(
                                                      Icons
                                                          .my_library_books_rounded,
                                                      color: Colors.white),
                                                  label: const Text(
                                                      "Расходная накладная"),
                                                  onPressed: () {
                                                    createRNK();
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    primary: Colors.green,
                                                    textStyle: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Container(),
                                      isContainsReturns
                                          ? Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: SizedBox(
                                                width: 400,
                                                height: 60,
                                                child: ElevatedButton.icon(
                                                  icon: const Icon(
                                                      Icons
                                                          .assignment_return_sharp,
                                                      color: Colors.white),
                                                  label: const Text("Возвраты"),
                                                  onPressed: () {
                                                    createVozvrat();
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    primary: Colors.red,
                                                    textStyle: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Container(),
                                      widget.order.paymentType == 1
                                          ? Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: SizedBox(
                                                width: 400,
                                                height: 60,
                                                child: ElevatedButton.icon(
                                                  icon: const Icon(
                                                      Icons.fact_check,
                                                      color: Colors.white),
                                                  label: const Text("ПКО"),
                                                  onPressed: () {
                                                    createPKO();
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    primary: Colors.grey,
                                                    textStyle: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Container(),
                                    ],
                                  ),
                                );
                              });
                        },
                        child: const Icon(Icons.print),
                      ))
                  : const SizedBox(),
            ],
            automaticallyImplyLeading: true,
            backgroundColor: Colors.red,
            shadowColor: Colors.white,
            bottomOpacity: 1,
            iconTheme: const IconThemeData(color: Colors.white)),
        body: ListView.separated(
            itemCount: widget.order.basket.length,
            itemBuilder: (BuildContext context, int index) =>
                widget.order.basket[index].type == 0
                    ? HistoryProductCard(widget.order.basket[index])
                    : Ink(
                        color: Colors.red[50],
                        child: HistoryProductCard(widget.order.basket[index])),
            separatorBuilder: (context, index) {
              return const Divider();
            }));
  }

  void toPrint() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => Print(widget.order.basket)));
  }

  void changeStatus() async {
    OrdersProvider()
        .changeStatus(widget.order.id.toString(), 2)
        .whenComplete(() => Navigator.pushAndRemoveUntil<dynamic>(
            context,
            MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => HomePage(),
            ),
            (route) => false));
  }

  void createRNK() async {
    final pdf = pw.Document();

    double fontSize = 6;
    double mediumFontSize = 7;
    double bigFontSize = 8;

    final font = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(font);

    final fontThin = await rootBundle.load("assets/fonts/Roboto-Thin.ttf");
    final ttfThin = pw.Font.ttf(fontThin);

    // final fontBold = await rootBundle.load("assets/fonts/Roboto-Bold.ttf");
    // final ttfBold = pw.Font.ttf(fontBold);

    double totalPrice = 0;

    int num = 0;

    for (int i = 0; i < widget.order.basket.length; i++) {
      if (widget.order.basket[i].type == 0) {
        totalPrice += widget.order.basket[i].price;
      }
    }

    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("ТОО \"Первомайские деликатесы\" (БИН 130740008859)",
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: mediumFontSize,
                  )),
              pw.SizedBox(height: 8),
              pw.Text("Накладная на отпуск заказов на сторону",
                  style: pw.TextStyle(
                      font: ttf,
                      fontSize: bigFontSize,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Text("№${widget.order.id} от ${widget.order.deliveryTime}",
                  style: pw.TextStyle(
                      font: ttf,
                      fontSize: bigFontSize,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text(
                  "Получатель ${widget.order.name}, ${widget.order.storeAddress}",
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: fontSize,
                  )),
              pw.SizedBox(height: 6),
              pw.Text("Склад: ${widget.order.driverName}",
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: fontSize,
                  )),
              pw.SizedBox(height: 6),
              pw.Text("Торговый: ${widget.order.salesRepName}",
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: fontSize,
                  )),
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
                        pw.Text("№",
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
                        pw.Text("Арт.",
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
                for (var i = 0; i < widget.order.basket.length; i++)
                  widget.order.basket[i].type == 0
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
                                pw.Text(widget.order.basket[i].name,
                                    style: pw.TextStyle(
                                        fontSize: fontSize, font: ttfThin)),
                              ]),
                          pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                                pw.Text(widget.order.basket[i].article,
                                    style: pw.TextStyle(
                                        fontSize: fontSize, font: ttfThin)),
                              ]),
                          pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                                pw.Text(
                                    widget.order.basket[i].measureId == 1
                                        ? "шт"
                                        : "кг",
                                    style: pw.TextStyle(
                                        fontSize: fontSize, font: ttfThin)),
                              ]),
                          pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                                pw.Text(widget.order.basket[i].count.toString(),
                                    style: pw.TextStyle(
                                        fontSize: fontSize, font: ttfThin)),
                              ]),
                          pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              children: [
                                pw.Text(widget.order.basket[i].price.toString(),
                                    style: pw.TextStyle(
                                        fontSize: fontSize, font: ttfThin)),
                              ]),
                          pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              children: [
                                pw.Text(
                                    (widget.order.basket[i].count *
                                            widget.order.basket[i].price)
                                        .toInt()
                                        .toString(),
                                    style: pw.TextStyle(
                                        fontSize: fontSize, font: ttfThin)),
                              ]),
                        ])
                      : pw.TableRow(children: []),
                pw.TableRow(children: [
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("",
                            style: pw.TextStyle(
                                fontSize: fontSize, font: ttfThin)),
                      ]),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(" Итог",
                            style: pw.TextStyle(
                                fontSize: fontSize, font: ttfThin)),
                      ]),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("",
                            style: pw.TextStyle(
                                fontSize: fontSize, font: ttfThin)),
                      ]),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("",
                            style: pw.TextStyle(
                                fontSize: fontSize, font: ttfThin)),
                      ]),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(num.toString(),
                            style: pw.TextStyle(
                                fontSize: fontSize, font: ttfThin)),
                      ]),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text('',
                            style: pw.TextStyle(
                                fontSize: fontSize, font: ttfThin)),
                      ]),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(widget.order.purchasePrice.toString(),
                            style: pw.TextStyle(
                                fontSize: fontSize, font: ttfThin)),
                      ]),
                ])
              ]),
              pw.SizedBox(height: 6),
              pw.Text("Всего отпущено количество запасов: $num",
                  style: pw.TextStyle(
                      font: ttfThin,
                      fontSize: mediumFontSize,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Text("на сумму: ${widget.order.purchasePrice} KZT",
                  style: pw.TextStyle(
                      font: ttfThin,
                      fontSize: mediumFontSize,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Text(
                  "В том числе НДС (12%): ${(widget.order.purchasePrice / 112 * 12).roundToDouble()} KZT",
                  style: pw.TextStyle(
                      font: ttfThin,
                      fontSize: mediumFontSize,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Text("Отпустил___________________________________________",
                  style: pw.TextStyle(
                      font: ttfThin,
                      fontSize: mediumFontSize,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Text("Получил____________________________________________",
                  style: pw.TextStyle(
                      font: ttfThin,
                      fontSize: mediumFontSize,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Text(
                  "Дата, время печати: ${DateTime.now().toString().substring(0, 16)}",
                  style: pw.TextStyle(
                      font: ttfThin,
                      fontSize: mediumFontSize,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.BarcodeWidget(
                  data:
                      "https://kaspi.kz/pay/pervdelic?service_id=4494&7068=${widget.order.id}&8250=${widget.order.salesRepId}&amount=${widget.order.purchasePrice - widget.order.returnPrice}",
                  barcode: pw.Barcode.qrCode(),
                  width: 120,
                  height: 120),
              pw.SizedBox(height: 6),
              pw.Text("Kaspi QR",
                  style: pw.TextStyle(
                      font: ttf,
                      fontSize: mediumFontSize,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Text("...",
                  style: pw.TextStyle(
                      font: ttf,
                      fontSize: mediumFontSize,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Text("...",
                  style: pw.TextStyle(
                      font: ttf,
                      fontSize: mediumFontSize,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
            ],
          );
        }));

    Directory directory = (await getApplicationDocumentsDirectory());
    final file = File("${directory.path}/file.pdf");
    await file.writeAsBytes(await pdf.save());

    OpenFile.open('${directory.path}/file.pdf');
  }

  void createVozvrat() async {
    final pdf = pw.Document();

    double fontSize = 6;
    double mediumFontSize = 7;
    double bigFontSize = 8;

    final font = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(font);

    final fontThin = await rootBundle.load("assets/fonts/Roboto-Thin.ttf");
    final ttfThin = pw.Font.ttf(fontThin);

    final fontBold = await rootBundle.load("assets/fonts/Roboto-Bold.ttf");
    final ttfBold = pw.Font.ttf(fontBold);

    double totalPrice = 0;
    int num = 0;

    for (int i = 0; i < widget.order.basket.length; i++) {
      if (widget.order.basket[i].type == 1) {
        totalPrice += widget.order.basket[i].price;
      }
    }

    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("ТОО \"Первомайские деликатесы\" (БИН 130740008859)",
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: mediumFontSize,
                  )),
              pw.SizedBox(height: 8),
              pw.Text("Возвратная накладная от покупателя",
                  style: pw.TextStyle(
                      font: ttf,
                      fontSize: bigFontSize,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Text("№${widget.order.id} от ${widget.order.deliveryTime}",
                  style: pw.TextStyle(
                      font: ttf,
                      fontSize: bigFontSize,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text(
                  "Получатель ${widget.order.name}, ${widget.order.storeAddress}",
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: fontSize,
                  )),
              pw.SizedBox(height: 6),
              pw.Text("Склад: ${widget.order.driverName}",
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: fontSize,
                  )),
              pw.SizedBox(height: 6),
              pw.Text("Торговый: ${widget.order.salesRepName}",
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: fontSize,
                  )),
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
                        pw.Text("№",
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
                        pw.Text("Арт.",
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
                for (var i = 0; i < widget.order.basket.length; i++)
                  widget.order.basket[i].type == 1
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
                                pw.Text(
                                    widget.order.basket[i].name +
                                        '\n' +
                                        'Причина: ${widget.order.basket[i].refundReason}',
                                    style: pw.TextStyle(
                                        fontSize: fontSize, font: ttfThin)),
                              ]),
                          pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                                pw.Text(widget.order.basket[i].article,
                                    style: pw.TextStyle(
                                        fontSize: fontSize, font: ttfThin)),
                              ]),
                          pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                                pw.Text(
                                    widget.order.basket[i].measureId == 1
                                        ? "шт"
                                        : "кг",
                                    style: pw.TextStyle(
                                        fontSize: fontSize, font: ttfThin)),
                              ]),
                          pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                                pw.Text(widget.order.basket[i].count.toString(),
                                    style: pw.TextStyle(
                                        fontSize: fontSize, font: ttfThin)),
                              ]),
                          pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              children: [
                                pw.Text(widget.order.basket[i].price.toString(),
                                    style: pw.TextStyle(
                                        fontSize: fontSize, font: ttfThin)),
                              ]),
                          pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              children: [
                                pw.Text(
                                    (widget.order.basket[i].count *
                                            widget.order.basket[i].price)
                                        .toInt()
                                        .toString(),
                                    style: pw.TextStyle(
                                        fontSize: fontSize, font: ttfThin)),
                              ]),
                        ])
                      : pw.TableRow(children: []),
                pw.TableRow(children: [
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("",
                            style: pw.TextStyle(
                                fontSize: fontSize, font: ttfThin)),
                      ]),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(" Итог",
                            style: pw.TextStyle(
                                fontSize: fontSize, font: ttfThin)),
                      ]),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("",
                            style: pw.TextStyle(
                                fontSize: fontSize, font: ttfThin)),
                      ]),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("",
                            style: pw.TextStyle(
                                fontSize: fontSize, font: ttfThin)),
                      ]),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(num.toString(),
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
                        pw.Text(widget.order.returnPrice.toString(),
                            style: pw.TextStyle(
                                fontSize: fontSize, font: ttfThin)),
                      ]),
                ])
              ]),
              pw.SizedBox(height: 6),
              pw.Text("Всего отпущено количество запасов: $num",
                  style: pw.TextStyle(
                      font: ttfThin,
                      fontSize: mediumFontSize,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Text("на сумму: ${widget.order.returnPrice} KZT",
                  style: pw.TextStyle(
                      font: ttfThin,
                      fontSize: mediumFontSize,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Text(
                  "В том числе НДС (12%): ${(widget.order.returnPrice / 112 * 12).roundToDouble()} KZT",
                  style: pw.TextStyle(
                      font: ttfThin,
                      fontSize: mediumFontSize,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Text("Отпустил___________________________________________",
                  style: pw.TextStyle(
                      font: ttfThin,
                      fontSize: mediumFontSize,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Text("Получил____________________________________________",
                  style: pw.TextStyle(
                      font: ttfThin,
                      fontSize: mediumFontSize,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Text(
                  "Дата, время печати: ${DateTime.now().toString().substring(0, 16)}",
                  style: pw.TextStyle(
                      font: ttfThin,
                      fontSize: mediumFontSize,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
            ],
          );
        }));

    Directory directory = (await getApplicationDocumentsDirectory());
    final file = File("${directory.path}/file.pdf");
    await file.writeAsBytes(await pdf.save());

    OpenFile.open('${directory.path}/file.pdf');
  }

  void createPKO() async {
    final pdf = pw.Document();

    double fontSize = 6;
    double mediumFontSize = 7;
    double bigFontSize = 8;

    final font = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(font);

    final fontThin = await rootBundle.load("assets/fonts/Roboto-Thin.ttf");
    final ttfThin = pw.Font.ttf(fontThin);

    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("ТОО \"Первомайские деликатесы\" (БИН 130740008859)",
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: mediumFontSize,
                  )),
              pw.SizedBox(height: 8),
              pw.Text("КВИТАНЦИЯ",
                  style: pw.TextStyle(
                      font: ttf,
                      fontSize: bigFontSize,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Text("к приходному кассовому ордеру",
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: mediumFontSize,
                  )),
              pw.SizedBox(height: 6),
              pw.Text("№${widget.order.id}",
                  style: pw.TextStyle(
                      font: ttf,
                      fontSize: bigFontSize,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Text(
                  "Принято от: ${widget.order.name}, ${widget.order.storeAddress}",
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: fontSize,
                  )),
              pw.SizedBox(height: 6),
              pw.Text("Основание: оплата за мясную продукцию",
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: fontSize,
                  )),
              pw.SizedBox(height: 6),
              pw.Text("Сумма: ${widget.order.purchasePrice} KZT",
                  style: pw.TextStyle(
                      font: ttfThin,
                      fontSize: mediumFontSize,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Text(
                  "В том числе НДС (12%): ${(widget.order.purchasePrice / 112 * 12).roundToDouble()} KZT",
                  style: pw.TextStyle(
                      font: ttfThin,
                      fontSize: mediumFontSize,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Text(widget.order.deliveryTime,
                  style: pw.TextStyle(
                      font: ttfThin,
                      fontSize: mediumFontSize,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Text("Кассир: ${widget.order.driverName}",
                  style: pw.TextStyle(
                      font: ttfThin,
                      fontSize: mediumFontSize,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Text("Подпись____________________________________________",
                  style: pw.TextStyle(
                      font: ttfThin,
                      fontSize: mediumFontSize,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Text(
                  "Дата, время печати: ${DateTime.now().toString().substring(0, 16)}",
                  style: pw.TextStyle(
                      font: ttfThin,
                      fontSize: mediumFontSize,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
            ],
          );
        }));

    Directory directory = (await getApplicationDocumentsDirectory());
    final file = File("${directory.path}/file.pdf");
    await file.writeAsBytes(await pdf.save());

    OpenFile.open('${directory.path}/file.pdf');
  }
}
