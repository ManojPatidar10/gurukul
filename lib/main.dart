import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/supabase_service.dart';
import 'services/auth_state.dart';
import 'screens/home_router.dart';
import 'theme/colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSupabase();
  // Firebase push notifications: uncomment once you've run
  // `flutterfire configure` to generate firebase_options.dart (see mobile/README.md)
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const GurukulApp());
}

class GurukulApp extends StatelessWidget {
  const GurukulApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthState(),
      child: MaterialApp(
        title: 'Gurukul',
        debugShowCheckedModeBanner: false,
        theme: buildGurukulTheme(),
        home: const HomeRouter(),
      ),
    );
  }
}
