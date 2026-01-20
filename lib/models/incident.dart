class Incident {
  final String title;
  final String description;

  Incident({required this.title, required this.description});

  Map<String, dynamic> toJson() {
    return {'title': title, 'description': description};
  }
}
