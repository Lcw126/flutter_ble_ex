import 'package:flutter/material.dart';
import 'package:flutter_ex_ble/models/bluetooth_device_data.dart';
import 'package:flutter_ex_ble/screens/bluetoote_list.dart';
import 'package:provider/provider.dart';

void main() => {runApp(MyApp())};

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BluetoothDeviceData(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: BluetoothList(),
      ),
    );
  }
}
