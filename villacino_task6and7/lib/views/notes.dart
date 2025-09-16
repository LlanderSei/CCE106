import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:villacino_task6and7/controllers/NoteController.dart';
import 'package:intl/intl.dart'; // For date formatting

class Notes extends StatefulWidget {
  const Notes({super.key, required this.noteController});
  final NoteController noteController;

  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  void _showNoteDialog({String? id, String? title, String? desc}) {
    final titleController = TextEditingController(text: title ?? "");
    final descController = TextEditingController(text: desc ?? "");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(id == null ? 'Add Note' : 'Edit Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text(id == null ? 'Add' : 'Update'),
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  descController.text.isNotEmpty) {
                if (id == null) {
                  widget.noteController.addNote(
                    titleController.text,
                    descController.text,
                  );
                } else {
                  widget.noteController.updateNote(
                    id,
                    titleController.text,
                    descController.text,
                  );
                }
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Title and Description cannot be empty'),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // START MODIFIED SECTION
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    // END MODIFIED SECTION
  }

  @override
  void dispose() {
    // START MODIFIED SECTION
    _searchController.dispose();
    // END MODIFIED SECTION
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes App'),
        backgroundColor: const Color.fromARGB(255, 250, 196, 255),
        // START MODIFIED SECTION
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search notes...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
              ),
            ),
          ),
        ),
        // END MODIFIED SECTION
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteDialog(),
        backgroundColor: const Color.fromARGB(255, 223, 64, 255),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: widget.noteController.notes
            .orderBy('TimestampAdded', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notes = snapshot.data!.docs;
          if (notes.isEmpty) {
            return const Center(child: Text('No notes available'));
          }

          // START MODIFIED SECTION
          // Filter notes based on search query
          final filteredNotes = notes.where((doc) {
            final note = doc.data() as Map<String, dynamic>;
            final title = (note['Title'] as String).toLowerCase();
            final desc = (note['Description'] as String).toLowerCase();
            return title.contains(_searchQuery) || desc.contains(_searchQuery);
          }).toList();

          if (filteredNotes.isEmpty) {
            return const Center(child: Text('No matching notes found'));
          }

          return ListView(
            padding: const EdgeInsets.all(10),
            children: filteredNotes.map((doc) {
              final note = doc.data() as Map<String, dynamic>;
              final id = doc.id;
              final title = note['Title'] as String;
              final desc = note['Description'] as String;

              final timestampAdded = note['TimestampAdded'] as Timestamp?;
              final addedDate = timestampAdded != null
                  ? DateFormat('MMM dd, yyyy h:mm a')
                      .format(timestampAdded.toDate())
                  : 'Unknown';

              // Handle TimestampUpdated (may not exist)
              String updatedDate = 'Not updated';
              try {
                final timestampUpdated = note['TimestampUpdated'] as Timestamp?;
                if (timestampUpdated != null) {
                  updatedDate = DateFormat('MMM dd, yyyy h:mm a')
                      .format(timestampUpdated.toDate());
                }
              } catch (e) {
                if (e.toString().contains(
                      'does not exist within the DocumentSnapshotPlatform',
                    )) {
                  updatedDate = 'Not updated';
                } else {
                  updatedDate = 'Error retrieving update time';
                }
              }

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3),
                ),
                margin: const EdgeInsets.symmetric(vertical: 3),
                child: ListTile(
                  title: Text(title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(desc),
                      const SizedBox(height: 4),
                      Text(
                        'Added: $addedDate',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        'Updated: $updatedDate',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () =>
                            _showNoteDialog(id: id, title: title, desc: desc),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          widget.noteController.deleteNote(id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Note deleted')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
          // END MODIFIED SECTION
        },
      ),
    );
  }
}