

import 'package:flutter/material.dart';

Widget buildButtonWithIcon(String title, double height, double width, Color color, IconData icon) {
  return SizedBox(
    width: width,
    height: height,
    child: ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white),
      label: Text(title),
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        primary: color,
        textStyle: const TextStyle(color: Colors.white,fontSize: 20),
      ),
    ),
  );
}
