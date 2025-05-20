import 'package:flutter/material.dart';

class OrDivider extends StatelessWidget {
  final Color? color;
  final double thickness;
  final double indent;
  final double endIndent;
  final TextStyle? textStyle;

  const OrDivider({
    Key? key,
    this.color,
    this.thickness = 1.0,
    this.indent = 10.0,
    this.endIndent = 10.0,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultColor = color ?? Theme.of(context).dividerColor;
    final defaultTextStyle = textStyle ??
        TextStyle(color: Colors.white, fontSize: 12.0, fontWeight: FontWeight.w600,fontFamily: "Montserrat");

    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.white,
            thickness: thickness,
            indent: indent,
            endIndent: endIndent // Adjust spacing
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'or Sign in with',
            style: defaultTextStyle,
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.white,
            thickness: thickness,
            indent: 10.0, // Adjust spacing
            endIndent: endIndent,
          ),
        ),
      ],
    );
  }
}



