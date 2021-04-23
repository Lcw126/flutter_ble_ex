import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_ex_ble/util/permission_check.dart';
import 'package:flutter_ex_ble/widgetStyle.dart';
import 'package:flutter_ex_ble/widgets/device_list.dart';

class BluetoothList extends StatefulWidget {
  @override
  _BluetoothListState createState() => _BluetoothListState();
}

class _BluetoothListState extends State<BluetoothList> {
  int deviceCount = 0;

  @override
  void initState() {
    checkPermissions(); //  permission check
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final FlutterBlue flutterBlue = FlutterBlue.instance;
    return Scaffold(
      appBar: AppBar(
        title: Text('AppBar Title'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    flutterBlue
                        .startScan(timeout: Duration(seconds: 4))
                        .then((value) {
                      setState(
                        () {
                          deviceCount = value.length;
                        },
                      );
                    });
                  },
                  style: textButtonStyle,
                  child: Text('Scan'),
                ),
                ElevatedButton(
                  onPressed: () {
                    flutterBlue.stopScan();
                  },
                  style: textButtonStyle,
                  child: Text('Stop'),
                ),
                Text('count:$deviceCount'),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: DevicesList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
