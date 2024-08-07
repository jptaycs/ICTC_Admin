// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registration_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegistrationHistory _$RegistrationHistoryFromJson(Map<String, dynamic> json) =>
    RegistrationHistory(
      id: (json['id'] as num?)?.toInt(),
      action: json['action'] as String?,
      occurredAt: json['occurred_at'] == null
          ? null
          : DateTime.parse(json['occurred_at'] as String),
      userEmail: json['user_email'] as String,
      studentId: (json['student_id'] as num).toInt(),
      courseId: (json['course_id'] as num).toInt(),
      courseName: json['course_name'] as String,
      studentName: json['student_name'] as String,
    );

Map<String, dynamic> _$RegistrationHistoryToJson(RegistrationHistory instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('action', instance.action);
  writeNotNull('occurred_at', instance.occurredAt?.toIso8601String());
  val['user_email'] = instance.userEmail;
  val['student_id'] = instance.studentId;
  val['course_id'] = instance.courseId;
  val['course_name'] = instance.courseName;
  val['student_name'] = instance.studentName;
  return val;
}
