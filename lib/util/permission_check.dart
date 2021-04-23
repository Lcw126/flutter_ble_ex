//퍼미션 체크 및 없으면 퍼미션 동의 화면 출력
import 'package:permission_handler/permission_handler.dart';

checkPermissions() async {
  if (await Permission.contacts.request().isGranted) {}
  Map<Permission, PermissionStatus> statuses =
      await [Permission.location].request();
  print(statuses[Permission.location]);
}
