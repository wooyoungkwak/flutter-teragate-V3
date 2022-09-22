import 'dart:convert';

import 'package:teragate_v3/config/env.dart';

LoginInfo resultInfoFromJson(String str) => LoginInfo.fromJson(json.decode(str));

String resultInfoToJson(LoginInfo loginInfo) => json.encode(loginInfo.toJson());

class LoginInfo {
  LoginInfo(this.success, this.data, this.message, this.tokenInfo);

  bool? success;
  String? message;
  Map<String, dynamic>? data = {};
  TokenInfo? tokenInfo;

  static LoginInfo fromJson(Map<String, dynamic> json) {
    TokenInfo tokenInfo = TokenInfo(accessToken: json["accessToken"], refreshToken: json["refreshToken"], isUpdated: true);
    return LoginInfo(json["success"], json["data"], "", tokenInfo);
  }

  static LoginInfo fromJsonByFail(Map<String, dynamic> json) => LoginInfo(json["success"], {}, Env.MSG_LOGIN_FAIL, null);

  Map<String, dynamic> toJson() => {"success": success, "data": data};

  String getPhotoPath() {
    return data![Env.KEY_PHOTO_PATH];
  }

  String getKrName() {
    return data![Env.KEY_KR_NAME];
  }

  String getPositionName() {
    return data![Env.KEY_POSITION_NAME];
  }

  String getCompanyName() {
    return data![Env.KEY_COMPANY_NAME];
  }
}

class WorkInfo {
  bool success; // 요청 결과 (예> true (성공) / false (실패))
  String message; // 요청 결과 메시지 ( 오류가 있을때만 message 가 존재 )
  int? userId; // 시스템  User ID
  String? krName; // 사용자 이름
  String? isweekend; // 주말 여부
  String? isholiday; // 휴일 여부
  String? attendtime; // 출근 시간
  String? leavetime; // 퇴근 시간
  String? attIpIn; //
  String? attIpOut; //
  String? targetAttendTime; // 출근 해야 되는 시간 (예> 09:00)
  String? targetLeaveTime; // 퇴근 해야 되는 시간 (예> 18:00)
  String? strAttendLeaveTime; // 출퇴근 상태 표현 (예> 휴일 or 09:00 ~ 18:00)
  String? noAttendCheckYn; //
  String? placeWork; //
  String? placeWorkName; //
  String? solardate; // 일자

  WorkInfo(this.userId, this.krName, this.isweekend, this.isholiday, this.attendtime, this.leavetime, this.attIpIn, this.attIpOut, this.targetAttendTime, this.targetLeaveTime, this.strAttendLeaveTime,
      this.noAttendCheckYn, this.placeWork, this.placeWorkName, this.solardate,
      {required this.success, required this.message});

  static WorkInfo fromJsonByWeek(bool success, String message, Map<String, dynamic> json) {
    return WorkInfo(json["userId"], json["krName"], json["isweekend"], json["isholiday"], json["attendtime"], json["leavetime"], json["attIpIn"], json["attIpOut"], json["targetAttendTime"],
        json["targetLeaveTime"], json["strAttendLeaveTime"], json["noAttendCheckYn"], json["placeWork"], json["placeWorkName"], json["solardate"],
        success: success, message: message);
  }

  static WorkInfo fromJsonByTracking(Map<String, dynamic> json) {
    if (json == null) {
      return WorkInfo(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, success: false, message: "");
    }

    return WorkInfo(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, success: json["success"], message: (json["message"] ?? ""));
  }

  static WorkInfo fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return WorkInfo(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, success: false, message: "");
    }

    if (!json["success"]) {
      return WorkInfo(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, success: false, message: json["message"] ?? "");
    }

    WorkInfo? workInfo;
    for (var data in json["data"]) {
      workInfo = WorkInfo(data["userId"], data["krName"], data["isweekend"], data["isholiday"], data["attendtime"], data["leavetime"], data["attIpIn"], data["attIpOut"], data["targetAttendTime"],
          data["targetLeaveTime"], data["strAttendLeaveTime"], data["noAttendCheckYn"], data["placeWork"], data["placeWorkName"], data["solardate"],
          success: json["success"], message: (json["message"] ?? ""));
    }

    return workInfo!;
  }

  static WorkInfo fromJsonByState(Map<String, dynamic> json) {
    if (json == null) {
      return WorkInfo(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, success: false, message: "");
    }

    return WorkInfo(json["userId"], json["krName"], json["isweekend"], json["isholiday"], json["attendtime"], json["leavetime"], json["attIpIn"], json["attIpOut"], json["targetAttendTime"],
        json["targetLeaveTime"], json["strAttendLeaveTime"], json["noAttendCheckYn"], json["placeWork"], json["placeWorkName"], json["solardate"],
        success: json["success"], message: (json["message"] ?? ""));
  }

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "krName": krName,
        "isweekend": isweekend,
        "isholiday": isholiday,
        "attendtime": attendtime,
        "leavetime": leavetime,
        "attIpIn": attIpIn,
        "attIpOut": attIpOut,
        "targetAttendTime": targetAttendTime,
        "targetLeaveTime": targetLeaveTime,
        "strAttendLeaveTime": strAttendLeaveTime,
        "noAttendCheckYn": noAttendCheckYn,
        "placeWork": placeWork,
        "placeWorkName": placeWorkName,
        "solardate": solardate,
        "success": success,
        "message": message,
      };

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

class WeekInfo {
  bool success = true; // 요청 결과 (예> true (성공) / false (실패))
  String message = ""; // 요청 결과 메시지 ( 오류가 있을때만 message 가 존재 )
  List<WorkInfo> workInfos;
  WeekInfo(this.success, this.message, {required this.workInfos});

  static WeekInfo fromJson(Map<String, dynamic> json) {
    List<WorkInfo> workInfos = [];

    if (json == null || json["data"] == null) {
      return WeekInfo(false, Env.MSG_FAIL_REGISTER, workInfos: workInfos);
    }

    for (var data in json["data"]) {
      workInfos.add(WorkInfo.fromJsonByWeek(json["success"], json["message"], data));
    }

    return WeekInfo(json["success"], json["message"], workInfos: workInfos);
  }

  Map<String, dynamic> toJson() {
    return {"success": success, "message": message, "workInfos": workInfos};
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

class ConfigInfo {
  bool? success;
  String? message;
  List<BeaconInfoData> beaconInfoDatas;

  ConfigInfo({this.success, this.message, required this.beaconInfoDatas});

  static ConfigInfo fromJson(Map<String, dynamic> json) {
    List<dynamic> config = json["config"];
    List<BeaconInfoData> beaconInfoDatas = [];

    Env.UUIDS.clear();

    for (var element in config) {
      Env.UUIDS["${element["uuid"]}"] = element["place"];
      beaconInfoDatas.add(BeaconInfoData.fromJson(element));
    }

    return ConfigInfo(success: json["success"], message: "", beaconInfoDatas: beaconInfoDatas);
  }

  Map<String, dynamic> toJson() => {"success": success, "message": message, "beaconInfoDatas": beaconInfoDatas};

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

class BeaconInfoData {
  String place;
  String uuid;

  BeaconInfoData({required this.uuid, required this.place});

  static BeaconInfoData fromJson(Map<String, dynamic> json) {
    return BeaconInfoData(place: json["place"], uuid: json["uuid"]);
  }

  static List<BeaconInfoData> fromJsons(List<dynamic> jsons) {
    List<BeaconInfoData> beaconInfoDatas = [];

    for (int i = 0; i < jsons.length; i++) {
      beaconInfoDatas.add(BeaconInfoData.fromJson(jsons[i]));
    }

    return beaconInfoDatas;
  }

  Map<String, dynamic> toJson() => {"place": place, "uuid": uuid};

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

class TokenInfo {
  bool isUpdated;
  String accessToken;
  String refreshToken;
  String? message;

  TokenInfo({required this.accessToken, required this.refreshToken, this.message, required this.isUpdated});

  String getAccessToken() {
    return accessToken;
  }

  String getRefreshToken() {
    return refreshToken;
  }

  String? getMessage() {
    return message;
  }

  void setAccessToken(String accessToken) {
    this.accessToken = accessToken;
  }

  void setRefreshToken(String refreshToken) {
    this.refreshToken = refreshToken;
  }
}
