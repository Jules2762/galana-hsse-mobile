class ReportModel {
  final dynamic id;
  final String reference;
  final String title;
  final String category;
  final String site;
  final String inspector;
  final dynamic rawInspector;
  final String date;
  final int conformity;
  final String status;
  final String executiveSummary;
  final List<ReportSectionModel> sections;
  final List<ReportNonConformityModel> nonConformities;
  final List<ReportActionModel> actions;

  const ReportModel({
    required this.id,
    required this.reference,
    required this.title,
    required this.category,
    required this.site,
    required this.inspector,
    this.rawInspector,
    required this.date,
    required this.conformity,
    required this.status,
    required this.executiveSummary,
    this.sections = const [],
    this.nonConformities = const [],
    this.actions = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference': reference,
      'title': title,
      'category': category,
      'site': site,
      'inspector': inspector,
      'rawInspector': rawInspector,
      'date': date,
      'conformity': conformity,
      'status': status,
      'executiveSummary': executiveSummary,
      'sections': sections.map((s) => s.toJson()).toList(),
      'nonConformities': nonConformities.map((n) => n.toJson()).toList(),
      'actions': actions.map((a) => a.toJson()).toList(),
    };
  }

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    String inspectorStr = 'Inspecteur HSSE';
    final rawInsp = json['rawInspector'] ?? json['inspector'];
    if (rawInsp is String && rawInsp.isNotEmpty) {
      inspectorStr = rawInsp;
    } else if (rawInsp is Map) {
      final fn = rawInsp['first_name'] ?? '';
      final ln = rawInsp['last_name'] ?? '';
      final combined = "$fn $ln".trim();
      inspectorStr = combined.isNotEmpty ? combined : (rawInsp['name']?.toString() ?? 'Inspecteur HSSE');
    }

    return ReportModel(
      id: json['id'] ?? '1',
      reference: json['reference']?.toString() ?? 'RPT-HSSE',
      title: json['title']?.toString() ?? 'Rapport d\'inspection',
      category: json['category']?.toString() ?? 'Sécurité',
      site: json['site']?.toString() ?? 'Site Galana',
      inspector: inspectorStr,
      rawInspector: rawInsp,
      date: json['date']?.toString() ?? 'Aujourd\'hui',
      conformity: (json['conformity'] is num) ? (json['conformity'] as num).toInt() : 75,
      status: json['status']?.toString() ?? 'Conforme',
      executiveSummary: json['executiveSummary']?.toString() ??
          'Évaluation de conformité des installations et des équipements HSSE.',
      sections: (json['sections'] as List<dynamic>?)
              ?.map((s) => ReportSectionModel.fromJson(Map<String, dynamic>.from(s)))
              .toList() ??
          [],
      nonConformities: (json['nonConformities'] as List<dynamic>?)
              ?.map((n) => ReportNonConformityModel.fromJson(Map<String, dynamic>.from(n)))
              .toList() ??
          [],
      actions: (json['actions'] as List<dynamic>?)
              ?.map((a) => ReportActionModel.fromJson(Map<String, dynamic>.from(a)))
              .toList() ??
          [],
    );
  }
}

class ReportSectionModel {
  final String title;
  final int score;
  final int totalQuestions;
  final int compliantQuestions;

  const ReportSectionModel({
    required this.title,
    required this.score,
    this.totalQuestions = 0,
    this.compliantQuestions = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'score': score,
      'totalQuestions': totalQuestions,
      'compliantQuestions': compliantQuestions,
    };
  }

  factory ReportSectionModel.fromJson(Map<String, dynamic> json) {
    return ReportSectionModel(
      title: json['title']?.toString() ?? '',
      score: (json['score'] is num) ? (json['score'] as num).toInt() : 100,
      totalQuestions: (json['totalQuestions'] is num) ? (json['totalQuestions'] as num).toInt() : 0,
      compliantQuestions: (json['compliantQuestions'] is num) ? (json['compliantQuestions'] as num).toInt() : 0,
    );
  }
}

class ReportNonConformityModel {
  final String title;
  final String priority; // 'Critique', 'Moyenne', 'Faible'
  final String section;
  final String? observation;

  const ReportNonConformityModel({
    required this.title,
    required this.priority,
    this.section = 'Général',
    this.observation,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'priority': priority,
      'section': section,
      'observation': observation,
    };
  }

  factory ReportNonConformityModel.fromJson(Map<String, dynamic> json) {
    return ReportNonConformityModel(
      title: json['title']?.toString() ?? '',
      priority: json['priority']?.toString() ?? 'Moyenne',
      section: json['section']?.toString() ?? 'Général',
      observation: json['observation']?.toString(),
    );
  }
}

class ReportActionModel {
  final String title;
  final String assignee;
  final String dueDate;
  final String status;

  const ReportActionModel({
    required this.title,
    required this.assignee,
    required this.dueDate,
    this.status = 'En cours',
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'assignee': assignee,
      'dueDate': dueDate,
      'status': status,
    };
  }

  factory ReportActionModel.fromJson(Map<String, dynamic> json) {
    return ReportActionModel(
      title: json['title']?.toString() ?? '',
      assignee: json['assignee']?.toString() ?? 'Responsable',
      dueDate: json['dueDate']?.toString() ?? '',
      status: json['status']?.toString() ?? 'En cours',
    );
  }
}
