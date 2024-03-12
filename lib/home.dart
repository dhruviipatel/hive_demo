import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final mybox = Hive.box('item_box');
  List<Map<String, dynamic>> mylist = [];
  var nameController = TextEditingController();
  var qtyController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getItem();
  }

  void getItem() {
    final data = mybox.keys.map((k) {
      final item = mybox.get(k);
      return {'key': k, 'name': item['name'], 'quantity': item['quantity']};
    }).toList();

    setState(() {
      mylist = data.reversed.toList();
    });
  }

  Future<void> addItem(item) async {
    await mybox.add(item);
    getItem();
  }

  Future<void> updateItem(itemkey, newitem) async {
    await mybox.put(itemkey, newitem);
    getItem();
  }

  Future<void> deleteItem(itemkey) async {
    await mybox.delete(itemkey);
    getItem();
  }

  _showAlertDialog(context, int? itemkey) {
    if (itemkey != null) {
      final item = mylist.firstWhere((element) => element['key'] == itemkey);
      nameController.text = item['name'];
      qtyController.text = item['quantity'];
    }
    return AlertDialog(
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
              nameController.text = '';
              qtyController.text = '';
            },
            child: const Text('Cancel')),
        TextButton(
            onPressed: () {
              itemkey != null
                  ? updateItem(itemkey, {
                      'name': nameController.text,
                      'quantity': qtyController.text
                    })
                  : addItem({
                      'name': nameController.text,
                      'quantity': qtyController.text
                    });
              Navigator.pop(context);
              nameController.text = '';
              qtyController.text = '';
            },
            child: Text(itemkey != null ? 'Update' : 'Add'))
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(hintText: 'Name'),
          ),
          TextFormField(
            controller: qtyController,
            decoration: const InputDecoration(hintText: 'Quantity'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) => _showAlertDialog(context, null));
        },
        child: const Text('Add'),
      ),
      body: ListView.builder(
          itemCount: mylist.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text('${mylist[index]['name']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) => _showAlertDialog(
                                context, mylist[index]['key']));
                      },
                      icon: const Icon(Icons.edit)),
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ))
                ],
              ),
            );
          }),
    );
  }
}
