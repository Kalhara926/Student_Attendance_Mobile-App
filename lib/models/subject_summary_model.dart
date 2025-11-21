// lib/models/subject_summary_model.dart
class SubjectSummary {
  final String subjectName;
  int presentCount = 0;
  int totalClasses = 0;

  SubjectSummary({required this.subjectName});

  double get percentage =>
      totalClasses == 0 ? 0.0 : (presentCount / totalClasses) * 100;
}
