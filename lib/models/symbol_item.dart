import 'dart:convert';

class SymbolItem {
  final String id;
  final String label;
  final String? imagePath;
  final String? emoji;
  final String? folderId;
  final bool isFolder;

  SymbolItem({
    required this.id,
    required this.label,
    this.imagePath,
    this.emoji,
    this.folderId,
    this.isFolder = false,
  });

  SymbolItem copyWith({
    String? id,
    String? label,
    String? imagePath,
    String? emoji,
    String? folderId,
    bool? isFolder,
  }) {
    return SymbolItem(
      id: id ?? this.id,
      label: label ?? this.label,
      imagePath: imagePath ?? this.imagePath,
      emoji: emoji ?? this.emoji,
      folderId: folderId ?? this.folderId,
      isFolder: isFolder ?? this.isFolder,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'label': label,
        'imagePath': imagePath,
        'emoji': emoji,
        'folderId': folderId,
        'isFolder': isFolder,
      };

  factory SymbolItem.fromMap(Map<String, dynamic> map) => SymbolItem(
        id: map['id'],
        label: map['label'],
        imagePath: map['imagePath'],
        emoji: map['emoji'],
        folderId: map['folderId'],
        isFolder: map['isFolder'] ?? false,
      );

  String toJson() => jsonEncode(toMap());
  factory SymbolItem.fromJson(String source) =>
      SymbolItem.fromMap(jsonDecode(source));
}
