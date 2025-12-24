class WeightLog {
  final String? id;
  final double weight;
  final DateTime date;
  final String? notes;

  WeightLog({
    this.id,
    required this.weight,
    required this.date,
    this.notes,
  });

  factory WeightLog.fromJson(Map<String, dynamic> json) {
    return WeightLog(
      id: json['_id'],
      weight: (json['weight_kg'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weight_kg': weight,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }
}

class SymptomLog {
  final String? id;
  final DateTime date;
  final List<String> symptoms;
  final String? mood;
  final String? notes;

  SymptomLog({
    this.id,
    required this.date,
    required this.symptoms,
    this.mood,
    this.notes,
  });

  factory SymptomLog.fromJson(Map<String, dynamic> json) {
    return SymptomLog(
      id: json['_id'],
      date: DateTime.parse(json['date']),
      symptoms: List<String>.from(json['symptoms'] ?? []),
      mood: json['mood'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'symptoms': symptoms,
      'mood': mood,
      'notes': notes,
    };
  }
}

class KickCountLog {
  final String? id;
  final DateTime date;
  final DateTime startTime;
  final int kickCount;
  final int? durationMinutes;
  final int? durationSeconds; // Store actual seconds for accurate calculations
  final String? notes;
  final int? averageIntensity; // 1-5 scale
  final List<String> contextTags; // Tags like 'After Meal', 'Cold Drink', etc.
  final String? diaryNotes; // Personal notes about the session

  KickCountLog({
    this.id,
    required this.date,
    required this.startTime,
    required this.kickCount,
    this.durationMinutes,
    this.durationSeconds,
    this.notes,
    this.averageIntensity,
    this.contextTags = const [],
    this.diaryNotes,
  });

  factory KickCountLog.fromJson(Map<String, dynamic> json) {
    return KickCountLog(
      id: json['_id'],
      date: DateTime.parse(json['date']),
      startTime: DateTime.parse(json['start_time']),
      kickCount: json['kick_count'],
      durationMinutes: json['duration_minutes'],
      durationSeconds: json['duration_seconds'],
      notes: json['notes'],
      averageIntensity: json['average_intensity'],
      contextTags: List<String>.from(json['context_tags'] ?? []),
      diaryNotes: json['diary_notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'start_time': startTime.toIso8601String(),
      'kick_count': kickCount,
      'duration_minutes': durationMinutes,
      'duration_seconds': durationSeconds,
      'notes': notes,
      'average_intensity': averageIntensity,
      'context_tags': contextTags,
      'diary_notes': diaryNotes,
    };
  }
}

class CheckupLog {
  final String? id;
  final DateTime date;
  final int? weekNumber;
  final String? doctorName;
  final String? hospitalName;
  final double? weight;
  final String? bloodPressure;
  final int? babyHeartRate;
  final String? notes;
  final DateTime? nextCheckupDate;

  CheckupLog({
    this.id,
    required this.date,
    this.weekNumber,
    this.doctorName,
    this.hospitalName,
    this.weight,
    this.bloodPressure,
    this.babyHeartRate,
    this.notes,
    this.nextCheckupDate,
  });

  factory CheckupLog.fromJson(Map<String, dynamic> json) {
    return CheckupLog(
      id: json['_id'],
      date: DateTime.parse(json['date']),
      weekNumber: json['week_number'],
      doctorName: json['doctor_name'],
      hospitalName: json['hospital_name'],
      weight: json['weight_kg'] != null
          ? (json['weight_kg'] as num).toDouble()
          : null,
      bloodPressure: json['blood_pressure'],
      babyHeartRate: json['baby_heart_rate'],
      notes: json['notes'],
      nextCheckupDate: json['next_checkup_date'] != null
          ? DateTime.parse(json['next_checkup_date'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'week_number': weekNumber,
      'doctor_name': doctorName,
      'hospital_name': hospitalName,
      'weight_kg': weight,
      'blood_pressure': bloodPressure,
      'baby_heart_rate': babyHeartRate,
      'notes': notes,
      'next_checkup_date': nextCheckupDate?.toIso8601String(),
    };
  }
}
