// import 'dart:developer' as dv;

// import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

enum AppLogger {
  Black("30"),
  Red("31"),
  Green("32"),
  Yellow("33"),
  Blue("34"),
  Magenta("35"),
  Cyan("36"),
  White("37");

  const AppLogger(this.code);

  final String code;

  void logger(dynamic text, {bool onlyDev = true}) {
// ignore: no_leading_underscores_for_local_identifiers
    final _text = text.toString().replaceAll(RegExp(r"(\r\n|\n)")," ");

    PackageInfo.fromPlatform().then((i) {
      if (onlyDev && Platform.isAndroid) {
        debugPrint(
            '\x1B[${code}m ${i.packageName.split('.').last}: $_text \x1B[0m');
      } else if (onlyDev && Platform.isIOS) {
        log('\x1B[${code}m ${i.packageName.split('.').last}: $_text \x1B[0m');
      } else if(code == "31") {
        // ignore: avoid_print
        print('\x1B[${code}m ${i.packageName.split('.').last}: $_text \x1B[0m');
      }
    });
  }
}

void appPrintW(dynamic text) {
  AppLogger.Black.logger(text);
}

void appPrintE(dynamic text) {
  AppLogger.Red.logger(text, onlyDev: false);
}

void appPrintI(dynamic text) {
  AppLogger.Green.logger(text);
}

void appPrintS(dynamic text) {
  AppLogger.Blue.logger(text);
}

void appPrintC(dynamic text){
  AppLogger.Yellow.logger(text);
}
