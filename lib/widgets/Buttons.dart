import 'package:flutter/material.dart';

Widget StopButton()
{
  return Container(
    child: MaterialButton(
      height: 60,
      minWidth: 120,
      color: Colors.blue,
      child: Text("Stop",style: TextStyle(
        color: Colors.white,
        fontSize: 25,
      ),),
      onPressed: ()=>null,
    ),
  );

}