import 'package:flutter/material.dart';

/// Reusable Diaspora Handbook logo widget
class LogoWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool showFallback;

  const LogoWidget({
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.showFallback = true,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icon.png',  // Using icon.png for now until logo.png is saved
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        if (!showFallback) {
          return const SizedBox.shrink();
        }
        // Fallback UI when logo image is not available
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Sun rays (simplified version)
              Icon(
                Icons.wb_sunny,
                color: const Color(0xFFFFD700),
                size: (height ?? 60) * 0.3,
              ),
              const SizedBox(height: 4),
              // Text
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  children: [
                    Text(
                      'DIASPORA',
                      style: TextStyle(
                        color: const Color(0xFF003366),
                        fontWeight: FontWeight.bold,
                        fontSize: (height ?? 60) * 0.15,
                      ),
                    ),
                    Text(
                      'HANDBOOK',
                      style: TextStyle(
                        color: const Color(0xFF00A86B),
                        fontWeight: FontWeight.bold,
                        fontSize: (height ?? 60) * 0.15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Diaspora Handbook logo icon - square version for smaller spaces
class LogoIcon extends StatelessWidget {
  final double size;

  const LogoIcon({
    super.key,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icon.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback icon
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              // Sun rays icon
              Positioned(
                top: size * 0.1,
                left: size * 0.1,
                child: Icon(
                  Icons.wb_sunny,
                  color: const Color(0xFFFFD700),
                  size: size * 0.4,
                ),
              ),
              // Text
              Align(
                alignment: Alignment.center,
                child: Text(
                  'DH',
                  style: TextStyle(
                    color: const Color(0xFF003366),
                    fontWeight: FontWeight.bold,
                    fontSize: size * 0.3,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

