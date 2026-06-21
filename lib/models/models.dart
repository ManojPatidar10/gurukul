enum UserRole { director, teacher, parent }

UserRole roleFromString(String value) {
  switch (value) {
    case 'director':
      return UserRole.director;
    case 'teacher':
      return UserRole.teacher;
    case 'parent':
    default:
      return UserRole.parent;
  }
}

class Profile {
  final String id;
  final String schoolId;
  final UserRole role;
  final String fullName;

  Profile({
    required this.id,
    required this.schoolId,
    required this.role,
    required this.fullName,
  });

  factory Profile.fromMap(Map<String, dynamic> map) => Profile(
        id: map['id'] as String,
        schoolId: map['school_id'] as String,
        role: roleFromString(map['role'] as String),
        fullName: map['full_name'] as String? ?? '',
      );
}

class SchoolClass {
  final String id;
  final String name;
  final String section;

  SchoolClass({required this.id, required this.name, required this.section});

  factory SchoolClass.fromMap(Map<String, dynamic> map) => SchoolClass(
        id: map['id'] as String,
        name: map['name'] as String,
        section: map['section'] as String,
      );

  String get label => '$name - $section';
}

class Student {
  final String id;
  final String classId;
  final String fullName;
  final String? rollNumber;

  Student({
    required this.id,
    required this.classId,
    required this.fullName,
    this.rollNumber,
  });

  factory Student.fromMap(Map<String, dynamic> map) => Student(
        id: map['id'] as String,
        classId: map['class_id'] as String,
        fullName: map['full_name'] as String,
        rollNumber: map['roll_number'] as String?,
      );
}

enum AttendanceStatus { present, absent, late, halfDay }

String attendanceStatusToDb(AttendanceStatus status) {
  switch (status) {
    case AttendanceStatus.present:
      return 'present';
    case AttendanceStatus.absent:
      return 'absent';
    case AttendanceStatus.late:
      return 'late';
    case AttendanceStatus.halfDay:
      return 'half_day';
  }
}

AttendanceStatus attendanceStatusFromDb(String value) {
  switch (value) {
    case 'present':
      return AttendanceStatus.present;
    case 'absent':
      return AttendanceStatus.absent;
    case 'late':
      return AttendanceStatus.late;
    case 'half_day':
      return AttendanceStatus.halfDay;
    default:
      return AttendanceStatus.present;
  }
}

class Announcement {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;

  Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
  });

  factory Announcement.fromMap(Map<String, dynamic> map) => Announcement(
        id: map['id'] as String,
        title: map['title'] as String,
        body: map['body'] as String,
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}

class FeePayment {
  final String id;
  final double amountPaid;
  final String status;
  final DateTime? paidAt;
  final String? receiptUrl;

  FeePayment({
    required this.id,
    required this.amountPaid,
    required this.status,
    this.paidAt,
    this.receiptUrl,
  });

  factory FeePayment.fromMap(Map<String, dynamic> map) => FeePayment(
        id: map['id'] as String,
        amountPaid: (map['amount_paid'] as num).toDouble(),
        status: map['status'] as String,
        paidAt: map['paid_at'] != null ? DateTime.parse(map['paid_at'] as String) : null,
        receiptUrl: map['receipt_url'] as String?,
      );
}
