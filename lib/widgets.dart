
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
class ScanResultTile extends StatelessWidget {
  const ScanResultTile({Key? key, required this.result, this.onTap})
      : super(key: key);

  final ScanResult result;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {

    return Card(
      child:  Padding(
        padding: const EdgeInsets.only(top:8.0,bottom: 8.0),
        child: ListTile(
        dense: false,
        leading: Icon(
          Icons.bluetooth,
          color: Colors.blue,
          size: 40.0,
        ),
        title: Text(
          (result.device.name=="")?"no name": result.device.name,
              style: TextStyle(
               color: Colors.red,
                fontSize: 20.0
              ),
            ),
        subtitle:  Text(
          result.device.id.id,
          style: TextStyle(
            color: Colors.blue,
              fontSize: 12.0
          ),
        ),
        trailing:  MaterialButton(
            shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0),
            ),
            child: Text('CONNECT'),
            color: Colors.blue,
            textColor: Colors.white,
            onPressed: (result.advertisementData.connectable) ? onTap : null,
          ),
    ),
      )
    );

    // return ListTile(
    //   dense: false,
    //   leading: Icon(
    //     Icons.bluetooth,
    //     color: Colors.green,
    //     size: 30.0,
    //   ),
    //   title: Text(
    //         result.device.name,
    //         style: TextStyle(
    //           fontSize: 19.0
    //         ),
    //       ),
    //   trailing:  MaterialButton(
    //       shape: new RoundedRectangleBorder(
    //         borderRadius: new BorderRadius.circular(30.0),
    //       ),
    //       child: Text('CONNECT'),
    //       color: Colors.blue,
    //       textColor: Colors.white,
    //       onPressed: (result.advertisementData.connectable) ? onTap : null,
    //     ),
    // );

    // return (result.device.name.length>0)? Padding(
    //   padding: const EdgeInsets.all(12.0),
    //   child: Row(
    //    
    //     mainAxisAlignment: MainAxisAlignment.spaceAround,
    //     children: [
    //       Text(
    //         result.device.name,
    //         style: TextStyle(
    //           fontSize: 19.0
    //         ),
    //       ),
    //       MaterialButton(
    //       shape: new RoundedRectangleBorder(
    //         borderRadius: new BorderRadius.circular(30.0),
    //       ),
    //       child: Text('CONNECT'),
    //       color: Colors.blue,
    //       textColor: Colors.white,
    //       onPressed: (result.advertisementData.connectable) ? onTap : null,
    //     ),
    //     ],
    //   ),
    // ): Container();
  }
}

class AdapterStateTile extends StatelessWidget {
  const AdapterStateTile({Key? key, required this.state}) : super(key: key);

  final BluetoothState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.redAccent,
      child: ListTile(
        title: Text(
          'Bluetooth adapter is ${state.toString().substring(15)}',

        ),
        trailing: Icon(
          Icons.error,

        ),
      ),
    );
  }
}
