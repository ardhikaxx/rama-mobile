class ActivityHistory {
  final int? id;
  final DateTime timestamp;
  final String actionType;
  final String title;
  final String description;
  final String? metadata;

  const ActivityHistory({
    this.id,
    required this.timestamp,
    required this.actionType,
    required this.title,
    required this.description,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'timestamp': timestamp.toIso8601String(),
      'action_type': actionType,
      'title': title,
      'description': description,
      'metadata': metadata,
    };
  }

  factory ActivityHistory.fromMap(Map<String, dynamic> map) {
    return ActivityHistory(
      id: map['id'] as int?,
      timestamp: DateTime.parse(map['timestamp'] as String),
      actionType: map['action_type'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      metadata: map['metadata'] as String?,
    );
  }
}
