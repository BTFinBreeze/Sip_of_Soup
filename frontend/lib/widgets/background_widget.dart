import 'package:flutter/material.dart';

class BackgroundWidget extends StatelessWidget {
  final Widget child;
  final bool showSOS;

  const BackgroundWidget({
    super.key,
    required this.child,
    this.showSOS = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            color: Colors.black.withOpacity(0.48),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.72),
                  Colors.black.withOpacity(0.08),
                  Colors.black.withOpacity(0.76),
                ],
                stops: const [0, 0.48, 1],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.35, -0.72),
                radius: 1.15,
                colors: [
                  const Color(0xFFFFB34B).withOpacity(0.24),
                  Colors.transparent,
                  Colors.black.withOpacity(0.68),
                ],
                stops: const [0, 0.36, 1],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                radius: 0.92,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.82),
                ],
                stops: const [0.52, 1],
              ),
            ),
          ),
          IgnorePointer(
            child: Opacity(
              opacity: 0.08,
              child: CustomPaint(
                painter: _PaperGrainPainter(),
                size: Size.infinite,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.black.withOpacity(0.52),
                  Colors.transparent,
                  Colors.black.withOpacity(0.54),
                ],
                stops: const [0.0, 0.46, 1.0],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFF0A0604).withOpacity(0.5),
                width: 8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.85),
                  blurRadius: 80,
                  spreadRadius: 22,
                ),
              ],
            ),
          ),
          if (showSOS)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  alignment: Alignment.center,
                  child: Text(
                    'S.O.S.',
                    style: TextStyle(
                      fontSize: 500,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[300]!.withOpacity(0.08),
                    ),
                  ),
                ),
              ),
            ),
          child,
        ],
      ),
    );
  }
}

class _PaperGrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF1E4C8)
      ..strokeWidth = 0.65;

    for (double y = 0; y < size.height; y += 9) {
      final startX = (y % 27) - 18;
      canvas.drawLine(
        Offset(startX, y),
        Offset(size.width + 18, y + (y % 5) - 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
