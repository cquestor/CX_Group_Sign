import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:signtogethor/controllers/main_controller.dart';
import 'package:signtogethor/models/user_model.dart';
import 'package:signtogethor/pages/login_page.dart';
import 'package:signtogethor/widgets/sign_card.dart';
import 'package:signtogethor/widgets/user_card.dart';

class HomePage extends GetView<MainController> {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.getTasks();
    return Scaffold(
      backgroundColor: const Color(0xff2d2e32),
      appBar: AppBar(
        backgroundColor: const Color(0xff38393d),
        title: const Text('群签到'),
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xff2d2e32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: Get.width,
              height: Get.height / 4,
              color: const Color(0xff38393d),
              child: SafeArea(
                child: Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: Get.width / 8,
                        backgroundImage: AssetImage(
                            'images/${controller.userList.any((element) => element.isMain) ? 'xiaozhi' : 'anyone'}.jpg'),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Visibility(
                        visible: !controller.userList
                            .any((element) => element.isMain),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                const Color(0xffea4b76)),
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        const LoginPage(loginType: 1)));
                          },
                          child: SizedBox(
                            width: Get.width / 4,
                            height: Get.height / 24,
                            child: const Center(
                              child: Text(
                                '登录',
                                style: TextStyle(
                                  color: Colors.white,
                                  letterSpacing: 10,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: controller.userList
                            .any((element) => element.isMain),
                        child: Text(
                          controller.userList.any((element) => element.isMain)
                              ? controller.userList
                                  .where((element) => element.isMain)
                                  .toList()[0]
                                  .name
                              : '',
                          style: const TextStyle(
                            color: Colors.white,
                            letterSpacing: 10,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: controller.userList
                          .where((element) => !element.isMain)
                          .toList()
                          .asMap()
                          .map((key, value) =>
                              MapEntry(key, _toUserCard(key, value)))
                          .values
                          .toList(),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: Get.width / 6,
                          height: Get.width / 6,
                          margin: const EdgeInsets.all(30),
                          child: FloatingActionButton(
                            onPressed: () {
                              if (!controller.userList
                                  .any((element) => element.isMain)) {
                                EasyLoading.showToast('请先登录');
                                return;
                              }
                              if (controller.userList
                                      .where((element) => !element.isMain)
                                      .length >=
                                  5) {
                                EasyLoading.showToast('已达群员上限');
                                return;
                              }
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          const LoginPage(loginType: 0)));
                            },
                            backgroundColor: const Color(0xffea4b76),
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: Get.width / 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: MediaQuery.removePadding(
        removeTop: true,
        context: context,
        child: RefreshIndicator(
          onRefresh: () async {
            EasyLoading.show(status: 'loading...');
            await controller.getTasks();
            EasyLoading.dismiss();
          },
          child: Obx(() => ListView(
                children: controller.signList
                    .asMap()
                    .map((key, value) => MapEntry(key, _toSignCard(key)))
                    .values
                    .toList(),
              )),
        ),
      ),
    );
  }

  Widget _toSignCard(int index) {
    return SignCard(index: index);
  }

  Widget _toUserCard(index, UserModel user) {
    return UserCard(user: user, index: index);
  }
}
