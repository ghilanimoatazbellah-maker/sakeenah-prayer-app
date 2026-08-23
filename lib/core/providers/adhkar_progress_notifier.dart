import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/adhkar/screens/models/adhkar_model.dart';

/// Keys for all available adhkar categories including custom
enum AdhkarType {
  sabah,
  massa,
  sleep,
  afterPrayer,
  ruqyah,
  custom,
}

/// Tracks daily adhkar progress across all categories with automatic midnight reset
/// and allows creating, repeating, and managing custom user adhkar.
class AdhkarProgressNotifier extends ChangeNotifier {
  static const _customAdhkarStorageKey = 'custom_adhkar_items_list';

  // Loaded adhkar sets
  final Map<AdhkarType, AdhkarSet?> _sets = {
    AdhkarType.sabah: null,
    AdhkarType.massa: null,
    AdhkarType.sleep: null,
    AdhkarType.afterPrayer: null,
    AdhkarType.ruqyah: null,
    AdhkarType.custom: null,
  };

  // Current repeat counts — outer key: AdhkarType, inner key: item index
  final Map<AdhkarType, List<int>> _counts = {
    AdhkarType.sabah: [],
    AdhkarType.massa: [],
    AdhkarType.sleep: [],
    AdhkarType.afterPrayer: [],
    AdhkarType.ruqyah: [],
    AdhkarType.custom: [],
  };

  static const _assetPaths = {
    AdhkarType.sabah: 'assets/data/azkar_sabah.json',
    AdhkarType.massa: 'assets/data/azkar_massa.json',
    AdhkarType.sleep: 'assets/data/azkar_sleep.json',
    AdhkarType.afterPrayer: 'assets/data/azkar_after_prayer.json',
    AdhkarType.ruqyah: 'assets/data/azkar_ruqyah.json',
  };

  static String _todayKey(AdhkarType type) {
    final d = DateTime.now();
    return 'adhkar_${type.name}_${d.year}_${d.month}_${d.day}';
  }

  AdhkarProgressNotifier() {
    _init();
  }

  Future<void> _init() async {
    for (final type in AdhkarType.values) {
      if (type == AdhkarType.custom) {
        await _loadCustomSet();
      } else {
        await _loadSet(type);
      }
    }
  }

  Future<void> _loadSet(AdhkarType type) async {
    try {
      final path = _assetPaths[type];
      if (path == null) return;
      final raw = await rootBundle.loadString(path);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final set = AdhkarSet.fromJson(json);
      _sets[type] = set;

      // Load persisted counts (or start fresh for today)
      final prefs = await SharedPreferences.getInstance();
      final key = _todayKey(type);
      final saved = prefs.getString(key);
      if (saved != null) {
        final decoded = jsonDecode(saved) as List;
        _counts[type] = List<int>.from(decoded);
        if (_counts[type]!.length != set.items.length) {
          _counts[type] = List.filled(set.items.length, 0);
        }
      } else {
        _counts[type] = List.filled(set.items.length, 0);
      }
    } catch (_) {
      // Fallback
    }
    notifyListeners();
  }

  Future<void> _loadCustomSet() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customJson = prefs.getString(_customAdhkarStorageKey);

      List<AdhkarItem> items = [];
      if (customJson != null) {
        final decoded = jsonDecode(customJson) as List;
        items = decoded
            .map((e) => AdhkarItem.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        // Default seed items if empty
        items = [
          AdhkarItem(
            zekr: 'سُبْحَانَ اللهِ وَبِحَمْدِهِ، سُبْحَانَ اللهِ العَظِيمِ.',
            repeat: 100,
            bless: 'كلمتان خفيفتان على اللسان، ثقيلتان في الميزان.',
          ),
          AdhkarItem(
            zekr: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ العَلِيِّ العَظِيمِ.',
            repeat: 33,
            bless: 'كنز من كنوز الجنة ودواء لتسعة وتسعين داء.',
          ),
          AdhkarItem(
            zekr: 'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ.',
            repeat: 10,
            bless: 'من صلى عليّ صلاة صلى الله عليه بها عشراً.',
          ),
        ];
      }

      _sets[AdhkarType.custom] = AdhkarSet(
        title: 'أذكاري المخصصة',
        items: items,
      );

      final key = _todayKey(AdhkarType.custom);
      final savedCounts = prefs.getString(key);
      if (savedCounts != null) {
        final decoded = jsonDecode(savedCounts) as List;
        _counts[AdhkarType.custom] = List<int>.from(decoded);
        if (_counts[AdhkarType.custom]!.length != items.length) {
          _counts[AdhkarType.custom] = List.filled(items.length, 0);
        }
      } else {
        _counts[AdhkarType.custom] = List.filled(items.length, 0);
      }
    } catch (_) {
      // Fallback
    }
    notifyListeners();
  }

  Future<void> _persistCounts(AdhkarType type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _todayKey(type),
      jsonEncode(_counts[type]),
    );
  }

  Future<void> _persistCustomItems() async {
    final prefs = await SharedPreferences.getInstance();
    final items = _sets[AdhkarType.custom]?.items ?? [];
    final jsonList = items
        .map((e) => {
              'zekr': e.zekr,
              'repeat': e.repeat,
              'bless': e.bless,
            })
        .toList();
    await prefs.setString(_customAdhkarStorageKey, jsonEncode(jsonList));
  }

  // ── Public API ──────────────────────────────────────────────────────────

  Future<void> ensureLoaded(AdhkarType type) async {
    if (_sets[type] == null) {
      if (type == AdhkarType.custom) {
        await _loadCustomSet();
      } else {
        await _loadSet(type);
      }
    }
  }

  AdhkarSet? getSet(AdhkarType type) => _sets[type];

  /// Current count for a specific dhikr item.
  int getCount(AdhkarType type, int index) {
    final list = _counts[type];
    if (list == null || index >= list.length) return 0;
    return list[index];
  }

  /// Increment count if not yet at max, then persist.
  void increment(AdhkarType type, int index) {
    final set = _sets[type];
    final list = _counts[type];
    if (set == null || list == null || index >= list.length) return;

    final maxRepeat = set.items[index].repeat;
    if (list[index] < maxRepeat) {
      list[index]++;
      notifyListeners();
      _persistCounts(type);
    }
  }

  /// Resets an individual dhikr item back to 0 so the user can repeat it.
  Future<void> resetItem(AdhkarType type, int index) async {
    final list = _counts[type];
    if (list == null || index >= list.length) return;
    list[index] = 0;
    notifyListeners();
    await _persistCounts(type);
  }

  /// Resets all counts for a specific category back to 0.
  Future<void> reset(AdhkarType type) async {
    final set = _sets[type];
    if (set == null) return;
    _counts[type] = List.filled(set.items.length, 0);
    notifyListeners();
    await _persistCounts(type);
  }

  /// Adds a new custom dhikr created by the user.
  Future<void> addCustomDhikr({
    required String zekr,
    required int repeat,
    required String bless,
  }) async {
    final currentSet = _sets[AdhkarType.custom];
    final currentItems = List<AdhkarItem>.from(currentSet?.items ?? []);
    final currentCounts = List<int>.from(_counts[AdhkarType.custom] ?? []);

    currentItems.add(AdhkarItem(zekr: zekr, repeat: repeat, bless: bless));
    currentCounts.add(0);

    _sets[AdhkarType.custom] = AdhkarSet(
      title: 'أذكاري المخصصة',
      items: currentItems,
    );
    _counts[AdhkarType.custom] = currentCounts;

    notifyListeners();
    await _persistCustomItems();
    await _persistCounts(AdhkarType.custom);
  }

  /// Deletes a custom dhikr created by the user.
  Future<void> deleteCustomDhikr(int index) async {
    final currentSet = _sets[AdhkarType.custom];
    final currentItems = List<AdhkarItem>.from(currentSet?.items ?? []);
    final currentCounts = List<int>.from(_counts[AdhkarType.custom] ?? []);

    if (index < currentItems.length) {
      currentItems.removeAt(index);
      currentCounts.removeAt(index);

      _sets[AdhkarType.custom] = AdhkarSet(
        title: 'أذكاري المخصصة',
        items: currentItems,
      );
      _counts[AdhkarType.custom] = currentCounts;

      notifyListeners();
      await _persistCustomItems();
      await _persistCounts(AdhkarType.custom);
    }
  }

  /// Number of completed items in a set.
  int completedCount(AdhkarType type) {
    final set = _sets[type];
    final list = _counts[type];
    if (set == null || list == null) return 0;
    int done = 0;
    for (int i = 0; i < set.items.length; i++) {
      if (list[i] >= set.items[i].repeat) done++;
    }
    return done;
  }

  int totalCount(AdhkarType type) => _sets[type]?.items.length ?? 0;

  /// Progress fraction 0.0–1.0 for a set.
  double progressFraction(AdhkarType type) {
    final total = totalCount(type);
    if (total == 0) return 0.0;
    return completedCount(type) / total;
  }

  bool isLoaded(AdhkarType type) => _sets[type] != null;
}
