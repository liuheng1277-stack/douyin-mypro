import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';

class ThemeProvider extends ChangeNotifier {
  Color _primaryColor = AppConstants.defaultPrimaryColor;
  Color _accentColor = AppConstants.defaultAccentColor;
  String? _backgroundImage;

  Color get primaryColor => _primaryColor;
  Color get accentColor => _accentColor;
  String? get backgroundImage => _backgroundImage;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final colorStr = await DatabaseService.getSetting(AppConstants.keyThemeColor);
    if (colorStr != null && colorStr.isNotEmpty) {
      _primaryColor = Color(int.parse(colorStr));
      _accentColor = _primaryColor.withOpacity(0.8);
    }

    final bgImage = await DatabaseService.getSetting(AppConstants.keyBackgroundImage);
    if (bgImage != null && bgImage.isNotEmpty) {
      _backgroundImage = bgImage;
    }

    notifyListeners();
  }

  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color;
    _accentColor = color.withOpacity(0.8);
    await DatabaseService.setSetting(AppConstants.keyThemeColor, color.value.toString());
    notifyListeners();
  }

  Future<void> setBackgroundImage(String? path) async {
    _backgroundImage = path;
    if (path != null) {
      await DatabaseService.setSetting(AppConstants.keyBackgroundImage, path);
    } else {
      await DatabaseService.setSetting(AppConstants.keyBackgroundImage, '');
    }
    notifyListeners();
  }

  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        brightness: Brightness.light,
      ),
      primaryColor: _primaryColor,
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      appBarTheme: AppBarTheme(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white.withOpacity(0.9),
        selectedItemColor: _primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget buildBackground({required Widget child}) {
    if (_backgroundImage != null && _backgroundImage!.isNotEmpty) {
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(_backgroundImage!),
            fit: BoxFit.cover,
          ),
        ),
        child: child,
      );
    }
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
        ),
      ),
      child: child,
    );
  }
}
