import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:notes_app/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'add_notes.dart';
import 'model.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({super.key});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  getRandomColor() {
    Random random = Random();
    return backgroundColors[random.nextInt(backgroundColors.length)];
  }

  List<Notes> filteredNotes = [];
  List<Notes> list = [];

  late SharedPreferences sharedPreferences;
  void onSearchTextChanged(String searchText) {
    setState(() {
      filteredNotes = list
          .where((note) =>
              note.title.toLowerCase().contains(searchText.toLowerCase()) ||
              note.description.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    });
  }

  void deleteNote(int index) {
    {
      setState(() {
        list.remove(index);
        filteredNotes.removeAt(index);

        List<String> stringList =
            list.map((item) => json.encode(item.toMap())).toList();
        sharedPreferences.setStringList("list", stringList);
      });
    }
  }

  getData() async {
    sharedPreferences = await SharedPreferences.getInstance();
    List<String>? stringList = sharedPreferences.getStringList("list");

    if (stringList != null) {
      list =
          stringList.map((item) => Notes.fromMap(json.decode(item))).toList();
      setState(() {
        filteredNotes = list;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notes',
                  style: TextStyle(fontSize: 30, color: Colors.white),
                ),
                IconButton(
                    onPressed: () {},
                    padding: EdgeInsets.all(0),
                    icon: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade800.withOpacity(.8),
                          borderRadius: BorderRadius.circular(10)),
                      child: Icon(
                        Icons.sort,
                        color: Colors.white,
                      ),
                    )),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              onChanged: onSearchTextChanged,
              style: TextStyle(fontSize: 16, color: Colors.white),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 12),
                hintText: "Search notes...",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.grey,
                ),
                fillColor: Colors.grey.shade800,
                filled: true,
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.transparent)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.transparent)),
              ),
            ),
            Expanded(
              child: ListView.builder(
                  padding: const EdgeInsets.only(top: 30),
                  itemCount: filteredNotes.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 20),
                      color: getRandomColor(),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  AddNotes(note: filteredNotes[index]),
                            ),
                          );
                        },
                        title: Text(
                          filteredNotes[index].title,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              height: 1.5),
                        ),
                        subtitle: Text(
                          filteredNotes[index].description,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                              height: 1.5),
                        ),
                        trailing: IconButton(
                          onPressed: () async {
                            final result = await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.grey.shade900,
                                    icon: Icon(
                                      Icons.info,
                                      color: Colors.grey,
                                    ),
                                    title: Text(
                                      'Are you sure you want to delete?',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    content: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context, true);
                                          },
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green),
                                          child: SizedBox(
                                              width: 60,
                                              child: Text(
                                                'Yes',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context, false);
                                          },
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red),
                                          child: SizedBox(
                                              width: 60,
                                              child: Text(
                                                'No',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )),
                                        ),
                                      ],
                                    ),
                                  );
                                });
                            if (result != null && result) {
                              deleteNote(index);
                            }
                          },
                          icon: Icon(
                            Icons.delete,
                          ),
                        ),
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String refresh = await Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddNotes()));
          if (refresh == "loadData") {
            setState(() {
              getData();
            });
          }
        },
        elevation: 10,
        backgroundColor: Colors.grey.shade800,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}
