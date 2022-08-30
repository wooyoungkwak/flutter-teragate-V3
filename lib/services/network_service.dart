import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:network_info_plus/network_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:teragate_v3/utils/log_util.dart';
import 'package:teragate_v3/config/env.dart';

// device IP 확인
Future<Map<String, dynamic>> getIPAddressByWifi() async {
  final networkInfo = NetworkInfo();
  var ip = await networkInfo.getWifiIP();
  var ssid = await networkInfo.getWifiBSSID();
  
  Map<String, dynamic> map = {
      "ip" : ip,
      "ssid" : ssid
  };
  return map;
}

Future<Map<String, dynamic>> getIPAddressByMobile() async {
  final url = Uri.parse('https://api.ipify.org');
  final response = await http.get(url);
  var ip = response.body;
  Map<String, dynamic> map = {
      "ip" : ip,
      "ssid" : ""
  };
  return map;
}

// ip 설정 ( wifi or mobile (lte, 5G 등 ) )
  Future<StreamSubscription> initIp() async {
    Connectivity().checkConnectivity().then((result) {
      if (result == ConnectivityResult.mobile) {
        getIPAddressByMobile().then((map) {
          Env.DEVICE_IP = map["ip"];
        });
      } else if (result == ConnectivityResult.wifi) {
        getIPAddressByWifi().then((map) {
          Env.DEVICE_IP = map["ip"];
        });
      }
    });

    return Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.mobile) {
        getIPAddressByMobile().then((map) {
          Log.log(' mobile ip address = ${map["ip"]}');
          Env.DEVICE_IP = map["ip"];
        });
      } else if (result == ConnectivityResult.wifi) {
        getIPAddressByWifi().then((map) {
          Log.log(' wifi ip address = ${map["ip"]}');
          Env.DEVICE_IP = map["ip"];
        });
      }
    });
  }
  
