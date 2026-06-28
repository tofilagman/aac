import 'package:flutter/material.dart';
import '../services/tts_service.dart';

class VoicePickerScreen extends StatefulWidget {
  const VoicePickerScreen({super.key});

  @override
  State<VoicePickerScreen> createState() => _VoicePickerScreenState();
}

class _VoicePickerScreenState extends State<VoicePickerScreen> {
  List<Map<String, String>> _voices = [];
  String? _selectedName;
  String? _previewingName;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await TtsService.instance.ready;
    if (!mounted) return;
    setState(() {
      _voices = TtsService.instance.availableVoices;
      _selectedName = TtsService.instance.currentVoiceName;
      _loading = false;
    });
  }

  Future<void> _preview(Map<String, String> voice) async {
    setState(() => _previewingName = voice['name']);
    await TtsService.instance.setVoice(voice['name']!, voice['locale']!);
    await TtsService.instance.speak('Hello, I am ready to help you.');
    if (!mounted) return;
    setState(() {
      _previewingName = null;
      _selectedName = voice['name'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: const Text('Choose Voice'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Done',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.indigo),
                  SizedBox(height: 16),
                  Text('Loading voices...'),
                ],
              ),
            )
          : _voices.isEmpty
              ? const Center(
                  child: Text('No voices found on this device.'),
                )
              : ListView.separated(
                  itemCount: _voices.length,
                  separatorBuilder: (context, i) =>
                      const Divider(height: 1, indent: 16),
                  itemBuilder: (context, i) {
                    final voice = _voices[i];
                    final name = voice['name']!;
                    final locale = voice['locale']!;
                    final isSelected = name == _selectedName;
                    final isPreviewing = name == _previewingName;

                    return ListTile(
                      onTap: () => _preview(voice),
                      leading: CircleAvatar(
                        backgroundColor:
                            isSelected ? Colors.indigo : Colors.grey.shade200,
                        child: Icon(
                          isSelected ? Icons.check : Icons.record_voice_over,
                          color: isSelected ? Colors.white : Colors.grey,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        name,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected ? Colors.indigo : null,
                          fontSize: 13,
                        ),
                      ),
                      subtitle: Text(locale,
                          style: const TextStyle(fontSize: 11)),
                      trailing: isPreviewing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.play_circle_outline,
                              color: Colors.indigo),
                    );
                  },
                ),
    );
  }
}
