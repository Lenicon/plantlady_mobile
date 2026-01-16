import 'dart:io';

import 'package:daisiedex/models/plant_result.dart';
import 'package:daisiedex/pages/plant_details.dart';
import 'package:daisiedex/services/storage_service.dart';
import 'package:flutter/material.dart';

class Florilegium extends StatefulWidget {
  const Florilegium({super.key});

  @override
  State<Florilegium> createState() => _FlorilegiumState();
}

class _FlorilegiumState extends State<Florilegium> {
  // List<dynamic> _savedPlants = [];
  // static List<dynamic> filteredPlants = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState(){
    super.initState();
    StorageService.load();
    // if (filteredPlants.isEmpty) setState(()=>filteredPlants = StorageService.savedPlants);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      // backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: appBar(),
      body: Column(
        children: [
          searchField(),

          Expanded(
            child: ValueListenableBuilder<List<dynamic>>(
            valueListenable: StorageService.plantsNotifier,
            builder: (context, allPlants, child) {
              final query = _searchController.text.toLowerCase();
                final filteredResults = allPlants.where((plant) {
                  final nickname = (plant['nickname'] ?? '').toString().toLowerCase();
                  return nickname.contains(query);
                }).toList();

                if (filteredResults.isEmpty) {
                  return const Center(
                    child: Text(
                      "No plants found!",
                      style: TextStyle(color: Colors.black54),
                    ),
                  );
                }

              return GridView.builder(
                    padding: const EdgeInsets.only(bottom: 20.0, left:20, right:20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: filteredResults.length,
                    itemBuilder: (context, index) {
                      final plantData = filteredResults[index];

                      // Map JSON to PlantResult object for the Details screen
                      final plantObj = PlantResult(
                        id: plantData['id'], // ID for easy finding
                        nickname: plantData['nickname'] == '' ? "Unnamed" : plantData['nickname'] ?? 'Unnamed',
                        notes: plantData['notes'] ?? "",
                        imagePaths: List<String>.from(plantData['imagePaths'] ?? []),
                        authorship: plantData['authorship'] ?? "",
                        scientificName: plantData['scientificName'] ?? "",
                        family: plantData['family'] ?? "",
                        commonNames: List<String>.from(plantData['commonNames'] ?? []),
                        wikiSummary: plantData['wikiSummary'] ?? "",
                        wikiImageURL: plantData['wikiImageURL'] ?? ""
                      );

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (c) => PlantDetailScreen(plant: plantObj),
                            ),
                          );
                        },
                        child: _buildCollectionCard(plantData),
                      );
                    },
                  );
                },
            ),
          ),
        ],
      ),
    );
  }


  // BUILDER FUNCTIONS

  Widget _buildCollectionCard(dynamic plant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
              image: DecorationImage(
                image: FileImage(File(plant['firstImage'])),
                fit: BoxFit.cover
              )
            ),
          )
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            plant['nickname'] ?? 'Unnamed',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }


  Container searchField() {
    return Container(
          margin: EdgeInsets.all(20),
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(
              color: Color.fromARGB(12, 29, 22, 23),
              blurRadius: 40,
              spreadRadius: 0.0
            )]
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(()=>{}),
            style: TextStyle(color: Color(0xFF524444), fontSize: 16),
            decoration: InputDecoration(
              filled: true,
              focusColor: Color(0xFF524444),
              hint: Text('Search gathered plant...', style: TextStyle(color: Colors.black54)),
              // fillColor: Color.fromARGB(255, 247, 220, 238),
              contentPadding: EdgeInsets.all(15),
              prefixIcon: Icon(Icons.search),
              // Clear button appears when typing
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none
              )
            ),
          ),
        );
  }


  

  AppBar appBar() {
    return AppBar(
      centerTitle: true,
      title: ValueListenableBuilder<List<dynamic>>(
        valueListenable: StorageService.plantsNotifier,
        builder: (context, plants, child) => Text('Florilegium (${plants.length})')
      ),
    );
  }
}