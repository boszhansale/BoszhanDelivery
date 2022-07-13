import 'package:boszhan_delivery_app/components/product_card.dart';
import 'package:boszhan_delivery_app/models/order.dart';
import 'package:boszhan_delivery_app/services/orders_api_provider.dart';
import 'package:boszhan_delivery_app/utils/number_formatter.dart';
import 'package:boszhan_delivery_app/views/currentPage/change_products_in_order.dart';
import 'package:boszhan_delivery_app/widgets/app_bar.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../home_page.dart';

class OrderInfoPage extends StatefulWidget {
  const OrderInfoPage(this.order);
  final Order order;

  @override
  _OrderInfoPageState createState() => _OrderInfoPageState();
}

class _OrderInfoPageState extends State<OrderInfoPage> {
  TextEditingController commentController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController winningNameController = TextEditingController();
  TextEditingController winningPhoneController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  final _mobileFormatter = NumberTextInputFormatter();
  Object? _value = 1;
  Object? _value2 = 1;

  List<bool> listOfCheckboxes = [false, false, false, false, false, false];
  bool isButtonDisabled = false;
  List<String> causes = [
    'Истек срок годности',
    'Жидкость в упаковке',
    'Развакуум',
    'Нарушенная упаковка',
    'Нарушенная упаковка',
    'Другое:'
  ];

  @override
  void initState() {
    widget.order.status != 2
        ? isButtonDisabled = true
        : isButtonDisabled = false;
    print('Order ID - ' + widget.order.id.toString());
    print(isButtonDisabled);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.white,
          appBar: PreferredSize(
              preferredSize: const Size.fromHeight(60.0),
              child: buildAppBar('Выдача заказа')),
          body: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.7,
                child: ListView.separated(
                    itemCount: widget.order.basket.length,
                    itemBuilder: (BuildContext context, int index) =>
                        widget.order.basket[index].type == 0
                            ? ProductCard(widget.order.basket[index], index)
                            : Ink(
                                color: Colors.red[200],
                                child: ProductCard(
                                    widget.order.basket[index], index)),
                    separatorBuilder: (context, index) {
                      return const Divider();
                    }),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.29,
                    height: MediaQuery.of(context).size.width * 0.1,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.assignment_rounded,
                          color: Colors.white),
                      label: const Text('Выполнить',
                          style: TextStyle(fontSize: 16)),
                      onPressed:
                          isButtonDisabled ? null : displayPaymentTypeDialog,
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green,
                        textStyle:
                            const TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.29,
                    height: MediaQuery.of(context).size.width * 0.1,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.cancel, color: Colors.white),
                      label: const Text(
                        'Отказ',
                        style: TextStyle(fontSize: 16),
                      ),
                      onPressed:
                          isButtonDisabled ? null : displayTextInputDialog,
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                        textStyle:
                            const TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.29,
                    height: MediaQuery.of(context).size.width * 0.1,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add_circle, color: Colors.white),
                      label: const Text('Изменить',
                          style: TextStyle(fontSize: 16)),
                      onPressed: isButtonDisabled ? null : editOrder,
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                        textStyle:
                            const TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ),
                ),
              ]),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                    'Общая сумма заказа: ' +
                        widget.order.totalCost.toString() +
                        ' ₸',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                    'Общее количество заказов: ' +
                        widget.order.basket.length.toString(),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ));
  }

  Future<void> displayPaymentTypeDialog() async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Выберите способ оплаты'),
            content: SizedBox(
              height: 270,
              child: Column(
                children: [
                  SizedBox(
                      height: 60,
                      child: DropdownButton(
                          value: _value,
                          items: const [
                            DropdownMenuItem(
                              child: Text("Наличный"),
                              value: 1,
                            ),
                            DropdownMenuItem(
                              child: Text("Без наличный"),
                              value: 2,
                            ),
                            DropdownMenuItem(
                              child: Text("Отсрочка платежа"),
                              value: 3,
                            ),
                            DropdownMenuItem(
                              child: Text("Kaspi.kz"),
                              value: 4,
                            )
                          ],
                          onChanged: (value) {
                            setState(() {
                              _value = value;
                              Navigator.pop(context);
                              displayPaymentTypeDialog();
                            });
                          },
                          hint: const Text("Select item"))),
                  // _value == 4
                  //     ? TextFormField(
                  //         controller: phoneController,
                  //         decoration: const InputDecoration(
                  //             hintText: "Номер телефона kaspi.kz"),
                  //         keyboardType: TextInputType.phone,
                  //         inputFormatters: <TextInputFormatter>[
                  //           FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                  //           _mobileFormatter,
                  //         ],
                  //         maxLength: 12,
                  //         validator: (value) {
                  //           if (value!.isEmpty) {
                  //             return 'Номер телефона';
                  //           } else if (!value.contains('+')) {
                  //             return 'Введите корректный номер телефона';
                  //           }
                  //           return null;
                  //         },
                  //       )
                  //     : Container(),
                  _value == 4 || _value == 1
                      ? SizedBox(
                          height: 60,
                          child: DropdownButton(
                              value: _value2,
                              items: const [
                                DropdownMenuItem(
                                  child: Text("Полное погашение"),
                                  value: 1,
                                ),
                                DropdownMenuItem(
                                  child: Text("Частичное погашение"),
                                  value: 2,
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _value2 = value;
                                  Navigator.pop(context);
                                  displayPaymentTypeDialog();
                                });
                              },
                              hint: const Text("Select item")))
                      : Container(),
                  (_value2 == 2 && _value == 4) || (_value == 1 && _value2 == 2)
                      ? TextFormField(
                          controller: amountController,
                          decoration:
                              const InputDecoration(hintText: "Введите сумму"),
                          keyboardType: TextInputType.phone,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                          ],
                          maxLength: 30,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Введите сумму';
                            }
                            return null;
                          },
                        )
                      : Container(),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: const Text('Отмена'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              FlatButton(
                color: Colors.green,
                textColor: Colors.white,
                child: const Text('Сохранить'),
                onPressed: () async {
                  var connectivityResult =
                      await (Connectivity().checkConnectivity());
                  if (connectivityResult == ConnectivityResult.mobile) {
                    if (_value == 400) {
                      if (phoneController.text.length == 12) {
                        setState(() {
                          finishOrder(int.parse(_value.toString()),
                              phoneController.text.substring(2));
                        });
                      } else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Введите корректный номер телефона.",
                              style: TextStyle(fontSize: 20)),
                        ));
                      }
                    } else {
                      finishOrder(int.parse(_value.toString()), 'null');
                    }
                  } else if (connectivityResult == ConnectivityResult.wifi) {
                    if (_value == 400) {
                      if (phoneController.text.length == 12) {
                        setState(() {
                          finishOrder(int.parse(_value.toString()),
                              phoneController.text.substring(2));
                        });
                      } else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Введите корректный номер телефона.",
                              style: TextStyle(fontSize: 20)),
                        ));
                      }
                    } else {
                      finishOrder(int.parse(_value.toString()), 'null');
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Соединение с интернетом отсутствует.",
                          style: TextStyle(fontSize: 20)),
                    ));
                  }
                },
              ),
            ],
          );
        });
  }

  Future<void> displayWinningDialog() async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Поздравляем'),
            content: SizedBox(
              height: 200,
              child: Column(
                children: [
                  Text('У заказчика есть выигрыш: ' +
                      widget.order.bonusGameSum.toString() +
                      ' тг'),
                  TextFormField(
                    controller: winningPhoneController,
                    decoration: const InputDecoration(
                        hintText: "Номер телефона kaspi.kz"),
                    keyboardType: TextInputType.phone,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                      _mobileFormatter,
                    ],
                    maxLength: 12,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Номер телефона';
                      } else if (!value.contains('+')) {
                        return 'Введите корректный номер телефона';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: winningNameController,
                    decoration: const InputDecoration(
                        hintText: "Введите имя получателя"),
                    maxLength: 30,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Введите имя';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: const Text('Отмена'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              FlatButton(
                color: Colors.green,
                textColor: Colors.white,
                child: const Text('Сохранить'),
                onPressed: () async {
                  var connectivityResult =
                      await (Connectivity().checkConnectivity());
                  if (connectivityResult == ConnectivityResult.mobile) {
                    sendWinningData();
                  } else if (connectivityResult == ConnectivityResult.wifi) {
                    sendWinningData();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Соединение с интернетом отсутствует.",
                          style: TextStyle(fontSize: 20)),
                    ));
                  }
                },
              ),
            ],
          );
        });
  }

  Future<void> displayTextInputDialog() async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Отказ'),
            content: SizedBox(
              height: 360,
              child: Column(
                children: [
                  Row(children: [
                    const Text("Истек срок годности"),
                    const Spacer(),
                    Checkbox(
                      value: listOfCheckboxes[0],
                      onChanged: (value) {
                        setState(() {
                          listOfCheckboxes[0] = value!;
                          Navigator.pop(context);
                          displayTextInputDialog();
                        });
                      },
                    )
                  ]),
                  Row(children: [
                    const Text("Жидкость в упаковке"),
                    const Spacer(),
                    Checkbox(
                      value: listOfCheckboxes[1],
                      onChanged: (value) {
                        setState(() {
                          listOfCheckboxes[1] = value!;
                          Navigator.pop(context);
                          displayTextInputDialog();
                        });
                      },
                    )
                  ]),
                  Row(children: [
                    const Text("Развакуум"),
                    const Spacer(),
                    Checkbox(
                      value: listOfCheckboxes[2],
                      onChanged: (value) {
                        setState(() {
                          listOfCheckboxes[2] = value!;
                          Navigator.pop(context);
                          displayTextInputDialog();
                        });
                      },
                    )
                  ]),
                  Row(children: [
                    const Text("Нарушенная упаковка"),
                    const Spacer(),
                    Checkbox(
                      value: listOfCheckboxes[3],
                      onChanged: (value) {
                        setState(() {
                          listOfCheckboxes[3] = value!;
                          Navigator.pop(context);
                          displayTextInputDialog();
                        });
                      },
                    )
                  ]),
                  Row(children: [
                    const Text("Нарушенная упаковка"),
                    const Spacer(),
                    Checkbox(
                      value: listOfCheckboxes[4],
                      onChanged: (value) {
                        setState(() {
                          listOfCheckboxes[4] = value!;
                          Navigator.pop(context);
                          displayTextInputDialog();
                        });
                      },
                    )
                  ]),
                  Row(children: [
                    const Text("Другое"),
                    const Spacer(),
                    Checkbox(
                      value: listOfCheckboxes[5],
                      onChanged: (value) {
                        setState(() {
                          listOfCheckboxes[5] = value!;
                          Navigator.pop(context);
                          displayTextInputDialog();
                        });
                      },
                    )
                  ]),
                  listOfCheckboxes[5]
                      ? TextFormField(
                          controller: commentController,
                          decoration: const InputDecoration(
                              hintText: "Введите причину"),
                          maxLength: 30,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Введите причину';
                            }
                            return null;
                          },
                        )
                      : Container(),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: const Text('Отмена'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              FlatButton(
                color: Colors.green,
                textColor: Colors.white,
                child: const Text('Сохранить'),
                onPressed: () async {
                  var connectivityResult =
                      await (Connectivity().checkConnectivity());
                  if (connectivityResult == ConnectivityResult.mobile) {
                    setState(() {
                      cancelOrder();
                    });
                  } else if (connectivityResult == ConnectivityResult.wifi) {
                    setState(() {
                      cancelOrder();
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Соединение с интернетом отсутствует.",
                          style: TextStyle(fontSize: 20)),
                    ));
                  }
                },
              ),
            ],
          );
        });
  }

  void finishOrder(int paymentType, String number) async {
    String status = '';
    bool paymentFull = true;
    _value2 == 2 ? paymentFull = false : true;
    if (paymentType == 4 || paymentType == 1) {
      if (_value2 == 2) {
        if (amountController.text != '' &&
            int.parse(amountController.text) < widget.order.totalCost) {
          OrdersProvider()
              .changePaymentType(widget.order.id.toString(), paymentType,
                  number, paymentFull, amountController.text)
              .then((value) => status = value)
              .whenComplete(() {
            if (status == 'Success') {
              Navigator.pop(context);
              if (widget.order.bonusGameSum != 0) {
                displayWinningDialog();
              } else {
                Navigator.pushAndRemoveUntil<dynamic>(
                    context,
                    MaterialPageRoute<dynamic>(
                      builder: (BuildContext context) => HomePage(),
                    ),
                    (route) => false);
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Something went wrong.",
                    style: TextStyle(fontSize: 20)),
              ));
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Заполните поле или введите корректное значение.",
                style: TextStyle(fontSize: 20)),
          ));
        }
      } else {
        OrdersProvider()
            .changePaymentType(widget.order.id.toString(), paymentType, number,
                paymentFull, amountController.text)
            .then((value) => status = value)
            .whenComplete(() {
          if (status == 'Success') {
            Navigator.pop(context);
            if (widget.order.bonusGameSum != 0) {
              displayWinningDialog();
            } else {
              Navigator.pushAndRemoveUntil<dynamic>(
                  context,
                  MaterialPageRoute<dynamic>(
                    builder: (BuildContext context) => HomePage(),
                  ),
                  (route) => false);
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content:
                  Text("Something went wrong.", style: TextStyle(fontSize: 20)),
            ));
          }
        });
      }
    } else {
      OrdersProvider()
          .changePaymentType(widget.order.id.toString(), paymentType, number,
              paymentFull, amountController.text)
          .then((value) => status = value)
          .whenComplete(() {
        if (status == 'Success') {
          if (widget.order.bonusGameSum != 0) {
            displayWinningDialog();
          } else {
            Navigator.pushAndRemoveUntil<dynamic>(
                context,
                MaterialPageRoute<dynamic>(
                  builder: (BuildContext context) => HomePage(),
                ),
                (route) => false);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text("Something went wrong.", style: TextStyle(fontSize: 20)),
          ));
        }
      });
    }
  }

  void sendWinningData() async {
    String status = '';
    if (winningPhoneController.text != '' &&
        winningNameController.text != '' &&
        winningPhoneController.text.length == 12) {
      OrdersProvider()
          .sendWinningData(
              widget.order.id.toString(),
              winningPhoneController.text.substring(2),
              winningNameController.text)
          .then((value) => status = value)
          .whenComplete(() {
        if (status == 'Success') {
          Navigator.pushAndRemoveUntil<dynamic>(
              context,
              MaterialPageRoute<dynamic>(
                builder: (BuildContext context) => HomePage(),
              ),
              (route) => false);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text("Something went wrong.", style: TextStyle(fontSize: 20)),
          ));
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Заполните поле или введите корректное значение.",
            style: TextStyle(fontSize: 20)),
      ));
    }
  }

  void cancelOrder() async {
    String status = '';
    String comment = '';

    for (int i = 0; i < listOfCheckboxes.length; i++) {
      if (listOfCheckboxes[i] == true) {
        i == 5 ? comment += causes[i] + ' ' : comment += causes[i] + ', ';
      }
    }

    listOfCheckboxes[5] ? comment += commentController.text : null;

    if (listOfCheckboxes[5] == true) {
      if (commentController.text != '') {
        OrdersProvider()
            .reject(widget.order.id.toString(), comment)
            .then((value) => status = value)
            .whenComplete(() {
          if (status == 'Success') {
            Navigator.pushAndRemoveUntil<dynamic>(
                context,
                MaterialPageRoute<dynamic>(
                  builder: (BuildContext context) => HomePage(),
                ),
                (route) => false);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content:
                  Text("Something went wrong.", style: TextStyle(fontSize: 20)),
            ));
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Заполните поле.", style: TextStyle(fontSize: 20)),
        ));
      }
    } else {
      OrdersProvider()
          .reject(widget.order.id.toString(), comment)
          .then((value) => status = value)
          .whenComplete(() {
        if (status == 'Success') {
          Navigator.pushAndRemoveUntil<dynamic>(
              context,
              MaterialPageRoute<dynamic>(
                builder: (BuildContext context) => HomePage(),
              ),
              (route) => false);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text("Something went wrong.", style: TextStyle(fontSize: 20)),
          ));
        }
      });
    }
  }

  void editOrder() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChangeProductsInOrderPage(widget.order)));
  }
}
