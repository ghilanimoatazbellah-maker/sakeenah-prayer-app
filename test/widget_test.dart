import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_adhkar_app/core/providers/location_notifier.dart';
import 'package:prayer_adhkar_app/core/providers/theme_notifier.dart';
import 'package:prayer_adhkar_app/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('AppTheme Light and Dark configuration test',
      (WidgetTester tester) async {
    final lightTheme = AppTheme.light;
    expect(lightTheme.colorScheme.primary, AppColors.primary);
    expect(lightTheme.colorScheme.primaryContainer, AppColors.primaryContainer);
    expect(lightTheme.colorScheme.secondary, AppColors.secondary);
    expect(lightTheme.scaffoldBackgroundColor, AppColors.background);

    final darkTheme = AppTheme.dark;
    expect(darkTheme.brightness, Brightness.dark);
    expect(darkTheme.colorScheme.primary, AppColorsDark.primary);
    expect(darkTheme.colorScheme.secondary, AppColorsDark.secondary);
    expect(darkTheme.scaffoldBackgroundColor, AppColorsDark.background);
  });

  test('ThemeNotifier changes and persists theme mode', () async {
    final notifier = ThemeNotifier();
    expect(notifier.themeMode, ThemeMode.system);

    await notifier.setThemeMode(ThemeMode.dark);
    expect(notifier.themeMode, ThemeMode.dark);
    expect(notifier.isDarkMode, true);

    await notifier.setThemeMode(ThemeMode.light);
    expect(notifier.themeMode, ThemeMode.light);
    expect(notifier.isDarkMode, false);
  });

  test('LocationNotifier manual city change test', () async {
    final loc = LocationNotifier();
    expect(loc.latitude, LocationNotifier.defaultLat);
    expect(loc.longitude, LocationNotifier.defaultLng);

    await loc.setManualLocation(
      lat: 36.1911,
      lng: 5.4137,
      name: 'سطيف، الجزائر',
    );

    expect(loc.latitude, 36.1911);
    expect(loc.longitude, 5.4137);
    expect(loc.locationLabel, 'سطيف');
    expect(loc.isAutoGps, false);
  });

  testWidgets('MaterialApp Arabic Directionality test',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        locale: const Locale('ar'),
        home: const Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Text('سَكِينة'),
          ),
        ),
      ),
    );

    expect(find.text('سَكِينة'), findsOneWidget);
  });
}
