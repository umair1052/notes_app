import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'model.dart';

class AddNotes extends StatefulWidget {
  final Notes? note;
  const AddNotes({super.key, this.note});

  @override
  State<AddNotes> createState() => _AddNotesState();
}

class _AddNotesState extends State<AddNotes> {
  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();

  List<Notes> list = [];
  List<Notes> filteredNotes = [];
  late SharedPreferences sharedPreferences;

  getData() async {
    sharedPreferences = await SharedPreferences.getInstance();
    List<String>? stringList = sharedPreferences.getStringList("list");

    if (stringList != null) {
      list =
          stringList.map((item) => Notes.fromMap(json.decode(item))).toList();
      setState(() {
        filteredNotes = List.from(list);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      title = TextEditingController(text: widget.note!.title);
      description = TextEditingController(text: widget.note!.description);
    }
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
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  padding: EdgeInsets.all(0),
                  icon: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800.withOpacity(.8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(
                          vertical: 50, horizontal: 30),
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white,
                              offset: Offset(7, 7),
                              blurRadius: 6,
                            )
                          ]),
                      child: Column(
                        children: [
                          TextField(
                            controller: title,
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 30),
                            maxLines: 1,
                            decoration: InputDecoration(
                                hintText: "Title",
                                hintStyle:
                                    TextStyle(color: Colors.grey, fontSize: 30),
                                border: InputBorder.none),
                          ),
                          TextField(
                            controller: description,
                            style: TextStyle(color: Colors.grey),
                            maxLines: 5,
                            decoration: InputDecoration(
                                hintText: "Type something here",
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (title.text.isEmpty || description.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  "Please enter both Title and Description!"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else {
                          setState(() {
                            list.insert(
                                0,
                                Notes(
                                    title: title.text,
                                    description: description.text));
                            filteredNotes = List.from(list);
                          });

                          List<String> stringList = list
                              .map((item) => json.encode(item.toMap()))
                              .toList();
                          sharedPreferences.setStringList("list", stringList);

                          Navigator.pop(context, "loadData");
                        }
                      },
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 30),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                          child: Text(
                            "Save",
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
