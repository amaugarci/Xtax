import 'package:flutter/material.dart';
import 'package:number_inc_dec/number_inc_dec.dart';
Widget IncDec(TextEditingController controller,String _msg,[num ?factor])
{
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
   Container(
        child: Text(_msg,style: TextStyle(
            fontSize: 18
        ),),
      ),

      Container(
    width: 150,
    child:  NumberInputPrefabbed.roundedEdgeButtons(
      incDecFactor: (factor==null)?1:factor,
      incDecBgColor: Colors.blue,
      decIconColor: Colors.white,
      incIconColor: Colors.white,
      controller: controller,
      incIcon: Icons.add,
      decIcon: Icons.remove,
      fractionDigits: 2,

    ),
  ),
    ],
  );
}
