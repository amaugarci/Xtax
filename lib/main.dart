import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_blue_example/widgets.dart';
void main() {
  runApp(MaterialApp(home: SplashPage(),));
}

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {

    final timer =
    Timer(const Duration(seconds: 3), () =>
        timerCallBack()
    );


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child:  Container(
            width: 250,
            height: 250,
            child:Image(image: AssetImage('assets/logo.png')),
          ),
        ),
      ),
    );
  }

  void timerCallBack()
  {
    Navigator
        .of(context)
        .pushReplacement(new MaterialPageRoute(builder: (BuildContext context) {
      return new FindDevicesScreen();
    }));

  }

}


class FlutterBlueApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamBuilder<BluetoothState>(
          stream: FlutterBlue.instance.state,
          initialData: BluetoothState.unknown,
          builder: (c, snapshot) {
            final state = snapshot.data;
            if (state == BluetoothState.on) {
              return FindDevicesScreen();
            }
            return BluetoothOffScreen(state: state);
          }),
    );
  }
}

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key? key, this.state}) : super(key: key);

  final BluetoothState? state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Colors.white54,
            ),
            Text(
              'Bluetooth Adapter is ${state != null ? state.toString().substring(15) : 'not available'}.',
            ),
          ],
        ),
      ),
    );
  }
}

class FindDevicesScreen extends StatefulWidget {
  const FindDevicesScreen({Key? key}) : super(key: key);

  @override
  _FindDevicesScreenState createState() => _FindDevicesScreenState();
}

class _FindDevicesScreenState extends State<FindDevicesScreen> {
  @override
  void initState() {
    super.initState();
    FlutterBlue.instance.startScan(timeout: Duration(seconds: 4),);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Search for BLE devices'),
        ),
        body: RefreshIndicator(
          onRefresh: () =>
              FlutterBlue.instance.startScan(timeout: Duration(seconds: 4), ),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                StreamBuilder<List<BluetoothDevice>>(
                  stream: Stream.periodic(Duration(seconds: 2))
                      .asyncMap((_) => FlutterBlue.instance.connectedDevices),
                  initialData: [],
                  builder: (c, snapshot) => Column(
                    children: snapshot.data!
                        .map((d) => Card(
                          child: Padding(
                            padding: const EdgeInsets.only(top:8.0,bottom: 8.0),
                            child: ListTile(
                              leading: Icon(
                                Icons.bluetooth,
                                color: Colors.blue,
                                size: 40.0,
                              ),

                              title: Text(
                                (d.name=="")?"no name": d.name,
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 20.0
                                ),
                              ),

                              subtitle:  Text(
                                d.id.id,
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 12.0
                                ),
                              ),
                              trailing: StreamBuilder<BluetoothDeviceState>(
                                    stream: d.state,
                                    initialData: BluetoothDeviceState.disconnected,
                                    builder: (c, snapshot) {
                                      if (snapshot.data ==
                                          BluetoothDeviceState.connected) {


                                        return MaterialButton(
                                          shape: new RoundedRectangleBorder(
                                            borderRadius: new BorderRadius.circular(30.0),
                                          ),
                                          child: Text('OPEN'),
                                          color: Colors.red,
                                          textColor: Colors.white,
                                          onPressed: () => Navigator.of(context)
                                              .push(MaterialPageRoute(
                                              builder: (context) =>
                                                  DeviceScreen(device: d))),
                                        );
                                      }
                                      return Text("");
                                    },
                                  ),
                                ),
                          ),
                        ))
                        .toList(),
                  ),
                ),
                StreamBuilder<List<ScanResult>>(

                  stream: FlutterBlue.instance.scanResults,
                  initialData: [],
                  builder: (c, snapshot) => Column(
                    children: snapshot.data!
                        .map(
                          (r) => ScanResultTile(
                            result: r,
                            onTap: () => Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              r.device.connect();
                              return DeviceScreen(device: r.device);
                            })),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: StreamBuilder<bool>(
          stream: FlutterBlue.instance.isScanning,
          initialData: false,
          builder: (c, snapshot) {
            if (snapshot.data!) {
              return FloatingActionButton(
                child: Icon(Icons.stop),
                onPressed: () => FlutterBlue.instance.stopScan(),
                backgroundColor: Colors.red,
              );
            } else {
              return FloatingActionButton(

                  child: Icon(Icons.search),
                  onPressed: () => FlutterBlue.instance
                      .startScan(timeout: Duration(seconds: 4), ));
            }
          },
        ),
      ),
    );
  }
}

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({Key? key, required this.device}) : super(key: key);
  final BluetoothDevice device;
  @override
  _DeviceScreenState createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  final TextEditingController _controllerMID = TextEditingController();
  final TextEditingController _controllerBST = TextEditingController();
  final TextEditingController _controllerBSA = TextEditingController();
  final TextEditingController _controllerPoles = TextEditingController();
  final TextEditingController _controllerBrushes = TextEditingController();

  final String SERVICE_UUID = "19b10000-e8f2-537e-4f6c-d104768a1214";
  final String INSTRUCTION_UUID = "19b10001-e8f2-537e-4f6c-d104768a1214";

  BluetoothCharacteristic? chObj1;
  BluetoothCharacteristic? chObj2;
  bool discover = false;
  bool isLoading = true;
  bool isConnected= false;
  String connectMsg="";
  bool btnStatus= false;


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      home: Scaffold(
        backgroundColor: Colors.white,
          appBar: AppBar(
            leading: IconButton(
                icon: Icon(Icons.close_outlined, color: Colors.white),
                onPressed: () {
                  if (discover) {
                    widget.device.disconnect();
                    // _Pop();
                    // Navigator.pushReplacement(
                    //   context,
                    //   MaterialPageRoute<void>(
                    //     builder: (BuildContext context) =>
                    //         const FindDevicesScreen(),
                    //   ),
                    // );
                  } else {
                    //_Pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) =>
                            const FindDevicesScreen(),
                      ),
                    );
                  }
                }),
            title: Text("X taz"),
            actions: <Widget>[
              StreamBuilder<BluetoothDeviceState>(
                stream: widget.device.state,
                initialData: BluetoothDeviceState.connecting,
                builder: (c, snapshot) {
                  VoidCallback? onPressed;

                  switch (snapshot.data) {
                    case BluetoothDeviceState.connected:
                      if (discover == false) {
                        discover = true;
                        discoverServices();


                        isConnected=true;

                        connectMsg = "Connected";

                      }
                      break;
                    case BluetoothDeviceState.disconnected:
                      print("not connected");

                      isConnected = false;

                        connectMsg = "Not Connected";

                      _Pop();

                      break;
                    default:
                      onPressed = null;
                      // text = snapshot.data.toString().substring(21).toUpperCase();
                      break;
                  }
                  return Container();
                },
              )
            ],
          ),
          body:
          (isLoading==true)? Center(child: CircularProgressIndicator()):
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: 200,
                height: 200,
                child:Image(image: AssetImage('assets/logo.png')),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [

                      MaterialButton(
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(18.0),
                        ),
                        minWidth: 250,
                        height: 120,
                          color: btnStatus==true?Colors.red:Colors.green,
                        child: Text(btnStatus==true?"OFF":"ON",style: TextStyle(
                            fontSize: 25,
                          color: Colors.white

                        ),),
                        onPressed: (){

                          setState(() {
                            btnStatus = !btnStatus;
                          });

                          (btnStatus==true)?chObj1!.write([0,0]):chObj1!.write([1,0]);

                        }
                      ),


                    ],
                  ),

                ],
              ),

              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      Text("Connection Status:", style: TextStyle(
                        fontSize: 18
                      ),),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(connectMsg, style: TextStyle(
                          fontSize: 18,
                        color: (connectMsg=="Connected")? Colors.green: Colors.red
                      ),),
                    ],
                  ),
                ],
              ),

            ],
          )),
    );
  }

  // void getNotifications() {
  //   List<int> data=[];
  //   List<int> con=[110];
  //   List<int> con2 = [65];
  //   try {
  //     chObj2!.value.listen((value) {
  //           data = value;
  //
  //           print(data);
  //
  //           if(data[0]==con[0])
  //             {
  //               print("Motor state is ON");
  //
  //               setState(() {
  //                 btnStatus = true;
  //               });
  //             }
  //
  //           else if(data[0] == con2[0])
  //             {
  //               print("Motor state is OFF");
  //
  //               setState(() {
  //                 btnStatus = false;
  //               });
  //             }
  //     });
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  discoverServices() async {
    if (widget.device == null) {
      _Pop();
      return;
    }

    List<BluetoothService> services = await widget.device.discoverServices();
    // services.forEach((service) {
    print("Discovering services........");
    for (BluetoothService s in services) {
      print(s.uuid.toString());
      if (s.uuid.toString() == SERVICE_UUID) {
        print("Service found!=============================");

        for (BluetoothCharacteristic c in s.characteristics) {
          if (c.uuid.toString() == INSTRUCTION_UUID) {
            chObj1 = c;

            print("charis found!===========================");

            setState(() {
              isLoading = false;
            });

          }



        }
      }
    }
  }

  _Pop() {
    Navigator.of(context).pop(true);
  }
}
