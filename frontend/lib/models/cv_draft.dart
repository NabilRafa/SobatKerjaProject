class CvDraft {
  final String label;
  final String? position;
  final String? summary;
  final List<Map<String, dynamic>> experience;
  final List<Map<String, dynamic>> education;
  final List<String> skills;

  CvDraft({
    required this.label,
    this.position,
    this.summary,
    required this.experience,
    required this.education,
    required this.skills,
  });
}
