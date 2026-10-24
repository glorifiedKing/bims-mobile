class ReferencedClause {
  final String document;
  final String clauseNumber;
  final String clauseTitle;

  ReferencedClause({
    required this.document,
    required this.clauseNumber,
    required this.clauseTitle,
  });

  factory ReferencedClause.fromJson(Map<String, dynamic> json) {
    return ReferencedClause(
      document: json['document'] ?? 'Uganda National Building Code',
      clauseNumber: json['clause_number'] ?? 'Clause Ref',
      clauseTitle: json['clause_title'] ?? '',
    );
  }
}

enum CopilotPersonaType {
  engineerKigozi,
  architectNamubiru,
  inspectorOkello,
}

class CopilotPersona {
  final CopilotPersonaType type;
  final String id;
  final String name;
  final String title;
  final String description;
  final String emoji;

  const CopilotPersona({
    required this.type,
    required this.id,
    required this.name,
    required this.title,
    required this.description,
    required this.emoji,
  });

  static const List<CopilotPersona> personas = [
    CopilotPersona(
      type: CopilotPersonaType.inspectorOkello,
      id: 'inspector_okello',
      name: 'Inspector Okello',
      title: 'Chief Building Control Officer',
      description: 'Strict statutory interpretations & NBRB compliance enforcement under Uganda Building Control Regulations.',
      emoji: '👮‍♂️',
    ),
    CopilotPersona(
      type: CopilotPersonaType.engineerKigozi,
      id: 'engineer_kigozi',
      name: 'Eng. Kigozi',
      title: 'Senior Structural & Site Engineer',
      description: 'Practical, safety-first guidance on structural schedules, concrete grades, and on-site engineering.',
      emoji: '👷‍♂️',
    ),
    CopilotPersona(
      type: CopilotPersonaType.architectNamubiru,
      id: 'architect_namubiru',
      name: 'Arch. Namubiru',
      title: 'Chartered Architect',
      description: 'Spatial ergonomics, natural ventilation, lighting ratios & PWD accessibility standards.',
      emoji: '👩‍💼',
    ),
  ];

  static CopilotPersona fromId(String id) {
    return personas.firstWhere(
      (p) => p.id == id,
      orElse: () => personas.first,
    );
  }
}

class CopilotMessage {
  final String id;
  final String text;
  final bool isUser;
  final CopilotPersona? persona;
  final List<ReferencedClause> referencedClauses;
  final DateTime timestamp;

  CopilotMessage({
    required this.id,
    required this.text,
    required this.isUser,
    this.persona,
    this.referencedClauses = const [],
    required this.timestamp,
  });
}
