import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});

  final List<Color> presetColors = const [
    Color(0xFF2E7D32), // 绿色（默认）
    Color(0xFF1976D2), // 蓝色
    Color(0xFFD32F2F), // 红色
    Color(0xFF7B1FA2), // 紫色
    Color(0xFFF57C00), // 橙色
    Color(0xFF00796B), // 青色
    Color(0xFF5D4037), // 棕色
    Color(0xFF455A64), // 蓝灰
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('主题设置')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 主题色选择
          const Text(
            '主题色',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: presetColors.map((color) {
              final isSelected = themeProvider.primaryColor.value == color.value;
              return GestureDetector(
                onTap: () => themeProvider.setPrimaryColor(color),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 3)
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          // 背景图片设置
          const Text(
            '背景图片',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final image = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (image != null) {
                      await themeProvider.setBackgroundImage(image.path);
                    }
                  },
                  icon: const Icon(Icons.image),
                  label: const Text('选择背景图片'),
                ),
              ),
            ],
          ),
          if (themeProvider.backgroundImage != null) ...[
            const SizedBox(height: 12),
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage(themeProvider.backgroundImage!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => themeProvider.setBackgroundImage(null),
              child: const Text('清除背景图片'),
            ),
          ],
        ],
      ),
    );
  }
}
