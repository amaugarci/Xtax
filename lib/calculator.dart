import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xls;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'constants.dart';
import 'dart:io';
import 'package:share/share.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen(
      {Key? key,
      required this.device,
      required this.chObj1,
      required this.MachineID,
      required this.brushSize_t,
      required this.brushSize_a,
      required this.poles,
      required this.brushesperpole})
      : super(key: key);
  final BluetoothDevice device;
  final BluetoothCharacteristic? chObj1;
  final MachineID;
  final double? brushSize_t;
  final double? brushSize_a;
  final double? poles;
  final double? brushesperpole;

  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  double sensorVal = 0;
  double pressureVal = 0;
  bool isGet = false;
  List<double> myList = List.filled(256, 0);
  var tmpList = List.generate(16, (i) => List.filled(16, 0.0, growable: false),
      growable: false);
  int myRows = 0;
  int myCols = 0;
  int counter = 0;
  double avg = 0;
  double plus10 = 0;
  double plus20 = 0;
  double minus10 = 0;
  double minus20 = 0;
  int tracker = 0;
  int tmpRow = 0;
  int tmpCol = 0;
  double tmpVal = 0;
  static const List<String> abcList = [
    "A",
    "B",
    "C",
    "D",
    "E",
    "F",
    "G",
    "H",
    "I",
    "J",
    "K",
    "L",
    "M",
    "N",
    "O",
    "P",
    "Q",
    "R",
    "S",
    "T",
    "U",
    "V"
  ];

  //late List<Color> clist = List.filled(256, Colors.white);

  var colorList = List.generate(
      16, (i) => List.filled(16, Colors.white, growable: false),
      growable: false);

  @override
  void initState() {
    test();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    return MaterialApp(
        theme: ThemeData(
            inputDecorationTheme: InputDecorationTheme(
              floatingLabelStyle: TextStyle(color: Colors.purple),
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple)),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple)),
            ),
            appBarTheme:
                AppBarTheme(backgroundColor: Colors.deepPurpleAccent[400])),
        home: Scaffold(
          appBar: AppBar(
            title: Text(widget.MachineID),
            leading: IconButton(
                icon: Icon(Icons.close_outlined, color: Colors.white),
                onPressed: () => Navigator.pop(context, false)),
            actions: <Widget>[
              IconButton(
                  icon: Icon(Icons.share, color: Colors.white),
                  onPressed: createExcel),
              StreamBuilder<BluetoothDeviceState>(
                stream: widget.device.state,
                initialData: BluetoothDeviceState.connecting,
                builder: (c, snapshot) {
                  VoidCallback? onPressed;

                  switch (snapshot.data) {
                    case BluetoothDeviceState.connected:
                      print("connected");
                      if (isGet == false) {
                        getNotifications();
                        isGet = true;
                      }
                      break;
                    case BluetoothDeviceState.disconnected:
                      print("not connected");

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
          body: Container(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Container(
                          height: 80,
                          width: 150,
                          child: Card(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  'Sensor',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  sensorVal.toString() + " N",
                                  style: TextStyle(fontSize: 19),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: 80,
                          width: 150,
                          child: Card(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  'Pressure',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  pressureVal!.toStringAsFixed(1) +
                                      " g/cm\u00B2",
                                  style: TextStyle(fontSize: 19),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Container(
                          height: 25,
                          width: 200,
                          color: Color(0xfff1a4a1),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                '> +20%',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                plus20 == 0.0 ? '-' : plus20.toString(),
                                style: TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                        ),
                        Container(
                          height: 25,
                          width: 200,
                          color: Color(0xfffdf5b1),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                '> +10%',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                plus10 == 0.0 ? '-' : plus10.toString(),
                                style: TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                        ),
                        Container(
                          height: 25,
                          width: 200,
                          color: Color(0xffb4faab),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                'Average',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                avg == 0.0 ? '-' : avg.toString(),
                                style: TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                        ),
                        Container(
                          height: 25,
                          width: 200,
                          color: Color(0xfffdf5b1),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                '< -10%',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                minus10 == 0.0 ? '-' : minus10.toString(),
                                style: TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                        ),
                        Container(
                          height: 25,
                          width: 200,
                          color: Color(0xfff1a4a1),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                '< -20%',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                minus20 == 0.0 ? '-' : minus20.toString(),
                                style: TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    MaterialButton(
                      child: Text('CLEAR'),
                      onPressed: () {
                        if (counter != 0) {
                          if (myRows >= 0) {
                            if (myCols == 0) {
                              myCols = widget.brushesperpole!.toInt() - 1;
                              myRows--;
                            } else {
                              myCols--;
                            }

                            tmpList[myRows][myCols] = 0.0;
                            colorList[myRows][myCols] = Colors.white;
                            counter--;
                          }

                          print("CmyCols:" + myCols.toString());
                          print("CmyRows:" + myRows.toString());
                          print("counter:" + counter.toString());
                        }

                        double sum = 0;

                        for (int i = 0; i < widget.poles!.toInt(); i++) {
                          for (int j = 0;
                              j < widget.brushesperpole!.toInt();
                              j++) {
                            sum = sum + tmpList[i][j];
                          }
                        }

                        setState(() {
                          // avg = (sum / (counter)).roundToDouble();
                          avg = (sum / (counter));

                          String inString = avg.toStringAsFixed(2); // '2.35'
                          avg = double.parse(inString);

                          print("sum=" + sum.toString());
                          print("counter=" + (counter).toString());
                          print("avg=" + avg.toString());
                          plus10 = avg + (avg * 0.1);

                          inString = plus10.toStringAsFixed(2); // '2.35'
                          plus10 = double.parse(inString);

                          plus20 = avg + (avg * 0.2);

                          inString = plus20.toStringAsFixed(2); // '2.35'
                          plus20 = double.parse(inString);

                          minus10 = avg - (avg * 0.1);

                          inString = minus10.toStringAsFixed(2); // '2.35'
                          minus10 = double.parse(inString);

                          minus20 = avg - (avg * 0.2);

                          inString = minus20.toStringAsFixed(2); // '2.35'
                          minus20 = double.parse(inString);

                          for (int i = 0; i < widget.poles!.toInt(); i++) {
                            for (int j = 0;
                                j < widget.brushesperpole!.toInt();
                                j++) {
                              if (tmpList[i][j] == 0) {
                              } else {
                                double x = tmpList[i][j];

                                if ((x >= plus20) || (x <= minus20))
                                  colorList[i][j] = Color(0xfff1a4a1);
                                else if ((x < plus20 && x > plus10) ||
                                    (x > minus20 && x < minus10) ||
                                    (x == plus10) ||
                                    (x == minus10))
                                  colorList[i][j] = Color(0xfffdf5b1);
                                else if (x < plus10 && x > minus10)
                                  colorList[i][j] = Color(0xffb4faab);
                              }
                            }
                          }
                        });
                      },
                      color: Colors.deepPurpleAccent[400],
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                    ),
                    MaterialButton(
                      child: Text('SAVE'),
                      onPressed: () {
                        if (widget.brushesperpole!.toInt() *
                                widget.poles!.toInt() >
                            counter) {
                          setState(() {
                            // myList[counter] = pressureVal.roundToDouble();

                            // tmpList[myRows][myCols] =
                            //     pressureVal.roundToDouble();

                            String inString =
                                pressureVal.toStringAsFixed(2); // '2.35'
                            pressureVal = double.parse(inString);

                            tmpList[myRows][myCols] = pressureVal;

                            print(pressureVal);

                            tmpVal = tmpList[myRows][myCols];
                            tmpRow = myRows;
                            tmpCol = myCols;

                            print("yahan:" + tmpList.toString());

                            myCols++;
                            if (myCols == widget.brushesperpole!.toInt()) {
                              myCols = 0;
                              myRows++;
                            }

                            counter++;
                          });

                          double sum = 0;

                          for (int i = 0; i < widget.poles!.toInt(); i++) {
                            for (int j = 0;
                                j < widget.brushesperpole!.toInt();
                                j++) {
                              sum = sum + tmpList[i][j];
                            }
                          }

                          setState(() {
                            //avg = (sum / (counter)).roundToDouble();
                            avg = (sum / (counter));
                            String inString = avg.toStringAsFixed(2); // '2.35'
                            avg = double.parse(inString);
                            print("sum=" + sum.toString());
                            print("counter=" + (counter).toString());
                            print("avg=" + avg.toString());
                            plus10 = avg + (avg * 0.1);
                            inString = plus10.toStringAsFixed(2); // '2.35'
                            plus10 = double.parse(inString);
                            plus20 = avg + (avg * 0.2);
                            inString = plus20.toStringAsFixed(2); // '2.35'
                            plus20 = double.parse(inString);
                            minus10 = avg - (avg * 0.1);
                            inString = minus10.toStringAsFixed(2); // '2.35'
                            minus10 = double.parse(inString);
                            minus20 = avg - (avg * 0.2);
                            inString = minus20.toStringAsFixed(2); // '2.35'
                            minus20 = double.parse(inString);

                            for (int i = 0; i < widget.poles!.toInt(); i++) {
                              for (int j = 0;
                                  j < widget.brushesperpole!.toInt();
                                  j++) {
                                if (tmpList[i][j] == 0) {
                                } else {
                                  double x = tmpList[i][j];

                                  if ((x >= plus20) || (x <= minus20))
                                    colorList[i][j] = Color(0xfff1a4a1);
                                  else if ((x < plus20 && x > plus10) ||
                                      (x > minus20 && x < minus10) ||
                                      (x == plus10) ||
                                      (x == minus10))
                                    colorList[i][j] = Color(0xfffdf5b1);
                                  else if (x < plus10 && x > minus10)
                                    colorList[i][j] = Color(0xffb4faab);
                                }
                              }
                            }

                            // if ((tmpVal >= plus20) || (tmpVal <= minus20))
                            //   colorList[tmpRow][tmpCol] = Color(0xfff1a4a1);
                            // else if ((tmpVal < plus20 && tmpVal > plus10) ||
                            //     (tmpVal < minus20 && tmpVal > minus10) ||
                            //     (tmpVal == plus10) ||
                            //     (tmpVal == minus10))
                            //   colorList[tmpRow][tmpCol] = Color(0xfffdf5b1);
                            // else if (tmpVal < plus10 && tmpVal > minus10)
                            //   colorList[tmpRow][tmpCol] = Color(0xffb4faab);
                          });
                        }
                      },
                      color: darkGreenColor,
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                    ),
                  ],
                ),
                Center(
                  child: Text('Brush'),
                ),
                _contentGridView(),
              ],
            ),
          ),
        ));
  }

  void colorSetter() {}

  Widget _contentGridView() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        height: MediaQuery.of(context).size.height / 1.7,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Row(children: [
            Center(
                child: RotatedBox(
              quarterTurns: -1,
              child: Text('Pole'),
            )),
            Column(
              children: [
                for (var no = 0; no < (widget.poles!.toInt()); no++) ...[
                  Container(
                    padding: EdgeInsets.only(left: 5, top: 20),
                    child: Center(child: Text(String.fromCharCode(no + 65))),
                    height: 60.0,
                  )
                ],
              ],
            ),
            for (var t = 0; t < (widget.brushesperpole!.toInt()); t++) ...[
              Column(children: [
                Text((t + 1).toString()),
                for (var s = 0; s < (widget.poles!.toInt()); s++) ...[
                  Container(
                    child: Card(
                        color: colorList[s][t],
                        child: Center(
                          child: Text(
                            tmpList[s][t] == 0.0
                                ? "--"
                                : tmpList[s][t].toString(),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )),
                    width: 80.0,
                    height: 60.0,
                  ),
                ],
              ]),
            ]
          ]),
        ),
      ),
    );

    //GridView.builder( scrollDirection: Axis.vertical, itemCount: widget.brushesperpole!.toInt()*widget.poles!.toInt() , gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: widget.brushesperpole!.toInt()), itemBuilder: (context, index)=>Padding(
    //  padding: const EdgeInsets.all(2.0),

    // child: Container(child: Card(child: Center(child: Text(myList[index]==0.0? "--": myList[index].toString()))),
    //    width: 100.0,
    //    height: 100.0,
    //  color: clist[index],),
    // ));
  }

  void getNotifications() {
    try {
      widget.chObj1!.value.listen((value) {
        // print( "sensor: " + utf8.decode(value));
        if (this.mounted) {
          // check whether the state object is in tree
          setState(() {
            // make changes here
            sensorVal = double.tryParse(utf8.decode(value))!;
            pressureVal = (sensorVal * 101.97) /
                (widget.brushSize_a! * widget.brushSize_t!);
            //print(double.tryParse(utf8.decode(value))!);
          });
        }
      });
    } catch (e) {
      print(e);
    }
  }

  void test() {
    // for (int i = 0; i < widget.poles!.toInt(); i++) {
    //   for (int j = 0; j < widget.brushesperpole!.toInt(); j++) {
    //     print(tmpList[i][j]);
    //   }
    // }

    print(tmpList);
  }

  Future<void> createExcel() async {
    final xls.Workbook workbook = new xls.Workbook();
    final xls.Worksheet sheet = workbook.worksheets[0];
    //sheet.getRangeByName('A1').setText('Hello World!');

    sheet.getRangeByName('A1').setText('Machine ID');
    sheet.getRangeByName('A1').autoFit();

    sheet.getRangeByName('B1').setText(widget.MachineID);
    sheet.getRangeByName('B1').autoFit();

    sheet.getRangeByName('A2').setText('Brush Size (t) cm');
    sheet.getRangeByName('A2').autoFit();
    sheet.getRangeByName('B2').setText(widget.brushSize_t.toString());

    sheet.getRangeByName('A3').setText('Brush Size (a) cm');
    sheet.getRangeByName('A3').autoFit();
    sheet.getRangeByName('B3').setText(widget.brushSize_a.toString());

    sheet.getRangeByName('A4').setText('Poles');
    sheet.getRangeByName('A4').autoFit();
    sheet.getRangeByName('B4').setText(widget.poles!.toInt().toString());

    sheet.getRangeByName('A5').setText('Brushes per Pole');
    sheet.getRangeByName('A5').autoFit();
    sheet
        .getRangeByName('B5')
        .setText(widget.brushesperpole!.toInt().toString());

    sheet.getRangeByName('A6').setText('Date and Time');
    String timeDate = DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.now());
    sheet.getRangeByName('A6').autoFit();
    sheet.getRangeByName('B6').setText(timeDate);
    sheet.getRangeByName('B6').autoFit();

    int num = 7;
    for (int i = 0; i < widget.poles!.toInt(); i++) {
      for (int j = 0; j < widget.brushesperpole!.toInt(); j++) {
        sheet
            .getRangeByName('${abcList[j]}${num}')
            .setText(tmpList[i][j].toString());
      }
      num++;
    }

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    {
      final String path = (await getApplicationSupportDirectory()).path;
      final String fileName = '$path/Output.xlsx';
      final File file = File(fileName);
      await file.writeAsBytes(bytes, flush: true);
      Share.share(fileName);
      Share.shareFiles([file.path]);
    }
  }
}
