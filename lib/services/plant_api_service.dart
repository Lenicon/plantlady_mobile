import 'package:floradex/env/env.dart';
import 'package:floradex/models/plant_photo.dart';
import 'package:floradex/models/plant_result.dart';
// import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'dart:io';

class PlantApiService {
  static final String _apiKey = Env.plantKey;

  static Future<PlantResult> identifyPlant(List<PlantPhoto> photos) async {
    final uri = Uri.parse('https://my-api.plantnet.org/v2/identify/all?api-key=$_apiKey');
    
    var request = http.MultipartRequest('POST', uri);

    for (var photo in photos) {
      // Add the image file
      request.files.add(await http.MultipartFile.fromPath(
        'images', 
        photo.path
      ));
      
      // Add the corresponding organ label (must be lowercase)
      request.files.add(http.MultipartFile.fromString(
        'organs', 
        photo.organ.toLowerCase(),
      ));
    }

    try {
      
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {

        var data = jsonDecode(response.body);
        var bestMatch = data['results'][0]; // Get the top result
        var species = bestMatch['species'];

        PlantResult result = PlantResult(
          imagePaths: photos.map((p) => p.path).toList(),
          scientificName: species['scientificNameWithoutAuthor'],
          authorship: species['scientificNameAuthorship'],
          family: species['family']['scientificNameWithoutAuthor'],
          commonNames: List<String>.from(species['commonNames']),
          nickname: species['scientificNameWithoutAuthor'].split(' ')[0], // First word
        );

        return result;
      
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }

    } catch (e) {
      throw Exception("Check your internet connection and try again.");
    }

  }

}