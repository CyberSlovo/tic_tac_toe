import 'package:flutter/material.dart';
import 'package:tic_tac_toe/infrastructure/data/todo_item.dart';
import 'package:tic_tac_toe/infrastructure/data/todo_list.dart';
import 'package:localstorage/localstorage.dart';

class LocalStoragePage extends StatefulWidget {
  const LocalStoragePage({Key? key}) : super(key: key);

  @override
  _LocalStoragePageState createState() => _LocalStoragePageState();
}

class _LocalStoragePageState extends State<LocalStoragePage> {
  final list =  TodoList();
  late LocalStorage storage;
  bool initialized = false;
  final controller = TextEditingController();
  
  @override
  void initState() {
    storage = LocalStorage('todo_app');
    super.initState();
  }

  _toggleItem(TodoItem item) {
    setState(() {
      item.done = !item.done;
      _saveToStorage();
    });
  }

  _addItem(String title) {
    setState(() {
      final item = TodoItem(title: title, done: false);
      list.items.add(item);
      _saveToStorage();
    });
  }

  _saveToStorage() {
    storage.setItem('todos', list.toJSONEncodable());
  }

  _clearStorage() async {
    await storage.clear();

    setState(() {
      list.items = storage.getItem('todos') ?? [];
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local storage demo'),
      ),
      body: Container(
        padding: const EdgeInsets.all(10.0),
        constraints: const BoxConstraints.expand(),
        child: FutureBuilder(
          future: storage.ready,
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.data == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (!initialized) {
              var items = storage.getItem('todos');

              if (items != null) {
                list.items = List<TodoItem>.from(
                  (items as List).map(
                        (item) => TodoItem(
                      title: item['title'],
                      done: item['done'],
                    ),
                  ),
                );
              }

              initialized = true;
            }

            List<Widget> widgets = list.items.map((item) {
              return CheckboxListTile(
                value: item.done,
                title: Text(item.title),
                selected: item.done,
                onChanged: (_) {
                  _toggleItem(item);
                },
              );
            }).toList();

            return Column(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: ListView(
                    children: widgets,
                    itemExtent: 50.0,
                  ),
                ),
                ListTile(
                  title: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'What to do?',
                    ),
                    onEditingComplete: _save,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.save),
                        onPressed: _save,
                        tooltip: 'Save',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: _clearStorage,
                        tooltip: 'Clear storage',
                      )
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _save() {
    _addItem(controller.value.text);
    controller.clear();
  }
}
