import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
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
  late ScrollController _controller;
  String? imagePath;
  String? imageURL;
  XFile? file;
  List items = [];
  bool isLoading = false;

  late Stream<QuerySnapshot> _stream;
  @override
  void initState() {
    _controller = ScrollController();
    // CollectionReference _reference =
    //     FirebaseFirestore.instance.collection("notes");
    // _stream = _reference.orderBy("createdAt", descending: true).snapshots();
    _stream = firestoreService.getNotes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: TextButton(
          child: Text(
            "Пользователь",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          onPressed: () {},
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _stream,
        builder: (context, snapshot) {
          // List arr = snapshot.data?? [];
          // log("$arr");
          if (snapshot.hasError) {
            return const Center(
              child: Text("Error"),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
                backgroundColor: Colors.white,
              ),
            );
          }
          if (snapshot.hasData) {
            items = snapshot.data?.docs ?? [];
            // QuerySnapshot querySnapshot = snapshot.data;
            // List<QueryDocumentSnapshot> documents = querySnapshot.docs;
            // if (documents.isEmpty) {
            //   return const Center(
            //     child: Text("Добавьте заметку!"),
            //   );
            // }
            // items = documents.map((e) => e.data() as Map).toList();
            if (items.isEmpty) {
              return const Center(
                child: Text("Добавьте заметку!"),
              );
            }
            // log("${items}");

            return ListView.builder(
                controller: _controller,
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) {
                  Note thisItem = items[index].data();
                  // String thisItemId = items[index].id;
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 5.h,
                    ),
                    margin: EdgeInsets.symmetric(
                      vertical: 5.0,
                      horizontal: 10,
                    ),
                    height: 85.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10.r)),
                      color: Theme.of(context).colorScheme.background,
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
                          child: thisItem.image != null
                              ? Container(
                                  height: 75.h,
                                  width: 75.w,
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                          "assets/images/default_image.png"),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Image.network(
                                    "${thisItem.image}",
                                    height: 75.h,
                                    width: 75.w,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Container(
                                  height: 75.h,
                                  width: 75.w,
                                  child: Image.asset(
                                    "assets/images/no_image.png",
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${thisItem.name}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall,
                                  ),
                                  Text(
                                    DateFormat("dd-MM-yyyy")
                                        .format(thisItem.createdAt!.toDate()),
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                              thisItem.description != ""
                                  ? Text(
                                      "${thisItem.description}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    )
                                  : Text(
                                      "Без описания",
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
            barrierDismissible: false,
            useSafeArea: false,
            context: context,
            builder: (context) => Dialog(
              insetPadding: EdgeInsets.all(20.0.r),
              child: SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  width: double.infinity,
                  height: 600.h,
                  child: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return Padding(
                        padding: EdgeInsets.all(20.0.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Добавить заметку",
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            SizedBox(height: 20.h),
                            TextFormField(
                              cursorColor: Colors.grey,
                              textCapitalization: TextCapitalization.sentences,
                              onChanged: (text) {
                                setState(() {});
                              },
                              controller: nameController,
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                    borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                    borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                      width: 1,
                                    ),
                                  ),
                                  hintText: "Название"),
                            ),
                            SizedBox(height: 10.h),
                            TextFormField(
                              textCapitalization: TextCapitalization.sentences,
                              controller: descriptionController,
                              maxLines: 5,
                              cursorColor: Colors.grey,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
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
                              },
                            ),
                            SizedBox(height: 10.h),
                            imagePath != null
                                ? Image.file(
                                    File(imagePath!),
                                    height: 150.h,
                                    width: 150.w,
                                    key: UniqueKey(),
                                    fit: BoxFit.cover,
                                  )
                                : const SizedBox(),
                            SizedBox(height: 10.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                AbsorbPointer(
                                  absorbing: isLoading,
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                    ),
                                    child: const Text(
                                      "Закрыть",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    onPressed: () {
                                      isLoading ? null : Navigator.pop(context);
                                    },
                                  ),
                                ),
                                isLoading
                                    ? CircularProgressIndicator(
                                        color: Colors.blue)
                                    : SizedBox(width: 10),
                                nameController.text.isEmpty || imagePath == null
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
                                        child: const Text(
                                          "Сохранить",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                    : AbsorbPointer(
                                        absorbing: isLoading,
                                        child: TextButton(
                                          style: TextButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                          ),
                                          child: const Text(
                                            "Сохранить",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                          onPressed: () async {
                                            setState(() => isLoading = true);
                                            String uniqueFileName =
                                                DateTime.now()
                                                    .millisecondsSinceEpoch
                                                    .toString();
                                            Reference referenceRoot =
                                                FirebaseStorage.instance.ref();
                                            Reference referenceDirImages =
                                                referenceRoot.child("images");
                                            Reference referenceImageToUpload =
                                                referenceDirImages
                                                    .child(uniqueFileName);
                                            try {
                                              await referenceImageToUpload
                                                  .putFile(File(imagePath!));
                                              imageURL =
                                                  await referenceImageToUpload
                                                      .getDownloadURL();
                                              setState(() {});
                                            } catch (e) {}
                                            // await Timer(
                                            //   Duration(seconds: 0),
                                            //   () {
                                            //     if (imageURL == "null") {
                                            //       ScaffoldMessenger.of(context)
                                            //           .showSnackBar(
                                            //         const SnackBar(
                                            //           content: Text(
                                            //               "Выберите фото!"),
                                            //         ),
                                            //       );
                                            //       return;
                                            //     }
                                            //   },
                                            // );

                                            Note note = Note(
                                              name: nameController.text,
                                              description:
                                                  descriptionController.text,
                                              image: imageURL,
                                              createdAt: Timestamp.now(),
                                              updatedAt: Timestamp.now(),
                                            );
                                            await firestoreService
                                                .addNote(note);
                                            setState(() => isLoading = false);
                                            // Map<String, dynamic> newNote = {
                                            //   "name": note.name,
                                            //   "description": note.description,
                                            //   "image": note.image,
                                            //   "createdAt": note.createdAt,
                                            // };
                                            nameController.clear();
                                            descriptionController.clear();
                                            imagePath = null;
                                            imageURL = null;
                                            // setState(() {
                                            // items.insert(0, newNote);
                                            // });
                                            if (!isLoading) {
                                              Navigator.pop(context);
                                            }
                                            WidgetsBinding.instance!
                                                .addPostFrameCallback((_) {
                                              _controller.jumpTo(0.0);
                                            });
                                          },
                                        ),
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
