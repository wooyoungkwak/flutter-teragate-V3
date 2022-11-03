// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:async';

class Env {
  // static const String TEST_SERVER = "http://192.168.0.247";  // local 테스트 서버
  static const String TEST_SERVER = "http://teraenergy.iptime.org"; // 개발 테스트 서버
  static const String REAL_SERVER = "http://teragroupware.duckdns.org";

  static const String SERVER_URL = TEST_SERVER;

  static const String SERVER_LOGIN_URL = '$SERVER_URL:3000/login';
  static const String SERVER_GET_WORK = '$SERVER_URL:3000/teragate/commute/time';
  static const String SERVER_POST_TRACKING = '$SERVER_URL:3000/teragate/add/log';
  static const String SERVER_GET_CONFIG = '$SERVER_URL:3000/teragate/select/config';
  static const String SERVER_REFRESH_TOKEN_URL = '$SERVER_URL:3000/teragate/refreshToken';

  static const String INITIAL_UUID = '74278bdb-b644-4520-8f0c-720eeaffffff';

  static const String SERVER_GROUPWARE_TEST = "$SERVER_URL:8060/pageLnk/Home";
  static const String SERVER_GROUPWARE_REAL = "$SERVER_URL/signIn";

  static const String SERVER_GET_IN_URL = '$SERVER_URL:3000/teragate/goToWork';
  static const String SERVER_GET_OUT_URL = '$SERVER_URL:3000/teragate/leaveWork';

  static bool isDebug = true; // 배포시 false

  static const String SERVER_GROUPWARE_URL = SERVER_GROUPWARE_TEST;

  static const String USER_NICK_NAME = 'USER_NICK_NAME';
  static const String LOGIN_ID = 'LOGIN_ID';
  static const String LOGIN_PW = 'LOGIN_PW';

  static const String WORK_TYPE_TODAY = "today";
  static const String WORK_TYPE_WEEK = "week";

  static bool WORK_PLACE_CHANGE_STATE = false;
  static String? WORK_KR_NAME;
  static String? WORK_POSITION_NAME;
  static String? WORK_PHOTO_PATH;
  static String? WORK_COMPANY_NAME;
  static String? LOCATION_STATE = "out_work";
  static const String LOGIN_STATE = "LOGIN_STATE";

  static const String KEY_USER_ID = "USER_ID"; // Login 후에 서버로부터 부여 받은 사용자 ID 값
  static const String KEY_ID_CHECK = 'KEY_ID_CHECK';
  static const String KEY_ACCESS_TOKEN = "accessToken";
  static const String KEY_REFRESH_TOKEN = "refreshToken";
  static const String KEY_SETTING_UUID = "uuid";
  static const String KEY_SETTING_VIBRATE = "VIBRATE";
  static const String KEY_SETTING_SOUND = "SOUND";
  static const String KEY_SETTING_ALARM = "ALARM";
  static const String KEY_LOGIN_SUCCESS = "success";
  static const String KEY_UUID_SIZE = "uuidSize";

  static const String KEY_PHOTO_PATH = "photo_path";
  static const String KEY_KR_NAME = "krName";
  static const String KEY_POSITION_NAME = "positionName";
  static const String KEY_COMPANY_NAME = "companyName";

  static const String KEY_SHARE_UUID = "share_uuid";
  static const String KEY_BACKGROUND_PATH = 'background_path';
  static const String KEY_LOCATION_STATE = "location_state";

  static const String MSG_NOT_TOKEN = "로그인 후 사용 해주세요.";
  static const String MSG_LOGIN_FAIL = "ID 또는 Passwoard 를 확인하세요.";
  static const String MSG_SUCCESS = "등록이 완료 되었습니다.";
  static const String MSG_FAIL_REGISTER = "등록이 실패 하였습니다.";
  static const String MSG_FAIL_BEACON = "비콘 동기화를 실패 하였습니다.";

  static const String TITLE_PERMISSION = "권한 허용";
  static const String TITLE_DIALOG = "알림";

  static const String CARD_COMMUTING_WORK_ON = "출근 완료";
  static const String CARD_COMMUTING_WORK_OFF = "출근 하기";
  static const String CARD_COMMUTING_LEAVE_ON = "퇴근 완료";
  static const String CARD_COMMUTING_LEAVE_OFF = "퇴근 하기";
  static const String CARD_STATE = "상태";
  static const String CARD_STATE_LOCATION = "현재 위치";

  static const String NOTIFICATION_CHANNEL_ID = "channelID";
  static const String NOTIFICATION_CHANNEL_ID_NO_ALARM = "channelIDNoAlarm";
  static const String NOTIFICATION_CHANNEL_NAME = "channelName";
  static const String NOTIFICATION_CHANNEL_NAME_NO_ALARM = "channelNameNoAlarm";

  static String UUID_DEFAULT = "74278BDB-B644-4520-8F0C-720EEAFFFFFF";

  static String CURRENT_STATE = "";
  static String DEVICE_IP = "";
  static String CURRENT_UUID = "";
  static String CURRENT_PLACE = "";
  static String OLD_PLACE = "";
  static int CHANGE_COUNT = 1;
  static DateTime INNER_TIME = DateTime.now();
  static bool CHECKED_BACKGOURND = true;
  static bool CHECKED_THEME = true;
  static int CURRENT_PAGE_INDEX = 0;

  static Map<String, String> UUIDS = {};
  static dynamic INIT_STATE_WORK_INFO;
  static dynamic INIT_STATE_WEEK_INFO;
  static StreamSubscription? CONNECTIVITY_STREAM_SUBSCRIPTION;
  static StreamSubscription? EVENT_STREAM_SUBSCRIPTION;
  static StreamSubscription? BEACON_STREAM_SUBSCRIPTION;
  static Function? EVENT_FUNCTION;
  static Function? EVENT_WEEK_FUNCTION;
  static Function? BEACON_FUNCTION;
  static String? BACKGROUND_PATH;

  static const String KEY_SAVED_ARRAY = 'savedArray';
}
