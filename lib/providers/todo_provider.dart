import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_app_with_firebase/models/todo.dart';
import 'package:todo_app_with_firebase/services/calendar_service.dart'; // Import calendar_service.dart

class TodoProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Todo> _todos = [];

  List<Todo> get todos => _todos;

  Future<void> fetchTodos(String userId) async {
    print('fetchTodos() dipanggil dengan userId: $userId');
    try {
      final snapshot = await _firestore
          .collection('todos')
          .where('userId', isEqualTo: userId)
          .orderBy('dueDate')
          .get();

      _todos = snapshot.docs
          .map((doc) => Todo.fromMap(doc.data(), doc.id))
          .toList();

      print('Jumlah todo yang diambil: ${_todos.length}');
      notifyListeners();
    } catch (e) {
      print('Error fetching todos: $e');
    }
  }

  Future<void> addTodo(Todo todo, String userId) async {
    try {
      final docRef = await _firestore.collection('todos').add({
        ...todo.toMap(),
        'userId': userId,
      });

      final newTodo = Todo(
        id: docRef.id,
        title: todo.title,
        description: todo.description,
        dueDate: todo.dueDate,
        isCompleted: todo.isCompleted,
        isSyncedWithCalendar: todo.isSyncedWithCalendar,
        calendarEventId: todo.calendarEventId,
      );

      _todos.add(newTodo);
      notifyListeners();

      // Tambahkan event ke Google Calendar
      await addEventToCalendar(newTodo);

    } catch (e) {
      print('Error adding todo: $e');
    }
  }

  Future<void> updateTodo(Todo todo) async {
    try {
      await _firestore.collection('todos').doc(todo.id).update(todo.toMap());

      final index = _todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        _todos[index] = todo;
        notifyListeners();

        // Update event di Google Calendar
        await updateEventInCalendar(todo);
      }
    } catch (e) {
      print('Error updating todo: $e');
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      // Dapatkan todo sebelum dihapus
      final todo = _todos.firstWhere((t) => t.id == id);

      await _firestore.collection('todos').doc(id).delete();
      _todos.removeWhere((todo) => todo.id == id);
      notifyListeners();

      // Hapus event dari Google Calendar
      if (todo.calendarEventId != null) {
        await deleteEventFromCalendar(todo.calendarEventId!);
      }
    } catch (e) {
      print('Error deleting todo: $e');
    }
  }


  Future<void> toggleTodoCompletion(String id) async {
    try {
      final todo = _todos.firstWhere((t) => t.id == id);
      final updatedTodo = Todo(
        id: todo.id,
        title: todo.title,
        description: todo.description,
        dueDate: todo.dueDate,
        isCompleted: !todo.isCompleted,
        isSyncedWithCalendar: todo.isSyncedWithCalendar,
        calendarEventId: todo.calendarEventId,
      );

      await updateTodo(updatedTodo);
    } catch (e) {
      print('Error toggling todo completion: $e');
    }
  }

  void clearTodos() {
    print('clearTodos() dipanggil');
    _todos = [];
    notifyListeners();
  }
}