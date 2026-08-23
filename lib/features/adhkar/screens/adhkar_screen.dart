import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/adhkar_progress_notifier.dart';
import '../../../core/theme/app_theme.dart';
import 'adhkar_detail_screen.dart';

/// Main Adhkar Menu Screen — displays vertical category buttons/cards
/// (Morning, Evening, Sleep, Post-Prayer, Ruqyah, Custom) that navigate
/// into dedicated category detail screens upon click.
/// Optimized with crystal-clear Dark Mode typography.
class AdhkarScreen extends StatelessWidget {
  const AdhkarScreen({super.key});

  static const _categories = [
    (
      AdhkarType.sabah,
      'أذكار الصباح',
      'حصن المسلم وأذكار بداية اليوم والبركة',
      Icons.wb_sunny_rounded,
      Color(0xFFE9A23B),
    ),
    (
      AdhkarType.massa,
      'أذكار المساء',
      'أذكار حفظ المسلم وحمايته عند الغروب',
      Icons.nights_stay_rounded,
      Color(0xFF6B58A8),
    ),
    (
      AdhkarType.sleep,
      'أذكار النوم',
      'آيات السكينة وأدعية النوم والاستيقاظ',
      Icons.bedtime_rounded,
      Color(0xFF2E6F9E),
    ),
    (
      AdhkarType.afterPrayer,
      'أذكار بعد الصلاة المفروضة',
      'التسبيح والتهليل والاستغفار دبر كل صلاة',
      Icons.mosque_rounded,
      Color(0xFF29695B),
    ),
    (
      AdhkarType.ruqyah,
      'الرقية الشرعية والأدعية',
      'حصن من العين والحسد والشفاء بإذن الله',
      Icons.shield_rounded,
      Color(0xFF785A1A),
    ),
    (
      AdhkarType.custom,
      'أذكاري المخصصة',
      'أذكارك وأورادك الخاصة التي قمت بإضافتها',
      Icons.star_rounded,
      Color(0xFFD48806),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('حصن المسلم والأذكار'),
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
            // Top greeting banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColorsDark.primaryContainer
                    : AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: AppShadows.liftedPaper,
                border: isDark
                    ? Border.all(
                        color:
                            AppColorsDark.primary.withValues(alpha: 0.2))
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      size: 28,
                      color: AppColors.secondaryFixedDim,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ألا بذكر الله تطمئن القلوب',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'اختر قسماً من الأذكار لبدء القراءة والتسبيح',
                          style: TextStyle(
                            color: AppColors.secondaryFixedDim,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // High contrast Section Title for Dark & Light modes
            Padding(
              padding: const EdgeInsets.only(right: 4, bottom: 14),
              child: Text(
                'أقسام الأذكار والأدعية',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColorsDark.primary
                      : AppColors.primary,
                ),
              ),
            ),

            // Vertical Category Buttons / Cards
            ..._categories.map((cat) {
              return _buildCategoryButton(
                context: context,
                type: cat.$1,
                title: cat.$2,
                subtitle: cat.$3,
                icon: cat.$4,
                accentColor: cat.$5,
                isDark: isDark,
              );
            }),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton({
    required BuildContext context,
    required AdhkarType type,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
  }) {
    return Consumer<AdhkarProgressNotifier>(
      builder: (context, notifier, _) {
        final total = notifier.totalCount(type);
        final completed = notifier.completedCount(type);
        final fraction = notifier.progressFraction(type);
        final isAllDone = total > 0 && completed == total;

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: isDark ? AppColorsDark.level1Card : Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: isAllDone
                  ? const Color(0xFF7EBDAC).withValues(alpha: 0.6)
                  : (isDark
                      ? AppColorsDark.outlineVariant
                      : AppColors.surfaceContainerHighest),
              width: isAllDone ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : AppColors.primary)
                    .withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              onTap: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (_) => AdhkarDetailScreen(
                      type: type,
                      title: title,
                      icon: icon,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Category Icon Circle
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.14),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: accentColor, size: 24),
                        ),

                        const SizedBox(width: 16),

                        // Title & Subtitle with high contrast in Dark Mode
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: isDark
                                          ? AppColorsDark.onSurface
                                          : AppColors.onSurface,
                                    ),
                                  ),
                                  if (isAllDone) ...[
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      size: 16,
                                      color: Color(0xFF29695B),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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

                        // Chevron Navigation Arrow
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: isDark
                              ? AppColorsDark.onSurfaceVariant
                              : AppColors.onSurfaceVariant,
                        ),
                      ],
                    ),

                    if (total > 0) ...[
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isAllDone
                                ? 'أكملت كافة الأذكار اليوم ✨'
                                : 'أكملت $completed من $total',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: isAllDone
                                  ? (isDark
                                      ? AppColorsDark.primary
                                      : AppColors.primary)
                                  : (isDark
                                      ? AppColorsDark.onSurfaceVariant
                                      : AppColors.onSurfaceVariant),
                            ),
                          ),
                          Text(
                            '${(fraction * 100).round()}%',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: isAllDone
                                  ? (isDark
                                      ? AppColorsDark.primary
                                      : AppColors.primary)
                                  : (isDark
                                      ? AppColorsDark.secondary
                                      : AppColors.secondary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        child: LinearProgressIndicator(
                          value: fraction,
                          minHeight: 4,
                          backgroundColor: isDark
                              ? AppColorsDark.surfaceContainer
                              : AppColors.surfaceContainerHigh,
                          valueColor: AlwaysStoppedAnimation(
                            isAllDone
                                ? (isDark
                                    ? AppColorsDark.primary
                                    : AppColors.primary)
                                : (isDark
                                    ? AppColorsDark.secondary
                                    : AppColors.secondary),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
