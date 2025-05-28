import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:injectable/injectable.dart';
import '../../../core/constants/app_themes-example.dart';
import '../../../domain/repositories/preferences_repository-example.dart';

part 'theme_store-example.g.dart';

@singleton
class ThemeStore = _ThemeStoreBase with _$ThemeStore;

abstract class _ThemeStoreBase with Store {
  final PreferencesRepository _preferencesRepository;

  _ThemeStoreBase(this._preferencesRepository);

  @observable
  bool isDarkMode = false;

  @observable
  bool isInitialized = false;

  @observable
  String currentThemeId = 'default';

  @observable
  double fontSize = 16.0;

  @observable
  bool useSystemTheme = true;

  @observable
  String accentColor = 'blue';

  @computed
  ThemeData get lightTheme => AppThemes.getLightTheme(
    accentColor: _getAccentColor(),
    fontSize: fontSize,
  );

  @computed
  ThemeData get darkTheme => AppThemes.getDarkTheme(
    accentColor: _getAccentColor(),
    fontSize: fontSize,
  );

  @computed
  ThemeData get currentTheme => isDarkMode ? darkTheme : lightTheme;

  @computed
  Brightness get brightness => isDarkMode ? Brightness.dark : Brightness.light;

  @computed
  bool get isCustomTheme => currentThemeId != 'default';

  @computed
  List<String> get availableThemes => AppThemes.availableThemes;

  @computed
  List<String> get availableAccentColors => [
    'blue',
    'green',
    'purple',
    'orange',
    'red',
    'teal',
    'indigo',
    'pink',
  ];

  @computed
  Map<String, dynamic> get themeSettings => {
    'isDarkMode': isDarkMode,
    'useSystemTheme': useSystemTheme,
    'currentThemeId': currentThemeId,
    'fontSize': fontSize,
    'accentColor': accentColor,
  };

  Color _getAccentColor() {
    switch (accentColor) {
      case 'green':
        return Colors.green;
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      case 'red':
        return Colors.red;
      case 'teal':
        return Colors.teal;
      case 'indigo':
        return Colors.indigo;
      case 'pink':
        return Colors.pink;
      default:
        return Colors.blue;
    }
  }

  @action
  Future<void> initialize() async {
    try {
      final savedIsDarkMode = await _preferencesRepository.getBool('isDarkMode');
      final savedUseSystemTheme = await _preferencesRepository.getBool('useSystemTheme');
      final savedThemeId = await _preferencesRepository.getString('currentThemeId');
      final savedFontSize = await _preferencesRepository.getDouble('fontSize');
      final savedAccentColor = await _preferencesRepository.getString('accentColor');

      isDarkMode = savedIsDarkMode ?? false;
      useSystemTheme = savedUseSystemTheme ?? true;
      currentThemeId = savedThemeId ?? 'default';
      fontSize = savedFontSize ?? 16.0;
      accentColor = savedAccentColor ?? 'blue';

      isInitialized = true;
    } catch (e) {
      // Use defaults if loading fails
      isDarkMode = false;
      useSystemTheme = true;
      currentThemeId = 'default';
      fontSize = 16.0;
      accentColor = 'blue';
      isInitialized = true;
    }
  }

  @action
  Future<void> toggleTheme() async {
    isDarkMode = !isDarkMode;
    await _saveThemePreference();
  }

  @action
  Future<void> setDarkMode(bool dark) async {
    if (isDarkMode != dark) {
      isDarkMode = dark;
      await _saveThemePreference();
    }
  }

  @action
  Future<void> setUseSystemTheme(bool useSystem) async {
    if (useSystemTheme != useSystem) {
      useSystemTheme = useSystem;
      await _preferencesRepository.setBool('useSystemTheme', useSystem);
    }
  }

  @action
  Future<void> setTheme(String themeId) async {
    if (currentThemeId != themeId && availableThemes.contains(themeId)) {
      currentThemeId = themeId;
      await _preferencesRepository.setString('currentThemeId', themeId);
    }
  }

  @action
  Future<void> setFontSize(double size) async {
    if (size >= 12.0 && size <= 24.0 && fontSize != size) {
      fontSize = size;
      await _preferencesRepository.setDouble('fontSize', size);
    }
  }

  @action
  Future<void> setAccentColor(String color) async {
    if (accentColor != color && availableAccentColors.contains(color)) {
      accentColor = color;
      await _preferencesRepository.setString('accentColor', color);
    }
  }

  @action
  void updateSystemTheme(bool isDark) {
    if (useSystemTheme) {
      isDarkMode = isDark;
    }
  }

  @action
  Future<void> resetToDefaults() async {
    isDarkMode = false;
    useSystemTheme = true;
    currentThemeId = 'default';
    fontSize = 16.0;
    accentColor = 'blue';

    await Future.wait([
      _preferencesRepository.setBool('isDarkMode', isDarkMode),
      _preferencesRepository.setBool('useSystemTheme', useSystemTheme),
      _preferencesRepository.setString('currentThemeId', currentThemeId),
      _preferencesRepository.setDouble('fontSize', fontSize),
      _preferencesRepository.setString('accentColor', accentColor),
    ]);
  }

  Future<void> _saveThemePreference() async {
    await _preferencesRepository.setBool('isDarkMode', isDarkMode);
  }

  @action
  Color getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  @action
  String getHexFromColor(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  void dispose() {
    // Clean up if needed
  }
}