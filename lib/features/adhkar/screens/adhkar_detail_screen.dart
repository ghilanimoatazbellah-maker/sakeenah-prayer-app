import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/providers/adhkar_progress_notifier.dart';
import '../../../core/theme/app_theme.dart';

/// Adhkar Detail Screen — shows the full list of adhkar cards
/// for a specific selected category with live tap-to-count,
/// Quranic typography, pinch-to-zoom text scaling, and compact top banner.
class AdhkarDetailScreen extends StatefulWidget {
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
  State<AdhkarDetailScreen> createState() => _AdhkarDetailScreenState();
}

class _AdhkarDetailScreenState extends State<AdhkarDetailScreen> {
  double _fontScale = 1.0;
  double _baseScale = 1.0;

  @override
  void initState() {
    super.initState();
    _loadFontScale();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AdhkarProgressNotifier>().ensureLoaded(widget.type);
      }
    });
  }

  Future<void> _loadFontScale() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getDouble('adhkar_font_scale');
    if (saved != null && mounted) {
      setState(() => _fontScale = saved.clamp(0.75, 1.5));
    }
  }

  Future<void> _saveFontScale(double scale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('adhkar_font_scale', scale);
  }

  void _adjustScale(double delta) {
    setState(() {
      _fontScale = (_fontScale + delta).clamp(0.75, 1.5);
    });
    _saveFontScale(_fontScale);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColorsDark.background : AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(
            fontSize: 18,
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
            size: 19,
            color: isDark ? AppColorsDark.onSurface : AppColors.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Quick Font Size Buttons
          IconButton(
            icon: const Icon(Icons.text_decrease_rounded, size: 20),
            tooltip: 'تصغير الخط',
            color: isDark ? AppColorsDark.secondary : AppColors.secondary,
            onPressed: () => _adjustScale(-0.1),
          ),
          IconButton(
            icon: const Icon(Icons.text_increase_rounded, size: 22),
            tooltip: 'تكبير الخط',
            color: isDark ? AppColorsDark.secondary : AppColors.secondary,
            onPressed: () => _adjustScale(0.1),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Consumer<AdhkarProgressNotifier>(
        builder: (context, notifier, _) {
          final set = notifier.getSet(widget.type);
          final items = set?.items ?? [];
          final completed = notifier.completedCount(widget.type);
          final total = items.length;
          final isAllDone = total > 0 && completed == total;

          if (set == null) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(
                  isDark ? AppColorsDark.secondary : AppColors.secondary,
                ),
              ),
            );
          }

          return Column(
            children: [
              // Sleek, Compact Top Progress Banner
              _buildTopProgressBanner(
                context,
                completed,
                total,
                isAllDone,
                isDark,
                onResetAll: () => notifier.reset(widget.type),
              ),

              // Adhkar List with Pinch-to-Zoom Gesture Support
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Text(
                          'لا توجد أذكار في هذا القسم حالياً',
                          style: TextStyle(
                            color: isDark
                                ? AppColorsDark.onSurfaceVariant
                                : AppColors.onSurfaceVariant,
                            fontSize: 15,
                          ),
                        ),
                      )
                    : GestureDetector(
                        onScaleStart: (details) {
                          _baseScale = _fontScale;
                        },
                        onScaleUpdate: (details) {
                          if (details.scale != 1.0) {
                            setState(() {
                              _fontScale = (_baseScale * details.scale)
                                  .clamp(0.75, 1.5);
                            });
                          }
                        },
                        onScaleEnd: (details) {
                          _saveFontScale(_fontScale);
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final count =
                                notifier.getCount(widget.type, index);
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
                              fontScale: _fontScale,
                              isCustom: widget.type == AdhkarType.custom,
                              onTap: () =>
                                  notifier.increment(widget.type, index),
                              onReset: () =>
                                  notifier.resetItem(widget.type, index),
                              onDelete: widget.type == AdhkarType.custom
                                  ? () => notifier.deleteCustomDhikr(index)
                                  : null,
                            );
                          },
                        ),
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
    final fraction = total > 0 ? (completed / total).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
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
                        : (isDark
                            ? const Color(0xFFFED488)
                            : AppColors.secondary),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'المنجز: $completed من $total ($pct%)',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColorsDark.onSurface
                          : AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              if (completed > 0)
                InkWell(
                  onTap: onResetAll,
                  borderRadius: BorderRadius.circular(AppRadius.base),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.refresh_rounded,
                          size: 14,
                          color: isDark
                              ? const Color(0xFFFED488)
                              : AppColors.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'إعادة القسم',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? const Color(0xFFFED488)
                                : AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 3,
              backgroundColor: isDark
                  ? const Color(0xFF223A33)
                  : const Color(0xFFE2EBE7),
              valueColor: AlwaysStoppedAnimation(
                isAllDone
                    ? (isDark
                        ? const Color(0xFF7EBDAC)
                        : AppColors.primary)
                    : (isDark
                        ? const Color(0xFFFED488)
                        : AppColors.secondary),
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
    required double fontScale,
    required bool isCustom,
    required VoidCallback onTap,
    required VoidCallback onReset,
    VoidCallback? onDelete,
  }) {
    final zekrFontSize = (17.5 * fontScale).clamp(14.0, 28.0);
    final blessFontSize = (12.5 * fontScale).clamp(10.5, 18.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: done
            ? (isDark
                ? const Color(0xFF132E26)
                : const Color(0xFFEBF5F1))
            : (isDark
                ? const Color(0xFF142420)
                : Colors.white),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: done
              ? (isDark
                  ? const Color(0xFF459A87)
                  : const Color(0xFF7EBDAC))
              : (isDark
                  ? const Color(0xFF2D4B42)
                  : const Color(0xFFE0E7E4)),
          width: done ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          splashColor: const Color(0xFFFED488).withValues(alpha: 0.12),
          highlightColor: const Color(0xFFFED488).withValues(alpha: 0.06),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header Badge Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
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
                          fontSize: 11.5,
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
                            horizontal: 11,
                            vertical: 4,
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
                              width: 1.0,
                            ),
                          ),
                          child: Text(
                            repeat == 1 ? 'مرة واحدة' : '$repeat مرات',
                            style: TextStyle(
                              fontSize: 11.5,
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
                                size: 18, color: AppColors.error),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: onDelete,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Arabic Zekr Text (Comfortable size & Pinch-to-zoom scalable)
                Text(
                  zekr,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: zekrFontSize,
                    height: 1.9,
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

                // Blessing / Virtue
                if (bless.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
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
                        width: 1.1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: 15,
                          color: isDark
                              ? const Color(0xFFFED488)
                              : const Color(0xFF8A6200),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            bless,
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontSize: blessFontSize,
                              height: 1.55,
                              color: isDark
                                  ? const Color(0xFFFFE082)
                                  : const Color(0xFF5D4200),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Mini Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4.5,
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

                const SizedBox(height: 12),

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
                              horizontal: 12,
                              vertical: 6,
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
                                  size: 14,
                                  color: isDark
                                      ? const Color(0xFFAFEFDD)
                                      : const Color(0xFF00382E),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'إعادة الذكر',
                                  style: TextStyle(
                                    fontSize: 12,
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
                          fontSize: 11.5,
                          color: isDark
                              ? const Color(0xFFAABEB8)
                              : AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                    // Counter Pill Indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 7,
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
                                .withValues(alpha: 0.30),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (done) ...[
                            const Icon(
                              Icons.check_rounded,
                              size: 15,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                          ],
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              '$currentCount / $repeat',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w900,
                                color: done
                                    ? Colors.white
                                    : (isDark
                                        ? const Color(0xFF261900)
                                        : const Color(0xFF422E00)),
                              ),
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
