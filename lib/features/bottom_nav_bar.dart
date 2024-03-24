import 'package:flutter/material.dart';
import 'package:notebook/features/add_note/presentation/screens/add_note_screen.dart';
import 'package:notebook/features/view_notes/presentation/screens/view_notes_screen.dart';

class BottomNavBarScreen extends StatefulWidget {
  const BottomNavBarScreen({super.key});

  @override
  State<BottomNavBarScreen> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBarScreen> {
  int selectedIndex = 0;

  void onItemTab(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  List<Widget> screens = const [
    AddNoteScreen(),
    ViewNotesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: screens.elementAt(selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0.0,
        // backgroundColor: Theme.of(context).colorScheme.background,
        backgroundColor: Colors.grey.shade200,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        iconSize: 24,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.note_add),
            label: 'Добавить Заметку',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.featured_play_list_outlined,
              color: Colors.grey,
            ),
            activeIcon: Icon(
              Icons.featured_play_list_outlined,
              color: Colors.blue,
            ),
            label: 'Заметки',
          ),
        ],
        currentIndex: selectedIndex,
        onTap: onItemTab,
      ),
    );
  }
}
