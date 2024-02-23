import 'package:flutter/material.dart';

class PlaylistCreationDialog extends StatefulWidget {
  final Function(String playlistName, bool isPublic, bool isCollaborative,
      String description) onCreate;

  const PlaylistCreationDialog({super.key, required this.onCreate});

  @override
  State<PlaylistCreationDialog> createState() => _PlaylistCreationDialogState();
}

class _PlaylistCreationDialogState extends State<PlaylistCreationDialog> {
  final TextEditingController playlistNameController = TextEditingController();
  bool isPublic = true;
  bool isCollaborative = false;
  final TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Playlist'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            TextField(
              controller: playlistNameController,
              decoration: const InputDecoration(hintText: "Playlist Name"),
            ),
            SwitchListTile(
              title: const Text('Public'),
              value: isPublic,
              onChanged: (bool value) {
                setState(() {
                  isPublic = value;
                  if (!isPublic && isCollaborative) {
                    isCollaborative = false;
                  }
                });
              },
            ),
            SwitchListTile(
              title: const Text('Collaborative'),
              value: isCollaborative,
              onChanged: isPublic
                  ? (bool value) {
                      setState(() {
                        isCollaborative = value;
                      });
                    }
                  : null,
            ),
            TextField(
              controller: descriptionController,
              decoration:
                  const InputDecoration(hintText: "Description (Optional)"),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text('Create'),
          onPressed: () {
            widget.onCreate(
              playlistNameController.text,
              isPublic,
              isCollaborative,
              descriptionController.text,
            );

            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
