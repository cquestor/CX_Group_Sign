import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:signtogethor/controllers/main_controller.dart';
import 'package:signtogethor/models/user_model.dart';

class UserCard extends GetView<MainController> {
  final UserModel user;
  final int index;
  const UserCard({Key? key, required this.user, required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> _images = [
      'images/pikaqiu.jpg',
      'images/jienigui.jpg',
      'images/miaowazhongzi.jpg',
      'images/bibiniao.jpg',
      'images/xiaohuolong.jpg'
    ];

    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      width: Get.width,
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xff363739),
        borderRadius: BorderRadius.circular(10),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(3, 3),
            blurRadius: 3,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage(_images[index]),
          ),
          const SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user.name,
                style: _infoStyle(),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                user.username,
                style: _infoStyle(),
              ),
            ],
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                              title: const Text('确定删除'),
                              content: const Text('删除后将无法再帮助此群员签到，您确定执行删除操作吗？'),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      _deleteUser(user);
                                      EasyLoading.showSuccess('删除成功',
                                          duration: const Duration(
                                              milliseconds: 1500));
                                      Navigator.pop(context);
                                    },
                                    child: const Text('确定')),
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('取消')),
                              ],
                            ));
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        const Color(0xffd15d8e).withOpacity(0.6)),
                  ),
                  child: const SizedBox(
                    width: 40,
                    height: 30,
                    child: Center(
                      child: Text(
                        '删除',
                        style: TextStyle(
                          color: Color(0xffd15d8e),
                          letterSpacing: 5,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _infoStyle() {
    return const TextStyle(
      color: Color(0xff858688),
      fontSize: 14,
    );
  }

  void _deleteUser(UserModel user) {
    controller.removeUser(user);
  }
}
