import 'package:flutter/material.dart';
import '../models/folder.dart';

class FolderButton extends StatelessWidget {
  final Folder folder;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const FolderButton({
    super.key,
    required this.folder,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.orange.shade300, width: 2),
        ),
        color: Colors.orange.shade50,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    folder.emoji,
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                folder.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade800,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Icon(Icons.folder, size: 14, color: Colors.orange.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
