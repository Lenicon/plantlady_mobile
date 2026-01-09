

import 'dart:io';

import 'package:floradex/main.dart';
import 'package:floradex/models/plant_result.dart';
import 'package:floradex/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';

class PlantDetailScreen extends StatefulWidget {
  final PlantResult plant;
  const PlantDetailScreen({super.key, required this.plant});

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  late TextEditingController _nicknameController;
  late TextEditingController _notesController;
  // late String _originalNickname; // To find the record in the file later
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.plant.nickname);
    _notesController = TextEditingController(text: widget.plant.notes);
    // _originalNickname = widget.plant.nickname;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                widget.plant.nickname,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Text("'s Details"),
          ],
        ),
      ),

      body: _showcasePlant(),
      
      bottomNavigationBar: _bottomNavigationBar(context),
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
            _backButton(context),
            const SizedBox(width: 10),
            _updateButton(),
          ]
        )],
      ),
    );
  }

  SingleChildScrollView _showcasePlant() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // REUSE your collage logic here
          _buildDynamicCollage(widget.plant.imagePaths),
          const SizedBox(height: 16),
          
          TextField(
            controller: _nicknameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Nickname', border: OutlineInputBorder()),
          ),
          
          const SizedBox(height: 16),

          _infoRow("Scientific Name", widget.plant.scientificName),
          _infoRow("Authorship", widget.plant.authorship),
          _infoRow("Family", widget.plant.family),
          _infoRow("Common Names", widget.plant.commonNames.join(", ")),

          const SizedBox(height: 16),

          TextField(
            controller: _notesController,
            keyboardType: TextInputType.multiline,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder(), hint: Text('Enter your notes here...', style: TextStyle(color: Colors.black54),)),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: _isSaving ? null : _showDeleteConfirmation,
              icon: Icon(Icons.delete_forever, color: Theme.of(context).colorScheme.error),
              label: Text("Delete from Collection", style: TextStyle(color: Theme.of(context).colorScheme.error)),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Expanded _backButton(BuildContext context) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () => Navigator.pop(context),
        child: Text("Back"),
      ),
    );
  }

  // Check if current text fields differ from the original plant data
  bool get _hasChanges {
    return _nicknameController.text != widget.plant.nickname ||
          _notesController.text != widget.plant.notes;
  }

  Expanded _updateButton() {
    return Expanded(
      child: ListenableBuilder(
        listenable: Listenable.merge([_nicknameController, _notesController]),
        builder: (context, child){

          bool canSave = _hasChanges && !_isSaving;

          return ElevatedButton(
            onPressed: canSave ? _handleUpdate : null,
            child: Text(_isSaving ? "Updating..." : "Update Details"),
          );
        }
      ) 
      
    );
  }


  Future<void> _showDeleteConfirmation() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.start,
          // backgroundColor: Colors.white,
          title: const Text("Delete Plant?"),
          content: const Text("This will permanently remove this plant from your collection and cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancel
              child: const Text("Cancel", style: TextStyle(color: Colors.black54)),
            ),
            TextButton(
              onPressed: () async {
                // Close the dialog
                Navigator.pop(context);
                
                await StorageService.deletePlant(widget.plant.id);
                
                if (mounted) {
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context); 
                  snackbarKey.currentState?.showSnackBar(
                    const SnackBar(content: Text("Plant removed from collection"), duration: Duration(seconds: 2))
                  );
                }
              },
              child: Text("Delete", style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleUpdate() async {
    setState(() => _isSaving = true);
    try {
      widget.plant.nickname = _nicknameController.text;
      widget.plant.notes = _notesController.text;

      await StorageService.updatePlant(widget.plant);
      
      // Global refresh so the grid updates
      await StorageService.load();

      if (mounted) {
        snackbarKey.currentState?.showSnackBar(
          const SnackBar(content: Text("Changes saved!"), duration: Duration(seconds: 2))
        );
      }
    } catch (e) {
      _showErrorDialog("Update failed: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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
          // backgroundColor: Colors.white,
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