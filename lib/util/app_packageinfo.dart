
import 'package:package_info_plus/package_info_plus.dart';

class AppPackageinfo {

  static Future<String> getAppVersion()async{
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }
}