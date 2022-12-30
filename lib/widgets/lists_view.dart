import 'package:flutter/material.dart';
import 'package:gb_shopping_list/models/item.dart';
import 'package:gb_shopping_list/models/list.dart';
import 'package:gb_shopping_list/services/auth.dart';
import 'package:gb_shopping_list/services/database.dart';
import 'package:gb_shopping_list/widgets/list_card.dart';
import 'package:provider/provider.dart';

class ListsView extends StatefulWidget {
  const ListsView({Key? key, required this.pageNumber}) : super(key: key);

  final int pageNumber;

  @override
  State<ListsView> createState() => _ListsViewState();
}

class _ListsViewState extends State<ListsView> {
  @override
  Widget build(BuildContext context) {
    List<ListModel> rawModels = Provider.of<List<ListModel>>(context) ?? [];

    List<ListCard> rawItems = <ListCard>[];

    for(ListModel lm in rawModels)
      {
        rawItems.add(ListCard(listModel: lm));
      }

    List<ListCard> activeLists = [];
    List<ListCard> finishedLists = [];
    List<ListCard> trashedLists = [];

    for (ListCard li in rawItems) {
      if (li.listModel.isTrashed) {
        trashedLists.add(li);
      } else {
        int checked = 0;
        for (ItemModel i in li.listModel.listItems) {
          if (i.isChecked) checked++;
        }
        if (checked >= li.listModel.listItems.length && li.listModel.listItems.isNotEmpty) {
          finishedLists.add(li);
        } else {
          activeLists.add(li);
        }
      }
    }

    final List<Widget> tabsList = <Widget>[
      RefreshIndicator(
        onRefresh: () {
          return Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              //rawItems = //TODO: pobieranie listy
            });
          });
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(5),
          itemCount: activeLists.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(child: activeLists[index]);
          },
        ),
      ),
      RefreshIndicator(
        onRefresh: () {
          return Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              //rawItems = //TODO: pobieranie listy
            });
          });
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(5),
          itemCount: finishedLists.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(child: finishedLists[index]);
          },
        ),
      ),
      RefreshIndicator(
        onRefresh: () {
          return Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              //rawItems = //TODO: pobieranie listy
            });
          });
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(5),
          itemCount: trashedLists.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(child: trashedLists[index]);
          },
        ),
      ),
    ];

    return tabsList[widget.pageNumber];
  }
}