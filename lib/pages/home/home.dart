import 'package:flutter/material.dart';
import 'package:gb_shopping_list/models/list.dart';
import 'package:gb_shopping_list/services/auth.dart';
import 'package:gb_shopping_list/services/database.dart';
import 'package:gb_shopping_list/widgets/drawer.dart';
import 'package:gb_shopping_list/widgets/lists_view.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedTab = 0;
  String _barTitle = "Aktywne listy";

  void _onTabTapped(int index) {
    setState(() {
      _selectedTab = index;
      switch (index) {
        case 0:
          _barTitle = "Aktywne listy";
          break;
        case 1:
          _barTitle = "Ukończone listy";
          break;
        case 2:
          _barTitle = "Usunięte listy";
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController listNameController = TextEditingController();

    final List<FloatingActionButton?> fabsList = <FloatingActionButton?>[
      FloatingActionButton(
        onPressed: () {
          showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Nazwa listy'),
              content: TextField(
                autofocus: true,
                controller: listNameController,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    listNameController.text = "";
                    Navigator.pop(context, "");
                  },
                  child: const Text('Anuluj'),
                ),
                TextButton(
                  onPressed: () {
                    String text = listNameController.text;
                    listNameController.text = "";
                    Navigator.pop(context, text);
                  },
                  child: const Text('Dodaj'),
                ),
              ],
            ),
          ).then((val) {
            String name = val!.trim();
            {
              if (name.isNotEmpty) {
                ListModel newList =
                    ListModel(listName: name, isTrashed: false, listItems: []);
                DatabaseService(uid: AuthService().uid).addNewList(newList);
              }
            }
          });
        },
        foregroundColor: Theme.of(context).colorScheme.tertiary,
        child: const Icon(Icons.add),
      ),
      null,
      FloatingActionButton(
          onPressed: () {
            showDialog<bool?>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('Czy usunąć wszystkie listy na zawsze?'),
                content: const Text('To jest bardzo długo!'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: const Text('Tak'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: const Text('Nie'),
                  ),
                ],
              ),
            ).then((val) {
              {
                if (val!) {
                  DatabaseService(uid: AuthService().uid)
                      .deleteAllListsFromTrash();
                }
              }
            });
          },
          foregroundColor: Theme.of(context).colorScheme.tertiary,
          child: const Icon(Icons.delete_forever)),
    ];

    return StreamProvider<List<ListModel>>(
      create: (_) => DatabaseService(uid: AuthService().uid).lists,
      lazy: false,
      initialData: const [],
      child: WillPopScope(
        onWillPop: () async {
          MoveToBackground.moveTaskToBack();
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(_barTitle),
            foregroundColor: Theme.of(context).colorScheme.tertiary,
          ),
          drawer: const MenuDrawer(),
          body: Center(
            child: ListsView(pageNumber: _selectedTab),
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart_outlined),
                  label: 'Aktywne listy'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.check_circle_outline_rounded),
                  label: 'Ukończone listy'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.delete_outline), label: 'Usunięte listy'),
            ],
            currentIndex: _selectedTab,
            onTap: _onTabTapped,
          ),
          floatingActionButton: fabsList.elementAt(_selectedTab),
        ),
      ),
    );
  }
}
