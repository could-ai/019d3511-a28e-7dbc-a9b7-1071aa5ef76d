import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '1-Point Perspective Drawing',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const PerspectiveDrawingScreen(),
      },
    );
  }
}

class PerspectiveDrawingScreen extends StatefulWidget {
  const PerspectiveDrawingScreen({super.key});

  @override
  State<PerspectiveDrawingScreen> createState() => _PerspectiveDrawingScreenState();
}

class _PerspectiveDrawingScreenState extends State<PerspectiveDrawingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('1-Point Perspective Room Interior'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _exportAsImage,
            tooltip: 'Export as PNG',
          ),
        ],
      ),
      body: Row(
        children: [
          // Drawing area
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.white,
              child: const PerspectivePainter(),
            ),
          ),
          // Text area
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.grey[100],
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Title: 1 Point Perspective Drawing',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Name: __________'),
                  SizedBox(height: 8),
                  Text('Class: BSc Animation & VFX'),
                  SizedBox(height: 8),
                  Text('Software: Adobe Illustrator'),
                  SizedBox(height: 8),
                  Text('Tools Used: Line Tool, Rectangle Tool, Pen Tool'),
                  SizedBox(height: 16),
                  Text(
                    'Concept: In one point perspective, all lines converge to one vanishing point on the horizon line.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportAsImage() async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final size = const Size(595, 842); // A4 size in points (72 DPI)
      const PerspectivePainter().paint(canvas, size);
      final picture = recorder.endRecording();
      final image = await picture.toImage(size.width.toInt(), size.height.toInt());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/perspective_drawing.png');
      await file.writeAsBytes(buffer);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image saved to ${file.path}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving image: $e')),
      );
    }
  }
}

class PerspectivePainter extends CustomPainter {
  const PerspectivePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Horizon Line
    canvas.drawLine(Offset(0, centerY), Offset(size.width, centerY), paint);

    // Vanishing Point (just a small circle for visualization)
    canvas.drawCircle(Offset(centerX, centerY), 5, paint);

    // Front wall rectangle
    final wallLeft = centerX - 150;
    final wallRight = centerX + 150;
    final wallTop = centerY - 100;
    final wallBottom = centerY + 100;
    canvas.drawRect(Rect.fromLTRB(wallLeft, wallTop, wallRight, wallBottom), paint);

    // Perspective lines from corners to vanishing point
    canvas.drawLine(Offset(wallLeft, wallTop), Offset(centerX, centerY), paint);
    canvas.drawLine(Offset(wallRight, wallTop), Offset(centerX, centerY), paint);
    canvas.drawLine(Offset(wallLeft, wallBottom), Offset(centerX, centerY), paint);
    canvas.drawLine(Offset(wallRight, wallBottom), Offset(centerX, centerY), paint);

    // Bed (simple rectangle on the left)
    final bedLeft = wallLeft + 20;
    final bedRight = bedLeft + 80;
    final bedTop = centerY + 20;
    final bedBottom = bedTop + 40;
    canvas.drawRect(Rect.fromLTRB(bedLeft, bedTop, bedRight, bedBottom), paint);
    // Bed perspective lines
    canvas.drawLine(Offset(bedRight, bedTop), Offset(centerX, centerY), paint);
    canvas.drawLine(Offset(bedRight, bedBottom), Offset(centerX, centerY), paint);

    // Window (rectangle on the right)
    final windowLeft = wallRight - 60;
    final windowRight = wallRight - 20;
    final windowTop = centerY - 40;
    final windowBottom = centerY - 10;
    canvas.drawRect(Rect.fromLTRB(windowLeft, windowTop, windowRight, windowBottom), paint);
    // Window perspective lines
    canvas.drawLine(Offset(windowRight, windowTop), Offset(centerX, centerY), paint);
    canvas.drawLine(Offset(windowRight, windowBottom), Offset(centerX, centerY), paint);

    // Door (rectangle in the middle)
    final doorLeft = centerX - 30;
    final doorRight = centerX + 30;
    final doorTop = centerY + 10;
    final doorBottom = centerY + 70;
    canvas.drawRect(Rect.fromLTRB(doorLeft, doorTop, doorRight, doorBottom), paint);
    // Door perspective lines
    canvas.drawLine(Offset(doorRight, doorTop), Offset(centerX, centerY), paint);
    canvas.drawLine(Offset(doorRight, doorBottom), Offset(centerX, centerY), paint);

    // Table (small rectangle near bed)
    final tableLeft = bedLeft;
    final tableRight = tableLeft + 40;
    final tableTop = bedBottom + 10;
    final tableBottom = tableTop + 20;
    canvas.drawRect(Rect.fromLTRB(tableLeft, tableTop, tableRight, tableBottom), paint);
    // Table perspective lines
    canvas.drawLine(Offset(tableRight, tableTop), Offset(centerX, centerY), paint);
    canvas.drawLine(Offset(tableRight, tableBottom), Offset(centerX, centerY), paint);

    // Carpet (larger rectangle on floor)
    final carpetLeft = wallLeft + 50;
    final carpetRight = wallRight - 50;
    final carpetTop = centerY + 50;
    final carpetBottom = centerY + 120;
    canvas.drawRect(Rect.fromLTRB(carpetLeft, carpetTop, carpetRight, carpetBottom), paint);
    // Carpet perspective lines
    canvas.drawLine(Offset(carpetRight, carpetTop), Offset(centerX, centerY), paint);
    canvas.drawLine(Offset(carpetRight, carpetBottom), Offset(centerX, centerY), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}