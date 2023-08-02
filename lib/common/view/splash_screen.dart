import 'package:delivery_app/common/const/colors.dart';
import 'package:delivery_app/common/const/data.dart';
import 'package:delivery_app/common/dio/dio.dart';
import 'package:delivery_app/common/layout/default_layout.dart';
import 'package:delivery_app/common/secure_storage/secure_storage.dart';
import 'package:delivery_app/common/view/root_tab.dart';
import 'package:delivery_app/user/view/login_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static String get routeName => 'splash';

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      backgroundColor: PRIMARY_COLOR,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'asset/img/logo/logo.png',
              width: MediaQuery.of(context).size.width / 2,
            ),
            const SizedBox(
              height: 16,
            ),
            const CircularProgressIndicator(
              color: Colors.white,
            )
          ],
        ),
      ),
    );
  }
}
