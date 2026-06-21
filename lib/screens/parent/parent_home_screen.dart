import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../services/auth_state.dart';
import '../../services/supabase_service.dart';
import '../../theme/colors.dart';
import '../../widgets/stamp_badge.dart';

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  List<Student> _children = [];
  Student? _selectedChild;
  int _tabIndex = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    final parentId = supabase.auth.currentUser!.id;
    final rows = await supabase
        .from('parent_student_links')
        .select('students(id, class_id, full_name, roll_number)')
        .eq('parent_id', parentId);

    final children = rows.map((r) => Student.fromMap(r['students'] as Map<String, dynamic>)).toList();

    setState(() {
      _children = children;
      _selectedChild = children.isNotEmpty ? children.first : null;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthState>();

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_selectedChild == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Gurukul'), actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => auth.signOut()),
        ]),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              "No child linked to your account yet. Ask your school to link your account in parent_student_links.",
              textAlign: TextAlign.center,
              style: TextStyle(color: GurukulColors.inkLight),
            ),
          ),
        ),
      );
    }

    final pages = [
      _AttendanceTab(student: _selectedChild!),
      _FeesTab(student: _selectedChild!),
      const _AnnouncementsTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: _children.length > 1
            ? DropdownButton<Student>(
                value: _selectedChild,
                underline: const SizedBox(),
                items: _children
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.fullName)))
                    .toList(),
                onChanged: (c) => setState(() => _selectedChild = c),
              )
            : Text(_selectedChild!.fullName),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => auth.signOut()),
        ],
      ),
      body: pages[_tabIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.check_circle_outline), label: 'Attendance'),
          NavigationDestination(icon: Icon(Icons.payments_outlined), label: 'Fees'),
          NavigationDestination(icon: Icon(Icons.campaign_outlined), label: 'Updates'),
        ],
      ),
    );
  }
}

class _AttendanceTab extends StatelessWidget {
  final Student student;
  const _AttendanceTab({required this.student});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().toIso8601String().substring(0, 10);

    return FutureBuilder(
      future: supabase
          .from('attendance_records')
          .select()
          .eq('student_id', student.id)
          .eq('date', today)
          .maybeSingle(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final record = snapshot.data;
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Today's status", style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                if (record != null)
                  StampBadge.attendance(attendanceStatusFromDb(record['status'] as String))
                else
                  const Text('Not marked yet today', style: TextStyle(color: GurukulColors.inkLight)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FeesTab extends StatelessWidget {
  final Student student;
  const _FeesTab({required this.student});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: supabase
          .from('fee_payments')
          .select()
          .eq('student_id', student.id)
          .order('created_at', ascending: false),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final payments = (snapshot.data ?? []).map((r) => FeePayment.fromMap(r)).toList();
        if (payments.isEmpty) {
          return const Center(child: Text('No fee records yet', style: TextStyle(color: GurukulColors.inkLight)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: payments.length,
          itemBuilder: (context, i) {
            final p = payments[i];
            return Card(
              child: ListTile(
                title: Text('₹${p.amountPaid.toStringAsFixed(0)}'),
                trailing: StampBadge(
                  label: p.status,
                  color: p.status == 'success' ? GurukulColors.sage : GurukulColors.brick,
                  background: p.status == 'success' ? GurukulColors.sageLight : GurukulColors.brickLight,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _AnnouncementsTab extends StatelessWidget {
  const _AnnouncementsTab();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: supabase.from('announcements').select().order('created_at', ascending: false),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final announcements = (snapshot.data ?? []).map((r) => Announcement.fromMap(r)).toList();
        if (announcements.isEmpty) {
          return const Center(child: Text('No updates yet', style: TextStyle(color: GurukulColors.inkLight)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: announcements.length,
          itemBuilder: (context, i) {
            final a = announcements[i];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(a.body, style: const TextStyle(color: GurukulColors.inkLight)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
