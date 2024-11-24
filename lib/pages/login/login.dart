import 'package:flutter/material.dart';
import 'package:qwara/api/user/user.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false; // 控制密码可见性

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.blue,
      appBar: AppBar(title: const Text('登录')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: '电子邮件',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16.0),
            TextField(
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
            const SizedBox(height: 16.0),
            ElevatedButton(
              style: ButtonStyle(
                fixedSize: WidgetStateProperty.all(const Size(330, 50)),
                backgroundColor: WidgetStateProperty.all(Colors.blue),
              ),
              onPressed: () async {
                // 在这里处理登录逻辑
                String email = _emailController.text;
                String password = _passwordController.text;
                // 进行验证以及后续操作
                await login(username: email, password:password);
                await getAccessToken();
                print('邮箱: $email, 密码: $password');
              },
              child: const Text('登录', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
