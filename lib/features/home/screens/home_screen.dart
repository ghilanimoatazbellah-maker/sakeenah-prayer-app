import 'dart:async';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/adhkar_progress_notifier.dart';
import '../../../core/providers/calc_method_notifier.dart';
import '../../../core/providers/location_notifier.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/notification_service.dart';
import '../../adhkar/screens/adhkar_detail_screen.dart';
import '../widgets/location_picker_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PrayerDisplayMode {
  postAdhanActive, // Within 30 minutes after prayer time (+00:15:00 after prayer)
  upcomingCountdown, // After 30 min, counting down to next prayer
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PrayerTimes _prayerTimes;
  late Timer _ticker;

  String _hijriDateText = '';
  PrayerDisplayMode _displayMode = PrayerDisplayMode.upcomingCountdown;
  String _heroPrayerTitle = '';
  String _heroPrayerSubtitle = '';
  String _timerDigits = '00:00:00';
  String _timerLabel = '';
  Prayer? _activeHighlightedPrayer;

  @override
  void initState() {
    super.initState();
    _hijriDateText = _getFormattedHijriDate();

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        _updatePrayerState();
      }
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  String _getFormattedHijriDate() {
    try {
      final h = HijriCalendar.now();
      const months = [
        'محرم',
        'صفر',
        'ربيع الأول',
        'ربيع الثاني',
        'جمادى الأولى',
        'جمادى الآخرة',
        'رجب',
        'شعبان',
        'رمضان',
        'شوال',
        'ذو القعدة',
        'ذو الحجة'
      ];
      final monthName = (h.hMonth >= 1 && h.hMonth <= 12)
          ? months[h.hMonth - 1]
          : 'رمضان';

      return '${h.hDay} $monthName ${h.hYear} هـ';
    } catch (_) {
      return '٨ ربيع الأول ١٤٤٨ هـ';
    }
  }

  void _calculatePrayerTimes(
      double lat, double lng, CalculationParameters params) {
    final coordinates = Coordinates(lat, lng);
    _prayerTimes = PrayerTimes(
      coordinates: coordinates,
      date: DateTime.now(),
      calculationParameters: params,
    );
    _updatePrayerState();
    _scheduleNotificationsIfEnabled();
  }

  Future<void> _scheduleNotificationsIfEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool('prayer_notif') ?? true;
      if (!enabled) return;

      await NotificationService.scheduleAllDailyPrayers(_prayerTimes);
    } catch (_) {}
  }

  void _updatePrayerState() {
    final now = DateTime.now();
    final prayerList = [
      (Prayer.fajr, 'الفجر', _prayerTimes.fajr.toLocal()),
      (Prayer.dhuhr, 'الظهر', _prayerTimes.dhuhr.toLocal()),
      (Prayer.asr, 'العصر', _prayerTimes.asr.toLocal()),
      (Prayer.maghrib, 'المغرب', _prayerTimes.maghrib.toLocal()),
      (Prayer.isha, 'العشاء', _prayerTimes.isha.toLocal()),
    ];

    // Check if any prayer occurred in the last 30 minutes
    (Prayer, String, DateTime)? recentlyPassedPrayer;
    for (final p in prayerList) {
      final diff = now.difference(p.$3);
      if (diff.inSeconds >= 0 && diff.inMinutes < 30) {
        recentlyPassedPrayer = p;
        break;
      }
    }

    if (recentlyPassedPrayer != null) {
      // 1. Within 30 min window: Count UP (+00:15:20 بعد الصلاة)
      final elapsed = now.difference(recentlyPassedPrayer.$3);
      setState(() {
        _displayMode = PrayerDisplayMode.postAdhanActive;
        _heroPrayerSubtitle = 'حان الآن وقت صلاة';
        _heroPrayerTitle = recentlyPassedPrayer!.$2;
        _timerDigits = _formatDuration(elapsed);
        _timerLabel = 'بعد الصلاة';
        _activeHighlightedPrayer = recentlyPassedPrayer.$1;
      });
    } else {
      // 2. After 30 min window: Count DOWN to the next prayer
      final nextPrayer = _prayerTimes.nextPrayer(date: now);
      final nextTimeLocal = _prayerTimes.timeForPrayer(nextPrayer).toLocal();
      final remaining = nextTimeLocal.difference(now);

      setState(() {
        _displayMode = PrayerDisplayMode.upcomingCountdown;
        _heroPrayerSubtitle = 'الصلاة القادمة بإذن الله';
        _heroPrayerTitle = _prayerNameArabic(nextPrayer);
        _timerDigits = _formatDuration(remaining);
        _timerLabel = 'متبقية';
        _activeHighlightedPrayer = nextPrayer;
      });
    }
  }

  Prayer _normalizePrayer(Prayer? prayer) {
    if (prayer == null) return Prayer.fajr;
    if (prayer == Prayer.fajrAfter) return Prayer.fajr;
    if (prayer == Prayer.ishaBefore) return Prayer.isha;
    return prayer;
  }

  String _prayerNameArabic(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
      case Prayer.fajrAfter:
        return 'الفجر';
      case Prayer.sunrise:
        return 'الشروق';
      case Prayer.dhuhr:
        return 'الظهر';
      case Prayer.asr:
        return 'العصر';
      case Prayer.maghrib:
        return 'المغرب';
      case Prayer.isha:
      case Prayer.ishaBefore:
        return 'العشاء';
    }
  }

  String _formatDuration(Duration d) {
    if (d.isNegative) return '00:00:00';
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String _formatTime(DateTime time) {
    final localTime = time.toLocal();
    final h = localTime.hour.toString().padLeft(2, '0');
    final m = localTime.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  AdhkarType _currentAdhkarType() {
    final now = DateTime.now();
    try {
      final current = _prayerTimes.currentPrayer(date: now);
      switch (current) {
        case Prayer.fajr:
        case Prayer.sunrise:
        case Prayer.dhuhr:
          return AdhkarType.sabah;
        case Prayer.asr:
        case Prayer.maghrib:
          return AdhkarType.massa;
        case Prayer.isha:
        case Prayer.fajrAfter:
          return AdhkarType.sleep;
        default:
          break;
      }
    } catch (_) {}

    // Precise Time-of-Day Fallback:
    final hour = now.hour;
    if (hour >= 4 && hour < 15) {
      return AdhkarType.sabah;
    } else if (hour >= 15 && hour < 22) {
      return AdhkarType.massa;
    } else {
      return AdhkarType.sleep;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locNotifier = context.watch<LocationNotifier>();
    final calcParams = context.watch<CalcMethodNotifier>().params;

    _calculatePrayerTimes(
        locNotifier.latitude, locNotifier.longitude, calcParams);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.containerMargin,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),

              // 1. Top Bar with Zero Overflow & Prominent Location Button
              _buildTopBar(context, locNotifier, isDark),

              const SizedBox(height: 18),

              // 2. Luxury Hero Next / Active Prayer Card
              _buildHeroPrayerCard(isDark),

              const SizedBox(height: 22),

              // 3. Prayer Timeline Cards with 30-min window highlighting
              _buildPrayerTimeline(_activeHighlightedPrayer, isDark),

              const SizedBox(height: 22),

              // 4. Clickable Luxury Adhkar Daily Progress Card
              _buildAdhkarProgressCard(context, isDark),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(
      BuildContext context, LocationNotifier locNotifier, bool isDark) {
    return Row(
      children: [
        // Hijri Date Badge
        Expanded(
          flex: 5,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColorsDark.surfaceContainer
                  : AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(
                color: isDark
                    ? AppColorsDark.outlineVariant
                    : AppColors.surfaceContainerHighest,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    _hijriDateText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color:
                          isDark ? AppColorsDark.onSurface : AppColors.primary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Prominent Clickable Location Button
        Expanded(
          flex: 4,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => LocationPickerSheet.show(context),
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E3831)
                      : const Color(0xFFE8F3EF),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                    color: isDark
                        ? AppColorsDark.secondary
                        : const Color(0xFF29695B),
                    width: 1.3,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 15,
                      color: isDark
                          ? AppColorsDark.secondary
                          : const Color(0xFF29695B),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        locNotifier.locationLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColorsDark.secondary
                              : const Color(0xFF00382E),
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: isDark
                          ? AppColorsDark.secondary
                          : const Color(0xFF29695B),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroPrayerCard(bool isDark) {
    final isActivePost = _displayMode == PrayerDisplayMode.postAdhanActive;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: isDark
              ? (isActivePost
                  ? [
                      const Color(0xFF15483D),
                      const Color(0xFF0F3B32),
                      const Color(0xFF07211C),
                    ]
                  : [
                      const Color(0xFF0F3B32),
                      const Color(0xFF0A2923),
                      const Color(0xFF051714),
                    ])
              : (isActivePost
                  ? [
                      const Color(0xFF00695C),
                      const Color(0xFF004D40),
                      const Color(0xFF00332B),
                    ]
                  : [
                      const Color(0xFF004D40),
                      const Color(0xFF00382E),
                      const Color(0xFF002720),
                    ]),
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF004D40).withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isActivePost
              ? const Color(0xFF7EBDAC)
              : const Color(0xFFFED488).withValues(alpha: 0.3),
          width: 1.3,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: -20,
            bottom: -20,
            child: Icon(
              Icons.mosque_rounded,
              size: 130,
              color: Colors.white.withValues(alpha: 0.04),
            ),
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isActivePost
                        ? Icons.check_circle_rounded
                        : Icons.auto_awesome_rounded,
                    size: 14,
                    color: AppColors.secondaryFixedDim,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _heroPrayerSubtitle,
                    style: const TextStyle(
                      color: AppColors.secondaryFixedDim,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _heroPrayerTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  border: Border.all(
                    color: const Color(0xFFFED488),
                    width: 1.6,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFED488).withValues(alpha: 0.25),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        isActivePost ? '+$_timerDigits' : _timerDigits,
                        style: const TextStyle(
                          color: Color(0xFFFED488),
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _timerLabel,
                      style: const TextStyle(
                        color: Color(0xFFFED488),
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimeline(Prayer? activePrayer, bool isDark) {
    final prayers = <(Prayer, String, DateTime, IconData)>[
      (Prayer.fajr, 'الفجر', _prayerTimes.fajr, Icons.wb_twilight_rounded),
      (Prayer.dhuhr, 'الظهر', _prayerTimes.dhuhr, Icons.wb_sunny_rounded),
      (Prayer.asr, 'العصر', _prayerTimes.asr, Icons.wb_cloudy_rounded),
      (Prayer.maghrib, 'المغرب', _prayerTimes.maghrib, Icons.nightlight_round),
      (Prayer.isha, 'العشاء', _prayerTimes.isha, Icons.bedtime_rounded),
    ];

    final normalizedActive = _normalizePrayer(activePrayer);

    return Column(
      children: prayers.map((p) {
        final isActive = p.$1 == normalizedActive;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          decoration: BoxDecoration(
            color: isActive
                ? (isDark
                    ? const Color(0xFF1E3831)
                    : const Color(0xFFE8F3EF))
                : (isDark
                    ? AppColorsDark.level1Card
                    : AppColors.level1Card),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: isActive
                ? Border.all(
                    color: isDark
                        ? AppColorsDark.secondary
                        : const Color(0xFF29695B),
                    width: 1.8,
                  )
                : Border.all(
                    color: isDark
                        ? AppColorsDark.outlineVariant
                        : AppColors.surfaceContainerHighest,
                  ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFF29695B).withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatTime(p.$3),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                  color: isActive
                      ? (isDark
                          ? AppColorsDark.secondary
                          : const Color(0xFF00382E))
                      : (isDark
                          ? AppColorsDark.onSurface
                          : AppColors.onSurface),
                ),
              ),
              Row(
                children: [
                  Text(
                    p.$2,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          isActive ? FontWeight.w800 : FontWeight.w600,
                      color: isActive
                          ? (isDark
                              ? AppColorsDark.secondary
                              : const Color(0xFF00382E))
                          : (isDark
                              ? AppColorsDark.onSurface
                              : AppColors.onSurface),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: isActive
                          ? (isDark
                              ? AppColorsDark.primaryContainer
                              : const Color(0xFF29695B)
                                  .withValues(alpha: 0.15))
                          : (isDark
                              ? AppColorsDark.surfaceContainer
                              : AppColors.surfaceContainerHigh),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      p.$4,
                      size: 17,
                      color: isActive
                          ? (isDark
                              ? AppColorsDark.secondary
                              : const Color(0xFF29695B))
                          : (isDark
                              ? AppColorsDark.onSurfaceVariant
                              : AppColors.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAdhkarProgressCard(BuildContext context, bool isDark) {
    return Consumer<AdhkarProgressNotifier>(
      builder: (context, notifier, _) {
        final type = _currentAdhkarType();
        final fraction = notifier.progressFraction(type);
        final completed = notifier.completedCount(type);
        final total = notifier.totalCount(type);
        final pct = (fraction * 100).round();

        final (label, subtitle, icon) = switch (type) {
          AdhkarType.sabah => (
              'أذكار الصباح',
              'أكملت $completed من $total ذكراً من أذكار الصباح',
              Icons.wb_sunny_rounded,
            ),
          AdhkarType.massa => (
              'أذكار المساء',
              'أكملت $completed من $total ذكراً من أذكار المساء',
              Icons.nights_stay_rounded,
            ),
          AdhkarType.sleep => (
              'أذكار النوم',
              'أكملت $completed من $total ذكراً من أذكار النوم',
              Icons.bedtime_rounded,
            ),
          _ => (
              'الأذكار اليومية',
              'أكملت $completed من $total ذكراً',
              Icons.auto_stories_rounded,
            ),
        };

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (_) => AdhkarDetailScreen(
                  type: type,
                  title: label,
                  icon: icon,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColorsDark.level1Card : AppColors.level1Card,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(
                color: isDark
                    ? AppColorsDark.outlineVariant
                    : AppColors.surfaceContainerHighest,
              ),
              boxShadow: AppShadows.liftedPaper,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: fraction,
                        strokeWidth: 5.5,
                        backgroundColor: isDark
                            ? AppColorsDark.surfaceContainer
                            : AppColors.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation(
                          isDark
                              ? AppColorsDark.secondary
                              : AppColors.secondary,
                        ),
                      ),
                      Text(
                        '$pct%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColorsDark.primary
                              : AppColors.primary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark
                              ? AppColorsDark.onSurfaceVariant
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: isDark
                      ? AppColorsDark.onSurfaceVariant
                      : AppColors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
