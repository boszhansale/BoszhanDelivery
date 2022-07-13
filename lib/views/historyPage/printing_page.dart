import 'dart:convert';
import 'dart:typed_data';
import 'package:boszhan_delivery_app/models/history_basket.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart';
import 'dart:io' show Platform;
import 'package:image/image.dart';
import 'package:windows1251/windows1251.dart';

class Print extends StatefulWidget {
  final List<HistoryBasket> data;
  Print(this.data);
  @override
  _PrintState createState() => _PrintState();
}

class _PrintState extends State<Print> {

  final PrinterBluetoothManager _printerManager = PrinterBluetoothManager();
  List<PrinterBluetooth> _devices = [];
  String? _devicesMsg;
  BluetoothManager bluetoothManager = BluetoothManager.instance;

  @override
  void initState() {
    if (Platform.isAndroid) {
      bluetoothManager.state.listen((val) {
        if (!mounted) return;
        if (val == 12) {
          print('on');
          initPrinter();
        } else if (val == 10) {
          print('off');
          setState(() => _devicesMsg = 'Bluetooth отключен!');
        }
      });
    } else {
      initPrinter();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Печать')),
        backgroundColor: Colors.red,
      ),
      body: _devices.isEmpty
          ? Center(child: Text(_devicesMsg ?? ''))
          : ListView.builder(
        itemCount: _devices.length,
        itemBuilder: (c, i) {
          return ListTile(
            leading: const Icon(Icons.print),
            title: Text(_devices[i].name.toString()),
            subtitle: Text(_devices[i].address.toString()),
            onTap: () {
              _startPrint(_devices[i]);
            },
          );
        },
      ),
    );
  }

  void initPrinter() {
    _printerManager.startScan(Duration(seconds: 2));
    _printerManager.scanResults.listen((val) {
      if (!mounted) return;
      setState(() => _devices = val);
      if (_devices.isEmpty) setState(() => _devicesMsg = 'No Devices');
    });
  }

  Future<void> _startPrint(PrinterBluetooth printer) async {
    _printerManager.selectPrinter(printer);
    final result = await _printerManager.printTicket(await getRealTicket());
    String statusMSG = '';
    result.msg == 'Success' ? statusMSG = 'Распечатано успешно!' : statusMSG = 'Ошибка распечатки: ' + result.msg;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(statusMSG),
        actions: [
          FlatButton(
            color: Colors.green,
            textColor: Colors.white,
            child: const Text('OK'),
            onPressed: () {
              setState(() {
                Navigator.pop(context);
              });
            },
          ),
        ],
      ),
    );
  }

  Future<List<int>> getRealTicket() async {
    final profile = await CapabilityProfile.load(name: 'XP-N160I');
    final generator = Generator(PaperSize.mm80, profile);
    List<int> ticket = [];
    ticket += generator.setGlobalCodeTable('CP1252');

    var amount = 0;
    // TODO: Adding data to ticket.

    ticket += generator.textEncoded(Uint8List.fromList(windows1251.encode('ТОО "Первомайские Деликатесы" БИН (151511214512)')),
        styles: const PosStyles(bold: true, underline: true));
    ticket += generator.textEncoded(Uint8List.fromList(windows1251.encode('Накладная на отпуск запасов на сторону № 123456789 от 08 октября 2021 г.')),
        styles: const PosStyles(bold: true, height: PosTextSize.size2, width: PosTextSize.size1));
    ticket += generator.textEncoded(Uint8List.fromList(windows1251.encode('Получатель: ТОРГОВАЯ ТОЧКА')));
    ticket += generator.textEncoded(Uint8List.fromList(windows1251.encode('Склад: ВОДИТЕЛЬ')));
    ticket += generator.hr();
    ticket += generator.row([
      PosColumn(
        textEncoded: Uint8List.fromList(windows1251.encode('Наименование товара')),
        width: 7,
        styles: const PosStyles(align: PosAlign.center, underline: true, bold: true),
      ),
      PosColumn(
        textEncoded: Uint8List.fromList(windows1251.encode('Ед.')),
        width: 1,
        styles: const PosStyles(align: PosAlign.center, underline: true, bold: true),
      ),
      PosColumn(
        textEncoded: Uint8List.fromList(windows1251.encode('Кол.')),
        width: 1,
        styles: const PosStyles(align: PosAlign.center, underline: true, bold: true),
      ),
      PosColumn(
        textEncoded: Uint8List.fromList(windows1251.encode('Сумма')),
        width: 1,
        styles: const PosStyles(align: PosAlign.center, underline: true, bold: true),
      ),
      PosColumn(
        textEncoded: Uint8List.fromList(windows1251.encode('с НДС')),
        width: 1,
        styles: const PosStyles(align: PosAlign.center, underline: true, bold: true),
      ),
      PosColumn(
        textEncoded: Uint8List.fromList(windows1251.encode('без НДС')),
        width: 1,
        styles: const PosStyles(align: PosAlign.center, underline: true, bold: true),
      ),
    ]);
    for (HistoryBasket basket in widget.data) {
      amount += basket.price;
      ticket += generator.row([
        PosColumn(
          textEncoded: Uint8List.fromList(windows1251.encode(basket.name)),
          width: 7,
          styles: const PosStyles(align: PosAlign.left, underline: false, bold: false),
        ),
        PosColumn(
          textEncoded: Uint8List.fromList(windows1251.encode('шт.')),
          width: 1,
          styles: const PosStyles(align: PosAlign.center, underline: false, bold: false),
        ),
        PosColumn(
          textEncoded: Uint8List.fromList(windows1251.encode(basket.count.toString())),
          width: 1,
          styles: const PosStyles(align: PosAlign.center, underline: false, bold: false),
        ),
        PosColumn(
          textEncoded: Uint8List.fromList(windows1251.encode(basket.price.toString())),
          width: 1,
          styles: const PosStyles(align: PosAlign.center, underline: false, bold: false),
        ),
        PosColumn(
          textEncoded: Uint8List.fromList(windows1251.encode((basket.price-(basket.price*0.12)).toString())),
          width: 1,
          styles: const PosStyles(align: PosAlign.center, underline: false, bold: false),
        ),
        PosColumn(
          textEncoded: Uint8List.fromList(windows1251.encode((basket.price+(basket.price*0.12)).toString())),
          width: 1,
          styles: const PosStyles(align: PosAlign.center, underline: false, bold: false),
        ),
      ]);
    }

    ticket += generator. row([
      PosColumn(
        textEncoded: Uint8List.fromList(windows1251.encode('Итого')),
        width: 9,
        styles: const PosStyles(align: PosAlign.left, underline: false, bold: true),
      ),
      PosColumn(
        textEncoded: Uint8List.fromList(windows1251.encode(amount.toString())),
        width: 1,
        styles: const PosStyles(align: PosAlign.center, underline: false, bold: true),
      ),
      PosColumn(
        textEncoded: Uint8List.fromList(windows1251.encode((amount-amount*0.12).toString())),
        width: 1,
        styles: const PosStyles(align: PosAlign.center, underline: false, bold: true),
      ),
      PosColumn(
        textEncoded: Uint8List.fromList(windows1251.encode((amount+amount*0.12).toString())),
        width: 1,
        styles: const PosStyles(align: PosAlign.center, underline: false, bold: true),
      ),
    ]);

    ticket += generator.hr(linesAfter: 1);

    ticket += generator.textEncoded(Uint8List.fromList(windows1251.encode('Отпустил ___________________')));
    ticket += generator.textEncoded(Uint8List.fromList(windows1251.encode('Получил ____________________')));

    ticket += generator.cut();
    return ticket;
  }

  @override
  void dispose() {
    _printerManager.stopScan();
    super.dispose();
  }

}