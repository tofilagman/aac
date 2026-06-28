import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/aac_provider.dart';
import '../services/tts_service.dart';

class BottomActionBar extends StatelessWidget {
  const BottomActionBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AacProvider>();
    final sentence = provider.sentence;
    final inFolder = provider.currentFolderId != null;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sentence display
            Container(
              color: Colors.indigo.shade50,
              constraints: const BoxConstraints(minHeight: 44),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              width: double.infinity,
              child: sentence.isEmpty
                  ? const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Tap symbols to build a sentence...',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: sentence.asMap().entries.map((entry) {
                          final i = entry.key;
                          final item = entry.value;
                          return GestureDetector(
                            onTap: () => provider.removeFromSentence(i),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.indigo,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (item.emoji != null)
                                    Text(item.emoji!,
                                        style: const TextStyle(fontSize: 14)),
                                  const SizedBox(width: 4),
                                  Text(
                                    item.label,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
            ),
            // Action buttons row
            Row(
              children: [
                // Back button (only in folder)
                if (inFolder)
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.arrow_back_rounded,
                      label: 'Back',
                      color: Colors.orange,
                      onTap: provider.exitFolder,
                    ),
                  ),
                // Speak button
                Expanded(
                  flex: 2,
                  child: _ActionButton(
                    icon: Icons.volume_up_rounded,
                    label: 'Speak',
                    color: Colors.indigo,
                    onTap: sentence.isEmpty
                        ? null
                        : () => TtsService.instance.speak(provider.sentenceText),
                  ),
                ),
                // Clear button
                Expanded(
                  child: _ActionButton(
                    icon: Icons.backspace_rounded,
                    label: 'Clear',
                    color: Colors.red,
                    onTap: sentence.isEmpty ? null : provider.clearSentence,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: disabled ? Colors.grey.shade300 : color, size: 26),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: disabled ? Colors.grey.shade300 : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
