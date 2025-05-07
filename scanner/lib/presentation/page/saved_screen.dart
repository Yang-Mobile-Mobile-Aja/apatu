import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SaveScreenState();
}

class _SaveScreenState extends State<SavedScreen> {
  Future<List<Map<String, dynamic>>> fetchSavedImages() async {
    try {
      final user = Supabase.instance.client.auth.currentUser!;
      if (user == null) throw 'User not logged in';

      final response = await Supabase.instance.client
          .from('tbl_picture')
          .select('id, picture, text_recognition, tbl_picture(*)')
          .eq('user_uuid', user.id);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error saved Image: $e');
      return [];
    }
  }

  Future<void> deleteAllBookmarks(BuildContext context) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw 'User not logged in';

      await Supabase.instance.client
          .from('tbl_picture')
          .delete()
          .eq('id_user', user.id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All bookmarks deleted successfully')),
      );
      (context as Element).markNeedsBuild();
    } catch (e) {
      debugPrint('Error deleting bookmarks: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete bookmarks')),
      );
    }
  }

  Future<void> deleteSavedImage(int savedImageId, BuildContext context) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw 'User not logged In';

      await Supabase.instance.client
          .from('tbl_picture')
          .delete()
          .eq('user_uuid', user)
          .eq('picture', savedImageId)
          .eq('text_recognition', savedImageId);

      setState(() {});
    } catch (e) {
      debugPrint('Error deleting Image :$e');
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed To Delete Image')));
    }
  }

  Future<void> showDeleteConfirmationDialog(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete All Saved Images'),
          content:
              const Text('Are you sure you want to delete all Saved Images?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
    if (shouldDelete == true) {
      await deleteAllBookmarks(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Image'),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await showDeleteConfirmationDialog(context);
            },
            icon: Icon(Icons.delete_forever),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchSavedImages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Data Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No Saved Images Found'),
            );
          }

          final images = snapshot.data!;
          return ListView.builder(
            itemCount: images.length,
            itemBuilder: (context, index) {
              final savedImages = images[index];
              final picture = savedImages['tbl_picture'];
              final saved = savedImages['id'];

              return Slidable(
                key: ValueKey(saved),
                endActionPane:
                    ActionPane(motion: const DrawerMotion(), children: [
                  SlidableAction(
                    onPressed: (context) async {
                      await deleteSavedImage(saved, context);
                    },
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Delete',
                  ),
                ]),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      picture['id'] != null
                          ? Image.network(
                              picture['picture'],
                              width: double.infinity,
                              height: 30,
                            )
                          : Icon(Icons.picture_in_picture),
                      const SizedBox(
                        height: 12,
                      ),
                      Text(
                        picture['text_recognition'],
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
