import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import 'supabase_service.dart';

class AuthState extends ChangeNotifier {
  Profile? profile;
  bool loading = true;
  String? error;

  AuthState() {
    _init();
  }

  Future<void> _init() async {
    supabase.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn || data.event == AuthChangeEvent.initialSession) {
        _loadProfile();
      } else if (data.event == AuthChangeEvent.signedOut) {
        profile = null;
        notifyListeners();
      }
    });
    await _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      loading = false;
      notifyListeners();
      return;
    }
    try {
      final row = await supabase.from('profiles').select().eq('id', user.id).single();
      profile = Profile.fromMap(row);
    } catch (e) {
      error = 'Could not load your profile. Contact your school admin.';
    }
    loading = false;
    notifyListeners();
  }

  Future<String?> signIn(String email, String password) async {
    try {
      await supabase.auth.signInWithPassword(email: email, password: password);
      return null;
    } on AuthException catch (e) {
      return e.message;
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}
