// main.dart for Pixico

import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:html' as html; // for web download

void main() {
  runApp(const PixicoApp());
}

class PixicoApp extends StatelessWidget {
  const PixicoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pixico',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const PixicoHome(),
    );
  }
}

class PixicoHome extends StatefulWidget {
  const PixicoHome({super.key});

  @override
  State<PixicoHome> createState() => _PixicoHomeState();
}

class _PixicoHomeState extends State<PixicoHome> {
  String _twoDigits(int n) => n.toString().padLeft(2, '0');
  String _monthName(int month) =>
      [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ][month];

  Uint8List? originalBytes;
  Uint8List? pixelatedBytes;
  int pixelWidth = 32;
  int pixelHeight = 32;
  bool isLoading = false;

  static const double pixelScale = 10.0;

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        originalBytes = result.files.single.bytes;
        pixelatedBytes = null;
        isLoading = true;
      });
      await processPixelate();
    }
  }

  Future<void> processPixelate() async {
    final image = img.decodeImage(originalBytes!);
    if (image == null) return;

    await Future.delayed(const Duration(milliseconds: 100));

    final resized = img.copyResize(
      image,
      width: pixelWidth,
      height: pixelHeight,
      interpolation: img.Interpolation.nearest,
    );
    final enlarged = img.copyResize(
      resized,
      width: (pixelWidth * pixelScale).toInt(),
      height: (pixelHeight * pixelScale).toInt(),
      interpolation: img.Interpolation.nearest,
    );

    setState(() {
      pixelatedBytes = Uint8List.fromList(img.encodePng(enlarged));
      isLoading = false;
    });
  }

  void downloadImageWeb(Uint8List bytes, String filename) {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor =
        html.AnchorElement(href: url)
          ..setAttribute('download', filename)
          ..click();
    html.Url.revokeObjectUrl(url);
  }

  Future<void> saveToGallery() async {
    if (pixelatedBytes == null) return;

    final timestamp = DateTime.now();
    final formatted =
        "${pixelWidth}x${pixelHeight}_${timestamp.year}.${_monthName(timestamp.month)}.${_twoDigits(timestamp.day)}_${_twoDigits(timestamp.hour)}.${_twoDigits(timestamp.minute)}.${_twoDigits(timestamp.second)}";
    final filename = "pixico_${formatted}.png";

    if (kIsWeb) {
      downloadImageWeb(pixelatedBytes!, filename);
      return;
    }

    final tempDir = await getTemporaryDirectory();
    final file = await File(
      '${tempDir.path}/$filename',
    ).writeAsBytes(pixelatedBytes!);
    await ImageGallerySaver.saveFile(file.path);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Saved to gallery!")));
  }

  @override
  Widget build(BuildContext context) {
    final double fixedDisplaySize = 1280;

    return Scaffold(
      appBar: AppBar(title: const Text("Pixico")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: pickImage,
                  child: const Text("Pick Image"),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: saveToGallery,
                  child: const Text("Save"),
                ),
              ],
            ),
            Row(
              children: [
                const Text("Width:"),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: pixelWidth,
                  items:
                      [16, 32, 64, 128]
                          .map(
                            (e) =>
                                DropdownMenuItem(value: e, child: Text("$e")),
                          )
                          .toList(),
                  onChanged:
                      (value) => setState(() {
                        pixelWidth = value!;
                        pixelHeight = value;
                        processPixelate();
                      }),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const CircularProgressIndicator()
            else if (pixelatedBytes != null && originalBytes != null)
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLabeledImage("Original", originalBytes!),
                    const SizedBox(width: 16),
                    _buildLabeledImage("Pixelated", pixelatedBytes!),
                  ],
                ),
              )
            else
              const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildLabeledImage(String label, Uint8List bytes) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          width: 300,
          height: 300,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            color: Colors.white,
          ),
          child: Image.memory(bytes),
        ),
      ],
    );
  }
}
