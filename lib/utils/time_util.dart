import 'package:intl/intl.dart';
import 'package:teragate_v3/models/result_model.dart';

String getDateToString(DateTime datetime, String formatStr) {
  DateFormat dateFormat = DateFormat(formatStr);
  return dateFormat.format(datetime);
}

DateTime getNow() {
  return DateTime.now();
}

String getDateToStringForMMDD(DateTime datetime) {
  return getDateToString(datetime, "MM-dd");
}

String getDateToStringForYYMMDD(DateTime datetime) {
  return getDateToString(datetime, "yyyy-MM-dd");
}

String getDateToStringForAll(DateTime datetime) {
  return getDateToString(datetime, "yyyy-MM-dd kk:mm:ss");
}

String getDateToStringForMMDDInNow() {
  return getDateToString(getNow(), "MM-dd");
}

String getDateToStringForYYYYMMDDInNow() {
  return getDateToString(getNow(), "yyyy-MM-dd");
}

String getDateToStringForYYYYMMDDKORInNow() {
  return getDateToString(getNow(), "yyyy년 MM월 dd일");
}

String getDateToStringForYYYYMMDDHHMMKORInNow() {
  return getDateToString(getNow(), "yyyy년 MM월 dd일 kk:mm");
}

String getDateToStringForMMDDKORInNow() {
  return getDateToString(getNow(), "MM월 dd일");
}

String getDateToStringForAllInNow() {
  return getDateToStringForAll(getNow());
}

String getPickerTime(DateTime datetime) {
  return getDateToString(datetime, "kk:mm");
}

String getDateToStringForHHMMSSInNow() {
  return getDateToString(getNow(), "kk:mm:ss");
}

String getDateToStringForHHMMInNow() {
  return getDateToString(getNow(), "kk:mm");
}

String getDateToStringForHHInNow() {
  return getDateToString(getNow(), "kk");
}

String getDateToStringForMMInNow() {
  return getDateToString(getNow(), "mm");
}

String getMinorToDate() {
  String date = getDateToString(getNow(), "MMdd");
  if (date.substring(0, 1) == "0") {
    date = date.substring(1);
  }

  return date;
}

String getWeek() {
  return DateFormat('E', 'en_US').format(getNow());
}

String getWeekByKor() {
  String result = "";
  switch (getWeek()) {
    case 'Mon':
      result = "월요일";
      break;
    case 'Tue':
      result = "화요일";
      break;
    case 'Wed':
      result = "수요일";
      break;
    case 'Thu':
      result = "목요일";
      break;
    case 'Fri':
      result = "금요일";
      break;
    case 'Sat':
      result = "토요일";
      break;
    case 'Sun':
      result = "일요일";
      break;
  }
  return result;
}

String getWeekByOneKor() {
  String result = "";
  switch (getWeek()) {
    case 'Mon':
      result = "월";
      break;
    case 'Tue':
      result = "화";
      break;
    case 'Wed':
      result = "수";
      break;
    case 'Thu':
      result = "목";
      break;
    case 'Fri':
      result = "금";
      break;
    case 'Sat':
      result = "토";
      break;
    case 'Sun':
      result = "일";
      break;
  }
  return result;
}

DateTime getToDateTime(String date) {
  return DateTime.parse(date);
}

Map<String, dynamic> getWorkState(WorkInfo workInfo) {
  Map<String, dynamic> stateMap = {"isAttendTimeOut": false, "isLeaveTime": false, "state": "-"};

  String? attendLeaveTime = workInfo.strAttendLeaveTime;

  if (attendLeaveTime == null) {
    return stateMap;
  }

  if (attendLeaveTime.contains("~")) {
    if (workInfo.attendtime != null) {
      DateTime defaultStartTime = getToDateTime("${workInfo.solardate} ${workInfo.targetAttendTime}");
      DateTime startTime = getToDateTime("${workInfo.solardate} ${workInfo.attendtime}");

      if (startTime.difference(defaultStartTime).inMinutes > 0) {
        stateMap["isAttendTimeOut"] = true;
      }

      stateMap["state"] = "업무중";
    }

    if (workInfo.leavetime != null) {
      DateTime defaultEndTime = getToDateTime("${workInfo.solardate} ${workInfo.targetLeaveTime}");
      DateTime endTime = getToDateTime("${workInfo.solardate} ${workInfo.leavetime}");

      if (endTime.difference(defaultEndTime).inMinutes > 0) {
        stateMap["isLeaveTime"] = true;
      }

      stateMap["state"] = "-";
    }
  } else {
    stateMap["state"] = attendLeaveTime;

    if (workInfo.leavetime != null) {
      stateMap["isLeaveTime"] = true;
    }
  }

  return stateMap;
}
