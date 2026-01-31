import 'package:app/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';
import 'package:app/profile/state.dart';
import 'package:app/chat/state.dart';
import 'package:app/matches/state.dart';
import 'package:app/register.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Handle Firebase initialization error
    print("Firebase initialization failed: $e");
    // Optionally, display an error message or fallback UI
  }

  WidgetsBinding.instance.addPostFrameCallback((_) {
    FirebaseAnalytics.instance.logAppOpen();
  });

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = createTextTheme(context, "Montserrat", "Inter");
    MaterialTheme theme = MaterialTheme(textTheme);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ChatState>(
          create: (_) => ChatState(),
        ),
        ChangeNotifierProvider<ProfileState>(
          create: (_) => ProfileState(),
        ),
        ChangeNotifierProvider<MatchState>(
          create: (_) => MatchState(),
        ),
      ],
      child: MaterialApp(
        title: 'Dating App',
        theme: theme.light(),
        home: AuthGate(),
      ),
    );
  }
}
