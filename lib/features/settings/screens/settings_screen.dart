import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/calc_method_notifier.dart';
import '../../../core/providers/theme_notifier.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Settings Screen — Theme Mode, Prayer calculation method, Notification toggles,
/// and location settings with full Dark Mode and local notification support.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _prayerNotifications = true;
  bool _adhkarReminders = true;
  bool _useAutoLocation = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _prayerNotifications = prefs.getBool('prayer_notif') ?? true;
      _adhkarReminders = prefs.getBool('adhkar_notif') ?? true;
      _useAutoLocation = prefs.getBool('auto_location') ?? true;
    });
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  String _getThemeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'تلقائي (حسب النظام)';
      case ThemeMode.light:
        return 'وضع النهار (فاتح)';
      case ThemeMode.dark:
        return 'الوضع الليلي (داكن)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final calcNotifier = context.watch<CalcMethodNotifier>();
    final themeNotifier = context.watch<ThemeNotifier>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.containerMargin,
            vertical: 16,
          ),
          children: [
            _buildSectionHeader('المظهر والثيم', isDark),
            _buildThemeSelectorTile(themeNotifier, isDark),
            const SizedBox(height: 16),
            _buildSectionHeader('مواقيت الصلاة', isDark),
            _buildCalculationMethodTile(calcNotifier, isDark),
            const SizedBox(height: 16),
            _buildSectionHeader('التنبيهات والإشعارات', isDark),
            _buildSwitchTile(
              title: 'تنبيهات مواقيت الصلاة',
              subtitle: 'إرسال إشعار عند حلول وقت كل صلاة',
              icon: Icons.notifications_active_outlined,
              value: _prayerNotifications,
              isDark: isDark,
              onChanged: (val) async {
                setState(() => _prayerNotifications = val);
                await _saveBool('prayer_notif', val);
                if (!val) {
                  await NotificationService.cancelAll();
                } else {
                  await NotificationService.showInstantNotification(
                    id: 999,
                    title: 'تنبيهات الصلاة مفعلة',
                    body: 'سيتم تنبيهك عند حلول مواقيت الصلاة اليومية بإذن الله.',
                  );
                }
              },
            ),
            const SizedBox(height: 8),
            _buildSwitchTile(
              title: 'تذكير أذكار الصباح والمساء',
              subtitle: 'تذكير يومي في الوقت المحدد للأذكار',
              icon: Icons.access_time_rounded,
              value: _adhkarReminders,
              isDark: isDark,
              onChanged: (val) {
                setState(() => _adhkarReminders = val);
                _saveBool('adhkar_notif', val);
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                side: BorderSide(
                  color: isDark
                      ? AppColorsDark.outlineVariant
                      : AppColors.surfaceContainerHighest,
                ),
              ),
              tileColor: isDark
                  ? AppColorsDark.level1Card
                  : AppColors.level1Card,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColorsDark.secondary.withValues(alpha: 0.15)
                      : AppColors.secondary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_active_rounded,
                  color: isDark ? AppColorsDark.secondary : AppColors.secondary,
                  size: 20,
                ),
              ),
              title: Text(
                'تجربة إشعار الأذان الفوري',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                  color: isDark ? AppColorsDark.onSurface : AppColors.onSurface,
                ),
              ),
              subtitle: Text(
                'إرسال إشعار تجريبي لاختبار الصوت والظهور',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColorsDark.onSurfaceVariant
                      : AppColors.onSurfaceVariant,
                ),
              ),
              trailing: Icon(
                Icons.send_rounded,
                color: isDark ? AppColorsDark.secondary : AppColors.secondary,
                size: 18,
              ),
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                await NotificationService.showInstantNotification(
                  id: 1001,
                  title: 'حان الآن وقت صلاة الظهر 🕌',
                  body: 'حي على الصلاة، حي على الفلاح — تجربة تطبيق سَكِينة',
                );
                if (mounted) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('تم إرسال إشعار التجربة بنجاح!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            _buildSectionHeader('الموقع والمدينة', isDark),
            _buildSwitchTile(
              title: 'التحديد التلقائي للموقع (GPS)',
              subtitle: 'تحديد الإحداثيات وتوقيت الصلاة تلقائياً',
              icon: Icons.my_location_rounded,
              value: _useAutoLocation,
              isDark: isDark,
              onChanged: (val) {
                setState(() => _useAutoLocation = val);
                _saveBool('auto_location', val);
              },
            ),
            const SizedBox(height: 16),
            _buildSectionHeader('عن التطبيق', isDark),
            _buildInfoTile(
              title: 'التطبيق',
              subtitle: 'سَكِينة — مواقيت وأذكار (الإصدار 1.2.0)',
              icon: Icons.info_outline_rounded,
              isDark: isDark,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColorsDark.primary : AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildThemeSelectorTile(ThemeNotifier themeNotifier, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.level1Card : AppColors.level1Card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark
              ? AppColorsDark.outlineVariant
              : AppColors.surfaceContainerHighest,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColorsDark.surfaceContainer
                  : AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppRadius.base),
            ),
            child: Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: isDark ? AppColorsDark.secondary : AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'وضع المظهر (الثيم)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getThemeLabel(themeNotifier.themeMode),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColorsDark.secondary
                        : AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<ThemeMode>(
            icon: Icon(Icons.arrow_drop_down_rounded,
                color: isDark ? AppColorsDark.primary : AppColors.primary),
            onSelected: (mode) {
              themeNotifier.setThemeMode(mode);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: ThemeMode.system,
                child: Text('تلقائي (حسب إعدادات النظام)'),
              ),
              const PopupMenuItem(
                value: ThemeMode.light,
                child: Text('وضع النهار (فاتح)'),
              ),
              const PopupMenuItem(
                value: ThemeMode.dark,
                child: Text('الوضع الليلي (داكن)'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required bool isDark,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.level1Card : AppColors.level1Card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark
              ? AppColorsDark.outlineVariant
              : AppColors.surfaceContainerHighest,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColorsDark.surfaceContainer
                  : AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppRadius.base),
            ),
            child: Icon(icon,
                color: isDark ? AppColorsDark.primary : AppColors.primary,
                size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColorsDark.onSurfaceVariant
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor:
                isDark ? AppColorsDark.secondary : AppColors.primaryContainer,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationMethodTile(
      CalcMethodNotifier calcNotifier, bool isDark) {
    final selectedMethod = calcNotifier.selectedMethod;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.level1Card : AppColors.level1Card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark
              ? AppColorsDark.outlineVariant
              : AppColors.surfaceContainerHighest,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColorsDark.surfaceContainer
                  : AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppRadius.base),
            ),
            child: Icon(
              Icons.calculate_outlined,
              color: isDark ? AppColorsDark.primary : AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'طريقة حساب المواقيت',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  selectedMethod,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColorsDark.secondary
                        : AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.arrow_drop_down_rounded,
                color: isDark ? AppColorsDark.primary : AppColors.primary),
            onSelected: (method) {
              calcNotifier.setMethod(method);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'الهيئة العامة المصرية للمساحة (شمال أفريقيا)',
                child: Text('الهيئة المصرية للمساحة (شمال أفريقيا)'),
              ),
              const PopupMenuItem(
                value: 'طريقة المغرب وشمال أفريقيا',
                child: Text('طريقة المغرب وشمال أفريقيا'),
              ),
              const PopupMenuItem(
                value: 'رابطة العالم الإسلامي',
                child: Text('رابطة العالم الإسلامي (MWL)'),
              ),
              const PopupMenuItem(
                value: 'أم القرى (مكة المكرمة)',
                child: Text('أم القرى (مكة المكرمة)'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.level1Card : AppColors.level1Card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark
              ? AppColorsDark.outlineVariant
              : AppColors.surfaceContainerHighest,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColorsDark.surfaceContainer
                  : AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppRadius.base),
            ),
            child: Icon(icon,
                color: isDark ? AppColorsDark.primary : AppColors.primary,
                size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColorsDark.onSurfaceVariant
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
