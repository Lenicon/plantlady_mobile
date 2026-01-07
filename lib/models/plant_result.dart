class PlantResult {
  final List<String> imagePaths;
  String nickname;
  final String scientificName;
  final String authorship;
  final String family;
  final List<String> commonNames;

  PlantResult({
    required this.imagePaths,
    required this.nickname,
    required this.scientificName,
    required this.authorship,
    required this.family,
    required this.commonNames,
  });
}