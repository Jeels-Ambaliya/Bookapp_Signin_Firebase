import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../helper/firebase_auth_helper.dart';
import '../../helper/firestore_helper.dart';

class Home_Page extends StatefulWidget {
  const Home_Page({Key? key}) : super(key: key);

  @override
  State<Home_Page> createState() => _Home_PageState();
}

class _Home_PageState extends State<Home_Page> {
  final GlobalKey<FormState> insertFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> updateFormKey = GlobalKey<FormState>();

  final TextEditingController authorController = TextEditingController();
  final TextEditingController bookController = TextEditingController();

  String? authorName;
  String? bookName;
  Uint8List? imageBytes;

  getFromGallery() async {
    ImagePicker picker = ImagePicker();

    XFile? xFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 40,
    );

    imageBytes = await xFile!.readAsBytes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                Color(0xff293957),
                Color(0xff3d539c),
              ],
            ),
          ),
        ),
        title: const Text(
          "HOME PAGE",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 22,
            letterSpacing: 3,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuthHelper.firebaseAuthHelper.logOut();

              Navigator.of(context)
                  .pushNamedAndRemoveUntil('login_page', (route) => false);
            },
            icon: const Icon(
              Icons.power_settings_new,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirestoreHelper.firestoreHelper.fetchRecords(),
        builder: (context, snapShot) {
          if (snapShot.hasError) {
            return Center(
              child: Text("Error : ${snapShot.error}"),
            );
          } else if (snapShot.hasData) {
            QuerySnapshot<Map<String, dynamic>>? data = snapShot.data;

            if (data == null) {
              return const Center(
                child: Text("No Any Data Available...."),
              );
            } else {
              List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs =
                  data.docs;

              return Padding(
                padding: const EdgeInsets.all(16),
                child: ListView.builder(
                  itemCount: allDocs.length,
                  itemBuilder: (context, i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Colors.grey.shade200,
                          border: Border.all(
                            width: 0.2,
                            color: Colors.deepPurple,
                          ),
                          boxShadow: [
                            BoxShadow(
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(3, 3),
                              color: Colors.deepPurple.shade100,
                            ),
                          ],
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Map<String, dynamic> updateData = {
                              "book": allDocs[i].data()['book'],
                              "author": allDocs[i].data()['author'],
                              "image": allDocs[i].data()['image']!,
                            };
                            validateUpdate(id: allDocs[i].id, data: updateData);
                          },
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: CircleAvatar(
                                    radius: 55,
                                    backgroundColor: Colors.blueGrey,
                                    backgroundImage:
                                        (allDocs[i].data()['image'] == null)
                                            ? null
                                            : MemoryImage(
                                                base64Decode(
                                                    allDocs[i].data()['image']),
                                              ),
                                    child: (allDocs[i].data()['image'] == null)
                                        ? Text(
                                            allDocs[i].data()['book'].name[0],
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        allDocs[i].data()['book'],
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          textStyle: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "${allDocs[i].data()['author']}",
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          textStyle: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "⭐ 4.2",
                                        style: GoogleFonts.poppins(
                                          textStyle: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: 30,
                                        width: 70,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Colors.deepPurple.shade100,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Text(
                                          "Love",
                                          style: GoogleFonts.poppins(
                                            textStyle: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: IconButton(
                                  onPressed: () async {
                                    await FirestoreHelper.firestoreHelper
                                        .deleteRecords(id: allDocs[i].id);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "Record Deleted Successfully..."),
                                        backgroundColor: Colors.redAccent,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: validateInsert,
        backgroundColor: const Color(0xff3d539c),
        child: const Icon(
          Icons.add,
          size: 30,
          color: Colors.white,
        ),
      ),
    );
  }

  validateInsert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(
          child: Text(
            "Add Records",
            style: TextStyle(
              color: Colors.deepPurple,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        content: Form(
          key: insertFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: GestureDetector(
                  onTap: () {
                    getFromGallery();
                  },
                  child: CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.deepPurple.shade100,
                    child: const Text(
                      "ADD",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              TextFormField(
                controller: bookController,
                validator: (val) {
                  if (val!.isEmpty) {
                    return "Enter Book Name First.....";
                  }
                  return null;
                },
                onSaved: (val) {
                  bookName = val;
                },
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: "Enter Book Name here....",
                  labelText: "Book Name",
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.deepPurple,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: const BorderSide(
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: TextFormField(
                  controller: authorController,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return "Enter Author Name First.....";
                    }
                    return null;
                  },
                  onSaved: (val) {
                    authorName = val;
                  },
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: "Enter Author Name here....",
                    labelText: "Author Name",
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.deepPurple,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          OutlinedButton(
            child: const Text("Add"),
            onPressed: () async {
              if (insertFormKey.currentState!.validate()) {
                insertFormKey.currentState!.save();

                Map<String, dynamic> records = {
                  "book": bookName,
                  "author": authorName,
                  "image": base64Encode(imageBytes!),
                };

                await FirestoreHelper.firestoreHelper
                    .insertRecords(data: records);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Record Inserted Successfully..."),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );

                bookController.clear();
                authorController.clear();

                setState(() {
                  bookName = null;
                  authorName = null;
                  imageBytes = null;
                });

                Navigator.pop(context);
              }
            },
          ),
          OutlinedButton(
            child: const Text("Cancel"),
            onPressed: () async {
              bookController.clear();
              authorController.clear();

              setState(() {
                bookName = null;
                authorName = null;
                imageBytes = null;
              });

              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  validateUpdate({required String id, required Map<String, dynamic> data}) {
    bookController.text = data['book'];
    authorController.text = data['author'];
    imageBytes = base64Decode(data['image']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(
          child: Text(
            "Update Records",
            style: TextStyle(
              color: Colors.deepPurple,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        content: Form(
          key: updateFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: GestureDetector(
                  onTap: () {
                    getFromGallery();
                  },
                  child: CircleAvatar(
                    radius: 70,
                    foregroundImage:
                        (imageBytes != null) ? MemoryImage(imageBytes!) : null,
                    backgroundColor: Colors.deepPurple.shade100,
                    child: const Text(
                      "ADD",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                ),
              ),
              TextFormField(
                controller: bookController,
                validator: (val) {
                  if (val!.isEmpty) {
                    return "Enter Book Name First.....";
                  }
                  return null;
                },
                onSaved: (val) {
                  bookName = val;
                },
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: "Enter Book Name here....",
                  labelText: "Book Name",
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.deepPurple,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: const BorderSide(
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: TextFormField(
                  controller: authorController,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return "Enter Author Name First.....";
                    }
                    return null;
                  },
                  onSaved: (val) {
                    authorName = val;
                  },
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: "Enter Author Name here....",
                    labelText: "Author Name",
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.deepPurple,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          OutlinedButton(
            child: const Text("Update"),
            onPressed: () async {
              if (updateFormKey.currentState!.validate()) {
                updateFormKey.currentState!.save();

                Map<String, dynamic> records = {
                  "book": bookName,
                  "author": authorName,
                  "image": base64Encode(imageBytes!),
                };

                await FirestoreHelper.firestoreHelper
                    .updateRecord(data: records, id: id);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Record Updated Successfully..."),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );

                bookController.clear();
                authorController.clear();

                setState(() {
                  bookName = null;
                  authorName = null;
                  imageBytes = null;
                });

                Navigator.pop(context);
              }
            },
          ),
          OutlinedButton(
            child: const Text("Cancel"),
            onPressed: () async {
              bookController.clear();
              authorController.clear();

              setState(() {
                bookName = null;
                authorName = null;
                imageBytes = null;
              });

              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
