import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/symbol_item.dart';
import '../models/folder.dart';
import '../services/phrase_expander.dart';

const _uuid = Uuid();

class AacProvider extends ChangeNotifier {
  List<SymbolItem> _symbols = [];
  List<Folder> _folders = [];
  final List<SymbolItem> _sentence = [];
  String? _currentFolderId;

  List<SymbolItem> get symbols => _currentFolderId == null
      ? _symbols.where((s) => s.folderId == null).toList()
      : _symbols.where((s) => s.folderId == _currentFolderId).toList();

  List<SymbolItem> get allSymbols => _symbols;
  List<SymbolItem> symbolsForFolder(String folderId) =>
      _symbols.where((s) => s.folderId == folderId).toList();

  List<Folder> get folders => _folders;
  List<SymbolItem> get sentence => _sentence;
  String? get currentFolderId => _currentFolderId;

  Folder? get currentFolder =>
      _currentFolderId == null
          ? null
          : _folders.firstWhere((f) => f.id == _currentFolderId,
              orElse: () => _folders.first);

  AacProvider() {
    _load();
  }

  void addToSentence(SymbolItem item) {
    _sentence.add(item);
    notifyListeners();
  }

  void removeFromSentence(int index) {
    _sentence.removeAt(index);
    notifyListeners();
  }

  void clearSentence() {
    _sentence.clear();
    notifyListeners();
  }

  String get sentenceText => _sentence.map((s) => s.label).join(' ');

  String get expandedSentenceText =>
      PhraseExpander.expand(_sentence.map((s) => s.label).toList());

  void enterFolder(String folderId) {
    _currentFolderId = folderId;
    notifyListeners();
  }

  void exitFolder() {
    _currentFolderId = null;
    notifyListeners();
  }

  void addSymbol({
    required String label,
    String? emoji,
    String? imagePath,
    String? folderId,
  }) {
    final symbol = SymbolItem(
      id: _uuid.v4(),
      label: label,
      emoji: emoji,
      imagePath: imagePath,
      folderId: folderId ?? _currentFolderId,
    );
    _symbols.add(symbol);
    notifyListeners();
    _save();
  }

  void deleteSymbol(String id) {
    _symbols.removeWhere((s) => s.id == id);
    notifyListeners();
    _save();
  }

  void reorderCoreSymbols(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final cores = _symbols.where((s) => s.folderId == null).toList();
    final others = _symbols.where((s) => s.folderId != null).toList();
    final item = cores.removeAt(oldIndex);
    cores.insert(newIndex, item);
    _symbols = [...cores, ...others];
    notifyListeners();
    _save();
  }

  void reorderFolderSymbols(String folderId, int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final inFolder = _symbols.where((s) => s.folderId == folderId).toList();
    final others = _symbols.where((s) => s.folderId != folderId).toList();
    final item = inFolder.removeAt(oldIndex);
    inFolder.insert(newIndex, item);
    _symbols = [...others, ...inFolder];
    notifyListeners();
    _save();
  }

  void reorderFolders(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = _folders.removeAt(oldIndex);
    _folders.insert(newIndex, item);
    notifyListeners();
    _save();
  }

  void addFolder({required String name, required String emoji}) {
    final folder = Folder(id: _uuid.v4(), name: name, emoji: emoji);
    _folders.add(folder);
    notifyListeners();
    _save();
  }

  void deleteFolder(String id) {
    _folders.removeWhere((f) => f.id == id);
    _symbols.removeWhere((s) => s.folderId == id);
    if (_currentFolderId == id) _currentFolderId = null;
    notifyListeners();
    _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        'symbols', jsonEncode(_symbols.map((s) => s.toMap()).toList()));
    prefs.setString(
        'folders', jsonEncode(_folders.map((f) => f.toMap()).toList()));
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final symbolsJson = prefs.getString('symbols');
    final foldersJson = prefs.getString('folders');

    if (symbolsJson != null) {
      final list = jsonDecode(symbolsJson) as List;
      _symbols = list.map((e) => SymbolItem.fromMap(e)).toList();
    }
    if (foldersJson != null) {
      final list = jsonDecode(foldersJson) as List;
      _folders = list.map((e) => Folder.fromMap(e)).toList();
    }

    if (_symbols.isEmpty && _folders.isEmpty) {
      _loadDefaults();
    }

    notifyListeners();
  }

  void _loadDefaults() {
    final foodId = _uuid.v4();
    final feelingsId = _uuid.v4();
    final activitiesId = _uuid.v4();
    final peopleId = _uuid.v4();
    final placesId = _uuid.v4();
    final bodyId = _uuid.v4();

    _folders = [
      Folder(id: foodId, name: 'Food', emoji: '🍎'),
      Folder(id: feelingsId, name: 'Feelings', emoji: '😊'),
      Folder(id: activitiesId, name: 'Activities', emoji: '⚽'),
      Folder(id: peopleId, name: 'People', emoji: '👨‍👩‍👧'),
      Folder(id: placesId, name: 'Places', emoji: '🏠'),
      Folder(id: bodyId, name: 'Body', emoji: '🦶'),
    ];

    _symbols = [
      // Core vocabulary
      SymbolItem(id: _uuid.v4(), label: 'I', emoji: '👤'),
      SymbolItem(id: _uuid.v4(), label: 'want', emoji: '🤲'),
      SymbolItem(id: _uuid.v4(), label: 'more', emoji: '➕'),
      SymbolItem(id: _uuid.v4(), label: 'stop', emoji: '🛑'),
      SymbolItem(id: _uuid.v4(), label: 'go', emoji: '🟢'),
      SymbolItem(id: _uuid.v4(), label: 'help', emoji: '🆘'),
      SymbolItem(id: _uuid.v4(), label: 'yes', emoji: '✅'),
      SymbolItem(id: _uuid.v4(), label: 'no', emoji: '❌'),
      SymbolItem(id: _uuid.v4(), label: 'please', emoji: '🙏'),
      SymbolItem(id: _uuid.v4(), label: 'thank you', emoji: '💛'),
      SymbolItem(id: _uuid.v4(), label: 'like', emoji: '👍'),
      SymbolItem(id: _uuid.v4(), label: 'not like', emoji: '👎'),
      SymbolItem(id: _uuid.v4(), label: 'give me', emoji: '🫴'),
      SymbolItem(id: _uuid.v4(), label: 'look', emoji: '👀'),
      SymbolItem(id: _uuid.v4(), label: 'done', emoji: '🏁'),
      SymbolItem(id: _uuid.v4(), label: 'wait', emoji: '⏳'),
      SymbolItem(id: _uuid.v4(), label: 'up', emoji: '⬆️'),
      SymbolItem(id: _uuid.v4(), label: 'down', emoji: '⬇️'),
      SymbolItem(id: _uuid.v4(), label: 'open', emoji: '🔓'),
      SymbolItem(id: _uuid.v4(), label: 'close', emoji: '🔒'),
      // Food
      SymbolItem(id: _uuid.v4(), label: 'water', emoji: '💧', folderId: foodId),
      SymbolItem(id: _uuid.v4(), label: 'milk', emoji: '🥛', folderId: foodId),
      SymbolItem(id: _uuid.v4(), label: 'juice', emoji: '🧃', folderId: foodId),
      SymbolItem(id: _uuid.v4(), label: 'apple', emoji: '🍎', folderId: foodId),
      SymbolItem(id: _uuid.v4(), label: 'banana', emoji: '🍌', folderId: foodId),
      SymbolItem(id: _uuid.v4(), label: 'grapes', emoji: '🍇', folderId: foodId),
      SymbolItem(id: _uuid.v4(), label: 'bread', emoji: '🍞', folderId: foodId),
      SymbolItem(id: _uuid.v4(), label: 'rice', emoji: '🍚', folderId: foodId),
      SymbolItem(id: _uuid.v4(), label: 'chicken', emoji: '🍗', folderId: foodId),
      SymbolItem(id: _uuid.v4(), label: 'egg', emoji: '🥚', folderId: foodId),
      SymbolItem(id: _uuid.v4(), label: 'cookie', emoji: '🍪', folderId: foodId),
      SymbolItem(id: _uuid.v4(), label: 'candy', emoji: '🍬', folderId: foodId),
      SymbolItem(id: _uuid.v4(), label: 'pizza', emoji: '🍕', folderId: foodId),
      SymbolItem(id: _uuid.v4(), label: 'ice cream', emoji: '🍦', folderId: foodId),
      SymbolItem(id: _uuid.v4(), label: 'cheese', emoji: '🧀', folderId: foodId),
      SymbolItem(id: _uuid.v4(), label: 'noodles', emoji: '🍜', folderId: foodId),
      // Feelings
      SymbolItem(id: _uuid.v4(), label: 'happy', emoji: '😊', folderId: feelingsId),
      SymbolItem(id: _uuid.v4(), label: 'sad', emoji: '😢', folderId: feelingsId),
      SymbolItem(id: _uuid.v4(), label: 'angry', emoji: '😠', folderId: feelingsId),
      SymbolItem(id: _uuid.v4(), label: 'scared', emoji: '😨', folderId: feelingsId),
      SymbolItem(id: _uuid.v4(), label: 'tired', emoji: '😴', folderId: feelingsId),
      SymbolItem(id: _uuid.v4(), label: 'hurt', emoji: '🤕', folderId: feelingsId),
      SymbolItem(id: _uuid.v4(), label: 'excited', emoji: '🤩', folderId: feelingsId),
      SymbolItem(id: _uuid.v4(), label: 'surprised', emoji: '😲', folderId: feelingsId),
      SymbolItem(id: _uuid.v4(), label: 'bored', emoji: '😑', folderId: feelingsId),
      SymbolItem(id: _uuid.v4(), label: 'love', emoji: '🥰', folderId: feelingsId),
      SymbolItem(id: _uuid.v4(), label: 'silly', emoji: '🤪', folderId: feelingsId),
      SymbolItem(id: _uuid.v4(), label: 'okay', emoji: '😌', folderId: feelingsId),
      // Activities
      SymbolItem(id: _uuid.v4(), label: 'play', emoji: '🎮', folderId: activitiesId),
      SymbolItem(id: _uuid.v4(), label: 'read', emoji: '📚', folderId: activitiesId),
      SymbolItem(id: _uuid.v4(), label: 'draw', emoji: '✏️', folderId: activitiesId),
      SymbolItem(id: _uuid.v4(), label: 'music', emoji: '🎵', folderId: activitiesId),
      SymbolItem(id: _uuid.v4(), label: 'outside', emoji: '🌳', folderId: activitiesId),
      SymbolItem(id: _uuid.v4(), label: 'sleep', emoji: '🛏️', folderId: activitiesId),
      SymbolItem(id: _uuid.v4(), label: 'swim', emoji: '🏊', folderId: activitiesId),
      SymbolItem(id: _uuid.v4(), label: 'run', emoji: '🏃', folderId: activitiesId),
      SymbolItem(id: _uuid.v4(), label: 'jump', emoji: '🦘', folderId: activitiesId),
      SymbolItem(id: _uuid.v4(), label: 'watch TV', emoji: '📺', folderId: activitiesId),
      SymbolItem(id: _uuid.v4(), label: 'paint', emoji: '🎨', folderId: activitiesId),
      SymbolItem(id: _uuid.v4(), label: 'sing', emoji: '🎤', folderId: activitiesId),
      SymbolItem(id: _uuid.v4(), label: 'eat', emoji: '🍽️', folderId: activitiesId),
      SymbolItem(id: _uuid.v4(), label: 'drink', emoji: '🥤', folderId: activitiesId),
      SymbolItem(id: _uuid.v4(), label: 'bath', emoji: '🛁', folderId: activitiesId),
      SymbolItem(id: _uuid.v4(), label: 'toilet', emoji: '🚽', folderId: activitiesId),
      // People
      SymbolItem(id: _uuid.v4(), label: 'mom', emoji: '👩', folderId: peopleId),
      SymbolItem(id: _uuid.v4(), label: 'dad', emoji: '👨', folderId: peopleId),
      SymbolItem(id: _uuid.v4(), label: 'me', emoji: '🙋', folderId: peopleId),
      SymbolItem(id: _uuid.v4(), label: 'brother', emoji: '👦', folderId: peopleId),
      SymbolItem(id: _uuid.v4(), label: 'sister', emoji: '👧', folderId: peopleId),
      SymbolItem(id: _uuid.v4(), label: 'teacher', emoji: '👩‍🏫', folderId: peopleId),
      SymbolItem(id: _uuid.v4(), label: 'friend', emoji: '🤝', folderId: peopleId),
      SymbolItem(id: _uuid.v4(), label: 'doctor', emoji: '👨‍⚕️', folderId: peopleId),
      SymbolItem(id: _uuid.v4(), label: 'grandma', emoji: '👵', folderId: peopleId),
      SymbolItem(id: _uuid.v4(), label: 'grandpa', emoji: '👴', folderId: peopleId),
      // Places
      SymbolItem(id: _uuid.v4(), label: 'home', emoji: '🏠', folderId: placesId),
      SymbolItem(id: _uuid.v4(), label: 'school', emoji: '🏫', folderId: placesId),
      SymbolItem(id: _uuid.v4(), label: 'park', emoji: '🌳', folderId: placesId),
      SymbolItem(id: _uuid.v4(), label: 'store', emoji: '🏪', folderId: placesId),
      SymbolItem(id: _uuid.v4(), label: 'hospital', emoji: '🏥', folderId: placesId),
      SymbolItem(id: _uuid.v4(), label: 'church', emoji: '⛪', folderId: placesId),
      SymbolItem(id: _uuid.v4(), label: 'car', emoji: '🚗', folderId: placesId),
      SymbolItem(id: _uuid.v4(), label: 'bathroom', emoji: '🚿', folderId: placesId),
      SymbolItem(id: _uuid.v4(), label: 'bedroom', emoji: '🛏️', folderId: placesId),
      SymbolItem(id: _uuid.v4(), label: 'kitchen', emoji: '🍳', folderId: placesId),
      // Body
      SymbolItem(id: _uuid.v4(), label: 'head', emoji: '🗣️', folderId: bodyId),
      SymbolItem(id: _uuid.v4(), label: 'eyes', emoji: '👀', folderId: bodyId),
      SymbolItem(id: _uuid.v4(), label: 'ears', emoji: '👂', folderId: bodyId),
      SymbolItem(id: _uuid.v4(), label: 'mouth', emoji: '👄', folderId: bodyId),
      SymbolItem(id: _uuid.v4(), label: 'nose', emoji: '👃', folderId: bodyId),
      SymbolItem(id: _uuid.v4(), label: 'hands', emoji: '🤲', folderId: bodyId),
      SymbolItem(id: _uuid.v4(), label: 'feet', emoji: '🦶', folderId: bodyId),
      SymbolItem(id: _uuid.v4(), label: 'tummy', emoji: '🫃', folderId: bodyId),
      SymbolItem(id: _uuid.v4(), label: 'teeth', emoji: '🦷', folderId: bodyId),
      SymbolItem(id: _uuid.v4(), label: 'hair', emoji: '💇', folderId: bodyId),
    ];

    _save();
  }
}
