import 'package:flutter/material.dart';

Widget MyTextWidget(String _msg)
{
  return Container(
    child:Text(
      _msg,style: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    )
  );
}