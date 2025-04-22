class AgriTechnology {
  final String id;
  final String name;
  final String description;
  final String category;
  final String imageUrl;
  final List<String> benefits;
  final String sourceUrl;

  AgriTechnology({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.imageUrl = '',
    required this.benefits,
    this.sourceUrl = '',
  });
}
