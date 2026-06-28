import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/aac_provider.dart';
import '../utils/math_guard.dart';
import '../widgets/sentence_bar.dart';
import '../widgets/symbol_button.dart';
import '../widgets/folder_button.dart';
import 'edit_screen.dart';
import 'voice_picker_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AacProvider>();
    final symbols = provider.symbols;
    final folders = provider.folders;
    final inFolder = provider.currentFolderId != null;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: Text(
          inFolder ? provider.currentFolder?.name ?? '' : 'AAC',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.record_voice_over),
            tooltip: 'Voice',
            onPressed: () async {
              final ok = await showMathGuard(context);
              if (ok && context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const VoicePickerScreen()),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: () async {
              final ok = await showMathGuard(context);
              if (ok && context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.85,
        ),
        itemCount:
            inFolder ? symbols.length : folders.length + symbols.length,
        itemBuilder: (context, index) {
          if (!inFolder && index < folders.length) {
            final folder = folders[index];
            return FolderButton(
              folder: folder,
              onTap: () => provider.enterFolder(folder.id),
            );
          }

          final symbolIndex = inFolder ? index : index - folders.length;
          final symbol = symbols[symbolIndex];
          return SymbolButton(
            symbol: symbol,
            onTap: () => provider.addToSentence(symbol),
          );
        },
      ),
      bottomNavigationBar: const BottomActionBar(),
    );
  }
}
