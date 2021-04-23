import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_ex_ble/models/bluetooth_device_data.dart';
import 'package:flutter_ex_ble/screens/device_detail.dart';
import 'package:flutter_ex_ble/widgets/deviceTile.dart';
import 'package:provider/provider.dart';

class DevicesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ScanResult>>(
      stream: FlutterBlue.instance.scanResults,
      initialData: [],
      builder: (c, snapshot) => Column(
        children: snapshot.data
            .map(
              (r) => DeviceTile(
                result: r,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      // r.device.connect();
                      Provider.of<BluetoothDeviceData>(context, listen: false)
                          .registDevice(r.device);
                      Provider.of<BluetoothDeviceData>(context, listen: false)
                          .connectDevice();
                      return DeviceDetatil(device: r.device);
                    },
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
