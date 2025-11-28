import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diaspora_handbook/screens/resources_screen.dart';

void main() {
  testWidgets('ResourcesScreen displays key sections', (WidgetTester tester) async {
    // Act
    await tester.pumpWidget(const MaterialApp(
      home: ResourcesScreen(),
    ));

    // Assert
    expect(find.text('Handbook Resources'), findsOneWidget);
    
    // Verify top sections are visible
    expect(find.text('Emergency Contacts'), findsOneWidget);
    expect(find.text('Police / Emergency'), findsOneWidget);
    expect(find.text('Ambulance'), findsOneWidget);
    
    expect(find.text('Accommodations'), findsOneWidget);
    
    // Attempt to find something that might be visible or just below fold
    // Depending on screen size (default is 800x600 for test), this might be visible
    expect(find.text('Official Hotel Partner'), findsOneWidget);
  });
}
