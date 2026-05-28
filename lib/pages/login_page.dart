import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  InAppWebViewController? _webViewController;
  double _progress = 0;

  Future<void> _extractCookies() async {
    if (_webViewController == null) return;

    try {
      final cookieManager = CookieManager.instance();
      final cookies = await cookieManager.getCookies(url: WebUri(AppConstants.douyinBaseUrl));

      final cookieStr = cookies.map((c) => '${c.name}=${c.value}').join('; ');

      // 保存关键Cookie
      await DatabaseService.setSetting(AppConstants.keyDouyinCookies, cookieStr);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('登录成功，Cookie已保存')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('获取Cookie失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('抖音登录'),
        actions: [
          TextButton(
            onPressed: _extractCookies,
            child: const Text('完成登录', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(value: _progress),
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(AppConstants.douyinBaseUrl)),
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
              onProgressChanged: (controller, progress) {
                setState(() => _progress = progress / 100);
              },
              onLoadStop: (controller, url) async {
                // 页面加载完成，检查是否已登录
                final cookies = await CookieManager.instance()
                    .getCookies(url: WebUri(AppConstants.douyinBaseUrl));
                final hasSession = cookies.any((c) =>
                    c.name == 'sessionid' || c.name == 'odin_tt');

                if (hasSession) {
                  _extractCookies();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
