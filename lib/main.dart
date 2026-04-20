import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboards/patient_dashboard.dart';
import 'screens/dashboards/emt_dashboard.dart';
import 'screens/dashboards/admin_dashboard.dart';
import 'services/user_service.dart';
import 'theme/theme_provider.dart';
import 'theme/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    return MaterialApp(
      title: 'STJ MediLink\u207A',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      locale: localeProvider.locale,
      supportedLocales: const [Locale('en'), Locale('si'), Locale('ta')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D3A8C),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D3A8C),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
      restorationScopeId: null,
    );
  }
}

// ── Auth gate ─────────────────────────────────────────────────────────────────
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginScreen();
        }
        return FutureBuilder(
          future: UserService().getUser(snapshot.data!.uid),
          builder: (context, userSnap) {
            if (userSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            final user = userSnap.data;
            if (user == null) return const LoginScreen();
            switch (user.role) {
              case 'admin':
                return const AdminDashboard();
              case 'emt':
                return const EmtDashboard();
              case 'patient':
              default:
                return const PatientDashboard();
            }
          },
        );
      },
    );
  }
}
