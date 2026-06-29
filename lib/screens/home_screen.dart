import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/aac_provider.dart';
import '../utils/math_guard.dart';
import '../widgets/sentence_bar.dart';
import '../widgets/symbol_button.dart';
import '../widgets/folder_button.dart';
import 'edit_screen.dart';
import 'voice_picker_screen.dart';
import 'privacy_policy_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AacProvider>();
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: isLandscape
          ? _LandscapeLayout(provider: provider)
          : _PortraitLayout(provider: provider),
    );
  }
}

// ── Portrait: scrollable grid (auto-hide bar) + fixed bottom bar ──────────────

class _PortraitLayout extends StatelessWidget {
  final AacProvider provider;
  const _PortraitLayout({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              _HomeAppBar(provider: provider),
              _SymbolGrid(provider: provider, isLandscape: false),
            ],
          ),
        ),
        const BottomActionBar(),
      ],
    );
  }
}

// ── Landscape: scrollable grid (auto-hide bar) + fixed right sidebar ──────────

class _LandscapeLayout extends StatelessWidget {
  final AacProvider provider;
  const _LandscapeLayout({required this.provider});

  @override
  Widget build(BuildContext context) {
    final sidebarWidth =
        MediaQuery.of(context).size.width > 960 ? 260.0 : 220.0;

    return Row(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              _HomeAppBar(provider: provider),
              _SymbolGrid(provider: provider, isLandscape: true),
            ],
          ),
        ),
        SizedBox(
          width: sidebarWidth,
          child: const SideActionBar(),
        ),
      ],
    );
  }
}

// ── Shared floating AppBar ────────────────────────────────────────────────────

class _HomeAppBar extends StatelessWidget {
  final AacProvider provider;
  const _HomeAppBar({required this.provider});

  @override
  Widget build(BuildContext context) {
    final inFolder = provider.currentFolderId != null;
    return SliverAppBar(
      floating: true,
      snap: true,
      automaticallyImplyLeading: false,
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
                MaterialPageRoute(builder: (_) => const VoicePickerScreen()),
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
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'privacy') {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const PrivacyPolicyScreen()),
              );
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'privacy',
              child: Row(
                children: [
                  Icon(Icons.privacy_tip_outlined, color: Colors.indigo),
                  SizedBox(width: 10),
                  Text('Privacy Policy'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Responsive symbol grid ────────────────────────────────────────────────────

class _SymbolGrid extends StatelessWidget {
  final AacProvider provider;
  final bool isLandscape;
  const _SymbolGrid({required this.provider, required this.isLandscape});

  @override
  Widget build(BuildContext context) {
    final symbols = provider.symbols;
    final folders = provider.folders;
    final inFolder = provider.currentFolderId != null;
    final itemCount =
        inFolder ? symbols.length : folders.length + symbols.length;

    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    final sidebarWidth = screenWidth > 960 ? 260.0 : 220.0;
    final gridWidth = isLandscape ? screenWidth - sidebarWidth : screenWidth;
    final crossAxisCount = (gridWidth / 130).round().clamp(4, 9);

    final SliverGridDelegate gridDelegate;
    if (isLandscape) {
      // Fix tile height so ~3 rows are always visible
      final availableHeight = mq.size.height - mq.padding.top;
      final tileHeight =
          ((availableHeight - 24 - 20) / 3.3).clamp(100.0, 180.0);
      gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        mainAxisExtent: tileHeight,
      );
    } else {
      gridDelegate = const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(12),
      sliver: SliverGrid(
        gridDelegate: gridDelegate,
        delegate: SliverChildBuilderDelegate(
          (context, index) {
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
          childCount: itemCount,
        ),
      ),
    );
  }
}
