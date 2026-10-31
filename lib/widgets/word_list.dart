import 'package:flutter/material.dart';
import '../models/word_entry.dart';

class WordList extends StatelessWidget {
  const WordList({super.key, required this.words, required this.foundWordIds});
  final List<WordEntry> words;
  final Set<String> foundWordIds;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(spacing: 8, runSpacing: 8, children: [
      for (final word in words)
        Semantics(label: '${word.word}, ${foundWordIds.contains(word.id) ? 'found' : 'not found'}',
          child: Chip(
            avatar: foundWordIds.contains(word.id) ? const Icon(Icons.check_rounded, size: 17) : null,
            label: Text(word.word),
            backgroundColor: foundWordIds.contains(word.id)
              ? scheme.tertiaryContainer : scheme.surfaceContainerHighest,
            side: BorderSide.none,
            labelStyle: TextStyle(decoration: foundWordIds.contains(word.id)
              ? TextDecoration.lineThrough : TextDecoration.none),
          )),
    ]);
  }
}
