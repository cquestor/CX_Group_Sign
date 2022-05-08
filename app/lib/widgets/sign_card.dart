import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:signtogethor/controllers/main_controller.dart';
import 'package:signtogethor/pages/scan_page.dart';

class SignCard extends GetView<MainController> {
  final int index;
  const SignCard({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map _icons = <String, Icon>{
      '签到': const Icon(
        Icons.podcasts_outlined,
        size: 70,
      ),
      '手势签到': const Icon(
        Icons.back_hand_outlined,
        size: 70,
      ),
      '位置签到': const Icon(
        Icons.map_outlined,
        size: 70,
      ),
      '二维码签到': const Icon(
        Icons.qr_code_2_outlined,
        size: 70,
      ),
    };

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(5, 5),
            blurRadius: 5,
            spreadRadius: 3,
          ),
        ],
      ),
      margin: const EdgeInsets.all(10),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xff363739),
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            onTap: () async {
              if (controller.signList[index].type == '二维码签到') {
                bool status = await controller.requestCameraPermission();
                if (status) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              ScanPage(sign: controller.signList[index])));
                }
                return;
              }
              EasyLoading.show(status: 'loading...');
              String result =
                  await controller.sign(controller.signList[index], index);
              if (result == 'position') {
                return;
              }
              if (result == 'success') {
                EasyLoading.showSuccess('签到成功',
                    duration: const Duration(milliseconds: 1500));
              } else if (result == 'cover') {
                EasyLoading.showToast('您已经签到过了',
                    duration: const Duration(milliseconds: 1500));
              } else {
                EasyLoading.showError('有成员签到失败',
                    duration: const Duration(milliseconds: 1500));
              }
            },
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: Get.width,
              height: 90,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xff3e3f41),
                    ),
                    child: Center(
                      child: _icons[controller.signList[index].type],
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.signList[index].type,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        controller.signList[index].className,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                          color: Color(0xff858688),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        controller.signList[index].startTime,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                          color: Color(0xff858688),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Obx(
                    () => Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 40,
                            height: 90,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: controller.signList[index].status == 1
                                  ? const Color(0xff7de1c5)
                                  : const Color(0xfff95f98),
                            ),
                            child: Center(
                              child: Text(
                                controller.signList[index].status == 1
                                    ? '已\n签\n到'
                                    : '未\n签\n到',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
