import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

late Box boxProfiles;
final supabase = Supabase.instance.client;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? imageProfileURL = supabase.auth.currentUser != null
      ? supabase.storage
          .from('avatars')
          .getPublicUrl('profiles/${supabase.auth.currentUser!.id}.jpg')
      : null;
  String? username = boxProfiles.get('username', defaultValue: 'Username');
  String? email = boxProfiles.get('email', defaultValue: 'email@example.com');
  File? imageFile;
  final ImagePicker picker = ImagePicker();

  Future<void> _editProfile() async {
    TextEditingController usernameController =
        TextEditingController(text: username);
    TextEditingController emailController = TextEditingController(text: email);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  final pickedFile = await picker.pickImage(
                      source: await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Choose Image Source'),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context, ImageSource.camera),
                          child: Text('Camera'),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context, ImageSource.gallery),
                          child: Text('Gallery'),
                        ),
                      ],
                    ),
                  ));
                  if (pickedFile != null) {
                    setState(() {
                      imageFile = File(pickedFile.path);
                    });
                    // Simpan ke Supabase
                    final user = supabase.auth.currentUser;
                    if (user != null) {
                      final imagePath = 'profiles/${user.id}.jpg';
                      await supabase.storage.from('avatars').upload(
                          imagePath, File(pickedFile.path),
                          fileOptions: const FileOptions(upsert: true));
                      final publicURL = supabase.storage
                          .from('avatars')
                          .getPublicUrl(imagePath);
                      await supabase
                          .from('profiles')
                          .upsert({'id': user.id, 'avatar_url': publicURL});
                      setState(() {
                        imageProfileURL = publicURL;
                      });
                    }
                  }
                },
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: imageProfileURL != null
                      ? NetworkImage(imageProfileURL!)
                      : (imageFile != null ? FileImage(imageFile!) : null),
                  child: imageProfileURL == null && imageFile == null
                      ? const Icon(Icons.camera_alt, size: 50)
                      : null,
                ),
              ),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                String newUsername = usernameController.text.trim();
                String newEmail = emailController.text.trim();

                setState(() {
                  username = newUsername;
                  email = newEmail;
                });

                // Simpan ke Hive
                boxProfiles.put('key_${newUsername.toString()}',
                    {'email': newEmail, 'username': newUsername});

                // Simpan ke Supabase
                final user = supabase.auth.currentUser;
                if (user != null) {
                  await supabase.from('tbl_profiles').upsert({
                    'id': user.id,
                    'username': newUsername,
                    'email': newEmail,
                  });
                }

                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, size: 18),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage:
                imageProfileURL != null ? NetworkImage(imageProfileURL!) : null,
            child: imageProfileURL == null
                ? const Icon(Icons.person, size: 50)
                : null,
          ),
          Text(username!,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          Text(email!, style: TextStyle(fontSize: 16)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _editProfile,
        child: Icon(Icons.edit),
      ),
    );
  }
}
