class AgricultureLaw {
  final String id;
  final String title;
  final String description;
  final String category;
  final String? documentUrl;
  final DateTime effectiveDate;
  final List<String> keyPoints;

  AgricultureLaw({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.documentUrl,
    required this.effectiveDate,
    required this.keyPoints,
  });
}
