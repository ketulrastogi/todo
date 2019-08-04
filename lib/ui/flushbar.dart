
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';

Widget showFlushbar(BuildContext context, String title, String message,  Color color){
  return Flushbar(
                  title: title,
                  message: message,
                  duration: Duration(seconds: 3),
                  backgroundColor: color,
                )..show(context);
}