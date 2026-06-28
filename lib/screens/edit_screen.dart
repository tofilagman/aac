import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/aac_provider.dart';
import '../models/folder.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({super.key});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddDialog() {
    final provider = context.read<AacProvider>();
    if (_tabController.index == 0) {
      _showAddSymbolDialog(provider);
    } else {
      _showAddFolderDialog(provider);
    }
  }

  void _showAddSymbolDialog(AacProvider provider) {
    final labelCtrl = TextEditingController();
    final emojiCtrl = TextEditingController();
    String? selectedFolderId;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Add Symbol'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelCtrl,
                decoration: const InputDecoration(labelText: 'Label *'),
                autofocus: true,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emojiCtrl,
                decoration: const InputDecoration(
                    labelText: 'Emoji', hintText: 'e.g. 🍎'),
              ),
              const SizedBox(height: 8),
              DropdownButton<String?>(
                isExpanded: true,
                value: selectedFolderId,
                hint: const Text('Core (no folder)'),
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text('Core (no folder)')),
                  ...provider.folders.map((f) => DropdownMenuItem(
                        value: f.id,
                        child: Text('${f.emoji} ${f.name}'),
                      )),
                ],
                onChanged: (v) => setState(() => selectedFolderId = v),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
              onPressed: () {
                if (labelCtrl.text.trim().isEmpty) return;
                provider.addSymbol(
                  label: labelCtrl.text.trim(),
                  emoji: emojiCtrl.text.trim().isEmpty
                      ? null
                      : emojiCtrl.text.trim(),
                  folderId: selectedFolderId,
                );
                Navigator.pop(ctx);
              },
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddFolderDialog(AacProvider provider) {
    final nameCtrl = TextEditingController();
    final emojiCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Folder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Folder Name *'),
              autofocus: true,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: emojiCtrl,
              decoration: const InputDecoration(
                  labelText: 'Emoji', hintText: 'e.g. 🎨'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              provider.addFolder(
                name: nameCtrl.text.trim(),
                emoji: emojiCtrl.text.trim().isEmpty
                    ? '📁'
                    : emojiCtrl.text.trim(),
              );
              Navigator.pop(ctx);
            },
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AacProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: const Text('Edit Board'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Symbols'),
            Tab(text: 'Folders'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _SymbolsTab(provider: provider),
          _FoldersTab(provider: provider),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }
}

class _SymbolsTab extends StatelessWidget {
  final AacProvider provider;
  const _SymbolsTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    final coreSymbols =
        provider.allSymbols.where((s) => s.folderId == null).toList();

    return ListView(
      children: [
        _sectionHeader('Core Vocabulary  •  hold & drag to reorder'),
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          onReorder: provider.reorderCoreSymbols,
          children: coreSymbols
              .map((s) => ListTile(
                    key: ValueKey(s.id),
                    leading: Text(s.emoji ?? '❓',
                        style: const TextStyle(fontSize: 28)),
                    title: Text(s.label),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.drag_handle, color: Colors.grey),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          onPressed: () => provider.deleteSymbol(s.id),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
        ...provider.folders.map((folder) {
          final folderSymbols = provider.symbolsForFolder(folder.id);
          return ExpansionTile(
            key: ValueKey(folder.id),
            leading:
                Text(folder.emoji, style: const TextStyle(fontSize: 24)),
            title: Text(folder.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            children: [
              if (folderSymbols.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No symbols yet.',
                      style: TextStyle(color: Colors.grey)),
                )
              else
                ReorderableListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  onReorder: (old, newIdx) =>
                      provider.reorderFolderSymbols(folder.id, old, newIdx),
                  children: folderSymbols
                      .map((s) => ListTile(
                            key: ValueKey(s.id),
                            leading: Text(s.emoji ?? '❓',
                                style: const TextStyle(fontSize: 24)),
                            title: Text(s.label),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.drag_handle,
                                    color: Colors.grey),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red),
                                  onPressed: () =>
                                      provider.deleteSymbol(s.id),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
            ],
          );
        }),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.grey)),
      );
}

class _FoldersTab extends StatelessWidget {
  final AacProvider provider;
  const _FoldersTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    final folders = provider.folders;

    if (folders.isEmpty) {
      return const Center(child: Text('No folders yet. Tap + to add one.'));
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      onReorder: provider.reorderFolders,
      itemCount: folders.length,
      itemBuilder: (context, i) {
        final folder = folders[i];
        return ListTile(
          key: ValueKey(folder.id),
          leading:
              Text(folder.emoji, style: const TextStyle(fontSize: 28)),
          title: Text(folder.name),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.drag_handle, color: Colors.grey),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _confirmDelete(context, folder, provider),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(
      BuildContext context, Folder folder, AacProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Folder'),
        content: Text(
            'Delete "${folder.name}"? All symbols inside will also be deleted.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              provider.deleteFolder(folder.id);
              Navigator.pop(ctx);
            },
            child:
                const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
