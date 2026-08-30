import 'dart:math';
import 'package:flutter/material.dart';
import '../services/tts_service.dart';

class DrawLettersGame extends StatefulWidget {
  const DrawLettersGame({super.key});

  @override
  State<DrawLettersGame> createState() => _DrawLettersGameState();
}

class _DrawLettersGameState extends State<DrawLettersGame> {
  List<Offset?> _points = [];
  int _currentLetterIndex = 0;
  int _score = 0;
  bool _showSuccess = false;
  final GlobalKey _canvasKey = GlobalKey();
  final TTSService _ttsService = TTSService();

  @override
  void initState() {
    super.initState();
    _ttsService.initialize();
    // Speak letter name and sound
    _speakLetter();
  }

  @override
  void dispose() {
    _ttsService.dispose();
    super.dispose();
  }

  final List<String> _letters = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
    'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T',
    'U', 'V', 'W', 'X', 'Y', 'Z'
  ];

  void _speakLetter() {
    String letter = _letters[_currentLetterIndex];
    // Clear phonetic pronunciation for each letter
    Map<String, String> phoneticSounds = {
      'A': 'AY. The letter A says AH as in Apple.',
      'B': 'BEE. The letter B says BUH as in Ball.',
      'C': 'SEE. The letter C says Kuh as in Cat.',
      'D': 'DEE. The letter D says DUH as in Dog.',
      'E': 'EE. The letter E says EH as in Egg.',
      'F': 'EFF. The letter F says FFF as in Fish.',
      'G': 'JEE. The letter G says GUH as in Goat.',
      'H': 'AYCH. The letter H says HUH as in Hat.',
      'I': 'EYE. The letter I says IH as in Igloo.',
      'J': 'JAY. The letter J says JUH as in Jug.',
      'K': 'KAY. The letter K says Kuh as in Kite.',
      'L': 'ELL. The letter L says LLL as in Lion.',
      'M': 'EMM. The letter M says MMM as in Moon.',
      'N': 'ENN. The letter N says NNN as in Nest.',
      'O': 'OH. The letter O says AH as in Orange.',
      'P': 'PEE. The letter P says PUH as in Pen.',
      'Q': 'CUE. The letter Q says KWUH as in Queen.',
      'R': 'AR. The letter R says RRR as in Rabbit.',
      'S': 'ESS. The letter S says SSS as in Sun.',
      'T': 'TEE. The letter T says TUH as in Tree.',
      'U': 'YOO. The letter U says UH as in Umbrella.',
      'V': 'VEE. The letter V says VVV as in Van.',
      'W': 'DOUBLE YOO. The letter W says WUH as in Water.',
      'X': 'EX. The letter X says KSS as in Box.',
      'Y': 'WYE. The letter Y says YUH as in Yellow.',
      'Z': 'ZED. The letter Z says ZZZ as in Zebra.',
    };
    
    _ttsService.speak(phoneticSounds[letter] ?? letter);
  }

  void _clearCanvas() {
    setState(() {
      _points = [];
      _showSuccess = false;
    });
  }

  void _nextLetter() {
    setState(() {
      if (_currentLetterIndex < _letters.length - 1) {
        _currentLetterIndex++;
      } else {
        _currentLetterIndex = 0;
      }
      _points = [];
      _showSuccess = false;
    });
    _speakLetter();
  }

  void _previousLetter() {
    setState(() {
      if (_currentLetterIndex > 0) {
        _currentLetterIndex--;
      } else {
        _currentLetterIndex = _letters.length - 1;
      }
      _points = [];
      _showSuccess = false;
    });
    _speakLetter();
  }

  void _completeDrawing() {
    if (_points.length > 10) {
      setState(() {
        _score += 10;
        _showSuccess = true;
      });
      _ttsService.speak('Amazing job! You earned 10 stars!');
      
      Future.delayed(const Duration(seconds: 3), () {
        _nextLetter();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFFF9C4),
              const Color(0xFFFFF59B),
              const Color(0xFFFFF9C4),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Cartoon clouds background
              Positioned(
                top: 80,
                left: 20,
                child: _buildCloud(40),
              ),
              Positioned(
                top: 120,
                right: 30,
                child: _buildCloud(30),
              ),
              Positioned(
                top: 180,
                left: 60,
                child: _buildCloud(35),
              ),
              // Cartoon sun
              Positioned(
                top: 60,
                right: 20,
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: CustomPaint(
                    painter: SunPainter(),
                  ),
                ),
              ),
              // Cartoon grass at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: 60,
                  child: CustomPaint(
                    painter: GrassPainter(),
                  ),
                ),
              ),
              // Cartoon flowers scattered
              Positioned(top: 200, left: 15, child: _buildFlower(const Color(0xFFFF69B4))),
              Positioned(top: 250, right: 20, child: _buildFlower(const Color(0xFFFFA500))),
              Positioned(top: 300, left: 25, child: _buildFlower(const Color(0xFF9370DB))),
              
              Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Color(0xFF4CAF50), size: 28),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF4CAF50), width: 2),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.volume_up, color: Color(0xFF4CAF50), size: 24),
                                onPressed: () {
                                  _ttsService.speak('Draw the letter ${_letters[_currentLetterIndex]}. Use your finger to trace the letter!');
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                ' Draw Letters!',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4CAF50),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.orange, width: 2),
                          ),
                          child: Row(
                            children: [
                              const Text('⭐', style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 4),
                              Text(
                                '$_score',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Letter navigation
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: _previousLetter,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF4CAF50), width: 2),
                            ),
                            child: const Icon(Icons.arrow_left, color: Color(0xFF4CAF50), size: 24),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF4CAF50), width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4CAF50).withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Text(
                                'Letter: ',
                                style: TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                              Text(
                                _letters[_currentLetterIndex],
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4CAF50),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: _nextLetter,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF4CAF50), width: 2),
                            ),
                            child: const Icon(Icons.arrow_right, color: Color(0xFF4CAF50), size: 24),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Drawing canvas
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: const Color(0xFF4CAF50), width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4CAF50).withOpacity(0.2),
                                  blurRadius: 10,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // Letter guide with dotted effect
                                Center(
                                  child: CustomPaint(
                                    painter: LetterGuidePainter(
                                      letter: _letters[_currentLetterIndex],
                                    ),
                                  ),
                                ),
                                // Large speaker button - very visible!
                                Positioned(
                                  top: 15,
                                  right: 15,
                                  child: GestureDetector(
                                    onTap: () {
                                      _speakLetter();
                                      // Visual feedback with haptic
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              const Icon(Icons.volume_up, color: Colors.white, size: 24),
                                              const SizedBox(width: 10),
                                              Text(
                                                '🔊 Letter ${_letters[_currentLetterIndex]} - Listen carefully!',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                          duration: const Duration(seconds: 2),
                                          backgroundColor: const Color(0xFF4CAF50),
                                          behavior: SnackBarBehavior.floating,
                                          margin: const EdgeInsets.all(16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.white, width: 3),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF4CAF50).withOpacity(0.6),
                                            blurRadius: 15,
                                            spreadRadius: 5,
                                          ),
                                        ],
                                      ),
                                      child: const Column(
                                        children: [
                                          Icon(
                                            Icons.volume_up,
                                            color: Colors.white,
                                            size: 48,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'TAP TO',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            'HEAR',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // Drawing area
                                GestureDetector(
                                  onPanUpdate: (details) {
                                    setState(() {
                                      final RenderBox? renderBox = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
                                      if (renderBox != null) {
                                        final Offset localPosition = renderBox.globalToLocal(details.globalPosition);
                                        _points.add(localPosition);
                                      }
                                    });
                                  },
                                  onPanEnd: (details) {
                                    setState(() {
                                      _points.add(null);
                                    });
                                  },
                                  child: SizedBox(
                                    width: constraints.maxWidth,
                                    height: constraints.maxHeight,
                                    key: _canvasKey,
                                    child: CustomPaint(
                                      painter: LeafDrawingPainter(
                                        points: _points,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Success message with animation
                  if (_showSuccess)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4CAF50).withOpacity(0.4),
                            blurRadius: 10,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🌿🌸 ', style: TextStyle(fontSize: 24)),
                          const Text(
                            'Amazing! +10 Stars!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Text(' 🌸🌿', style: TextStyle(fontSize: 24)),
                        ],
                      ),
                    ),
                  if (_showSuccess) const SizedBox(height: 16),
                  // Action buttons
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _clearCanvas,
                            icon: const Icon(Icons.refresh, size: 24),
                            label: const Text('Clear', style: TextStyle(fontSize: 16)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _completeDrawing,
                            icon: const Icon(Icons.check_circle, size: 24),
                            label: const Text('Done!', style: TextStyle(fontSize: 16)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCloud(double size) {
    return SizedBox(
      width: size * 2,
      height: size,
      child: CustomPaint(
        painter: CloudPainter(),
      ),
    );
  }

  Widget _buildFlower(Color color) {
    return SizedBox(
      width: 40,
      height: 40,
      child: CustomPaint(
        painter: FlowerPainter(color: color),
      ),
    );
  }
}

// Custom painter for leaf/flower themed drawing
class LeafDrawingPainter extends CustomPainter {
  final List<Offset?> points;

  LeafDrawingPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw leaves along the path
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        final leafPaint = Paint()
          ..color = const Color(0xFF4CAF50)
          ..style = PaintingStyle.fill;
        
        final flowerPaint = Paint()
          ..color = const Color(0xFFFF69B4)
          ..style = PaintingStyle.fill;

        // Draw leaf
        canvas.drawCircle(points[i]!, 6, leafPaint);
        
        // Add small flowers at intervals
        if (i % 8 == 0) {
          canvas.drawCircle(points[i]!, 4, flowerPaint);
        }

        // Draw connecting line
        final linePaint = Paint()
          ..color = const Color(0xFF8BC34A)
          ..strokeWidth = 4.0
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(points[i]!, points[i + 1]!, linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(LeafDrawingPainter oldDelegate) => true;
}

// Letter guide painter with dotted outline
class LetterGuidePainter extends CustomPainter {
  final String letter;

  LetterGuidePainter({required this.letter});

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: letter,
        style: const TextStyle(
          fontSize: 180,
          fontWeight: FontWeight.bold,
          color: Color(0xFFE0E0E0),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(LetterGuidePainter oldDelegate) => oldDelegate.letter != letter;
}

// Cloud painter for cartoon background
class CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    // Draw cloud shape
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.width * 0.3, size.height * 0.6), width: size.width * 0.5, height: size.height * 0.4),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.width * 0.5, size.height * 0.5), width: size.width * 0.6, height: size.height * 0.5),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.width * 0.7, size.height * 0.6), width: size.width * 0.5, height: size.height * 0.4),
      paint,
    );
  }

  @override
  bool shouldRepaint(CloudPainter oldDelegate) => false;
}

// Sun painter for cartoon background
class SunPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Sun rays
    final rayPaint = Paint()
      ..color = Colors.orange.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * 3.14159 / 180;
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(0, -radius * 0.7), width: 8, height: 20),
        rayPaint,
      );
      canvas.restore();
    }

    // Sun circle
    final sunPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.6, sunPaint);

    // Sun face
    final facePaint = Paint()
      ..color = Colors.brown
      ..style = PaintingStyle.fill;
    
    // Eyes
    canvas.drawCircle(Offset(center.dx - 8, center.dy - 5), 3, facePaint);
    canvas.drawCircle(Offset(center.dx + 8, center.dy - 5), 3, facePaint);
    
    // Smile
    final smilePath = Path()
      ..arcTo(
        Rect.fromCenter(center: Offset(center.dx, center.dy + 5), width: 16, height: 10),
        0,
        3.14159,
        false,
      );
    canvas.drawPath(smilePath, Paint()..color = Colors.brown..strokeWidth = 2..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(SunPainter oldDelegate) => false;
}

// Grass painter for bottom
class GrassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Grass background
    final grassPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF8BC34A),
          const Color(0xFF4CAF50),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), grassPaint);

    // Grass blades
    final bladePaint = Paint()
      ..color = const Color(0xFF66BB6A)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < size.width.toInt(); i += 15) {
      final path = Path()
        ..moveTo(i.toDouble(), size.height)
        ..quadraticBezierTo(
          i.toDouble() + 5,
          size.height - 20,
          i.toDouble() + 3,
          size.height - 30,
        )
        ..quadraticBezierTo(
          i.toDouble() + 7,
          size.height - 20,
          i.toDouble() + 10,
          size.height,
        );
      canvas.drawPath(path, bladePaint);
    }
  }

  @override
  bool shouldRepaint(GrassPainter oldDelegate) => false;
}

// Flower painter
class FlowerPainter extends CustomPainter {
  final Color color;

  FlowerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Petals
    final petalPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      final angle = (i * 72) * pi / 180;
      final petalOffset = Offset(
        center.dx + 10 * cos(angle),
        center.dy + 10 * sin(angle),
      );
      canvas.drawCircle(petalOffset, 6, petalPaint);
    }

    // Center
    final centerPaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 5, centerPaint);
  }

  @override
  bool shouldRepaint(FlowerPainter oldDelegate) => false;
}
