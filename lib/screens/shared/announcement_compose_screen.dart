import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';

class AnnouncementComposeScreen extends StatefulWidget {
  const AnnouncementComposeScreen({super.key});

  @override
  State<AnnouncementComposeScreen> createState() => _AnnouncementComposeScreenState();
}

class _AnnouncementComposeScreenState extends State<AnnouncementComposeScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _sending = false;

  Future<void> _send() async {
    if (_titleController.text.trim().isEmpty || _bodyController.text.trim().isEmpty) return;
    setState(() => _sending = true);

    final userId = supabase.auth.currentUser!.id;
    final profile = await supabase.from('profiles').select('school_id').eq('id', userId).single();

    try {
      await supabase.from('announcements').insert({
        'school_id': profile['school_id'],
        'class_id': null,
        'title': _titleController.text.trim(),
        'body': _bodyController.text.trim(),
        'created_by': userId,
      });
      if (!mounted) return;
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New announcement')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bodyController,
              decoration: const InputDecoration(labelText: 'Message'),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _sending ? null : _send,
                child: Text(_sending ? 'Sending…' : 'Send'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
