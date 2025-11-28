import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

void main() async {
  // Initialize Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🎨 Generating Diaspora Handbook icon...');
  
  // Icon size
  const size = 1024.0;
  
  // Create a picture recorder
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  
  // Background gradient (matching app theme)
  final backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1a1a2e), // Dark blue
      Color(0xFF16213e), // Darker blue
      Color(0xFF0f3460), // Navy blue
    ],
  );
  
  final backgroundPaint = Paint()
    ..shader = backgroundGradient.createShader(
      Rect.fromLTWH(0, 0, size, size),
    );
  
  // Draw background with rounded corners
  final rrect = RRect.fromRectAndRadius(
    Rect.fromLTWH(0, 0, size, size),
    Radius.circular(size * 0.22), // iOS-style rounded corners
  );
  canvas.drawRRect(rrect, backgroundPaint);
  
  // Draw decorative sun rays in top left (subtle)
  final sunPaint = Paint()
    ..color = Color(0xFFFFD700).withOpacity(0.15)
    ..style = PaintingStyle.fill;
  
  for (int i = 0; i < 8; i++) {
    final angle = (i * 45.0) * (3.14159 / 180.0);
    final path = Path();
    path.moveTo(size * 0.15, size * 0.15);
    path.lineTo(
      size * 0.15 + 100 * (i % 2 == 0 ? 1.2 : 0.8) * (angle * 0.1).cos(),
      size * 0.15 + 100 * (i % 2 == 0 ? 1.2 : 0.8) * (angle * 0.1).sin(),
    );
    canvas.drawPath(path, sunPaint);
  }
  
  // Add a subtle border/glow effect
  final borderPaint = Paint()
    ..color = Color(0xFFFFD700).withOpacity(0.3)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4;
  canvas.drawRRect(rrect, borderPaint);
  
  // Draw "DH" text
  final textStyle = TextStyle(
    fontSize: size * 0.5, // Large text
    fontWeight: FontWeight.w900,
    letterSpacing: -20,
  );
  
  // Draw "D" in purple
  final dPainter = TextPainter(
    text: TextSpan(
      text: 'D',
      style: textStyle.copyWith(
        foreground: Paint()
          ..shader = LinearGradient(
            colors: [
              Color(0xFF9B59B6), // Purple
              Color(0xFF8E44AD), // Darker purple
            ],
          ).createShader(Rect.fromLTWH(0, 0, size * 0.3, size * 0.6)),
      ),
    ),
    textDirection: TextDirection.ltr,
  );
  dPainter.layout();
  
  // Draw "H" in gold/yellow
  final hPainter = TextPainter(
    text: TextSpan(
      text: 'H',
      style: textStyle.copyWith(
        foreground: Paint()
          ..shader = LinearGradient(
            colors: [
              Color(0xFFFFD700), // Gold
              Color(0xFFFFA500), // Orange-gold
            ],
          ).createShader(Rect.fromLTWH(0, 0, size * 0.3, size * 0.6)),
      ),
    ),
    textDirection: TextDirection.ltr,
  );
  hPainter.layout();
  
  // Calculate total width and center position
  final totalWidth = dPainter.width + hPainter.width - 20;
  final startX = (size - totalWidth) / 2;
  final startY = (size - dPainter.height) / 2;
  
  // Draw shadow for depth
  final shadowPaint = Paint()
    ..color = Colors.black.withOpacity(0.5)
    ..maskFilter = MaskFilter.blur(BlurStyle.normal, 20);
  
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(startX + 10, startY + 10, totalWidth, dPainter.height),
      Radius.circular(20),
    ),
    shadowPaint,
  );
  
  // Paint the letters
  dPainter.paint(canvas, Offset(startX, startY));
  hPainter.paint(canvas, Offset(startX + dPainter.width - 20, startY));
  
  // Add a subtle tagline at bottom
  final taglinePainter = TextPainter(
    text: TextSpan(
      text: 'HOMECOMING GUIDE',
      style: TextStyle(
        fontSize: size * 0.04,
        fontWeight: FontWeight.w600,
        color: Color(0xFFFFD700).withOpacity(0.8),
        letterSpacing: 8,
      ),
    ),
    textDirection: TextDirection.ltr,
  );
  taglinePainter.layout();
  taglinePainter.paint(
    canvas,
    Offset((size - taglinePainter.width) / 2, size * 0.85),
  );
  
  // Convert to image
  final picture = recorder.endRecording();
  final image = await picture.toImage(size.toInt(), size.toInt());
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  
  if (byteData == null) {
    print('❌ Failed to generate image');
    exit(1);
  }
  
  // Save to file
  final file = File('assets/icon.png');
  await file.writeAsBytes(byteData.buffer.asUint8List());
  
  print('✅ Icon generated successfully: assets/icon.png');
  print('   Size: ${size.toInt()}x${size.toInt()} pixels');
  print('   Colors: Purple "D" + Gold "H"');
  print('');
  print('Next steps:');
  print('  1. Run: flutter pub run flutter_launcher_icons');
  print('  2. Run: flutter clean && flutter run');
}

extension on double {
  double cos() => this * 1.0; // Simplified for script
  double sin() => this * 1.0;
}

