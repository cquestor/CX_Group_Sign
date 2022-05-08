import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:signtogethor/controllers/main_controller.dart';

class LoginPage extends GetView<MainController> {
  final int loginType;

  const LoginPage({Key? key, required this.loginType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController _usernameCtrl = TextEditingController();
    TextEditingController _passwordCtrl = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xff2d2e32),
      appBar: AppBar(
        backgroundColor: const Color(0xff38393d),
        title: const Text('登录'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: Get.width - 20,
              child: TextField(
                maxLength: 11,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                ),
                controller: _usernameCtrl,
                keyboardType: TextInputType.phone,
                cursorColor: const Color(0xffea4b76),
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.phone_android_outlined,
                    color: Color(0xffea4b76),
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xffea4b76)),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xffea4b76)),
                  ),
                  labelText: '手机号',
                  labelStyle: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                  ),
                  floatingLabelStyle: const TextStyle(
                    color: Color(0xffea4b76),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: Get.width - 20,
              child: TextField(
                maxLength: 25,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                ),
                controller: _passwordCtrl,
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                cursorColor: const Color(0xffea4b76),
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.lock_open_outlined,
                    color: Color(0xffea4b76),
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xffea4b76)),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xffea4b76)),
                  ),
                  labelText: '密码',
                  labelStyle: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                  ),
                  floatingLabelStyle: const TextStyle(
                    color: Color(0xffea4b76),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                EasyLoading.show(status: 'loading...');
                String username = _usernameCtrl.text;
                String password = _passwordCtrl.text;
                String result = await _login(username, password);
                if (result == 'success') {
                  EasyLoading.showSuccess(loginType == 1 ? '登录成功' : '添加成功',
                      duration: const Duration(milliseconds: 1500));
                  Navigator.pop(context);
                } else if (result.toString() == 'error') {
                  EasyLoading.showError('网络请求失败',
                      duration: const Duration(milliseconds: 1500));
                } else {
                  EasyLoading.showError(result.toString(),
                      duration: const Duration(milliseconds: 1500));
                }
              },
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(const Color(0xffea4b76)),
              ),
              child: SizedBox(
                width: Get.width / 4 * 3,
                height: 50,
                child: const Center(
                  child: Text(
                    '登录',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      letterSpacing: 30,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: Get.height / 5,
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _login(String username, String password) async {
    if (username == '') {
      return '账号不能为空';
    }
    if (password == '') {
      return '密码不能为空';
    }
    String text = await controller.login(username, password, loginType);
    return text;
  }
}
