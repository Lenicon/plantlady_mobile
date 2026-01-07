import 'package:floradex/models/plant_photo.dart';
import 'package:floradex/pages/result_screen.dart';
import 'package:floradex/services/plant_api_service.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

class Scanner extends StatefulWidget {
  const Scanner({super.key});

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  // Now we use a dynamic list of your custom class
  final List<PlantPhoto> _selectedPhotos = [];
  final int _maxPhotos = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Photos: ${_selectedPhotos.length} / $_maxPhotos (same plant's organs)",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              // We add 1 to the count to show the "Add" button
              itemCount: _selectedPhotos.length < _maxPhotos 
                  ? _selectedPhotos.length + 1 
                  : _selectedPhotos.length,
              itemBuilder: (context, index) {
                if (index < _selectedPhotos.length) {
                  return _buildImageThumbnail(index);
                } else {
                  return _buildAddButton();
                }
              },
            ),
          ),
          _buildIdentifyButton(),
        ],
      ),
    );
  }

  // UI for an image that has already been picked
  Widget _buildImageThumbnail(int index) {
    final photo = _selectedPhotos[index];
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: FileImage(File(photo.path)),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Label overlay (Leaf, Flower, etc.)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              photo.organ.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        // Delete button
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => setState(() => _selectedPhotos.removeAt(index)),
            child: const CircleAvatar(
              radius: 12,
              backgroundColor: Colors.red,
              child: Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // The empty slot used to add a new photo
  final ImagePicker _picker = ImagePicker();
  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () => _showPickerMenu(),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            style: BorderStyle.none
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo,
              // color: Colors.green[800],
              size: 32
            ),
            const SizedBox(height: 8),
            Text("Add Photo", style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold
            )),
          ],
        ),
      ),
    );
  }

  void _showPickerMenu() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  _processImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _processImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _processImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 80, // Reduces file size for faster API uploads
    );

    if (image != null) {
      // Re-using the organ dialog from our previous step
      String? selectedOrgan = await _showOrganDialog();

      if (selectedOrgan != null) {
        setState(() {
          _selectedPhotos.add(
            PlantPhoto(path: image.path, organ: selectedOrgan),
          );
        });
      }
    }
  }

  Future<String?> _showOrganDialog() async {
    final List<String> options = ['Leaf', 'Flower', 'Fruit', 'Bark', "Auto"];
    
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Identify the organ'),
          content: const Text('Which part of the plant is in this photo?'),
          actions: options.map((String organ) {
            return SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context, organ),
                child: Text(
                  organ.contains("Auto") ? "I don't know (Auto)" : organ, 
                  // textAlign: TextAlign.left,
                  style: TextStyle(color: Colors.black),
                ),
                
              )
            );
          }).toList(),
        );
      },
    );
  }

  bool _isLoading = false;
  Widget _buildIdentifyButton() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          disabledBackgroundColor: Colors.grey,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _selectedPhotos.isEmpty ? null : _isLoading ? null : () async {
          _handleIdentification();
        },
        child: _isLoading 
          ? Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 18, height: 18,child:CircularProgressIndicator(color: Colors.white)),
              SizedBox(width:16.0),
              Transform.translate(offset: Offset(0, 2), child: Text("Hmm... identifying...", style: TextStyle(color: Colors.white, fontSize: 18)))
            ])
          : Transform.translate(offset: Offset(0, 2), child:Text("Identify Plant", style: TextStyle(color: Colors.white, fontSize: 18)),)
      ),
    );
  }

  void _handleIdentification() async {
    setState(() => _isLoading = true);

    try {
      // 1. Call the service (no context passed!)
      final result = await PlantApiService.identifyPlant(_selectedPhotos);

      // 2. If it reaches here, it succeeded. Use context to navigate.
      if (!mounted) return;
      
      Navigator.push(
        context,
        MaterialPageRoute(builder: (c) => ResultScreen(result: result)),
      );

    } catch (e) {
      // 3. If the service "threw" an error, we catch it here and show the popup
      if (!mounted) return;
      _showErrorDialog(e.toString().replaceFirst('Exception: ', ''));
      
    } finally {
      if (mounted) {
        setState(() {
          _selectedPhotos.clear();
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 10),
              Text("Error"),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  AppBar appBar() {
    return AppBar(
      title: Text('Identifier', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold)),
      elevation: 0.0,
      centerTitle: true,
    );
  }
}