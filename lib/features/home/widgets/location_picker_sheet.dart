import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/location_notifier.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/location_service.dart';

/// Luxury Location Selection Modal Sheet — allows toggling Auto GPS
/// or manually searching and selecting any city in Algeria or the world.
class LocationPickerSheet extends StatefulWidget {
  const LocationPickerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const LocationPickerSheet(),
    );
  }

  @override
  State<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<LocationPickerSheet> {
  final _searchController = TextEditingController();
  bool _isSearching = false;
  String? _searchError;

  Future<void> _handleManualSearch(
      BuildContext context, LocationNotifier locNotifier) async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    final result = await LocationService.searchCityByName(query);

    if (!mounted) return;

    setState(() {
      _isSearching = false;
    });

    if (result != null) {
      await locNotifier.setManualLocation(
        lat: result.lat,
        lng: result.lng,
        name: result.name,
      );
      if (context.mounted) Navigator.pop(context);
    } else {
      setState(() {
        _searchError = 'لم يتم العثور على المدينة، يرجى كتابة الاسم بدقة.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locNotifier = context.watch<LocationNotifier>();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.level1Card : Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header handle
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColorsDark.outlineVariant
                    : AppColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.location_on_rounded,
                      color: AppColors.secondary, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'تحديد موقعك والمدينة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 1. Auto GPS Button
          InkWell(
            onTap: locNotifier.isLoading
                ? null
                : () async {
                    final success = await locNotifier.refreshGpsLocation();
                    if (context.mounted) {
                      if (success) {
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'يرجى التأكد من تشغيل الـ GPS وإعطاء الإذن لتحديد موقعك.',
                              textAlign: TextAlign.right,
                            ),
                          ),
                        );
                      }
                    }
                  },
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: locNotifier.isAutoGps
                    ? (isDark
                        ? AppColorsDark.primaryContainer
                        : AppColors.primaryContainer.withValues(alpha: 0.1))
                    : (isDark
                        ? AppColorsDark.surfaceContainer
                        : AppColors.surfaceContainerLow),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: locNotifier.isAutoGps
                      ? AppColors.primary
                      : (isDark
                          ? AppColorsDark.outlineVariant
                          : AppColors.surfaceContainerHighest),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: locNotifier.isAutoGps
                          ? AppColors.primary
                          : (isDark
                              ? AppColorsDark.surfaceContainerHigh
                              : AppColors.surfaceContainerHigh),
                      shape: BoxShape.circle,
                    ),
                    child: locNotifier.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            Icons.my_location_rounded,
                            size: 20,
                            color: locNotifier.isAutoGps
                                ? Colors.white
                                : AppColors.secondary,
                          ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'التحديد التلقائي عبر GPS',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          locNotifier.isAutoGps
                              ? 'الموقع الحالي: ${locNotifier.locationLabel}'
                              : 'اضغط لتحديد إحداثياتك بدقة عبر القمر الصناعي',
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
                  if (locNotifier.isAutoGps)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          // 2. Search City by Name TextField
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) =>
                      _handleManualSearch(context, locNotifier),
                  decoration: InputDecoration(
                    hintText: 'اكتب اسم الولاية أو المدينة (مثال: سطيف)...',
                    prefixIcon: _isSearching
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.search_rounded),
                            onPressed: () => _handleManualSearch(
                                context, locNotifier),
                          ),
                    filled: true,
                    fillColor: isDark
                        ? AppColorsDark.surfaceContainer
                        : AppColors.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (_searchError != null) ...[
            const SizedBox(height: 6),
            Text(
              _searchError!,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ],

          const SizedBox(height: 20),

          // 3. Quick Popular Cities Presets
          const Text(
            'أو اختر من المدن الشائعة:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
              itemCount: LocationNotifier.popularCities.length,
              itemBuilder: (context, i) {
                final city = LocationNotifier.popularCities[i];
                final isSelected = !locNotifier.isAutoGps &&
                    locNotifier.locationLabel.contains(city.name);

                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark
                            ? AppColorsDark.primaryContainer.withValues(alpha: 0.3)
                            : AppColors.secondaryContainer.withValues(alpha: 0.25))
                        : (isDark
                            ? AppColorsDark.surfaceContainer
                            : AppColors.surfaceContainerLow),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: isSelected
                        ? Border.all(color: AppColors.secondary, width: 1.2)
                        : null,
                  ),
                  child: ListTile(
                    dense: true,
                    leading: Icon(
                      Icons.location_city_rounded,
                      color: isSelected
                          ? AppColors.secondary
                          : (isDark
                              ? AppColorsDark.onSurfaceVariant
                              : AppColors.onSurfaceVariant),
                    ),
                    title: Text(
                      city.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected
                            ? (isDark
                                ? AppColorsDark.secondary
                                : AppColors.secondary)
                            : null,
                      ),
                    ),
                    subtitle: Text(
                      city.country,
                      style: const TextStyle(fontSize: 11),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded,
                            color: AppColors.secondary, size: 18)
                        : const Icon(Icons.chevron_left_rounded, size: 18),
                    onTap: () async {
                      await locNotifier.setManualLocation(
                        lat: city.latitude,
                        lng: city.longitude,
                        name: '${city.name}، ${city.country}',
                      );
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
