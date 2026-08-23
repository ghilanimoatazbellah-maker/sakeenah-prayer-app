/// Model matching the JSON structure:
/// { "title": "...", "content": [ { "zekr": "", "repeat": #, "bless": "" } ] }
class AdhkarSet {
  final String title;
  final List<AdhkarItem> items;

  AdhkarSet({required this.title, required this.items});

  factory AdhkarSet.fromJson(Map<String, dynamic> json) {
    final list = json['content'] as List? ?? [];
    return AdhkarSet(
      title: (json['title'] ?? '') as String,
      items: list
          .map((e) => AdhkarItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AdhkarItem {
  final String zekr;
  final int repeat;
  final String bless;

  AdhkarItem({
    required this.zekr,
    required this.repeat,
    required this.bless,
  });

  factory AdhkarItem.fromJson(Map<String, dynamic> json) {
    return AdhkarItem(
      zekr: (json['zekr'] ?? '') as String,
      repeat: json['repeat'] is int
          ? json['repeat'] as int
          : int.tryParse(json['repeat']?.toString() ?? '1') ?? 1,
      bless: (json['bless'] ?? '') as String,
    );
  }
}
