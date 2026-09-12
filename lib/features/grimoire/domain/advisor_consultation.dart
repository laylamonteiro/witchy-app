/// Request state of one question to the Mystic Advisor. It is the persisted
/// truth, separate from any animation: a mist loop never re-sends, and a
/// pending row found after a restart is shown as such, never retried alone.
enum AdvisorConsultationStatus { pending, answered, failed }

class AdvisorConsultation {
  const AdvisorConsultation({
    required this.id,
    required this.userId,
    required this.question,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.answer,
    this.writingId,
  });

  final String id;
  final String userId;
  /// Exactly the text captured when the question was sent.
  final String question;
  final AdvisorConsultationStatus status;
  final String? answer;
  /// The archive page created by "Save advice", when it exists.
  final String? writingId;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isAnswered => status == AdvisorConsultationStatus.answered && answer != null;
  bool get isSaved => writingId != null;

  factory AdvisorConsultation.fromRow(Map<String, Object?> row) => AdvisorConsultation(
    id: row['id'] as String,
    userId: row['user_id'] as String,
    question: row['question'] as String,
    status: AdvisorConsultationStatus.values.byName(row['status'] as String),
    answer: row['answer'] as String?,
    writingId: row['writing_id'] as String?,
    createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(row['updated_at'] as int),
  );
}
