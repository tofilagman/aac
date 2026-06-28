import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefVoiceName = 'tts_voice_name';
const _prefVoiceLocale = 'tts_voice_locale';

class TtsService {
  TtsService._() {
    _setup();
  }
  static final TtsService instance = TtsService._();

  final FlutterTts _tts = FlutterTts();
  final Completer<void> _readyCompleter = Completer();

  List<Map<String, String>> _availableVoices = [];
  String? _currentVoiceName;

  Future<void> get ready => _readyCompleter.future;
  List<Map<String, String>> get availableVoices => _availableVoices;
  String? get currentVoiceName => _currentVoiceName;

  Future<void> _setup() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.48);
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(false);

    final raw = await _tts.getVoices as List?;
    if (raw != null) {
      _availableVoices = raw
          .where((v) {
            final locale = (v['locale'] as String? ?? '').toLowerCase();
            return locale.startsWith('en');
          })
          .map((v) => {
                'name': v['name'] as String? ?? '',
                'locale': v['locale'] as String? ?? 'en-US',
              })
          .where((v) => v['name']!.isNotEmpty)
          .toList();
    }

    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString(_prefVoiceName);
    final savedLocale = prefs.getString(_prefVoiceLocale);

    if (savedName != null && savedLocale != null) {
      await _applyVoice(savedName, savedLocale);
    }

    _readyCompleter.complete();
  }

  Future<void> _applyVoice(String name, String locale) async {
    await _tts.setVoice({'name': name, 'locale': locale});
    _currentVoiceName = name;
  }

  Future<void> setVoice(String name, String locale) async {
    await _applyVoice(name, locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefVoiceName, name);
    await prefs.setString(_prefVoiceLocale, locale);
  }

  Future<void> speak(String text) async {
    _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() async => _tts.stop();
}
