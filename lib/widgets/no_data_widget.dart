import 'package:flutter/material.dart';

class NoDataWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "No Data",
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}
