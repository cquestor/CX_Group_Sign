import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bmflocation/flutter_bmflocation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signtogethor/models/sign_model.dart';
import 'package:signtogethor/models/user_model.dart';
import 'package:dio/dio.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class MainController extends GetxController {
  late String appPath;
  List results = <String>[];
  List userList = <UserModel>[].obs;
  List signList = <SignModel>[].obs;
  final LocationFlutterPlugin _myLocPlugin = LocationFlutterPlugin();
  late SignModel weizhiSign;

  @override
  void onInit() async {
    super.onInit();
    EasyLoading.instance.indicatorType = EasyLoadingIndicatorType.fadingCircle;
    appPath = await _getDocPath();
    File mainUserFile = File(appPath + '/main.json');
    if (mainUserFile.existsSync()) {
      _addUserFromFile(mainUserFile);
    }
    Directory userDir = Directory(appPath + '/user');
    if (!userDir.existsSync()) {
      userDir.create();
    } else {
      for (FileSystemEntity file in userDir.listSync()) {
        File userFile = File(file.path);
        _addUserFromFile(userFile);
      }
    }
  }

  @override
  void onReady() {
    _myLocPlugin.setAgreePrivacy(true);
    _myLocPlugin.seriesLocationCallback(
        callback: (BaiduLocation result) => _weizhiPost(result));
  }

  Future<String> sign(SignModel sign, int index) async {
    results.clear();
    if (sign.type == '位置签到') {
      weizhiSign = sign;
      _signHandler(sign);
      return 'position';
    }
    await _signHandler(sign);
    if (results.every((element) => element == 'cover')) {
      signList[index].status = 1;
      return 'cover';
    } else if (results
        .every((element) => element == 'success' || element == 'cover')) {
      signList[index].status = 1;
      return 'success';
    } else {
      signList[index].status = 0;
      return 'error';
    }
  }

  Future _signHandler(SignModel sign) async {
    for (UserModel user in userList) {
      if (sign.type == '签到') {
        await _putongHandler(user, sign);
      } else if (sign.type == '手势签到') {
        await _putongHandler(user, sign);
      } else if (sign.type == '位置签到') {
        await _weizhiHandler(user, sign);
      }
    }
  }

  Future _weizhiHandler(UserModel user, SignModel sign) async {
    if ((await _requestPermission()).toString() == 'success') {
      _locationAction();
      _startLocation();
    } else {
      debugPrint('定位授权失败');
    }
  }

  Future<void> _startLocation() async {
    await _myLocPlugin.startLocation();
  }

  void _weizhiPost(BaiduLocation result) async {
    _myLocPlugin.stopLocation();
    await _weizhiFor(result);
  }

  Future _weizhiFor(BaiduLocation result) async {
    for (UserModel user in userList) {
      await _weizhiSub(user, result);
    }
    if (results.every((element) => element == 'cover')) {
      signList.singleWhere((element) => element.id == weizhiSign.id).status = 1;
      EasyLoading.showToast('您已经签到过了',
          duration: const Duration(milliseconds: 1500));
    } else if (results
        .every((element) => element == 'success' || element == 'cover')) {
      signList.singleWhere((element) => element.id == weizhiSign.id).status = 1;
      EasyLoading.showSuccess('签到成功',
          duration: const Duration(milliseconds: 1500));
    } else {
      signList.singleWhere((element) => element.id == weizhiSign.id).status = 0;
      EasyLoading.showError('有成员签到失败',
          duration: const Duration(milliseconds: 1500));
    }
  }

  Future _weizhiSub(UserModel user, BaiduLocation location) async {
    String address = location.address.toString() +
        location.locationDetail
            .toString()
            .replaceFirst('在', '')
            .replaceAll('附近', '');
    String url =
        'https://mobilelearn.chaoxing.com/pptSign/stuSignajax?name=${Uri.encodeComponent(user.name)}&address=${Uri.encodeComponent(address)}&activeId=${weizhiSign.id}&uid=${user.id}&clientip=&latitude=${location.latitude}&longitude=${location.longitude}&fid=1283&appType=15&ifTiJiao=1';
    Map<String, dynamic> headers = {
      'Cookie': user.cookie,
    };
    http.Options options = http.Options();
    options.headers = headers;
    http.Response response = await http.Dio().get(url, options: options);
    if (response.data.toString() == 'success') {
      results.add('success');
    } else if (response.data.toString() == '您已签到过了') {
      results.add('cover');
    } else {
      results.add('error');
    }
  }

  Future scanSign(SignModel sign, String result) async {
    for (UserModel user in userList) {
      await _scanSignSub(sign, user, result);
    }
    if (results.every((element) => element == 'cover')) {
      signList.singleWhere((element) => element.id == sign.id).status = 1;
      EasyLoading.showToast('您已经签到过了',
          duration: const Duration(milliseconds: 1500));
    } else if (results
        .every((element) => element == 'success' || element == 'cover')) {
      signList.singleWhere((element) => element.id == sign.id).status = 1;
      EasyLoading.showSuccess('签到成功',
          duration: const Duration(milliseconds: 1500));
    } else {
      signList.singleWhere((element) => element.id == sign.id).status = 0;
      EasyLoading.showError('有成员签到失败',
          duration: const Duration(milliseconds: 1500));
    }
  }

  Future _scanSignSub(SignModel sign, UserModel user, String result) async {
    String enc = result.split('enc=')[1];
    String url =
        'https://mobilelearn.chaoxing.com/pptSign/stuSignajax?enc=$enc&name=${Uri.encodeComponent(user.name)}&activeId=${sign.id}&uid=${user.id}&clientip=&useragent=&latitude=-1&longitude=-1&fid=1283&appType=15';
    Map<String, dynamic> headers = {
      'Cookie': user.cookie,
    };
    http.Options options = http.Options();
    options.headers = headers;
    http.Response response = await http.Dio().get(url, options: options);
    if (response.data.toString() == 'success') {
      results.add('success');
    } else if (response.data.toString() == '您已签到过了') {
      results.add('cover');
    } else {
      results.add('error');
    }
  }

  void _locationAction() async {
    Map iosMap = initIOSOptions().getMap();
    Map androidMap = initAndroidOptions().getMap();
    await _myLocPlugin.prepareLoc(androidMap, iosMap);
  }

  BaiduLocationIOSOption initIOSOptions() {
    BaiduLocationIOSOption options = BaiduLocationIOSOption(
        coordType: BMFLocationCoordType.bd09ll,
        BMKLocationCoordinateType: 'BMKLocationCoordinateTypeBMK09LL',
        desiredAccuracy: BMFDesiredAccuracy.best);
    return options;
  }

  BaiduLocationAndroidOption initAndroidOptions() {
    BaiduLocationAndroidOption options = BaiduLocationAndroidOption(
        coorType: 'bd09ll',
        locationMode: BMFLocationMode.hightAccuracy,
        isNeedAddress: true,
        isNeedAltitude: true,
        isNeedLocationPoiList: true,
        isNeedNewVersionRgc: true,
        isNeedLocationDescribe: true,
        openGps: true,
        locationPurpose: BMFLocationPurpose.sport,
        coordType: BMFLocationCoordType.bd09ll);
    return options;
  }

  Future<String> _requestPermission() async {
    bool hasLocationPermission = await requestLocationPermission();
    if (!hasLocationPermission) {
      SystemNavigator.pop();
    }
    return 'success';
  }

  Future<bool> requestLocationPermission() async {
    var status = await Permission.location.status;
    if (status == PermissionStatus.granted) {
      return true;
    } else {
      status = await Permission.location.request();
      if (status == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
  }

  Future<bool> requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (status == PermissionStatus.granted) {
      return true;
    } else {
      status = await Permission.camera.request();
      if (status == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
  }

  Future _putongHandler(UserModel user, SignModel sign) async {
    Map<String, dynamic> headers = {
      'Cookie': user.cookie,
    };
    http.Options options = http.Options();
    options.headers = headers;
    options.responseType = http.ResponseType.plain;
    http.Response response = await http.Dio().get(
        'https://mobilelearn.chaoxing.com/pptSign/stuSignajax?activeId=${sign.id}&uid=${user.id}&clientip=&useragent=&latitude=-1&longitude=-1&appType=15&fid=1283&name=${Uri.encodeComponent(user.name)}',
        options: options);
    if (response.data.toString() == 'success') {
      results.add('success');
    } else if (response.data.toString() == '您已签到过了') {
      results.add('cover');
    } else {
      results.add('error');
    }
  }

  Future getTasks() async {
    if (userList.isEmpty) {
      return;
    } else {
      signList.clear();
      UserModel mainUser = userList.singleWhere((element) => element.isMain);
      Map<String, dynamic> headers = {
        'Cookie': mainUser.cookie,
      };
      http.Options options = http.Options();
      options.headers = headers;
      options.responseType = http.ResponseType.plain;
      http.FormData requestData = http.FormData.fromMap({
        "courseType": 1,
        "courseFolderId": 0,
        "baseEducation": 0,
        "courseFolderSize": 0,
      });
      http.Response response = await http.Dio().post(
        'http://mooc1-2.chaoxing.com/visit/courselistdata',
        data: requestData,
        options: options,
      );
      String html = response.data.toString();
      RegExp courseIdPattern = RegExp(
          r'"color1" href="https://mooc1-2.chaoxing.com/visit/stucoursemiddle?(.*?)"');
      var courseIds = courseIdPattern.allMatches(html).toList();
      RegExp courseNamePattern = RegExp(r'overHidden2" title="(.*)"');
      var courseNames = courseNamePattern.allMatches(html).toList();
      for (var i = 0; i < courseIds.length; i++) {
        String courseUrl = courseIds[i].group(0).toString();
        String courseName = courseNames[i]
            .group(0)
            .toString()
            .split('=')[1]
            .replaceAll('"', '');
        RegExp courseidPattern = RegExp(r'courseid=(.*?)&');
        RegExp clazzidPattern = RegExp(r'clazzid=(.*?)&');
        var courseid = courseidPattern
            .stringMatch(courseUrl)!
            .split('=')[1]
            .replaceAll('&', '');
        var clazzid = clazzidPattern
            .stringMatch(courseUrl)!
            .split('=')[1]
            .replaceAll('&', '');
        Map courseInfo = {
          'courseid': courseid,
          'clazzid': clazzid,
          'courseName': courseName,
        };
        _checkSigns(courseInfo, options);
      }
    }
  }

  void _checkSigns(Map courseInfo, http.Options options) async {
    String url =
        "https://mobilelearn.chaoxing.com/v2/apis/active/student/activelist?fid=0&courseId=${courseInfo['courseid']}&classId=${courseInfo['clazzid']}";
    http.Response response = await http.Dio().get(url, options: options);
    Map<String, dynamic> responseJson = jsonDecode(response.data.toString());
    if (responseJson['result'] != 1) {
      EasyLoading.showError('操作过于频繁',
          duration: const Duration(milliseconds: 1500));
      return;
    } else {
      for (var task in responseJson['data']['activeList']) {
        if (task['activeType'] == 2 &&
            task['attendNum'] == 0 &&
            task['groupId'] == 1) {
          response = await http.Dio().get(
              'https://mobilelearn.chaoxing.com/v2/apis/sign/getAttendInfo?activeId=${task['id']}',
              options: options);
          Map<String, dynamic> responseJson =
              jsonDecode(response.data.toString());
          signList.add(SignModel(
              task['id'].toString(),
              courseInfo['clazzid'],
              DateTime.fromMillisecondsSinceEpoch(task['startTime'])
                  .toString()
                  .split('.')[0],
              task['nameOne'],
              courseInfo['courseName'],
              responseJson['data']['status']));
        }
      }
    }
  }

  Future<String> login(String username, String password, int type) async {
    return (await _requestLogin(username, password, type)).toString();
  }

  Future<String> _requestLogin(
      String username, String password, int type) async {
    http.FormData requestData = http.FormData.fromMap({
      "fid": "1283",
      "uname": username,
      "password": base64.encode(utf8.encode(password)),
      "refer": "http%3A%2F%2Fi.mooc.chaoxing.com",
      "t": "true",
      "validate": "",
    });
    http.Response response = await http.Dio()
        .post('https://passport2.chaoxing.com/fanyalogin', data: requestData);
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.data.toString());
      if (responseData['status']) {
        String cookie = '';
        String uid = '';
        for (var element in response.headers['set-cookie']!) {
          cookie += element.split(';')[0] + ";";
          if (element.startsWith('UID')) {
            uid = element.split(';')[0].split('=')[1];
          }
        }
        Map<String, dynamic> headers = {
          'Cookie': cookie,
        };
        http.Options options = http.Options();
        options.headers = headers;
        responseData = await http.Dio()
            .get('http://i.mooc.chaoxing.com/settings/info', options: options);
        String html = responseData.data.toString();
        RegExp namePattern = RegExp(r'class="personalName" title="(.*?)"');
        String name = namePattern
            .stringMatch(html)!
            .split('title=')[1]
            .replaceAll('"', '');
        if (userList.any((element) => element.id == uid)) {
          return '用户已存在';
        } else {
          _addUser(UserModel(uid, name, username, password, cookie, type == 1),
              type);
          return 'success';
        }
      } else {
        return responseData['msg2'];
      }
    } else {
      return 'error';
    }
  }

  void _addUser(UserModel user, int type) {
    File userFile =
        File(appPath + (type == 1 ? "/main.json" : "/user/${user.id}.json"));
    userFile
        .create()
        .then((value) => userFile.writeAsString(jsonEncode(user.toJson())));
    userList.add(user);
  }

  void removeUser(UserModel user) {
    File userFile = File(appPath + "/user/${user.id}.json");
    if (userFile.existsSync()) {
      userFile.delete();
    }
    userList.remove(user);
  }

  Future _addUserFromFile(File file) async {
    userList.add(UserModel.formJson(jsonDecode(await file.readAsString())));
  }

  Future<String> _getDocPath() async {
    return (await getApplicationDocumentsDirectory()).path;
  }
}
