import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:teragate_v3/config/env.dart';
import 'package:teragate_v3/models/result_model.dart';
import 'package:teragate_v3/models/storage_model.dart';
import 'package:teragate_v3/services/beacon_service.dart';
import 'package:teragate_v3/services/server_service.dart';
import 'package:teragate_v3/utils/log_util.dart';
import 'package:teragate_v3/utils/time_util.dart';

StreamSubscription startBeaconSubscription(StreamController streamController, SecureStorage secureStorage) {
  String oldScanTime = "";
  Map<String, dynamic> eventMap;
  return streamController.stream.listen((event) {
    if (event.isNotEmpty) {
      eventMap = jsonDecode(event);
      if (oldScanTime == eventMap["scanTime"]) {
        return;
      }

      _processEvent(secureStorage, eventMap);
    }
  }, onError: (dynamic error) {
    Log.error('Received error: ${error.message}');
  });
}

Future<void> _processEvent(SecureStorage secureStorage, Map<String, dynamic> eventMap) async {
  String uuid = getUUID(eventMap);

  Log.debug(" *** uuid = $uuid :: UUIDS SIZE = ${Env.UUIDS.length}");

  if (!Env.UUIDS.containsKey(uuid)) {
    return;
  }

  Env.INNER_TIME = getNow();

  if (Env.CURRENT_UUID != uuid) {
    Env.CURRENT_UUID = uuid;
    _getPlace(secureStorage, uuid).then((place) {
      if (Env.CURRENT_PLACE != place) {
        Env.CURRENT_PLACE = (place ?? "");
        Env.BEACON_FUNCTION!(BeaconInfoData(uuid: uuid, place: Env.CURRENT_PLACE));
      }
    });
  }
}

Future<String?> _getPlace(SecureStorage secureStorage, String uuid) async {
  return await secureStorage.read(uuid);
}

void stopBeaconSubscription(StreamSubscription? streamSubscription) {
  if (streamSubscription != null) streamSubscription.cancel();
}

Future<Timer> startBeaconTimer(BuildContext? context, SecureStorage secureStorage) async {
  int count = 0;

  Timer? timer = Timer.periodic(const Duration(seconds: 60), (timer) {
    // ignore: unnecessary_null_comparison
    if (Env.INNER_TIME == null) return;

    int diff = getNow().difference(Env.INNER_TIME).inSeconds;
    if(Env.isDebug) Log.debug(" *** diff = $diff");

    if (diff == 60) {
      Env.CURRENT_UUID = "";
      Env.CURRENT_PLACE = "---";
      Env.OLD_PLACE = Env.CURRENT_PLACE;
      Env.CHANGE_COUNT = 1;
      // 서버에 전송
      if (Env.LOCATION_STATE == "in_work") {
        sendMessageTracking(context, secureStorage, "", Env.CURRENT_PLACE).then((workInfo) {
          if(Env.isDebug) Log.debug(" tracking event = ${workInfo == null ? "" : workInfo.success.toString()}");
          // 외부(비콘 범위 밖) 상태 변경
          setLocationState(secureStorage, "out_work");
          if(Env.isDebug) Log.debug("비콘 외부(비콘 범위 밖에서) LOCATION_STAET : ${Env.LOCATION_STATE}");
        });
      }
    } else {
      if(Env.isDebug) Log.debug("비콘 내부에 있을 때 LOCATION_STAET : ${Env.LOCATION_STATE}");

      if (Env.OLD_PLACE == "" || Env.OLD_PLACE == "---") {
        // 외부에서 내부 ( 사무실 또는 회의실 또는 기타 장소) 에 들어온 경우 와 처음 설치 했을때 경우의 변경 이벤트 체크
        if (Env.OLD_PLACE != Env.CURRENT_PLACE) {
          Env.CHANGE_COUNT = 1;
          Env.OLD_PLACE = Env.CURRENT_PLACE;
          // 서버에 전송
          sendMessageTracking(context, secureStorage, Env.CURRENT_UUID, Env.CURRENT_PLACE).then((workInfo) {
            Log.debug(" tracking event = ${workInfo == null ? "" : workInfo.success.toString()}");
            // 외부에서 내부 또는 처음 설치시 상태 변경
            setLocationState(secureStorage, "in_work");
          });
        }
      } else {
        // 같은 내부 공간에서 2개의 비콘이 지속적으로 잡히면 최소한 연속으로 60회에서 현재 위치가 아닌 곳에서 다른 곳으로 변경이 이루어 지면 변경 위치를 기준으로 변경 이벤트 체크
        if (Env.OLD_PLACE != Env.CURRENT_PLACE) {
          if (Env.CHANGE_COUNT > 60) {
            Env.CHANGE_COUNT = 1;
            Env.OLD_PLACE = Env.CURRENT_PLACE;
            // 서버에 전송
            sendMessageTracking(context, secureStorage, Env.CURRENT_UUID, Env.CURRENT_PLACE).then((workInfo) => Log.debug(" tracking event = ${workInfo == null ? "" : workInfo.success.toString()}"));
          } else {
            Env.CHANGE_COUNT++;
          }
        } else {
          Env.CHANGE_COUNT = 1;
        }
      }
    }

    if (count == 60) {
      // 금일 출근 퇴근 정보 요청
      sendMessageByWork(context, secureStorage).then((workInfo) {
        Env.EVENT_FUNCTION == null ? "" : Env.EVENT_FUNCTION!(workInfo);
      });

      Future.delayed(const Duration(seconds: 2), () {
        // 일주일간 출근 퇴근 정보 요청
        sendMessageByWeekWork(context, secureStorage).then((weekInfo) {
          Env.INIT_STATE_WEEK_INFO = weekInfo;
          Env.EVENT_WEEK_FUNCTION == null ? "" : Env.EVENT_WEEK_FUNCTION!(weekInfo);
        });
      });
      count = 0;
    } else {
      count++;
    }
  });

  return timer;
}

Future<Timer> startUiTimer(Function setUI) async {
  Timer? timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    setUI();
  });

  return timer;
}

Future<void> stopTimer(Timer? timer) async {
  if (timer != null) timer.cancel();
}

// 현재 위치 상태 (내부, 외부)
Future<void> setLocationState(SecureStorage secureStorage, String? state) async {
  secureStorage.write(Env.KEY_LOCATION_STATE, state!);
  Env.LOCATION_STATE = await secureStorage.read(Env.KEY_LOCATION_STATE);
}
