import 'dart:async';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

import 'package:teragate_v3/config/env.dart';
import 'package:teragate_v3/services/background_service.dart';
import 'package:teragate_v3/models/storage_model.dart';
import 'package:teragate_v3/services/network_service.dart';
import 'package:teragate_v3/services/server_service.dart';
import 'package:teragate_v3/state/widgets/custom_text.dart';
import 'package:teragate_v3/services/beacon_service.dart';
import 'package:teragate_v3/services/permission_service.dart';
import 'package:teragate_v3/utils/alarm_util.dart';
import 'package:teragate_v3/utils/log_util.dart';

class Login extends StatefulWidget {
  final StreamController eventStreamController;
  final StreamController beaconStreamController;

  const Login({required this.eventStreamController, required this.beaconStreamController, Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // late StreamSubscription beaconStreamSubscription;
  // late StreamSubscription eventStreamSubscription;
  StreamSubscription? connectivityStreamSubscription;

  late TextEditingController _loginIdContoroller;
  late TextEditingController _passwordContorller;
  bool checkBoxValue = false;
  Color boxColor = const Color(0xffEBEBF1);
  TextStyle textStyle = const TextStyle(fontWeight: FontWeight.w500, fontFamily: 'SpoqaHanSansNeo', color: Colors.white, fontSize: 16.0);

  TextStyle textFieldStyle = const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'SpoqaHanSansNeo', color: Color(0xffA3A6B9), fontSize: 20);
  late bool initcheck = true;

  late SecureStorage secureStorage;

  late SimpleFontelicoProgressDialog dialog;

  @override
  void initState() {
    super.initState();
    secureStorage = SecureStorage();

    if (Env.isDebug) {
      _loginIdContoroller = TextEditingController(text: "raindrop891");
      _passwordContorller = TextEditingController(text: "raindrop891");
    } else {
      _loginIdContoroller = TextEditingController(text: "");
      _passwordContorller = TextEditingController(text: "");
    }
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    callPermissions();
    initIp().then((value) => Env.CONNECTIVITY_STREAM_SUBSCRIPTION = value);
    _checkLogin();

    //Location Permission Android
    checkDeviceLocationIsOn().then((value) {
      if (value) {
        showAlertDialog(context, text: "앱에서 위치 켜기를 요청합니다.", action: AppSettings.openLocationSettings);
      }
    });

    //Location Permission iOS
    _checkPermissionLocation().then((value) {
      if (value) {
        showAlertDialog(context, text: "앱에서 위치 접근 허용을 요청합니다.", action: AppSettings.openLocationSettings);
      }
    });

    Env.BEACON_FUNCTION = null;
    Env.EVENT_FUNCTION = null;
  }

  @override
  Widget build(BuildContext context) {
    dialog = SimpleFontelicoProgressDialog(context: context, barrierDimisable: false, duration: const Duration(milliseconds: 3000));

    return _createWillPopScope(
      Container(
        // 배경화면
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/login_background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              child: Center(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    // Header
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 0.0,
                        horizontal: 15.0,
                      ),
                      child: Text(
                        "Groupware",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xff3450FF), fontSize: 20.0),
                      ),
                    ),
                    // Logo
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 8.0,
                        bottom: 30.0,
                        left: 80.0,
                        right: 80.0,
                      ),
                      child: Image.asset(
                        'assets/workon_logo.png',
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                    // TextFeild ID, PW
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _createTextFormField(false, _loginIdContoroller, "아이디를 입력해 주세요", textFieldStyle, "Id"),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _createTextFormField(true, _passwordContorller, " 패스워드를 입력해 주세요", textFieldStyle, "Password"),
                    ),
                    FutureBuilder(
                        future: _setsaveid(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData == false) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    checkBoxValue = !checkBoxValue;
                                  });
                                  secureStorage.write(Env.KEY_ID_CHECK, checkBoxValue.toString());
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      height: 17.0,
                                      width: 17.0,
                                      alignment: Alignment.center,
                                      color: boxColor,
                                      margin: const EdgeInsets.only(right: 5),
                                      child: Checkbox(
                                        activeColor: boxColor,
                                        checkColor: const Color(0xff141E33),
                                        value: checkBoxValue,
                                        onChanged: (value) {
                                          setState(() {
                                            checkBoxValue = !checkBoxValue;
                                          });
                                          secureStorage.write(Env.KEY_ID_CHECK, checkBoxValue.toString());
                                        },
                                      ),
                                    ),
                                    Text(
                                      "ID Check",
                                      style: textStyle.copyWith(fontSize: 16, color: const Color(0xff141E33)),
                                    ),
                                    Transform.scale(
                                      scale: 1.5,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        }),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 35.0, horizontal: 16.0),
                      child: Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(8.0),
                        color: const Color(0xff3450FF),
                        child: MaterialButton(
                            height: 60.0,
                            onPressed: () {
                              dialog.show(message: '로그인 중..');
                              login(
                                _loginIdContoroller.text,
                                _passwordContorller.text,
                              ).then((loginInfo) {
                                if (loginInfo.success!) {
                                  Env.CURRENT_PAGE_INDEX = 0;
                                  Env.WORK_PHOTO_PATH = loginInfo.getPhotoPath();
                                  Env.WORK_KR_NAME = loginInfo.getKrName();
                                  Env.WORK_POSITION_NAME = loginInfo.getPositionName();
                                  Env.WORK_COMPANY_NAME = loginInfo.getCompanyName();

                                  secureStorage.write(Env.KEY_PHOTO_PATH, loginInfo.getPhotoPath());
                                  secureStorage.write(Env.KEY_KR_NAME, loginInfo.getKrName());
                                  secureStorage.write(Env.KEY_POSITION_NAME, loginInfo.getPositionName());
                                  secureStorage.write(Env.KEY_COMPANY_NAME, loginInfo.getCompanyName());

                                  secureStorage.write(Env.LOGIN_ID, _loginIdContoroller.text);
                                  secureStorage.write(Env.LOGIN_PW, _passwordContorller.text);
                                  secureStorage.write(Env.LOGIN_STATE, "true");
                                  secureStorage.write(Env.KEY_ACCESS_TOKEN, loginInfo.tokenInfo!.getAccessToken());
                                  secureStorage.write(Env.KEY_REFRESH_TOKEN, loginInfo.tokenInfo!.getRefreshToken());
                                  secureStorage.write(Env.KEY_USER_ID, loginInfo.data!["userId"].toString());
                                  _initForBeacon();
                                  _setBackgroundPath();

                                  sendMessageByWork(context, secureStorage).then((workInfo) {
                                    Env.INIT_STATE_WORK_INFO = workInfo;
                                    sendMessageByWeekWork(context, secureStorage).then((weekInfo) {
                                      Env.INIT_STATE_WEEK_INFO = weekInfo;
                                      dialog.hide();
                                      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                                    });
                                  });
                                } else {
                                  Log.debug("workIfon Error");
                                  dialog.hide();
                                  showSnackBar(context, loginInfo.message!);
                                }
                              });
                            },
                            child: const CustomText(
                              text: "로그인",
                              weight: FontWeight.w500,
                            )),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // beaconStreamSubscription.cancel();
    // eventStreamSubscription.cancel();
    super.dispose();
  }

  void _checkLogin() async {
    String? loginState = await secureStorage.read(Env.LOGIN_STATE);
    if (loginState == "true") {
      // move
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }
  }

  WillPopScope _createWillPopScope(Widget widget) {
    return WillPopScope(
        onWillPop: () {
          return _onWillPop();
        },
        child: widget);
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('프로그램 종료'),
            content: const Text('프로그램을 종료하시겠습니까?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => {
                  _stopForBeacon(),
                  Env.CONNECTIVITY_STREAM_SUBSCRIPTION!.cancel(),
                  Navigator.of(context).pop(true),
                  SystemNavigator.pop(),
                },
                child: const Text('확인'),
              ),
            ],
          ),
        ) ??
        false;
  }

  TextFormField _createTextFormField(bool isObscureText, TextEditingController controller, String message, TextStyle style, String decorationType) {
    return TextFormField(
      obscureText: isObscureText,
      controller: controller,
      validator: (value) => (value!.isEmpty) ? message : null,
      style: style,
      decoration: decorationType == "Id"
          ? InputDecoration(
              filled: true,
              fillColor: boxColor,
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 20.0, right: 10.0),
                child: Icon(
                  Icons.person_outline,
                  color: Color(0xffA3A6B9),
                ),
              ),
              hintText: "아이디",
              hintStyle: textFieldStyle,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide.none),
            )
          : InputDecoration(
              filled: true,
              fillColor: boxColor,
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 20.0, right: 10.0),
                child: Icon(
                  Icons.lock_outline,
                  color: Color(0xffA3A6B9),
                ),
              ),
              hintText: "비밀번호",
              hintStyle: textFieldStyle,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide.none),
            ),
    );
  }

  Future<String> _setsaveid() async {
    if (initcheck) {
      String? chek = await secureStorage.read(Env.KEY_ID_CHECK);
      if (chek == null) {
        setState(() {
          checkBoxValue = false;
        });
      } else if (chek == "true") {
        checkBoxValue = true;
        String? sevedid = await secureStorage.read(Env.LOGIN_ID);
        if (sevedid != null) {
          setState(() {
            _loginIdContoroller = TextEditingController(text: sevedid);
          });
        }
      } else if (chek == "false") {
        checkBoxValue = false;
      }
      initcheck = false;
    }
    return "...";
  }

  // 비콘 시작
  Future<void> _initForBeacon() async {
    Env.BEACON_STREAM_SUBSCRIPTION = startBeaconSubscription(widget.beaconStreamController, secureStorage);
    initBeacon(context, widget.beaconStreamController, secureStorage, null);
  }

  // 비콘 종료
  Future<void> _stopForBeacon() async {
    stopBeacon();
  }

  void _setBackgroundPath() async {
    Env.BACKGROUND_PATH = await secureStorage.read(Env.KEY_BACKGROUND_PATH) ?? "theme2.png";
  }

  Future<bool> _checkPermissionLocation() async {
    Location location = Location();
    PermissionStatus permissionGranted;

    if (Platform.isIOS) {
      permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        return true;
      }
    }
    return false;
  }
}
