import 'dart:io';

import 'package:daisiedex/env/env.dart';
import 'package:daisiedex/models/plant_photo.dart';
import 'package:daisiedex/models/plant_result.dart';
import 'package:daisiedex/models/wikipedia_result.dart';
// import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'dart:convert';

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
// import 'package:uuid/uuid.dart';
// import 'dart:io';

class PlantApiService {
  static final String _apiKey = Env.plantKey;

  // For handling handshake cuz of the damn certificate security
  static http.Client _getSafeClient(){
    final HttpClient client = HttpClient()
      ..badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
    return IOClient(client);
  }

  static Future<PlantResult> identifyPlant(List<PlantPhoto> photos) async {
    final bool isConnected = await InternetConnection().hasInternetAccess;

    if (!isConnected) throw Exception("Looks like you have no internet connection, pretty lady.");

    final uri = Uri.parse('https://my-api.plantnet.org/v2/identify/all?api-key=$_apiKey');
    
    var client = _getSafeClient();
    var request = http.MultipartRequest('POST', uri);

    for (var photo in photos) {

      // Add image file
      request.files.add(await http.MultipartFile.fromPath(
        'images', 
        photo.path
      ));
      
      // Add corresponding organ label (must be lowercase)
      request.files.add(http.MultipartFile.fromString(
        'organs', 
        photo.organ.toLowerCase(),
      ));
    }

    try {
      
      var streamedResponse = await client.send(request);
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {

        var data = jsonDecode(response.body);
        var bestMatch = data['results'][0]; // top result
        var species = bestMatch['species'];

        
        // Wikipedia Result
        WikipediaResult wikires = await fetchWiki(species['scientificNameWithoutAuthor']);

        PlantResult result = PlantResult(
          imagePaths: photos.map((p) => p.path).toList(),
          scientificName: species['scientificNameWithoutAuthor'],
          authorship: species['scientificNameAuthorship'],
          family: species['family']['scientificNameWithoutAuthor'],
          commonNames: List<String>.from(species['commonNames']),
          nickname: species['scientificNameWithoutAuthor'].split(' ')[0], // First word
          wikiSummary: wikires.wikiSummary,
          wikiImageURL: wikires.wikiImageURL
        );

        return result;
      
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }

    } catch (e) {
      throw Exception("Something went wrong. I don't think that's a plant, pretty lady.");
    } finally {
      client.close();
    }

  }

  // Fetch wikipedia summary and image
  static Future<WikipediaResult> fetchWiki(String scientificName) async {

    final encodedTitle = encodePlantName(scientificName);
    
    final url = 'https://en.wikipedia.org/w/api.php?action=query&format=json&prop=extracts|pageimages&exintro&explaintext&redirects=1&titles=$encodedTitle&pithumbsize=1000';
    WikipediaResult res = WikipediaResult(wikiSummary: '', wikiImageURL: '');

    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200){
        // If data is found
        final data = json.decode(response.body);
        final pages = data['query']['pages'] as Map<String, dynamic>;
        final pageId = pages.keys.first;

        if (pageId != "-1"){
          // If found pageID
          res.wikiSummary = pages[pageId]['extract']?.split('\n\n==')[0];
          res.wikiImageURL = pages[pageId]['thumbnail']?['source'];

          return res;
        }

        return res;

      } 
      else {
        return res;
      }
    } catch (e) {
      return res;
    }
  }

  static String encodePlantName(String scientificName){
    return Uri.encodeComponent(scientificName.replaceAll(' × ', ' ').replaceAll(' x ', ' '));
  }
}

