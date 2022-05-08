import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:signtogethor/controllers/main_controller.dart';
import 'package:signtogethor/models/sign_model.dart';
import 'package:scan/scan.dart';

class ScanPage extends GetView<MainController> {
  final SignModel sign;

  const ScanPage({Key? key, required this.sign}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScanController scanCtrl = ScanController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('扫描二维码'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 250,
              height: 250,
              child: ScanView(
                controller: scanCtrl,
                scanAreaScale: .8,
                scanLineColor: Colors.green.shade400,
                onCapture: (data) {
                  EasyLoading.show(status: 'loading...');
                  controller.scanSign(sign, data);
                  Navigator.pop(context);
                },
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
}
