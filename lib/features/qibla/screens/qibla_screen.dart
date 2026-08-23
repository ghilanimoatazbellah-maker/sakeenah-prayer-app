import 'dart:math' as math;
import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/location_notifier.dart';
import '../../../core/theme/app_theme.dart';
import '../../home/widgets/location_picker_sheet.dart';

/// Luxury Qibla Screen — calculates the astronomical Qibla bearing,
/// distance to the Holy Kaaba in Makkah in Kilometers, with a high-end
/// concentric compass dial and interactive location selector.
class QiblaScreen extends StatelessWidget {
  const QiblaScreen({super.key});

  // Makkah Kaaba exact coordinates
  static const double makkahLat = 21.4225;
  static const double makkahLng = 39.8262;

  String _getDirectionText(double degrees) {
    if (degrees >= 67.5 && degrees <= 112.5) return 'شرقاً';
    if (degrees > 112.5 && degrees < 157.5) return 'جنوب شرق';
    if (degrees >= 157.5 && degrees <= 202.5) return 'جنوباً';
    if (degrees > 202.5 && degrees < 247.5) return 'جنوب غرب';
    if (degrees >= 247.5 && degrees <= 292.5) return 'غرباً';
    if (degrees > 292.5 && degrees < 337.5) return 'شمال غرب';
    if (degrees >= 337.5 || degrees <= 22.5) return 'شمالاً';
    return 'شمال شرق';
  }

  @override
  Widget build(BuildContext context) {
    final locNotifier = context.watch<LocationNotifier>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final qiblaBearing = Qibla.qibla(
      Coordinates(locNotifier.latitude, locNotifier.longitude),
    );
    final bearingInt = qiblaBearing.round();
    final directionWord = _getDirectionText(qiblaBearing);

    // Calculate distance to Makkah in Kilometers
    final distanceMeters = Geolocator.distanceBetween(
      locNotifier.latitude,
      locNotifier.longitude,
      makkahLat,
      makkahLng,
    );
    final distanceKm = (distanceMeters / 1000).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('بوصلة اتجاه القبلة'),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.containerMargin,
            vertical: 16,
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),

              // 1. Luxury Gradient Hero Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: isDark
                        ? [
                            const Color(0xFF0F3B32),
                            const Color(0xFF0A2923),
                            const Color(0xFF061A16),
                          ]
                        : [
                            const Color(0xFF004D40),
                            const Color(0xFF00382E),
                            const Color(0xFF002720),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  boxShadow: AppShadows.liftedPaper,
                  border: Border.all(
                    color: const Color(0xFFFED488).withValues(alpha: 0.3),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mosque_rounded,
                        size: 32,
                        color: AppColors.secondaryFixedDim,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'زاوية القبلة نحو الكعبة المشرفة',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$bearingInt° $directionWord من الشمال الحقيقي',
                      style: const TextStyle(
                        color: AppColors.secondaryFixedDim,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        'المسافة إلى مكة: $distanceKm كم',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // 2. High-End Concentric Astronomical Compass Dial
              Center(
                child: SizedBox(
                  width: 270,
                  height: 270,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer Golden/Emerald Glow Ring
                      Container(
                        width: 270,
                        height: 270,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? AppColorsDark.level1Card
                              : Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF004D40)
                                  .withValues(alpha: 0.08),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ],
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFFE9C176).withValues(alpha: 0.3)
                                : const Color(0xFFE9C176).withValues(alpha: 0.5),
                            width: 2.5,
                          ),
                        ),
                      ),

                      // Inner Concentric Ring
                      Container(
                        width: 210,
                        height: 210,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? AppColorsDark.surfaceContainer
                              : AppColors.surfaceContainerLow,
                          border: Border.all(
                            color: isDark
                                ? AppColorsDark.outlineVariant
                                : AppColors.surfaceContainerHighest,
                            width: 1.5,
                          ),
                        ),
                      ),

                      // Cardinal Directions (N, S, E, W)
                      const Positioned(
                        top: 14,
                        child: Text(
                          'N (شمال)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 14,
                        child: Text(
                          'S (جنوب)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColorsDark.onSurfaceVariant
                                : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 14,
                        child: Text(
                          'E (شرق)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColorsDark.onSurfaceVariant
                                : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 14,
                        child: Text(
                          'W (غرب)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColorsDark.onSurfaceVariant
                                : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),

                      // Rotating Needle pointing to Qibla Angle
                      Transform.rotate(
                        angle: qiblaBearing * (math.pi / 180),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Needle body with Gold Gradient
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 85,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Color(0xFFFED488),
                                        Color(0xFFE9A23B),
                                      ],
                                    ),
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(6),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFE9A23B)
                                            .withValues(alpha: 0.4),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 85),
                              ],
                            ),

                            // Golden Kaaba Beacon at Tip
                            Positioned(
                              top: 16,
                              child: Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF004D40),
                                      Color(0xFF002720),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFFED488),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFED488)
                                          .withValues(alpha: 0.5),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.navigation_rounded,
                                  color: Color(0xFFFED488),
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Center Pivot Pin
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFED488), Color(0xFFE9A23B)],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // 3. Clickable Location Footer Card
              InkWell(
                onTap: () => LocationPickerSheet.show(context),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColorsDark.level1Card
                        : AppColors.level1Card,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: isDark
                          ? AppColorsDark.outlineVariant
                          : AppColors.surfaceContainerHighest,
                    ),
                    boxShadow: AppShadows.liftedPaper,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColorsDark.surfaceContainer
                              : AppColors.surfaceContainerHigh,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          locNotifier.isAutoGps
                              ? Icons.my_location_rounded
                              : Icons.location_on_rounded,
                          color: isDark
                              ? AppColorsDark.secondary
                              : AppColors.secondary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'الموقع المعتمد (اضغط للتغيير)',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              locNotifier.locationLabel,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? AppColorsDark.primary
                                    : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '$bearingInt°',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: isDark
                              ? AppColorsDark.secondary
                              : AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
