// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart' as legacy_provider;

import 'package:finial_project/main.dart';
import 'package:finial_project/theme/theme_provider.dart';

void main() {
  testWidgets('App boots to splash screen', (WidgetTester tester) async {
    final TestWidgetsFlutterBinding binding =
        TestWidgetsFlutterBinding.ensureInitialized();
    final Size originalSize = binding.window.physicalSize;
    final double originalDpr = binding.window.devicePixelRatio;
    binding.window.physicalSizeTestValue = const Size(1080, 1920);
    binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(() {
      binding.window.physicalSizeTestValue = originalSize;
      binding.window.devicePixelRatioTestValue = originalDpr;
    });

    await tester.pumpWidget(
      ProviderScope(
        child: legacy_provider.ChangeNotifierProvider(
          create: (_) => ThemeProvider(ThemeMode.light),
          child: const SharkStageApp(),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('SharkStage'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
