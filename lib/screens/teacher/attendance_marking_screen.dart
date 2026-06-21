import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/supabase_service.dart';
import '../../theme/colors.dart';
import '../../widgets/stamp_badge.dart';

class AttendanceMarkingScreen extends StatefulWidget {
  final SchoolClass schoolClass;
  const AttendanceMarkingScreen({super.key, required this.schoolClass});

  @override
  State<AttendanceMarkingScreen> createState() => _AttendanceMarkingScreenState();
}

class _AttendanceMarkingScreenState extends State<AttendanceMarkingScreen> {
  List<Student> _students = [];
  final Map<String, AttendanceStatus> _statuses = {};
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final rows = await supabase
        .from('students')
        .select()
        .eq('class_id', widget.schoolClass.id)
        .order('roll_number');

    setState(() {
      _students = rows.map((r) => Student.fromMap(r)).toList();
      // Fast path: default everyone to present, teacher only taps exceptions.
      for (final s in _students) {
        _statuses[s.id] = AttendanceStatus.present;
      }
      _loading = false;
    });
  }

  void _cycleStatus(String studentId) {
    const order = [
      AttendanceStatus.present,
      AttendanceStatus.absent,
      AttendanceStatus.late,
      AttendanceStatus.halfDay,
    ];
    setState(() {
      final current = _statuses[studentId] ?? AttendanceStatus.present;
      final next = order[(order.indexOf(current) + 1) % order.length];
      _statuses[studentId] = next;
    });
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);

    final today = DateTime.now().toIso8601String().substring(0, 10);
    final teacherId = supabase.auth.currentUser!.id;

    final rows = _students
        .map((s) => {
              'student_id': s.id,
              'class_id': widget.schoolClass.id,
              'date': today,
              'status': attendanceStatusToDb(_statuses[s.id] ?? AttendanceStatus.present),
              'marked_by': teacherId,
            })
        .toList();

    try {
      // upsert on (student_id, date) — re-marking the same day overwrites cleanly
      await supabase.from('attendance_records').upsert(rows, onConflict: 'student_id,date');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Attendance saved for ${widget.schoolClass.label}')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save attendance. Check your connection and try again.')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.schoolClass.label)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: GurukulColors.sageLight,
                  child: const Text(
                    "Everyone is marked Present by default. Tap a student to cycle through Present → Absent → Late → Half day.",
                    style: TextStyle(fontSize: 12, color: GurukulColors.ink),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _students.length,
                    itemBuilder: (context, i) {
                      final s = _students[i];
                      final status = _statuses[s.id] ?? AttendanceStatus.present;
                      return ListTile(
                        title: Text(s.fullName),
                        subtitle: s.rollNumber != null ? Text('Roll no. ${s.rollNumber}') : null,
                        trailing: GestureDetector(
                          onTap: () => _cycleStatus(s.id),
                          child: StampBadge.attendance(status),
                        ),
                        onTap: () => _cycleStatus(s.id),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      child: Text(_submitting ? 'Saving…' : 'Submit attendance'),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
