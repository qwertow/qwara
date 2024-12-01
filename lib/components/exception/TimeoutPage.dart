import 'package:flutter/material.dart';

class TimeoutPage extends StatelessWidget {
  const TimeoutPage({super.key, this.onRetry});
  final Function? onRetry;
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: Image.asset('assets/images/timeout01.jpg'),
            ),
            const Text(
              '请求超时！',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 这里可以添加重试逻辑
                onRetry?.call();
              },
              child: const Text('重试'),
            ),
          ],
        ),
      );
  }
}
