import 'package:flutter/material.dart';

class ImportAskDialog extends StatelessWidget {
  final VoidCallback onImportToExisting;
  final VoidCallback onCreateNew;

  const ImportAskDialog({
    super.key,
    required this.onImportToExisting,
    required this.onCreateNew,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Import Playlist"),
      content: const Text(
          "Do you want to import tracks to an existing playlist or create a new one?"),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onImportToExisting();
          },
          child: const Text("Import to Existing"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onCreateNew();
          },
          child: const Text("Create New"),
        ),
      ],
    );
  }
}
