class Story {
  final int? id;
  final String title;
  final String surface;
  final String truth;
  final List<String> tags;
  final String difficulty;
  final List<String> keywords;

  Story({
    this.id,
    required this.title,
    required this.surface,
    required this.truth,
    required this.tags,
    required this.difficulty,
    required this.keywords,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()),
      title: json['title'],
      surface: json['surface'],
      truth: json['truth'],
      tags: List<String>.from(json['tags']),
      difficulty: json['difficulty'],
      keywords: List<String>.from(json['keywords']),
    );
  }
}
