import 'package:flutter/cupertino.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BluetoothDeviceData extends ChangeNotifier {
  // 읽기 결과 Text
  String _response = '';

  void changeResponse(String response) {
    _response = response;
    notifyListeners();
  }

  String get response {
    return _response;
  }

  //  디바이스 정보
  BluetoothDevice _device;

  void registDevice(BluetoothDevice device) {
    _device = device;
  }

  void connectDevice() {
    if (_device != null) {
      _device.connect();
    }
  }

  void disconnectDevice() {
    if (_device != null) {
      _device.disconnect();
    }
  }
}
