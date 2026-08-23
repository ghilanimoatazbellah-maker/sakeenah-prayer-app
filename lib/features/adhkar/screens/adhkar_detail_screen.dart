import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/adhkar_progress_notifier.dart';
import '../../../core/theme/app_theme.dart';

/// Adhkar Detail Screen — shows the full list of adhkar cards
/// for a specific selected category with live tap-to-count,
/// Quranic typography, and individual repeat buttons.
class AdhkarDetailScreen extends StatelessWidget {
  final AdhkarType type;
  final String title;
  final IconData icon;

  const AdhkarDetailScreen({
    super.key,
    required this.type,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColorsDark.background : AppColors.background,
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColorsDark.onSurface : AppColors.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor:
            isDark ? AppColorsDark.surface : AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: isDark ? AppColorsDark.onSurface : AppColors.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<AdhkarProgressNotifier>(
        builder: (context, notifier, _) {
          final set = notifier.getSet(type);
          final items = set?.items ?? [];
          final completed = notifier.completedCount(type);
          final total = items.length;
          final isAllDone = total > 0 && completed == total;

          return Column(
            children: [
              // Top Progress Banner
              _buildTopProgressBanner(
                context,
                completed,
                total,
                isAllDone,
                isDark,
                onResetAll: () => notifier.reset(type),
              ),

              // Full Adhkar Scrollable List
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Text(
                          'لا توجد أذكار في هذا القسم حالياً',
                          style: TextStyle(
                            color: isDark
                                ? AppColorsDark.onSurfaceVariant
                                : AppColors.onSurfaceVariant,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.containerMargin,
                          vertical: 16,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final count = notifier.getCount(type, index);
                          final done = count >= item.repeat;
                          final progress = item.repeat > 0
                              ? (count / item.repeat).clamp(0.0, 1.0)
                              : 0.0;

                          return _buildZekrCard(
                            context: context,
                            index: index + 1,
                            totalItems: items.length,
                            zekr: item.zekr,
                            bless: item.bless,
                            repeat: item.repeat,
                            currentCount: count,
                            done: done,
                            progress: progress,
                            isDark: isDark,
                            isCustom: type == AdhkarType.custom,
                            onTap: () => notifier.increment(type, index),
                            onReset: () => notifier.resetItem(type, index),
                            onDelete: type == AdhkarType.custom
                                ? () => notifier.deleteCustomDhikr(index)
                                : null,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopProgressBanner(
    BuildContext context,
    int completed,
    int total,
    bool isAllDone,
    bool isDark, {
    required VoidCallback onResetAll,
  }) {
    final pct = total > 0 ? ((completed / total) * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: isDark
            ? (isAllDone
                ? const Color(0xFF15483D)
                : AppColorsDark.level1Card)
            : (isAllDone
                ? const Color(0xFFE8F3EF)
                : AppColors.level1Card),
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? AppColorsDark.outlineVariant
                : AppColors.surfaceContainerHighest,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isAllDone
                    ? Icons.check_circle_rounded
                    : Icons.pie_chart_rounded,
                color: isAllDone
                    ? (isDark ? const Color(0xFF7EBDAC) : AppColors.primary)
                    : (isDark ? const Color(0xFFFED488) : AppColors.secondary),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'المنجز: $completed من $total ($pct%)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColorsDark.onSurface
                      : AppColors.onSurface,
                ),
              ),
            ],
          ),
          if (completed > 0)
            TextButton.icon(
              onPressed: onResetAll,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: isDark
                    ? const Color(0xFFFED488)
                    : AppColors.secondary,
              ),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text(
                'إعادة القسم',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildZekrCard({
    required BuildContext context,
    required int index,
    required int totalItems,
    required String zekr,
    required String bless,
    required int repeat,
    required int currentCount,
    required bool done,
    required double progress,
    required bool isDark,
    required bool isCustom,
    required VoidCallback onTap,
    required VoidCallback onReset,
    VoidCallback? onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: done
            ? (isDark
                ? const Color(0xFF132E26)
                : const Color(0xFFEBF5F1))
            : (isDark
                ? const Color(0xFF142420)
                : Colors.white),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: done
              ? (isDark
                  ? const Color(0xFF459A87)
                  : const Color(0xFF7EBDAC))
              : (isDark
                  ? const Color(0xFF2D4B42)
                  : const Color(0xFFE0E7E4)),
          width: done ? 1.8 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          splashColor: const Color(0xFFFED488).withValues(alpha: 0.12),
          highlightColor: const Color(0xFFFED488).withValues(alpha: 0.06),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Meta Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF203B33)
                            : AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(AppRadius.base),
                      ),
                      child: Text(
                        'ذكر $index من $totalItems',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xFFD4E7E1)
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: done
                                ? (isDark
                                    ? const Color(0xFF1B5547)
                                    : AppColors.primaryContainer
                                        .withValues(alpha: 0.15))
                                : (isDark
                                    ? const Color(0xFF3F2F06)
                                    : AppColors.secondaryContainer
                                        .withValues(alpha: 0.35)),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            border: Border.all(
                              color: done
                                  ? (isDark
                                      ? const Color(0xFF7EBDAC)
                                      : AppColors.primary)
                                  : (isDark
                                      ? const Color(0xFFFED488)
                                      : AppColors.secondary),
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            repeat == 1 ? 'مرة واحدة' : '$repeat مرات',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: done
                                  ? (isDark
                                      ? const Color(0xFFAFEFDD)
                                      : AppColors.primary)
                                  : (isDark
                                      ? const Color(0xFFFED488)
                                      : AppColors.secondary),
                            ),
                          ),
                        ),
                        if (isCustom && onDelete != null) ...[
                          const SizedBox(width: 6),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded,
                                size: 20, color: AppColors.error),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: onDelete,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Arabic Zekr Text (High Definition Pure White in Dark Mode)
                Text(
                  zekr,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: 21,
                    height: 2.1,
                    fontWeight: FontWeight.w700,
                    color: done
                        ? (isDark
                            ? const Color(0xFF98E8D5)
                            : const Color(0xFF1E483D))
                        : (isDark
                            ? Colors.white
                            : const Color(0xFF0C1D19)),
                  ),
                ),

                // Blessing / Virtue (Super High Contrast in Dark Mode)
                if (bless.trim().isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1F352E)
                          : const Color(0xFFFFFBF0),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFFFED488)
                            : const Color(0xFFE5B558),
                        width: 1.3,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: 18,
                          color: isDark
                              ? const Color(0xFFFED488)
                              : const Color(0xFF8A6200),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            bless,
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontSize: 13.5,
                              height: 1.65,
                              color: isDark
                                  ? const Color(0xFFFFF1C2)
                                  : const Color(0xFF5D4200),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 18),

                // Mini Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: isDark
                        ? const Color(0xFF223A33)
                        : const Color(0xFFE2EBE7),
                    valueColor: AlwaysStoppedAnimation(
                      done
                          ? (isDark
                              ? const Color(0xFF7EBDAC)
                              : AppColors.primary)
                          : (isDark
                              ? const Color(0xFFFED488)
                              : AppColors.secondary),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Bottom Action: Tap hint / Reset Button + Counter Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (done)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onReset,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E5245)
                                  : const Color(0xFFD4EAE2),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.full),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF7EBDAC)
                                    : const Color(0xFF29695B),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.refresh_rounded,
                                  size: 16,
                                  color: isDark
                                      ? const Color(0xFFAFEFDD)
                                      : const Color(0xFF00382E),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'إعادة الذكر',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? const Color(0xFFAFEFDD)
                                        : const Color(0xFF00382E),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      Text(
                        'المس البطاقة للتسبيح',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark
                              ? const Color(0xFFAABEB8)
                              : AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                    // Counter Pill Indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: done
                            ? (isDark
                                ? const Color(0xFF004D40)
                                : AppColors.primaryContainer)
                            : (isDark
                                ? const Color(0xFFFED488)
                                : AppColors.secondaryContainer),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        boxShadow: [
                          BoxShadow(
                            color: (done
                                    ? (isDark
                                        ? const Color(0xFF004D40)
                                        : AppColors.primaryContainer)
                                    : const Color(0xFFFED488))
                                .withValues(alpha: 0.35),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (done) ...[
                            const Icon(
                              Icons.check_rounded,
                              size: 17,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            '$currentCount / $repeat',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: done
                                  ? Colors.white
                                  : (isDark
                                      ? const Color(0xFF261900)
                                      : const Color(0xFF422E00)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
