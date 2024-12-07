import 'package:flutter/material.dart';
import 'package:qwara/api/user/user.dart';
import 'package:qwara/getX/StoreController.dart';
import 'package:sizer/sizer.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:get/get.dart' hide ScreenType;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false; // 控制密码可见性
  bool loading = false; // 控制登录按钮的loading状态
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.blue,
      appBar: AppBar(
        // leading: BackButton(
        //   onPressed: () {
        //     Navigator.pop(context);
        //   },
        // ),
          title: const Text('登录')
      ),
      body: Center(
        child: SizedBox(
          width: Device.screenType == ScreenType.mobile ? 80.w : 50.w,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Colors.black,
                ),
                child: Image.asset('assets/images/iwaraLogo.png',
                  width: 100, height: 100,
                  // color: Colors.black,
                ),
              ),
              AutofillGroup(child: Column(
                children: [
                  TextField(
                    autofillHints: const [AutofillHints.email, AutofillHints.username],
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: '电子邮件/用户名',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    autofillHints: const [AutofillHints.password],
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: '密码',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible; // 切换可见性
                          });
                        },
                      ),
                    ),
                    obscureText: !_isPasswordVisible, // 根据可见性切换
                  ),
                ],
              )),

              const SizedBox(height: 16.0),
              Skeletonizer(enabled: loading, child: ElevatedButton(
                style: ButtonStyle(
                  fixedSize: WidgetStateProperty.all( Size(100.w, 50)),
                  backgroundColor: WidgetStateProperty.all(Colors.blue),
                ),
                onPressed: () async {
                  setState(() {
                    loading = true;
                  });
                  // 在这里处理登录逻辑
                  String email = _emailController.text;
                  String password = _passwordController.text;
                  print('邮箱: $email, 密码: $password');
                  // 进行验证以及后续操作
                  if(!await login(username: email, password:password)){
                    Get.snackbar('提示', '登录失败',
                        backgroundColor: Colors.red,
                        snackPosition: SnackPosition.TOP,
                        duration: const Duration(seconds: 2));
                  }
                  setState(() {
                    loading = false;
                  });
                  // await getAccessToken();
                },
                child: const Text('登录', style: TextStyle(color: Colors.black)),
              )),
              TextButton(onPressed: () {
                storeController.setIsTourist(true);
                Get.offAndToNamed('/home');
              }, child: const Text('暂不登陆'))
            ],
          ),
        ),
      ),
    );
  }
}
