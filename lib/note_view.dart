import 'note.dart';
import 'note_database.dart';
import 'note_details_view.dart';
import 'package:flutter/material.dart';


class NotesView extends StatefulWidget {
  const NotesView({super.key});


  @override
  State<NotesView> createState() => _NotesViewState();
}


class _NotesViewState extends State<NotesView> {
  NoteDatabase noteDatabase = NoteDatabase.instance;


  List<NoteModel> notes = [];


  @override
  void initState() {
    refreshNotes();
    super.initState();
  }


 @override
void dispose() {
  noteDatabase.close(); // Cierra la base de datos
  super.dispose();
}



  ///Gets all the notes from the database and updates the state
  refreshNotes() {
    noteDatabase.readAll().then((value) {
      setState(() {
        notes = value;
      });
    });
  }


  ///Navigates to the NoteDetailsView and refreshes the notes after the navigation
  goToNoteDetailsView({int? id}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteDetailsView(noteId: id)),
    );
    refreshNotes();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: Center(
        child: notes.isEmpty
            ? const Text(
                'No Notes yet',
                style: TextStyle(color: Colors.white),
              )
            : ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return GestureDetector(
                    onTap: () => goToNoteDetailsView(id: note.id),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                note.createdTime.toString().split(' ')[0],
                              ),
                              Text(
                                note.title,
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: goToNoteDetailsView,
        tooltip: 'Create Note',
        child: const Icon(Icons.add),
      ),
    );
  }
}
