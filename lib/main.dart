import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

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
  Uint8List? originalBytes;
  Uint8List? pixelatedBytes;
  int pixelWidth = 32;
  int pixelHeight = 32;

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        originalBytes = result.files.single.bytes;
        pixelatedBytes = null;
      });
      processPixelate();
    }
  }

  void processPixelate() {
    final image = img.decodeImage(originalBytes!);
    if (image == null) return;

    final resized = img.copyResize(
      image,
      width: pixelWidth,
      height: pixelHeight,
      interpolation: img.Interpolation.nearest,
    );
    final enlarged = img.copyResize(
      resized,
      width: pixelWidth * 10,
      height: pixelHeight * 10,
      interpolation: img.Interpolation.nearest,
    );

    setState(() {
      pixelatedBytes = Uint8List.fromList(img.encodePng(enlarged));
    });
  }

  Future<void> saveToGallery() async {
    if (pixelatedBytes == null) return;
    final tempDir = await getTemporaryDirectory();
    final file = await File(
      '${tempDir.path}/pixelated.png',
    ).writeAsBytes(pixelatedBytes!);
    await ImageGallerySaver.saveFile(file.path);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Saved to gallery!")));
  }

  @override
  Widget build(BuildContext context) {
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
            if (pixelatedBytes != null)
              Expanded(child: Image.memory(pixelatedBytes!))
            else
              const Spacer(),
          ],
        ),
      ),
    );
  }
}
