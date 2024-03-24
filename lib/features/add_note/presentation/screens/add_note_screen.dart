import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notebook/features/models/note_model.dart';
import 'package:notebook/features/services/firestore.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({Key? key}) : super(key: key);

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  final FirestoreService firestoreService = FirestoreService();
  ScrollController _controller = ScrollController();
  String? imagePath;
  String? imageURL;
  XFile? file;
  List<Map> items = [];

  late Stream<QuerySnapshot> _stream;
  @override
  void initState() {
    CollectionReference _reference =
        FirebaseFirestore.instance.collection("notes");
    _stream = _reference.orderBy("createdAt", descending: true).snapshots();
    super.initState();
  }

  void _scrollToStart() {
    _controller.animateTo(
      0.0,
      duration: Duration(milliseconds: 0),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: TextButton(
          child: const Text(
            "Пользователь",
            style: TextStyle(
              fontSize: 24,
              color: Colors.black,
            ),
          ),
          onPressed: () {},
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _stream,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Error"),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
                backgroundColor: Colors.grey,
              ),
            );
          }
          if (snapshot.hasData) {
            QuerySnapshot querySnapshot = snapshot.data;
            List<QueryDocumentSnapshot> documents = querySnapshot.docs;
            items = documents.map((e) => e.data() as Map).toList();

            return ListView.builder(
                controller: _controller,
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) {
                  Map thisItem = items[index];
                  return ListTile(
                    title: Text("${thisItem["name"]}"),
                    subtitle: Text("${thisItem["description"]}"),
                    leading: thisItem["image"] != null
                        ? Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                    "assets/images/default_image.png"),
                                fit: BoxFit.fill,
                              ),
                            ),
                            child: Image.network(
                              "${thisItem["image"]}",
                              height: 80,
                              width: 80,
                              fit: BoxFit.fill,
                            ),
                          )
                        : Container(
                            height: 80,
                            width: 80,
                            child: Image.asset(
                              "assets/images/no_image.png",
                              fit: BoxFit.fill,
                            ),
                          ),
                    onTap: () {},
                  );
                });
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          showDialog(
            useSafeArea: false,
            context: context,
            builder: (context) => Dialog(
              insetPadding: EdgeInsets.all(20.0.r),
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  height: 600.h,
                  child: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return Padding(
                        padding: EdgeInsets.all(20.0.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "Добавить заметку",
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 20.h),
                            TextFormField(
                              cursorColor: Colors.grey,
                              textCapitalization: TextCapitalization.words,
                              onChanged: (text) {
                                setState(() {});
                              },
                              controller: nameController,
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                    borderSide: const BorderSide(
                                      color: Colors.black,
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                    borderSide: const BorderSide(
                                      color: Colors.black,
                                      width: 1,
                                    ),
                                  ),
                                  hintText: "Название"),
                            ),
                            SizedBox(height: 10.h),
                            TextFormField(
                              textCapitalization: TextCapitalization.words,
                              controller: descriptionController,
                              maxLines: 5,
                              cursorColor: Colors.grey,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                ),
                                hintText: "Описание",
                              ),
                            ),
                            SizedBox(height: 10.h),
                            IconButton(
                              icon: const Icon(
                                Icons.camera_alt,
                                size: 40,
                              ),
                              onPressed: () async {
                                ImagePicker imagePicker = ImagePicker();
                                file = await imagePicker.pickImage(
                                    source: ImageSource.gallery);
                                if (file == null) {
                                  return;
                                }
                                setState(() {
                                  imagePath = file!.path;
                                });

                                String uniqueFileName = DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString();
                                Reference referenceRoot =
                                    FirebaseStorage.instance.ref();
                                Reference referenceDirImages =
                                    referenceRoot.child("images");
                                Reference referenceImageToUpload =
                                    referenceDirImages.child(uniqueFileName);
                                try {
                                  await referenceImageToUpload
                                      .putFile(File(imagePath!));
                                  imageURL = await referenceImageToUpload
                                      .getDownloadURL();
                                  setState(() {});
                                } catch (e) {}
                              },
                            ),
                            SizedBox(height: 10.h),
                            imagePath != null
                                ? Image.file(
                                    File(imagePath!),
                                    height: 150.h,
                                    width: double.infinity,
                                    key: UniqueKey(),
                                    fit: BoxFit.fitHeight,
                                  )
                                : const SizedBox(),
                            SizedBox(height: 10.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                  ),
                                  child: const Text("Закрыть"),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                nameController.text.isEmpty || imageURL == null
                                    ? TextButton(
                                        style: TextButton.styleFrom(
                                          backgroundColor:
                                              Colors.blue.withOpacity(0.5),
                                        ),
                                        onPressed: () {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "Название и Фото обязательны!"),
                                            ),
                                          );
                                        },
                                        child: Text("Сохранить"),
                                      )
                                    : TextButton(
                                        style: TextButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                        ),
                                        child: Text("Сохранить"),
                                        onPressed: () async {
                                          await Timer(
                                            Duration(seconds: 1),
                                            () {
                                              if (imageURL == "null") {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content:
                                                        Text("Выберите фото!"),
                                                  ),
                                                );
                                                return;
                                              }
                                            },
                                          );
                                          Navigator.pop(context);
                                          Timestamp currentTime =
                                              Timestamp.now();
                                          Note note = Note(
                                            name: nameController.text,
                                            description:
                                                descriptionController.text,
                                            image: imageURL,
                                            createdAt: currentTime,
                                          );
                                          await firestoreService.addNote(note);
                                          Map<String, dynamic> newNote = {
                                            "name": note.name,
                                            "description": note.description,
                                            "image": note.image,
                                            "createdAt": note.createdAt,
                                          };
                                          nameController.clear();
                                          descriptionController.clear();
                                          imagePath = null;
                                          imageURL = null;
                                          // setState(() {
                                          items.insert(0, newNote);
                                          // });
                                          _scrollToStart();
                                          _controller.jumpTo(0.0);
                                        },
                                      ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
