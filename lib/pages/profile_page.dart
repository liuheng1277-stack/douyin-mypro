import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';
import 'login_page.dart';
import 'settings/theme_settings_page.dart';
import 'settings/sync_settings_page.dart';
import 'settings/download_settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final cookies = await DatabaseService.getSetting(AppConstants.keyDouyinCookies);
    setState(() => _isLoggedIn = cookies != null && cookies.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return themeProvider.buildBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: themeProvider.primaryColor,
          title: const Text('我的'),
        ),
        body: ListView(
          children: [
            // 用户信息卡片
            _buildUserCard(themeProvider),
            const SizedBox(height: 16),

            // 设置列表
            _buildSettingsGroup(
              title: '外观',
              children: [
                _buildSettingItem(
                  icon: Icons.color_lens,
                  title: '主题设置',
                  subtitle: '更换主题色和背景',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ThemeSettingsPage()),
                  ),
                ),
              ],
            ),

            _buildSettingsGroup(
              title: '同步',
              children: [
                _buildSettingItem(
                  icon: Icons.sync,
                  title: '同步设置',
                  subtitle: '配置自动同步规则',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SyncSettingsPage()),
                  ),
                ),
                _buildSettingItem(
                  icon: Icons.login,
                  title: '抖音登录',
                  subtitle: _isLoggedIn ? '已登录' : '未登录',
                  trailing: _isLoggedIn
                      ? TextButton(
                          onPressed: () async {
                            await DatabaseService.setSetting(
                                AppConstants.keyDouyinCookies, '');
                            setState(() => _isLoggedIn = false);
                          },
                          child: const Text('退出登录'),
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: _isLoggedIn
                      ? null
                      : () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginPage()),
                          );
                          if (result == true) {
                            setState(() => _isLoggedIn = true);
                          }
                        },
                ),
              ],
            ),

            _buildSettingsGroup(
              title: '下载',
              children: [
                _buildSettingItem(
                  icon: Icons.download,
                  title: '下载设置',
                  subtitle: '下载目录、同时下载数等',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DownloadSettingsPage()),
                  ),
                ),
              ],
            ),

            _buildSettingsGroup(
              title: '关于',
              children: [
                _buildSettingItem(
                  icon: Icons.info,
                  title: '版本',
                  subtitle: AppConstants.appVersion,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [themeProvider.primaryColor, themeProvider.accentColor],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: themeProvider.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 40, color: themeProvider.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '抖下载用户',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isLoggedIn ? '已绑定抖音账号' : '未登录抖音',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
