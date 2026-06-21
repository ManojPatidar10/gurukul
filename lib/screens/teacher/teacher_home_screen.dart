import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../services/auth_state.dart';
import '../../services/supabase_service.dart';
import '../../theme/colors.dart';
import 'attendance_marking_screen.dart';
import '../shared/announcement_compose_screen.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  late Future<List<SchoolClass>> _classesFuture;

  @override
  void initState() {
    super.initState();
    _classesFuture = _loadClasses();
  }

  Future<List<SchoolClass>> _loadClasses() async {
    final teacherId = supabase.auth.currentUser!.id;
    final rows = await supabase
        .from('teacher_class_assignments')
        .select('classes(id, name, section)')
        .eq('teacher_id', teacherId);

    return rows
        .map((r) => SchoolClass.fromMap(r['classes'] as Map<String, dynamic>))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your classes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.campaign_outlined),
            tooltip: 'New announcement',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AnnouncementComposeScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => auth.signOut(),
          ),
        ],
      ),
      body: FutureBuilder<List<SchoolClass>>(
        future: _classesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final classes = snapshot.data ?? [];
          if (classes.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  "You're not assigned to any classes yet. Ask your director to add you in teacher_class_assignments.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: GurukulColors.inkLight),
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: classes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final c = classes[i];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(c.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Tap to mark attendance'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => AttendanceMarkingScreen(schoolClass: c)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
