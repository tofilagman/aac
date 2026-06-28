import 'dart:io';
import 'package:flutter/material.dart';
import '../models/symbol_item.dart';
import '../services/tts_service.dart';

class SymbolButton extends StatefulWidget {
  final SymbolItem symbol;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const SymbolButton({
    super.key,
    required this.symbol,
    required this.onTap,
    this.onLongPress,
  });

  @override
  State<SymbolButton> createState() => _SymbolButtonState();
}

class _SymbolButtonState extends State<SymbolButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.9,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _controller.reverse();
    await _controller.forward();
    widget.onTap();
    await TtsService.instance.speak(widget.symbol.label);
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTap: _handleTap,
        onLongPress: widget.onLongPress,
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: widget.symbol.isFolder
                  ? Colors.orange.shade300
                  : Colors.indigo.shade100,
              width: 2,
            ),
          ),
          color: widget.symbol.isFolder
              ? Colors.orange.shade50
              : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: _buildImage(),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.symbol.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: widget.symbol.isFolder
                        ? Colors.orange.shade800
                        : Colors.indigo.shade900,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (widget.symbol.imagePath != null) {
      final file = File(widget.symbol.imagePath!);
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(file, fit: BoxFit.cover),
      );
    }
    return Center(
      child: Text(
        widget.symbol.emoji ?? '❓',
        style: const TextStyle(fontSize: 48),
      ),
    );
  }
}
