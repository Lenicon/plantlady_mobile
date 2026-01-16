import 'dart:convert';
import 'dart:io';
import 'package:daisiedex/models/plant_result.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class StorageService {
  static const int maxFileSize = 20 * 1024 * 1024; // 20 MB

  static List<dynamic> savedPlants = [];
  static ValueNotifier<List<dynamic>> plantsNotifier = ValueNotifier([]);

  /// Loads all plants from all collection files and updates notifier
  static Future<void> load() async {
    final plants = await getAllSavedPlants();
    savedPlants = plants;
    plantsNotifier.value = plants;
  }

  /// Saves new plant with unique ID and full image path list
  static Future<void> savePlant(PlantResult result) async {
    final directory = await getApplicationDocumentsDirectory();
    int fileIndex = 1;
    File targetFile;

    while (true) {
      targetFile = File('${directory.path}/collection_$fileIndex.json');
      if (await targetFile.exists()) {
        int size = await targetFile.length();
        if (size < maxFileSize) break;
        fileIndex++;
      } else {
        await targetFile.create();
        await targetFile.writeAsString('[]');
        break;
      }
    }

    List<dynamic> currentList = jsonDecode(await targetFile.readAsString());
    
    currentList.add({
      'id': result.id, // Saving unique ID
      'nickname': result.nickname,
      'firstImage': result.imagePaths.isNotEmpty ? result.imagePaths.first : '',
      'imagePaths': result.imagePaths, // Save all paths for collage
      'scientificName': result.scientificName,
      'authorship': result.authorship,
      'family': result.family,
      'commonNames': result.commonNames,
      'notes': result.notes,
      'wikiSummary': result.wikiSummary,
      'wikiImageURL': result.wikiImageURL
    });

    await targetFile.writeAsString(jsonEncode(currentList));
    await load(); // Refresh notifier automatically
  }

  /// Updates nickname and notes for existing plant by ID
  static Future<void> updatePlant(PlantResult updatedPlant) async {
    final directory = await getApplicationDocumentsDirectory();
    final files = directory.listSync().where((file) => file.path.contains('collection_'));

    for (var file in files) {
      if (file is File) {
        List<dynamic> list = jsonDecode(await file.readAsString());
        int index = list.indexWhere((p) => p['id'] == updatedPlant.id);
        
        if (index != -1) {
          list[index]['nickname'] = updatedPlant.nickname;
          list[index]['notes'] = updatedPlant.notes;
          await file.writeAsString(jsonEncode(list));
          await load(); // load changes
          return; 
        }
      }
    }
  }

  /// Deletes plant from JSON files and notifies UI
  static Future<void> deletePlant(String id) async {
    final directory = await getApplicationDocumentsDirectory();
    final files = directory.listSync().where((file) => file.path.contains('collection_'));

    for (var file in files) {
      if (file is File) {
        String content = await file.readAsString();
        List<dynamic> list = jsonDecode(content);
        
        // Find plant to get its image paths before deleting it
        int index = list.indexWhere((plant) => plant['id'] == id);

        if (index != -1) {
          final plantToDelete = list[index];

          // Delete the physical image files from the 'photos' folder
          if (plantToDelete['imagePaths'] != null) {
            List<dynamic> paths = plantToDelete['imagePaths'];
            for (String path in paths) {
              final imageFile = File(path);
              if (await imageFile.exists()) {
                await imageFile.delete(); // Removes the .jpg from storage
              }
            }
          }

          // Remove from JSON
          list.removeAt(index);

          // Save updated list back to file
          await file.writeAsString(jsonEncode(list));

          await load(); 
          return;
        }
      }
    }
  }

  static Future<List<dynamic>> getAllSavedPlants() async {
    final directory = await getApplicationDocumentsDirectory();
    List<dynamic> allPlants = [];
    final files = directory.listSync().where((file) => file.path.contains('collection_'));

    for (var file in files) {
      if (file is File) {
        String content = await file.readAsString();
        allPlants.addAll(jsonDecode(content));
      }
    }
    return allPlants;
  }

  static Future<String> saveImagePermanently(String tempPath) async {
    final directory = await getApplicationDocumentsDirectory();
    final name = p.basename(tempPath);
    final folder = Directory('${directory.path}/photos');
    
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }

    final permanentPath = '${folder.path}/$name';
    final File tempFile = File(tempPath);
    
    if (await tempFile.exists()) {
      final File newFile = await tempFile.copy(permanentPath);
      return newFile.path;
    }
    return tempPath;
  }

  // Check if saved this session so no multisaving
  static final Set<String> globalSavedPaths = {};

  static void markAsSaved(String path) {
    globalSavedPaths.add(path);
  }

  static bool isSaved(String path) {
    return globalSavedPaths.contains(path);
  }

}