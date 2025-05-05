import 'package:authentication/presentation/pages/login_page.dart';
import 'package:authentication/presentation/pages/profile_page.dart';
import 'package:authentication/presentation/pages/sign_up_page.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://iksuthhpqxdeqlitpgkh.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imlrc3V0aGhwcXhkZXFsaXRwZ2toIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzkzNDUyNzQsImV4cCI6MjA1NDkyMTI3NH0.ziIvd2TRRQurc0T69JesYYcs95ovC9s1bZPsXt2tUz4',
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final _router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        name: SIGNUP_PAGE_ROUTE,
        path: '/',
        builder: (context, state) {
          return SignUpPage();
        },
      ),
      GoRoute(
        name: LOGIN_PAGE_ROUTE,
        path: '/login',
        builder: (context, state) {
          return LoginPage();
        },
      ),
      GoRoute(
        name: PROFILE_PAGE_ROUTE,
        path: '/profile',
        builder: (context, state) {
          return ProfilePage();
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Apatu Apps(demo)',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}
