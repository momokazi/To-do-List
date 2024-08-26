import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<Map<String, dynamic>> _todoItems = [];

  @override
  void initState() {
    super.initState();
    _loadTodoItems();
  }

  void _loadTodoItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      List<String>? stringList = prefs.getStringList('todoItems');
      if (stringList != null) {
        _todoItems = stringList
            .map((item) => json.decode(item) as Map<String, dynamic>)
            .toList();
      }
    });
  }

  void _saveTodoItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> stringList =
        _todoItems.map((item) => json.encode(item)).toList();
    prefs.setStringList('todoItems', stringList);
  }

  void _addTodoItem(String item) {
    if (item.isNotEmpty) {
      setState(() {
        _todoItems.add({'task': item, 'completed': false});
      });
      _saveTodoItems();
    }
  }

  void _editTodoItem(int index, String item) {
    if (item.isNotEmpty) {
      setState(() {
        _todoItems[index]['task'] = item;
      });
      _saveTodoItems();
    }
  }

  void _deleteTodoItem(int index) {
    setState(() {
      _todoItems.removeAt(index);
    });
    _saveTodoItems();
  }

  void _toggleTodoItem(int index) {
    setState(() {
      _todoItems[index]['completed'] = !_todoItems[index]['completed'];
    });
    _saveTodoItems();
  }

  void _displayAddTodoDialog() {
    TextEditingController _textFieldController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add a new to-do item'),
          content: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: 'Enter your task here'),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () {
                _addTodoItem(_textFieldController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _displayEditTodoDialog(int index) {
    TextEditingController _textFieldController = TextEditingController();
    _textFieldController.text = _todoItems[index]['task'];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit to-do item'),
          content: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: 'Enter your task here'),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                _editTodoItem(index, _textFieldController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _displayDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete to-do item'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Delete'),
              onPressed: () {
                _deleteTodoItem(index);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "To-Do List",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: const Color.fromARGB(255, 27, 146, 243),
      ),
      body: _buildTodoList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _displayAddTodoDialog,
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTodoList() {
    return ListView.builder(
      itemCount: _todoItems.length,
      itemBuilder: (context, index) {
        return _buildTodoItem(_todoItems[index], index);
      },
    );
  }

  Widget _buildTodoItem(Map<String, dynamic> todoItem, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: ListTile(
        leading: CircleAvatar(
          child: Text('${index + 1}'),
        ),
        title: Text(
          todoItem['task'],
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            decoration: todoItem['completed']
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.check),
              color: todoItem['completed'] ? Colors.green : Colors.grey,
              onPressed: () => _toggleTodoItem(index),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _displayEditTodoDialog(index),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _displayDeleteConfirmationDialog(index),
            ),
          ],
        ),
      ),
    );
  }
}
