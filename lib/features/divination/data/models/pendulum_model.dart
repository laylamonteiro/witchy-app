enum PendulumAnswer {
  yes,
  no,
  maybe,
  unclear;

  String get displayName {
    switch (this) {
      case PendulumAnswer.yes:
        return 'SIM';
      case PendulumAnswer.no:
        return 'NÃO';
      case PendulumAnswer.maybe:
        return 'TALVEZ';
      case PendulumAnswer.unclear:
        return 'INCERTO';
    }
  }

  String get message {
    switch (this) {
      case PendulumAnswer.yes:
        return 'A energia indica uma resposta positiva';
      case PendulumAnswer.no:
        return 'A energia indica uma resposta negativa';
      case PendulumAnswer.maybe:
        return 'A resposta não é clara. Reformule sua pergunta.';
      case PendulumAnswer.unclear:
        return 'A energia está confusa. Tente mais tarde.';
    }
  }

  String get emoji {
    switch (this) {
      case PendulumAnswer.yes:
        return '✅';
      case PendulumAnswer.no:
        return '❌';
      case PendulumAnswer.maybe:
        return '❓';
      case PendulumAnswer.unclear:
        return '🌀';
    }
  }
}

class PendulumConsultation {
  final String id;
  final String question;
  final PendulumAnswer answer;
  final DateTime date;

  const PendulumConsultation({
    required this.id,
    required this.question,
    required this.answer,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer.name,
      'date': date.toIso8601String(),
    };
  }

  factory PendulumConsultation.fromJson(Map<String, dynamic> json) {
    return PendulumConsultation(
      id: json['id'],
      question: json['question'],
      answer: PendulumAnswer.values.firstWhere(
        (e) => e.name == json['answer'],
      ),
      date: DateTime.parse(json['date']),
    );
  }
}
