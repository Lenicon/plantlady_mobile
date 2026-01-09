import 'dart:io';

import 'package:floradex/main.dart';
import 'package:floradex/models/plant_result.dart';
import 'package:floradex/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';

class ResultScreen extends StatefulWidget {
  final PlantResult result;
  const ResultScreen({super.key, required this.result});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late TextEditingController _nicknameController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.result.nickname);
    _notesController = TextEditingController(text: widget.result.notes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Identification Result")),
      
      body: showcasePlant(context),
      bottomNavigationBar: _bottomNavigationBar(context)
    );
  }

  Container _bottomNavigationBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 60),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            offset: const Offset(0, 0),
            blurRadius: 5, 
          )]
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [Row(
          children:[
            _saveButton(context),
            const SizedBox(width: 10),
            _discardButton(context),
          ]
        )],
      ),
    );
  }

  bool _isSaving = false;
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
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Nickname', border: OutlineInputBorder()),
            onChanged: (val) => widget.result.nickname = val,
          ),
          const SizedBox(height: 16),

          // Information Table
          _infoRow("Scientific Name", widget.result.scientificName),
          _infoRow("Authorship", widget.result.authorship),
          _infoRow("Family", widget.result.family),
          _infoRow("Common Names", widget.result.commonNames.join(", ")),

          const SizedBox(height: 16),

          // Notes (Editable)
          TextField(
            controller: _notesController,
            keyboardType: TextInputType.multiline,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder(), hint: Text('Enter your notes here...', style: TextStyle(color: Colors.black54),)),
            onChanged: (val) => widget.result.notes = val,
          ),

          const SizedBox(height: 20),

        ],
      ),
    );
  }

  Expanded _discardButton(BuildContext context) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () => Navigator.pop(context),
        child: Text("Discard"),
      ),
    );
  }

  Expanded _saveButton(BuildContext context) {
    return Expanded(
      child: ElevatedButton(
        onPressed: _isSaving ? null : () async {
          // SAVE LOGIC
          
          setState(() => _isSaving = true);

          try {
            List<String> permanentPaths = [];
            
            for (String tempPath in widget.result.imagePaths) {
              String newPath = await StorageService.saveImagePermanently(tempPath);
              permanentPaths.add(newPath);
            }

            final savedResult = PlantResult(
              id: widget.result.id,
              imagePaths: permanentPaths,
              nickname: _nicknameController.text == '' ? 'Unnamed' : _nicknameController.text,
              scientificName: widget.result.scientificName,
              authorship: widget.result.authorship,
              family: widget.result.family,
              commonNames: widget.result.commonNames,
              notes: widget.result.notes,
            );

            await StorageService.savePlant(savedResult);

            if (mounted) {
              snackbarKey.currentState?.showSnackBar(
                const SnackBar(content: Text("Added to collection!"), duration: Duration(seconds: 2))
              );
              
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
            }


          } catch (e) {
            _showErrorDialog("Failed to save: $e");
          } finally {
            if (mounted) setState(() => _isSaving = false);
          }

        },
        child: 
          Text(_isSaving ? "Saving..." : "Save Plant"),
      ),
    );
  }

  ////////////// FOR IMAGES /////////////////////
  void _openFullImage(List<String> paths, int initialIndex) {
    int currentIndex = initialIndex;

    showDialog(
      context: context,
      useSafeArea: false, // Allows the image to take up the whole screen
      builder: (context) => Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // 1. Swipable Image Viewer
            Center(
              child: PageView.builder(
                controller: PageController(initialPage: initialIndex),
                itemCount: paths.length,
                onPageChanged: (index) => currentIndex = index,
                itemBuilder: (context, index) {
                  return InteractiveViewer( // Allows pinching to zoom
                    child: Image.file(
                      File(paths[index]),
                      fit: BoxFit.contain,
                    ),
                  );
                },
              ),
            ),
            // Buttons
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:[
                    // Close Button
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 30),
                      onPressed: () => Navigator.pop(context),
                    ),
                    // Download Button
                    IconButton(
                      // style: TextButton.styleFrom(iconSize: 30, backgroundColor: Colors.black45, foregroundColor: Colors.white),
                      icon: const Icon(Icons.download_rounded, color: Colors.white, size: 30),
                      onPressed: () async {
                        String currentPath = paths[currentIndex];
                        
                        if (StorageService.isSaved(currentPath)){
                          snackbarKey.currentState?.showSnackBar(
                            const SnackBar(content: Text("Image already saved!"), duration: Duration(seconds: 2))
                          );
                          return;
                        }
                        
                        try {
                          await Gal.putImage(currentPath, album: 'DaisieDex');

                          StorageService.markAsSaved(currentPath);
                          snackbarKey.currentState?.showSnackBar(
                            const SnackBar(content: Text("Saved to Gallery!"), duration: Duration(seconds: 2))
                          );
                          
                        } catch (e) {
                          _showErrorDialog("Couldn't save image: $e");
                        }
                      },
                    )
                  ]
                )
              ) 
              
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicCollage(List<String> paths) {
    double height = 200; // Total height for the banner
    int count = paths.length;

    // if (count == 0) return const SizedBox.shrink();

    // Layout for 1 Image: Full screen width
    if (count == 1) {
      return SizedBox(
        height: height,
        child: Row(
          children:[Expanded(flex:1, child:_imageWrapper(paths[0], height, paths, 0))]
        )
      );
    }

    // Layout for 2 Images: Two equal columns
    if (count == 2) {
      return SizedBox(
        height: height,
        child: Row(
          children: [
            Expanded(child: _imageWrapper(paths[0], height, paths, 0)),
            const SizedBox(width: 2),
            Expanded(child: _imageWrapper(paths[1], height, paths, 1)),
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
            Expanded(flex: 4, child: _imageWrapper(paths[0], height, paths, 0)),
            const SizedBox(width: 2),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Expanded(child: _imageWrapper(paths[1], height / 2, paths, 1)),
                  const SizedBox(height: 2),
                  Expanded(child: _imageWrapper(paths[2], height / 2, paths, 2)),
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
          Expanded(flex: 5, child: _imageWrapper(paths[0], height, paths, 0)),
          const SizedBox(width: 2),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Expanded(flex:2,child: _imageWrapper(paths[1], height / 3, paths, 1)),
                const SizedBox(height: 2),
                Expanded(flex:2,child: _imageWrapper(paths[2], height / 3, paths, 2)),
                const SizedBox(height: 2),
                Expanded(
                  // flex: 2,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _imageWrapper(paths[3], height / 3, paths, 3),
                      if (count > 4)
                        GestureDetector(
                          onTap: () => _openFullImage(paths, 3),
                          child: Container(
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
                        )
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
  Widget _imageWrapper(String path, double height, List<String> allPaths, int index) {
    return GestureDetector(
      onTap: () => _openFullImage(allPaths, index),
      child: Image.file(
        File(path),
        height: height,
        fit: BoxFit.cover,
      ),
    );
  }

  /////////////////////// END OF IMAGE BUILDERS ////////////////

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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
              SizedBox(width: 10),
              Transform.translate(offset: Offset(0, 2), child: Text("Error", style: TextStyle(fontWeight: FontWeight.bold),)),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Okayyy, if you say so...", style: TextStyle(color: Colors.black54)),
            ),
          ],
        );
      },
    );
  }
}