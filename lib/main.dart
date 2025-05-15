import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:readify/firebase_options.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:readify/services/notification_service.dart';
import 'package:readify/services/auth_service.dart';
import 'package:readify/blocs/auth/auth_bloc.dart';
import 'package:readify/blocs/theme/theme_bloc.dart';
import 'package:readify/blocs/language/language_bloc.dart';
import 'app_router.dart';
import 'blocs/book/book_bloc.dart';
import 'repositories/book_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  bool firebaseInitialized = false;
  String? initializationError;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseInitialized = true;
  } catch (e) {
    debugPrint('Failed to initialize Firebase: $e');
    initializationError = e.toString();
  }

  final prefs = await SharedPreferences.getInstance();
  final notificationService = NotificationService();

  final authService = AuthService(
    firebaseAuth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  );

  runApp(MyApp(
    prefs: prefs,
    notificationService: notificationService,
    authService: authService,
    firebaseInitialized: firebaseInitialized,
    initializationError: initializationError,
  ));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final NotificationService notificationService;
  final AuthService authService;
  final bool firebaseInitialized;
  final String? initializationError;
  
  const MyApp({
    super.key,
    required this.prefs,
    required this.notificationService,
    required this.authService,
    required this.firebaseInitialized,
    this.initializationError,
  });

  @override
  Widget build(BuildContext context) {
    if (!firebaseInitialized) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to initialize Firebase',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (initializationError != null) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      initializationError!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Попытка перезапуска приложения
                    main();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ThemeBloc(prefs),
        ),
        BlocProvider(
          create: (context) => LanguageBloc(prefs),
        ),
        BlocProvider(
          create: (context) => BookBloc(
            bookRepository: BookRepository(),
            auth: FirebaseAuth.instance,
          ),
        ),
        BlocProvider(
          create: (context) => AuthBloc(authService: authService),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<LanguageBloc, LanguageState>(
            builder: (context, languageState) {
              return MaterialApp.router(
                title: 'Readify',
                routerConfig: AppRouter.router,
                theme: ThemeData.light(useMaterial3: true),
                darkTheme: ThemeData.dark(useMaterial3: true),
                themeMode: themeState.themeMode,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('en'),
                  Locale('kk'),
                  Locale('ru'),
                ],
                locale: languageState.locale,
                builder: (context, child) {
                  return MediaQuery(
                    data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
                    child: child!,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}