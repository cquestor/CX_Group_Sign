import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:signtogethor/bindings/main_binding.dart';
import 'package:signtogethor/pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SignTogethor',
      home: const HomePage(),
      builder: EasyLoading.init(),
      initialBinding: MainBinding(),
      theme: ThemeData.dark(),
    );
  }
}
