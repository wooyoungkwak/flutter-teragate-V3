import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:teragate_v3/config/env.dart';
import 'package:teragate_v3/models/result_model.dart';
import 'package:teragate_v3/models/storage_model.dart';
import 'package:teragate_v3/services/beacon_service.dart';
import 'package:teragate_v3/services/server_service.dart';
import 'package:teragate_v3/utils/log_util.dart';
import 'package:teragate_v3/utils/time_util.dart';

StreamSubscription startBeaconSubscription(StreamController streamController, SecureStorage secureStorage) {
  return streamController.stream.listen((event) {
    if (event.isNotEmpty) {
      _processEvent(secureStorage, event);
    }
  }, onError: (dynamic error) {
    Log.error('Received error: ${error.message}');
  });
}

Future<void> _processEvent(SecureStorage secureStorage, var event) async {
  String uuid = getUUID(event);

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

  Timer? timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    // ignore: unnecessary_null_comparison
    if (Env.INNER_TIME == null) return;

    int diff = getNow().difference(Env.INNER_TIME).inSeconds;
    Log.debug(" *** diff = $diff");

    if (diff == 60) {
      Env.CURRENT_UUID = "";
      Env.CURRENT_PLACE = "-";
      Env.OLD_PLACE = Env.CURRENT_PLACE;
      Env.CHANGE_COUNT = 1;
      // 서버에 전송
      sendMessageTracking(context, secureStorage, "", Env.CURRENT_PLACE).then((workInfo) => Log.debug(" tracking event = ${workInfo == null ? "" : workInfo.success.toString()}"));
    } else {
      if (Env.OLD_PLACE == "" || Env.OLD_PLACE == "-") {
        // 외부에서 내부 ( 사무실 또는 회의실 또는 기타 장소) 에 들어온 경우 와 처음 설치 했을때 경우의 변경 이벤트 체크
        if (Env.OLD_PLACE != Env.CURRENT_PLACE) {
          Env.CHANGE_COUNT = 1;
          Env.OLD_PLACE = Env.CURRENT_PLACE;
          // 서버에 전송
          sendMessageTracking(context, secureStorage, Env.CURRENT_UUID, Env.CURRENT_PLACE).then((workInfo) => Log.debug(" tracking event = ${workInfo == null ? "" : workInfo.success.toString()}"));
        }
      } else {
        // 같은 내부 공간에서 2개의 비콘이 지속적으로 잡히면 최소한 연속으로 60회에서 현재 위치가 아닌 곳으로 다른 곳으로 변경이 이루어 지면 변경 위치를 기준으로 변경 이벤트 체크
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
