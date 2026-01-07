import 'dart:io';

import 'package:floradex/main.dart';
import 'package:floradex/models/plant_result.dart';
import 'package:flutter/material.dart';

class ResultScreen extends StatefulWidget {
  final PlantResult result;
  const ResultScreen({super.key, required this.result});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late TextEditingController _nicknameController;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.result.nickname);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Identification Result", style: TextStyle(fontWeight: FontWeight.bold,)), centerTitle: true,),
      body: showcasePlant(context),
    );
  }

  SingleChildScrollView showcasePlant(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          // Collaged Images
          _buildDynamicCollage(widget.result.imagePaths),
          
          const SizedBox(height: 16),

          // Nickname (Editable)
          TextField(
            controller: _nicknameController,
            decoration: const InputDecoration(labelText: 'Nickname', border: OutlineInputBorder()),
            onChanged: (val) => widget.result.nickname = val,
          ),
          const SizedBox(height: 16),

          // Information Table
          _infoRow("Scientific Name", widget.result.scientificName),
          _infoRow("Authorship", widget.result.authorship),
          _infoRow("Family", widget.result.family),
          _infoRow("Common Names", widget.result.commonNames.join(", ")),

          const SizedBox(height: 20),

          // 4. Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Discard", style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
                  onPressed: () {
                    // SAVE LOGIC HERE (e.g., Save to Local Database)
                    Navigator.pop(context);
                    snackbarKey.currentState?.showSnackBar(SnackBar(
                      content: Text("Saved to Collection!"),
                      action: SnackBarAction(
                        label: '✕', // Using the multiplication symbol looks like a clean X
                        textColor: Colors.white,
                        onPressed: () {
                          snackbarKey.currentState?.hideCurrentSnackBar();
                        },
                      ),
                    ));
                  },
                  child: Text("Keep Result", style: TextStyle(color: Colors.white),),
                ),
              ),
            ],
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildDynamicCollage(List<String> paths) {
    double height = 200; // Total height for the banner
    int count = paths.length;

    if (count == 0) return const SizedBox.shrink();

    // Layout for 1 Image: Full screen width
    if (count == 1) {
      return _imageWrapper(paths[0], height);
    }

    // Layout for 2 Images: Two equal columns
    if (count == 2) {
      return SizedBox(
        height: height,
        child: Row(
          children: [
            Expanded(child: _imageWrapper(paths[0], height)),
            const SizedBox(width: 2),
            Expanded(child: _imageWrapper(paths[1], height)),
          ],
        ),
      );
    }

    // Layout for 3 Images: Large left, two stacked on the right
    if (count == 3) {
      return SizedBox(
        height: height,
        child: Row(
          children: [
            Expanded(flex: 4, child: _imageWrapper(paths[0], height)),
            const SizedBox(width: 2),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Expanded(child: _imageWrapper(paths[1], height / 2)),
                  const SizedBox(height: 2),
                  Expanded(child: _imageWrapper(paths[2], height / 2)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Layout for 4 or 5 Images: Large left, three stacked on the right
    // (Matches your 4th diagram with the "+" overlay logic)
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(flex: 5, child: _imageWrapper(paths[0], height)),
          const SizedBox(width: 2),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Expanded(flex:2,child: _imageWrapper(paths[1], height / 3)),
                const SizedBox(height: 2),
                Expanded(flex:2,child: _imageWrapper(paths[2], height / 3)),
                const SizedBox(height: 2),
                Expanded(
                  // flex: 2,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _imageWrapper(paths[3], height / 3),
                      if (count > 4)
                        Container(
                          color: Colors.black54,
                          child: Center(
                            child: Text(
                              "+${count - 4}",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper to handle the File Image and fit
  Widget _imageWrapper(String path, double height) {
    return Image.file(
      File(path),
      height: height,
      fit: BoxFit.cover,
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 18)),
          const Divider(),
        ],
      ),
    );
  }
}