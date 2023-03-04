class HistoryData {
  final String title;
  final List<String> events;

  const HistoryData({
    required this.title,
    required this.events,
  });

  factory HistoryData.fromJson(Map<String, dynamic> json) {
    var title = '';
    if (json.containsKey('Title')) {
      title = json['Title'];
    }

    var events = <String>[];
    if (json.containsKey('Events')) {
      var es = json['Events'] as List<dynamic>;
      events = es.map((e) => e as String).toList();
    }

    return HistoryData(
      title: title,
      events: events,
    );
  }
}
