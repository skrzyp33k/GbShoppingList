import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gb_shopping_list/models/item.dart';
import 'package:gb_shopping_list/props/units.dart';
import 'package:gb_shopping_list/services/auth.dart';
import 'package:gb_shopping_list/services/database.dart';
import 'package:gb_shopping_list/widgets/item_card.dart';

class ListInfoPage extends StatefulWidget {
  const ListInfoPage(
      {Key? key,
      required this.listName,
      required this.items,
      required this.listID})
      : super(key: key);

  final String listName;
  final String listID;

  final List<ItemModel> items;

  @override
  State<ListInfoPage> createState() => _ListInfoPageState();
}

class _ListInfoPageState extends State<ListInfoPage> {
  late String listName;

  @override
  @mustCallSuper
  void initState() {
    listName = widget.listName;
    super.initState();
  }

  String itemUnit = "";

  @override
  Widget build(BuildContext context) {
    List<String> units = Units().list;

    if (itemUnit.isEmpty) {
      itemUnit = units.first;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(listName),
        foregroundColor: Theme.of(context).colorScheme.tertiary,
        automaticallyImplyLeading: false,
        centerTitle: true,
        actions: <Widget>[
          Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  TextEditingController nameController =
                      TextEditingController();
                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Zmiana nazwy listy'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            autofocus: true,
                            controller: nameController,
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            String text = nameController.text;
                            nameController.text = "";
                            Navigator.pop(context, text);
                          },
                          child: const Text('Zmień'),
                        ),
                        TextButton(
                          onPressed: () {
                            nameController.text = "";
                            Navigator.pop(context, "");
                          },
                          child: const Text('Anuluj'),
                        ),
                      ],
                    ),
                  ).then((val) {
                    String name = val!.trim();
                    {
                      if (name.isNotEmpty) {
                        DatabaseService(uid: AuthService().uid)
                            .renameList(widget.listID, name);
                        setState(() {
                          listName = name;
                        });
                      }
                    }
                  });
                },
                child: const Icon(
                  Icons.edit,
                ),
              )),
          Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Czy przenieść listę do kosza?'),
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
                            .moveListToTrash(widget.listID);
                        Navigator.pop(context);
                      }
                    }
                  });
                },
                child: const Icon(Icons.delete),
              )),
        ],
      ),
      body: StreamBuilder(
        stream: DatabaseService(uid: AuthService().uid)
            .rootCollection
            .doc(AuthService().uid)
            .collection('lists')
            .doc(widget.listID)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }
          var rawItems = snapshot.data!['items'];

          List<ItemModel> items = [];

          for (var item in rawItems) {
            items.add(ItemModel(
                itemName: item['itemName'],
                itemCount: item['itemCount'],
                itemUnit: item['itemUnit'],
                itemBarcode: item['itemBarcode'],
                isChecked: item['isChecked'],
                itemInfo: item['itemInfo'],
                listID: widget.listID));
          }

          items.sort((a, b) => a.itemName.compareTo(b.itemName));

          return ListView.builder(
            padding: const EdgeInsets.all(5),
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              return ItemCard(
                itemModel: items[index],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          TextEditingController nameController = TextEditingController();
          TextEditingController countController = TextEditingController();
          showDialog<String>(
            context: context,
            builder: (BuildContext context) => StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                title: const Text('Dodawanie produktu'),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Text("Nazwa:"),
                        Expanded(
                            child: TextField(
                          controller: nameController,
                        )),
                      ],
                    ),
                    Row(
                      children: [
                        const Text("Ilość:"),
                        Expanded(
                            child: TextField(
                          controller: countController,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                            RegExp(r"[0-9.]")),
                            TextInputFormatter.withFunction(
                            (oldValue, newValue) {
                              try {
                            final text = newValue.text;
                            if (text.isNotEmpty) double.parse(text);
                            return newValue;
                              } catch (e) {
                                //do nothing
                              }
                              return oldValue;
                            }),
                          ],
                        )),
                        DropdownButton<String>(
                            value: itemUnit,
                            items: units
                                .map<DropdownMenuItem<String>>((String val) {
                              return DropdownMenuItem<String>(
                                value: val,
                                child: Text(val),
                              );
                            }).toList(),
                            onChanged: (String? val) {
                              setState(() {
                                itemUnit = val!;
                              });
                            }),
                      ],
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      nameController.text = "";
                      Navigator.pop(context, "");
                    },
                    child: const Text('Anuluj'),
                  ),
                  TextButton(
                    onPressed: () {
                      String name = nameController.text;
                      String count = countController.text;
                      widget.items.add(ItemModel(
                          itemName: name,
                          itemCount: count,
                          itemUnit: itemUnit,
                          isChecked: false));
                      DatabaseService(uid: AuthService().uid)
                          .addItems(widget.listID, widget.items);
                      nameController.text = "";
                      countController.text = "";
                      Navigator.pop(context, "");
                    },
                    child: const Text('Dodaj'),
                  ),
                ],
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
