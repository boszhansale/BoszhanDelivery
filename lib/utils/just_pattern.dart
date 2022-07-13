import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class JustPage extends StatefulWidget {
  // JustPage(this.product);
  // final Product product;

  @override
  _JustPageState createState() => _JustPageState();
}

class _JustPageState extends State<JustPage> {

  @override
  void initState() {
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
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: Text('₸', style: TextStyle(color: Colors.white, fontSize: 18)),
          automaticallyImplyLeading: true,
          backgroundColor: Colors.red,
          shadowColor: Colors.white,
          bottomOpacity: 1,
          iconTheme: IconThemeData(color: Colors.white)
        ),
        body: Container(
          // child:
          ),
        )
    );
  }
}