import 'package:authentication/main.dart';
import 'package:authentication/presentation/pages/sign_up_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? userPhoto;
  String? userEmail;
  String? username;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    if (user.userMetadata != null && user.userMetadata!['avatar_url'] != null) {
      setState(() {
        userPhoto = user.userMetadata!['avatar_url'];
        username = user.userMetadata!['full_name'];
        userEmail = user.email;
      });
    } else {
      final response = await supabase
          .from('tbl_profiles')
          .select('user_photo, user_email, username')
          .eq('user_uuid', user.id)
          .single();

      setState(() {
        userPhoto = response['user_photo'];
        userEmail = response['user_email'];
        username = response['username'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Profile',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await supabase.auth.signOut();
              if (context.mounted) {
                context.go('/');
              }
            },
            child: Text(
              'Sign out',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (userPhoto != null)
              ClipOval(
                child: Image.network(
                  userPhoto!,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              )
            else
              const Icon(Icons.person, size: 100),
            const SizedBox(height: 16),
            Text(
              username ?? 'Username not found',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              userEmail ?? 'Email not found',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
