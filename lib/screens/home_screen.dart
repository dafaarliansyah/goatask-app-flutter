import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:todo_app_with_firebase/models/todo.dart';
import 'package:todo_app_with_firebase/providers/auth_provider.dart';
import 'package:todo_app_with_firebase/providers/todo_provider.dart';
import 'package:todo_app_with_firebase/screens/todo_detail_screen.dart';
import 'package:todo_app_with_firebase/widgets/todo_item.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
  }

  // Fungsi untuk melakukan pencarian
  List<Todo> _searchTodos(List<Todo> todos, String query) {
    if (query.isEmpty) {
      return todos;
    }
    return todos
        .where((todo) =>
            todo.title.toLowerCase().contains(query.toLowerCase()) ||
            todo.description.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final todoProvider = Provider.of<TodoProvider>(context);

    // Ambil daftar todos dari provider
    final todos = todoProvider.todos.toList(); // buat salinan

    // Sort supaya yang belum selesai di atas, yang sudah selesai di bawah
      todos.sort((a, b) {
      if (a.isCompleted == b.isCompleted) {
        if (!a.isCompleted) {
          // Keduanya belum selesai, urutkan berdasarkan dueDate ascending (terdekat paling atas)
          return a.dueDate.compareTo(b.dueDate);
        } else {
          // Keduanya sudah selesai, bisa diurutkan bebas (misal berdasarkan dueDate juga)
          return a.dueDate.compareTo(b.dueDate);
        }
      }
      // yang sudah selesai (isCompleted==true) taruh di bawah (return 1 untuk a)
      if (a.isCompleted) return 1;
      return -1;
    });

    // Lakukan pencarian berdasarkan _searchQuery pada list yang sudah di-sort
    final searchedTodos = _searchTodos(todos, _searchQuery);


    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Tugas Saya',
          style: TextStyle(color: Colors.white), // Warna teks
        ),
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white), 
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).signOut(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari tugas...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchedTodos.length,
              itemBuilder: (context, index) {
                final todo = searchedTodos[index];
                return TodoItem(todo: todo);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue, // Warna background FAB
        foregroundColor: Colors.white, // Warna icon di dalam FAB
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TodoDetailScreen(),
            ),
          );
        },
      ),
    );
  }
}