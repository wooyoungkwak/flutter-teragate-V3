import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'package:teragate_v3/config/env.dart';
import 'package:teragate_v3/models/result_model.dart';
import 'package:teragate_v3/models/storage_model.dart';
import 'package:teragate_v3/utils/alarm_util.dart';
import 'package:teragate_v3/utils/log_util.dart';
import 'package:teragate_v3/utils/time_util.dart';

Map<String, String> headers = {};

// 로그인
Future<LoginInfo> login(String id, String pw) async {
  var data = {"loginId": id, "password": pw};
  var body = json.encode(data);

  var response = await http.post(Uri.parse(Env.SERVER_LOGIN_URL), headers: {"Content-Type": "application/json"}, body: body);
  if (response.statusCode == 200) {
    String result = utf8.decode(response.bodyBytes);
    Map<String, dynamic> resultMap = jsonDecode(result);

    LoginInfo loginInfo;

    if (resultMap.values.first) {
      //로그인 성공 실패 체크해서 Model 다르게 설정
      loginInfo = LoginInfo.fromJson(resultMap);
    } else {
      loginInfo = LoginInfo.fromJsonByFail(resultMap);
    }

    return loginInfo;
  } else {
    throw Exception('로그인 서버 오류');
  }
}

// 금일 출근 정보
Future<WorkInfo> _getWokrInfoByToday(String accessToken) async {
  var data = {"strStDt": getDateToStringForYYYYMMDDInNow(), "strEndDt": getDateToStringForYYYYMMDDInNow()};
  var url = Uri.parse(Env.SERVER_GET_WORK).replace(queryParameters: data);
  var response = await http.get(url, headers: {"Content-Type": "application/json", "Authorization": accessToken});

  if (response.statusCode == 200) {
    List<dynamic> lists = json.decode(response.body);
    return WorkInfo.fromJson(lists.first);
  } else {
    throw Exception(response.body);
  }
}

// 일주일간 정보 
Future<List<WorkInfo>> _getWokrInfoByWeeks(String accessToken) async {
  
  int diff = 0;

   switch (getWeek()) {
    case 'Mon':
      diff = 1;
      break;
    case 'Tue':
      diff = 2;
      break;
    case 'Wed':
      diff = 3;
      break;
    case 'Thu':
      diff = 4;
      break;
    case 'Fri':
      diff = 5;
      break;
    case 'Sat':
      diff = 6;
      break;
    case 'Sun':
      diff = 7;
      break;
  }

  DateTime now = getNow();
  DateTime substracted = now.subtract(Duration(days: diff));
  DateTime added = substracted.add(const Duration(days: 6));

  String strStDt= getDateToStringForYYMMDD(substracted);
  String strEndDt = getDateToStringForYYMMDD(added);

  var data = {"strStDt": strStDt, "strEndDt": strEndDt};
  var url = Uri.parse(Env.SERVER_GET_WORK).replace(queryParameters: data);
  final response = await http.get(url, headers: {"Content-Type": "application/json", "Authorization": accessToken});

  if (response.statusCode == 200) {
    List<dynamic> list = json.decode(response.body);
    List<WorkInfo> workInfos = [];
    for ( Map<String, String> element in list  ) {
      workInfos.add(WorkInfo.fromJson(element));
    }

    return workInfos;
  } else {
    throw Exception(response.body);
  }
}

// beacon 동기화
Future<ConfigInfo> _getBeaconInfos(String accessToken, String userId) async {
  var data = {"userId": userId};
  var url = Uri.parse(Env.SERVER_GET_CONFIG).replace(queryParameters: data);
  final response = await http.get(url, headers: {"Content-Type": "application/json", "Authorization": accessToken});

  if (response.statusCode == 200) {
    return ConfigInfo.fromJson(json.decode(response.body));
  } else {
    throw Exception(response.body);
  }
}

// 실시간 추적 정보
Future<WorkInfo> _tracking(String accessToken, String userId, String ip, String uuid, String place) async {
  var data = {"ip": ip, "id": userId, "uuid": uuid, "place": place};
  var body = json.encode(data);
  final response = await http.post(Uri.parse(Env.SERVER_POST_TRACKING), headers: {"Content-Type": "application/json", "Authorization": accessToken}, body: body);

  if (response.statusCode == 200) {
    return WorkInfo.fromJson(json.decode(response.body));
  } else {
    throw Exception(response.body);
  }
}

// 토큰 재요청
Future<TokenInfo> _getTokenByRefreshToken(String refreshToken) async {
  var data = {"refreshToken": refreshToken};
  var body = json.encode(data);
  var response = await http.post(Uri.parse(Env.SERVER_REFRESH_TOKEN_URL), headers: {"Content-Type": "application/json"}, body: body);
  if (response.statusCode == 200) {
    Map<String, dynamic> data = json.decode(response.body);
    if (data[Env.KEY_LOGIN_SUCCESS]) {
      return TokenInfo(accessToken: data[Env.KEY_ACCESS_TOKEN], refreshToken: data[Env.KEY_REFRESH_TOKEN], isUpdated: true);
    } else {
      return TokenInfo(accessToken: "", refreshToken: "", message: data[Env.KEY_LOGIN_SUCCESS], isUpdated: false);
    }
  } else {
    throw Exception(response.body);
  }
}

// 업무 동기화 처리 
Future<WorkInfo> _processWork(SecureStorage secureStorage, String accessToken, String refreshToken, String type, int repeat) async {

  WorkInfo workInfo = await _getWokrInfoByToday(accessToken);
  TokenInfo tokenInfo;

  try {
    if (workInfo.success) {
      tokenInfo = TokenInfo(accessToken: accessToken, refreshToken: refreshToken, isUpdated: false);
    } else {
      if (workInfo.message == "expired") {
        // 만료 인 경우 재 요청 경우
        tokenInfo = await _getTokenByRefreshToken(refreshToken);

        if (tokenInfo.isUpdated == true) {
          // Token 저장
          secureStorage.write(Env.KEY_ACCESS_TOKEN, tokenInfo.getAccessToken());
          secureStorage.write(Env.KEY_ACCESS_TOKEN, tokenInfo.getRefreshToken());

          repeat++;
          if (repeat < 2) {
            return await _processWork(secureStorage, tokenInfo.getAccessToken(), tokenInfo.getRefreshToken(), type, repeat);
          } else {
            return WorkInfo(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, success: false, message: Env.MSG_FAIL_REGISTER);
          }
        }
      }
    }
    return workInfo;
  } catch (err) {
    Log.log(" processTracking Exception : ${err.toString()}");
    return WorkInfo(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, success: false, message: Env.MSG_FAIL_REGISTER);
  }
}

// 비콘 정보 동기화 처리
Future<ConfigInfo> _processBeaconInfos(SecureStorage secureStorage, String accessToken, String refreshToken, String userId, int repeat) async {
  ConfigInfo configInfo = await _getBeaconInfos(accessToken, userId);
  TokenInfo tokenInfo;

  try {
    if (configInfo.success!) {
      tokenInfo = TokenInfo(accessToken: accessToken, refreshToken: refreshToken, isUpdated: false);
    } else {
      if (configInfo.message == "expired") {
        // 만료 인 경우 재 요청 경우
        tokenInfo = await _getTokenByRefreshToken(refreshToken);

        if (tokenInfo.isUpdated == true) {
          // Token 저장
          secureStorage.write(Env.KEY_ACCESS_TOKEN, tokenInfo.getAccessToken());
          secureStorage.write(Env.KEY_ACCESS_TOKEN, tokenInfo.getRefreshToken());

          repeat++;
          if (repeat < 2) {
            return await _processBeaconInfos(secureStorage, tokenInfo.getAccessToken(), tokenInfo.getRefreshToken(), userId, repeat);
          } else {
            return ConfigInfo(success: false, config: []);
          }
        }
      }
    }
    return configInfo;
  } catch (err) {
    Log.log(" processTracking Exception : ${err.toString()}");
    return ConfigInfo(success: false, config: []);
  }
}

// 실시간 추적 처리
Future<WorkInfo> _processTracking(SecureStorage secureStorage, String accessToken, String refreshToken, String userId, String ip, String uuid, String place, int repeat) async {
  WorkInfo workInfo = await _tracking(accessToken, userId, ip, uuid, place);
  TokenInfo tokenInfo;

  try {
    if (workInfo.success) {
      tokenInfo = TokenInfo(accessToken: accessToken, refreshToken: refreshToken, isUpdated: false);
      workInfo.message = Env.MSG_SUCCESS;
    } else {
      if (workInfo.message == "expired") {
        // 만료 인 경우 재 요청 경우
        tokenInfo = await _getTokenByRefreshToken(refreshToken);

        if (tokenInfo.isUpdated == true) {
          // Token 저장
          secureStorage.write(Env.KEY_ACCESS_TOKEN, tokenInfo.getAccessToken());
          secureStorage.write(Env.KEY_ACCESS_TOKEN, tokenInfo.getRefreshToken());

          repeat++;
          if (repeat < 2) {
            return await _processTracking(secureStorage, tokenInfo.getAccessToken(), tokenInfo.getRefreshToken(), userId, ip, uuid, place, repeat);
          } else {
            return WorkInfo(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, success: false, message: Env.MSG_FAIL_REGISTER);
          }
        }
      }
    }
    return workInfo;
  } catch (err) {
    Log.log(" processTracking Exception : ${err.toString()}");
    return WorkInfo(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, success: false, message: Env.MSG_FAIL_REGISTER);
  }
}

// 업무 정보 동기화 메시지 전송 (type : Env.WORK_TYPE_TODAY or Env.WORK_TYPE_WEEK )
Future<WorkInfo> sendMessageByWork(BuildContext context, SecureStorage secureStorage, String type) async {
  String? acccessToken = await secureStorage.read(Env.KEY_ACCESS_TOKEN);
  String? refreshToken = await secureStorage.read(Env.KEY_REFRESH_TOKEN);

  WorkInfo workInfo = await _processWork(secureStorage, acccessToken!, refreshToken!, type, 0);
  if (workInfo.message == Env.MSG_FAIL_REGISTER) {
    showConfirmDialog(context, "알림", Env.MSG_FAIL_REGISTER);
  }
  return workInfo;
}

// 비콘 정보 동기화 메시지 전송
Future<ConfigInfo> sendMessageByBeacon(BuildContext context, SecureStorage secureStorage) async {
  String? acccessToken = await secureStorage.read(Env.KEY_ACCESS_TOKEN);
  String? refreshToken = await secureStorage.read(Env.KEY_REFRESH_TOKEN);
  String? userId = await secureStorage.read(Env.KEY_USER_ID);

  ConfigInfo configInfo = await _processBeaconInfos(secureStorage, acccessToken!, refreshToken!, userId!, 0);
  if (configInfo.message == Env.MSG_FAIL_REGISTER) {
    showConfirmDialog(context, "알림", Env.MSG_FAIL_BEACON);
  }
  return configInfo;
}

// 추적 정보 등록 메시지 전송
Future<WorkInfo> sendMessageTracking(BuildContext context, SecureStorage secureStorage, String uuid, String place) async {
  String? acccessToken = await secureStorage.read(Env.KEY_ACCESS_TOKEN);
  String? refreshToken = await secureStorage.read(Env.KEY_REFRESH_TOKEN);
  String? userId = await secureStorage.read(Env.KEY_USER_ID);

  WorkInfo workInfo = await _processTracking(secureStorage, acccessToken!, refreshToken!, userId!, Env.DEVICE_IP, uuid, place, 0);

  if (workInfo.message == Env.MSG_FAIL_REGISTER) {
    showConfirmDialog(context, "알림", Env.MSG_FAIL_REGISTER);
  }
  return workInfo;
}