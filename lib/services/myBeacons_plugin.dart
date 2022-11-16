import 'dart:async';

import 'package:flutter/services.dart';
import 'package:teragate_v3/config/env.dart';
import 'package:teragate_v3/utils/log_util.dart';

class BeaconsPlugin {
  static const MethodChannel channel = MethodChannel('beacons_plugin');
  static const eventChannel = EventChannel('beacons_plugin_stream');

  static void printDebugMessage(String? msg, int msgDebugLevel) {
    if (Env.isDebug) Log.debug(msg);
  }

  static Future<void> startMonitoring() async {
    final String? result = await channel.invokeMethod('startMonitoring');
    printDebugMessage(result, 2);
  }

  static Future<void> stopMonitoring() async {
    final String? result = await channel.invokeMethod('stopMonitoring');
    printDebugMessage(result, 2);
  }

  static Future<void> addRegion(String identifier, String uuid) async {
    final String? result = await channel.invokeMethod('addRegion', <String, dynamic>{'identifier': identifier, 'uuid': uuid});
    printDebugMessage(result, 2);
  }

  static Future<void> clearRegions() async {
    final String? result = await channel.invokeMethod('clearRegions');
    printDebugMessage(result, 2);
  }

  static Future<void> runInBackground(bool runInBackground) async {
    final String? result = await channel.invokeMethod(
      'runInBackground',
      <String, dynamic>{'background': runInBackground},
    );
    printDebugMessage(result, 2);
  }

  static Future<void> clearDisclosureDialogShowFlag(bool clearFlag) async {
    final String? result = await channel.invokeMethod(
      'clearDisclosureDialogShowFlag',
      <String, dynamic>{'clearFlag': clearFlag},
    );
    printDebugMessage(result, 2);
  }

  static Future<void> addBeaconLayoutForAndroid(String layout) async {
    final String? result = await channel.invokeMethod('addBeaconLayoutForAndroid', <String, dynamic>{'layout': layout});
    printDebugMessage(result, 2);
  }

  static Future<void> setForegroundScanPeriodForAndroid({int foregroundScanPeriod = 1100, int foregroundBetweenScanPeriod = 0}) async {
    final String? result = await channel.invokeMethod('setForegroundScanPeriodForAndroid', <String, dynamic>{'foregroundScanPeriod': foregroundScanPeriod, 'foregroundBetweenScanPeriod': foregroundBetweenScanPeriod});
    printDebugMessage(result, 2);
  }

  static Future<void> setBackgroundScanPeriodForAndroid({int backgroundScanPeriod = 1100, int backgroundBetweenScanPeriod = 0}) async {
    final String? result = await channel.invokeMethod('setBackgroundScanPeriodForAndroid', <String, dynamic>{'backgroundScanPeriod': backgroundScanPeriod, 'backgroundBetweenScanPeriod': backgroundBetweenScanPeriod});
    printDebugMessage(result, 2);
  }

  static Future<void> setDisclosureDialogMessage({String? title, String? message}) async {
    final String? result = await channel.invokeMethod('setDisclosureDialogMessage', <String, dynamic>{'title': title, 'message': message});
    printDebugMessage(result, 2);
  }

  static Future<void> addRegionForIOS(String uuid, int major, int minor, String name) async {
    final String? result = await channel.invokeMethod(
      'addRegionForIOS',
      <String, dynamic>{'uuid': uuid, 'major': major, 'minor': minor, 'name': name},
    );
    printDebugMessage(result, 2);
  }

  static listenToBeacons(StreamController controller) async {
    eventChannel.receiveBroadcastStream().listen((dynamic event) {
      printDebugMessage('Received: $event', 2);
      // TODO :  로그 찍기 ...

      controller.add(event);
    }, onError: (dynamic error) {
      printDebugMessage('Received error: ${error.message}', 1);
    });
  }
}
