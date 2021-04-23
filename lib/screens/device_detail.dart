import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_ex_ble/models/bluetooth_device_data.dart';
import 'package:flutter_ex_ble/util/Dynamixel.dart';
import 'package:flutter_ex_ble/util/toast_message.dart';
import 'package:flutter_ex_ble/widgetStyle.dart';
import 'package:provider/provider.dart';

class DeviceDetatil extends StatelessWidget {
  const DeviceDetatil({@required this.device});

  final BluetoothDevice device;

  static BluetoothCharacteristic bluetoothcharacteristic;
  static BluetoothCharacteristic subscibeBluetoothcharacteristic;
  static bool isRead = false;

  void getServices(BuildContext context) async {
    List<BluetoothService> services = await device.discoverServices();
    BluetoothService bleService = services.last;
    List<BluetoothCharacteristic> bleCharacteristics =
        bleService.characteristics;

    for (int i = 0; i < bleCharacteristics.length; i++) {
      if (bleCharacteristics[i].uuid.toString() ==
          '6e400003-b5a3-f393-e0a9-e50e24dcca9e') {
        if (bleCharacteristics[i].properties.notify) {
          subscibeBluetoothcharacteristic = bleCharacteristics[i];
          await subscibeBluetoothcharacteristic.setNotifyValue(true);
          subscibeBluetoothcharacteristic.value.listen((event) {
            if (isRead) {
              print('-$event');
              Provider.of<BluetoothDeviceData>(context, listen: false)
                  .changeResponse(event.toString());
              isRead = false;
            }
          });
        }
      } else if (bleCharacteristics[i].uuid.toString() ==
          '6e400002-b5a3-f393-e0a9-e50e24dcca9e') {
        bluetoothcharacteristic = bleCharacteristics[i];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 1), () {
      getServices(context);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
        actions: <Widget>[
          StreamBuilder<BluetoothDeviceState>(
            stream: device.state,
            initialData: BluetoothDeviceState.connecting,
            builder: (c, snapshot) {
              VoidCallback onPressed;
              String text;
              switch (snapshot.data) {
                case BluetoothDeviceState.connected:
                  onPressed = () => device.disconnect();
                  text = 'DISCONNECT';
                  break;
                case BluetoothDeviceState.disconnected:
                  onPressed = () {
                    device.connect();
                    getServices(context);
                  };
                  text = 'CONNECT';
                  break;
                default:
                  onPressed = null;
                  text = snapshot.data.toString().substring(21).toUpperCase();
                  break;
              }
              return FlatButton(
                  onPressed: onPressed,
                  child: Text(
                    text,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .button
                        ?.copyWith(color: Colors.white),
                  ));
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            StreamBuilder<BluetoothDeviceState>(
                stream: device.state,
                initialData: BluetoothDeviceState.connecting,
                builder: (c, snapshot) {
                  return ListTile(
                    leading: (snapshot.data == BluetoothDeviceState.connected)
                        ? Icon(Icons.bluetooth_connected)
                        : Icon(Icons.bluetooth_disabled),
                    title: Text(
                        'Device is ${snapshot.data.toString().split('.')[1]}.'),
                    subtitle: Text('${device.id}'),
                    trailing: StreamBuilder<bool>(
                      stream: device.isDiscoveringServices,
                      initialData: false,
                      builder: (c, snapshot) => IndexedStack(
                        index: snapshot.data ? 1 : 0,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.refresh),
                            onPressed: () {
                              Provider.of<BluetoothDeviceData>(context,
                                      listen: false)
                                  .changeResponse('');
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    List<int> data = Dynamixel.writeBytePacket(200, 79, 1);
                    // try {
                    await bluetoothcharacteristic.write(data);
                    // } catch (e) {
                    //   print(e);
                    //   showToast('다시 연결해주세요.');
                    // }
                  },
                  style: textButtonStyle,
                  child: Text('On'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    List<int> data = Dynamixel.writeBytePacket(200, 79, 0);
                    // try {
                    await bluetoothcharacteristic.write(data);
                    // } catch (e) {
                    //   print(e);
                    //   showToast('다시 연결해주세요.');
                    // }
                  },
                  style: textButtonStyle,
                  child: Text('Off'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    List<int> data = Dynamixel.readPacket(200, 79, 3);
                    try {
                      await bluetoothcharacteristic.write(data);
                      isRead = true;
                    } catch (e) {
                      print(e);
                      showToast('다시 연결해주세요.');
                    }
                  },
                  style: textButtonStyle,
                  child: Text('Read'),
                ),
              ],
            ),
            Text(Provider.of<BluetoothDeviceData>(context).response),
          ],
        ),
      ),
    );
  }
}
