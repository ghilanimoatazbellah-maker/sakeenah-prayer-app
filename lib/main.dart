import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/providers/adhkar_progress_notifier.dart';
import 'core/providers/calc_method_notifier.dart';
import 'core/providers/location_notifier.dart';
import 'core/providers/theme_notifier.dart';
import 'core/theme/app_theme.dart';
import 'features/root_shell.dart';
import 'services/notification_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Launch UI immediately on the first frame
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => LocationNotifier()),
        ChangeNotifierProvider(create: (_) => CalcMethodNotifier()),
        ChangeNotifierProvider(create: (_) => AdhkarProgressNotifier()),
      ],
      child: const PrayerAdhkarApp(),
    ),
  );

  // Initialize secondary services asynchronously in background
  _initServicesAsync();
}

void _initServicesAsync() {
  try {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  } catch (_) {}

  try {
    NotificationService.initialize();
  } catch (_) {}
}

class PrayerAdhkarApp extends StatelessWidget {
  const PrayerAdhkarApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();

    return MaterialApp(
      title: 'سَكينة',
      debugShowCheckedModeBanner: false,

      // ── Design System (Light & Dark Themes) ─────────────────
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeNotifier.themeMode,

      // ── Arabic locale & Material Localizations ──────────────
      locale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ── Root Shell with Navigation ─────────────────────────
      home: const RootShell(),
    );
  }
}
