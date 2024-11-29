import 'package:flutter/material.dart';
import 'note.dart';
import 'note_database.dart';

class NoteDetailsView extends StatefulWidget {
  const NoteDetailsView({super.key, this.noteId});
  final int? noteId;

  @override
  State<NoteDetailsView> createState() => _NoteDetailsViewState();
}

class _NoteDetailsViewState extends State<NoteDetailsView> {
  NoteDatabase noteDatabase = NoteDatabase.instance;

  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  late NoteModel note;
  bool isLoading = false;
  bool isNewNote = false;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    refreshNotes();
  }

  /// Gets the note from the database and updates the state if the noteId is not null else sets isNewNote to true
  Future<void> refreshNotes() async {
  if (widget.noteId == null) {
    setState(() {
      isNewNote = true;
    });
    return;
  }

  try {
    final value = await noteDatabase.read(widget.noteId!);
    setState(() {
      note = value;
      titleController.text = note.title;
      contentController.text = note.content;
      isFavorite = note.isFavorite;
    });
  } catch (e) {
    debugPrint('Error fetching note: $e');
  }
}


  /// Creates a new note if isNewNote is true else updates the existing note
  Future<void> createNote() async {
    if (titleController.text.isEmpty || contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and content cannot be empty')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final model = NoteModel(
      title: titleController.text,
      number: 1,
      content: contentController.text,
      isFavorite: isFavorite,
      createdTime: DateTime.now(),
    );

    try {
      if (isNewNote) {
        await noteDatabase.create(model);
      } else {
        model.id = note.id;
        await noteDatabase.update(model);
      }
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error saving note: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Deletes the note from the database and navigates back to the previous screen
  Future<void> deleteNote() async {
    if (note.id != null) {
      await noteDatabase.delete(note.id!);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isFavorite = !isFavorite;
              });
            },
            icon: Icon(!isFavorite ? Icons.favorite_border : Icons.favorite),
          ),
          Visibility(
            visible: !isNewNote,
            child: IconButton(
              onPressed: deleteNote,
              icon: const Icon(Icons.delete),
            ),
          ),
          IconButton(
            onPressed: createNote,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    TextField(
                      controller: titleController,
                      cursorColor: Colors.white,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Title',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextField(
                      controller: contentController,
                      cursorColor: Colors.white,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Type your note here...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
