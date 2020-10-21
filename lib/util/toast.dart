import 'package:flutter/material.dart';
import 'package:flutter_flexible_toast/flutter_flexible_toast.dart';

void showToast(BuildContext context, String message,
    {ToastGravity toastGravity = ToastGravity.BOTTOM, bool isError = false}) {
  FlutterFlexibleToast.cancel();

  Color textColor = Colors.white;
  if (isError) {
    textColor = Colors.red;
  }
  FlutterFlexibleToast.showToast(
    message: message,
    toastLength: Toast.LENGTH_SHORT,
    toastGravity: toastGravity,
    radius: 12,
    elevation: 10,
    fontSize: 16,
    textColor: textColor,
    backgroundColor: Theme.of(context).primaryColorLight,
  );
}
