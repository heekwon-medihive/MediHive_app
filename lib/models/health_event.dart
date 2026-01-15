import 'package:flutter/material.dart';

enum EventType {
  hospital, // 병원 진료
  vital, // 생체 수치 기록
  symptom, // 증상 기록
  medication, // 복약 기록
}

class HealthEvent {
  final DateTime date;
  final String title;
  final EventType type;
  final Map<String, dynamic> data;
  final TimeOfDay? time;

  HealthEvent({
    required this.date,
    required this.title,
    required this.type,
    required this.data,
    this.time,
  });

  // 이벤트 타입별 아이콘
  IconData get icon {
    switch (type) {
      case EventType.hospital:
        return Icons.local_hospital;
      case EventType.vital:
        return Icons.favorite;
      case EventType.symptom:
        return Icons.healing;
      case EventType.medication:
        return Icons.medication;
    }
  }

  // 이벤트 타입별 색상
  Color get color {
    switch (type) {
      case EventType.hospital:
        return const Color(0xFF2196F3); // 파란색
      case EventType.vital:
        return const Color(0xFF4CAF50); // 초록색
      case EventType.symptom:
        return const Color(0xFFF44336); // 빨간색
      case EventType.medication:
        return const Color(0xFF9C27B0); // 보라색
    }
  }

  // 시간 포맷팅
  String? get formattedTime {
    if (time == null) return null;
    return '${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}';
  }
}

