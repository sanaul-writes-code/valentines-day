import 'package:flutter/material.dart';

void main() => runApp(const ValentineApp());

class ValentineApp extends StatelessWidget {
  const ValentineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ValentineHome(),
      theme: ThemeData(useMaterial3: true),
    );
  }
}

class ValentineHome extends StatefulWidget {
  const ValentineHome({super.key});

  @override
  State<ValentineHome> createState() => _ValentineHomeState();
}

class Balloon {
  double x;
  double y;
  double speed;
  Color color;

  Balloon({
    required this.x,
    required this.y,
    required this.speed,
    required this.color,
  });
}

class _ValentineHomeState extends State<ValentineHome>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  List<Balloon> balloons = [];
  bool _dropBalloons = false;

  final List<String> emojiOptions = ['Sweet Heart', 'Party Heart'];
  String selectedEmoji = 'Sweet Heart';

  String get currentImage {
    if (selectedEmoji == 'Sweet Heart') {
      return 'assets/images/heart.jpeg';
    } else {
      return 'assets/images/sweetie.jpeg';
    }
  }

  void _startBalloonDrop() {
    balloons = List.generate(20, (i) {
      return Balloon(
        x: (50 + i * 15).toDouble(),
        y: -100.0,
        speed: 1 + (i % 5),
        color: Colors.primaries[i % Colors.primaries.length],
      );
    });

    _dropBalloons = true;
  }

  final List<Color> _bgColors = [
    Colors.white,
    Color(0xFFFFEBEE),
    Color(0xFFFCE4EC),
    Color(0xFFFFF0F5),
    Color(0xFFFFFDE7),
  ];
  int _bgIndex = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _animation = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.repeat(reverse: true);
    _controller.addListener(() {
      if (_dropBalloons) {
        setState(() {
          for (var b in balloons) {
            b.y += b.speed;

            // Reset balloon when it falls off screen
            if (b.y > 600) {
              b.y = -50;
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColors[_bgIndex],
      appBar: AppBar(title: const Text('Cupid\'s Canvas')),
      body: Column(
        children: [
          const SizedBox(height: 50),
          ScaleTransition(
            scale: _animation,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(currentImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 50),
          DropdownButton<String>(
            value: selectedEmoji,
            items: emojiOptions
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedEmoji = value ?? selectedEmoji;

                if (selectedEmoji == 'Sweet Heart') {
                  _controller.duration = const Duration(milliseconds: 1200);
                } else if (selectedEmoji == 'Party Heart') {
                  _controller.duration = const Duration(milliseconds: 500);
                }

                _controller.repeat(reverse: true);
              });
            },
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              setState(() {
                _bgIndex = (_bgIndex + 1) % _bgColors.length;
              });
            },
            child: const Text('Colors of Love ❤️'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              setState(() {
                if (_dropBalloons) {
                  // Turn OFF balloons
                  _dropBalloons = false;
                } else {
                  // Turn ON balloons
                  _startBalloonDrop();
                }
              });
            },
            child: Text(_dropBalloons ? "Stop Balloons ❌" : "Drop Balloons 🎈"),

          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: CustomPaint(
                size: const Size(300, 300),
                painter: HeartEmojiPainter(
                  type: selectedEmoji,
                  balloons: balloons,
                  dropBalloons: _dropBalloons,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HeartEmojiPainter extends CustomPainter {
  HeartEmojiPainter({
    required this.type,
    required this.balloons,
    required this.dropBalloons,
  });
  final String type;
  final List<Balloon> balloons;
  final bool dropBalloons;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    if (dropBalloons) {
      for (var b in balloons) {
        final balloonPaint = Paint()..color = b.color;

        // Balloon body
        canvas.drawOval(
          Rect.fromCenter(center: Offset(b.x, b.y), width: 30, height: 40),
          balloonPaint,
        );

        // String
        final stringPaint = Paint()
          ..color = Colors.black
          ..strokeWidth = 2;

        canvas.drawLine(
          Offset(b.x, b.y + 20),
          Offset(b.x, b.y + 50),
          stringPaint,
        );
      }
    }

    final heartPath = Path()
      ..moveTo(center.dx, center.dy + 60)
      ..cubicTo(
        center.dx + 110,
        center.dy - 10,
        center.dx + 60,
        center.dy - 120,
        center.dx,
        center.dy - 40,
      )
      ..cubicTo(
        center.dx - 60,
        center.dy - 120,
        center.dx - 110,
        center.dy - 10,
        center.dx,
        center.dy + 60,
      )
      ..close();

    paint.color = type == 'Party Heart'
        ? const Color(0xFFF48FB1)
        : const Color(0xFFE91E63);
    canvas.drawPath(heartPath, paint);

    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(center.dx - 30, center.dy - 10), 10, eyePaint);
    canvas.drawCircle(Offset(center.dx + 30, center.dy - 10), 10, eyePaint);

    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(center.dx, center.dy + 20), radius: 30),
      0,
      3.14,
      false,
      mouthPaint,
    );

    // Party hat placeholder (expand for confetti)
    if (type == 'Party Heart') {
      final hatPaint = Paint()..color = const Color(0xFFFFD54F);
      final hatPath = Path()
        ..moveTo(center.dx, center.dy - 110)
        ..lineTo(center.dx - 40, center.dy - 40)
        ..lineTo(center.dx + 40, center.dy - 40)
        ..close();
      canvas.drawPath(hatPath, hatPaint);

      final confettiPaint = Paint()..style = PaintingStyle.fill;
      final confettiOffsets = [
        Offset(center.dx - 80, center.dy - 80),
        Offset(center.dx + 70, center.dy - 70),
        Offset(center.dx - 90, center.dy + 20),
        Offset(center.dx + 85, center.dy + 10),
        Offset(center.dx - 40, center.dy + 90),
        Offset(center.dx + 40, center.dy + 95),
      ];
      final confettiColors = [
        Colors.yellow,
        Colors.blue,
        Colors.green,
        Colors.orange,
        Colors.purple,
        Colors.red,
      ];
      for (int i = 0; i < confettiOffsets.length; i++) {
        confettiPaint.color = confettiColors[i % confettiColors.length];
        canvas.drawCircle(confettiOffsets[i], 6, confettiPaint);
      }
    }

    if (type == 'Sweet Heart') {
      final blushPaint = Paint()..color = const Color(0xFFFFC1CC);

      canvas.drawCircle(Offset(center.dx - 45, center.dy + 5), 12, blushPaint);
      canvas.drawCircle(Offset(center.dx + 45, center.dy + 5), 12, blushPaint);
    }
  }

  @override
  bool shouldRepaint(covariant HeartEmojiPainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.dropBalloons != dropBalloons ||
        oldDelegate.balloons != balloons;
  }
}
