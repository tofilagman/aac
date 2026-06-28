import 'dart:convert';

class Folder {
  final String id;
  final String name;
  final String emoji;
  final List<String> symbolIds;

  Folder({
    required this.id,
    required this.name,
    required this.emoji,
    List<String>? symbolIds,
  }) : symbolIds = symbolIds ?? [];

  Folder copyWith({
    String? id,
    String? name,
    String? emoji,
    List<String>? symbolIds,
  }) {
    return Folder(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      symbolIds: symbolIds ?? List.from(this.symbolIds),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'symbolIds': symbolIds,
      };

  factory Folder.fromMap(Map<String, dynamic> map) => Folder(
        id: map['id'],
        name: map['name'],
        emoji: map['emoji'],
        symbolIds: List<String>.from(map['symbolIds'] ?? []),
      );

  String toJson() => jsonEncode(toMap());
  factory Folder.fromJson(String source) =>
      Folder.fromMap(jsonDecode(source));
}
