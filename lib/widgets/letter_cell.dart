import 'package:flutter/material.dart';

class LetterCell extends StatelessWidget {
  const LetterCell({super.key, required this.letter, required this.backgroundColor,
    required this.foregroundColor, this.selected = false, this.onTap});
  final String letter;
  final Color backgroundColor, foregroundColor;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true, label: 'Letter $letter',
    child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(6),
      child: Container(alignment: Alignment.center,
        decoration: BoxDecoration(color: backgroundColor,
          borderRadius: BorderRadius.circular(6),
          border: selected ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2) : null),
        child: FittedBox(fit: BoxFit.scaleDown,
          child: Text(letter, style: TextStyle(color: foregroundColor, fontWeight: FontWeight.bold))),
      )),
  );
}
