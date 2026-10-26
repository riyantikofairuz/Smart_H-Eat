import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_heat/widgets/smart_heat_header.dart';
import 'package:smart_heat/widgets/smart_heat_logo.dart';

void main() {
  group('SmartHeatLogo Tests', () {
    testWidgets('SmartHeatLogo renders Image.asset with correct path and BoxFit.contain', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SmartHeatLogo(size: 52),
            ),
          ),
        ),
      );

      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);

      final imageWidget = tester.widget<Image>(imageFinder);
      expect(imageWidget.image, isA<AssetImage>());
      final assetImage = imageWidget.image as AssetImage;
      expect(assetImage.assetName, 'assets/images/smart_heat_logo.png');
      expect(imageWidget.fit, BoxFit.contain);
      expect(imageWidget.width, 52);
      expect(imageWidget.height, 52);
    });

    testWidgets('SmartHeatHeader displays SmartHeatLogo when showLogo is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmartHeatHeader(
              pageTitle: 'Customer',
              showLogo: true,
              onCartTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(SmartHeatLogo), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('SmartHeatHeader hides SmartHeatLogo when showLogo is false', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmartHeatHeader(
              pageTitle: 'Detail Menu',
              showLogo: false,
              onBack: () {},
            ),
          ),
        ),
      );

      expect(find.byType(SmartHeatLogo), findsNothing);
    });
  });
}
