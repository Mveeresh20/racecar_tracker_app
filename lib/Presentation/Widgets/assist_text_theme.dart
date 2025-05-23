import 'package:flutter/material.dart';
import 'package:racecar_tracker/Utils/theme_extensions.dart';


class AssistTextTheme extends StatelessWidget {
  const AssistTextTheme({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'LabelSmall:\n ${context.labelSmall?.fontSize} | ${context.labelSmall?.fontWeight}',
          style: context.labelSmall,
        ),
        Divider(),
        Text(
          'LabelMedium:\n ${context.labelMedium?.fontSize} | ${context.labelMedium?.fontWeight}',
          style: context.labelMedium,
        ),
        Divider(),
        Text(
          'LabelLarge:\n ${context.labelLarge?.fontSize} | ${context.labelLarge?.fontWeight}',
          style: context.labelLarge,
        ),
        Divider(),
        Text(
          'BodySmall:\n ${context.bodySmall?.fontSize} | ${context.bodySmall?.fontWeight}',
          style: context.bodySmall,
        ),
        Divider(),
        Text(
          'BodyMedium:\n ${context.bodyMedium?.fontSize} | ${context.bodyMedium?.fontWeight}',
          style: context.bodyMedium,
        ),
        Divider(),
        Text(
          'BodyLarge:\n ${context.bodyLarge?.fontSize} | ${context.bodyLarge?.fontWeight}',
          style: context.bodyLarge,
        ),
        Divider(),
        Text(
          'TitleSmall:\n ${context.titleSmall?.fontSize} | ${context.titleSmall?.fontWeight}',
          style: context.titleSmall,
        ),
        Divider(),
        Text(
          'TitleMedium:\n ${context.titleMedium?.fontSize} | ${context.titleMedium?.fontWeight}',
          style: context.titleMedium,
        ),
        Divider(),
        Text(
          'TitleLarge:\n ${context.titleLarge?.fontSize} | ${context.titleLarge?.fontWeight}',
          style: context.titleLarge,
        ),
        Divider(),
        Text(
          'HeadlineSmall:\n ${context.headlineSmall?.fontSize} | ${context.headlineSmall?.fontWeight}',
          style: context.headlineSmall,
        ),
        Divider(),
        Text(
          'HeadlineMedium:\n ${context.headlineMedium?.fontSize} | ${context.headlineMedium?.fontWeight}',
          style: context.headlineMedium,
        ),
        Divider(),
        Text(
          'HeadlineLarge:\n ${context.headlineLarge?.fontSize} | ${context.headlineLarge?.fontWeight}',
          style: context.headlineLarge,
        ),
        Divider(),
        Text(
          'DisplaySmall:\n ${context.displaySmall?.fontSize} | ${context.displaySmall?.fontWeight}',
          style: context.displaySmall,
        ),
        Divider(),
        Text(
          'DisplayMedium:\n ${context.displayMedium?.fontSize} | ${context.displayMedium?.fontWeight}',
          style: context.displayMedium,
        ),
        Divider(),
        Text(
          'DisplayLarge:\n ${context.displayLarge?.fontSize} | ${context.displayLarge?.fontWeight}',
          style: context.displayLarge,
        ),
        Divider(),
      ],
    );
  }
}
