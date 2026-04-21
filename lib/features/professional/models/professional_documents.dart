class ProfessionalDocuments {
  final Map<String, String> documents;

  ProfessionalDocuments({required this.documents});

  factory ProfessionalDocuments.fromJson(Map<String, dynamic> json) {
    // The API returns a structure where data is an array of objects containing a 'documents' object
    final Map<String, String> parsedDocs = {};
    if (json.containsKey('documents') && json['documents'] != null) {
      final Map<String, dynamic> docsJson = json['documents'];
      docsJson.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          parsedDocs[key] = value.toString();
        }
      });
    }
    return ProfessionalDocuments(documents: parsedDocs);
  }
}
