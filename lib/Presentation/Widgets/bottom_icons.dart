import 'dart:ui';

import 'package:flutter/material.dart';

class BottomIcons extends StatelessWidget {
  final String? imageUrl;
  final IconData? iconData;
  final double size;
  final Color defaultColor;
  final Color selectedColor;
  final bool isSelected;
  final Color selectedBorderColor;
  final Color unselectedBorderColor;

  const BottomIcons({
    Key? key,
    this.imageUrl,
    this.iconData,
    this.size = 24,
    required this.defaultColor,
    required this.selectedColor,
    required this.isSelected,
      this.selectedBorderColor = const Color(0xFF0E5BC5),
    this.unselectedBorderColor = const Color(0xFF134A97),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentColor = isSelected ? selectedColor : defaultColor;
     Color borderColor = selectedBorderColor; 

    Widget contentWidget;

    if (imageUrl != null) {
      contentWidget = Image.network(
        imageUrl!,
        height: size,
        width: size,
        color: currentColor,
        errorBuilder: (_, __, ___) => Icon(Icons.broken_image, size: size),
      );
    } else if (iconData != null) {
      contentWidget = Icon(
        iconData,
        size: size,
        color: currentColor,
      );
    } else {
      contentWidget = Icon(Icons.error, color: Colors.red, size: size);
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          Color(0xFF13386B ),
          Color(0xFF171E45),
        ]),
        shape: BoxShape.circle,
        border: Border.all(width: 1, color: borderColor),
      ),
      padding: const EdgeInsets.all(8),
      child: contentWidget,
    );
  }
}
