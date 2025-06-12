import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:todo_app_with_firebase/models/todo.dart';
import 'package:todo_app_with_firebase/providers/todo_provider.dart';
import 'package:todo_app_with_firebase/screens/todo_detail_screen.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;

  const TodoItem({required this.todo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Slidable(
        key: Key(todo.id),
        endActionPane: ActionPane(
          motion: ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) {
                Provider.of<TodoProvider>(context, listen: false)
                    .deleteTodo(todo.id);
              },
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Hapus',
            ),
          ],
        ),
        child: Card(
          color: Colors.white, 
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: Checkbox(
              value: todo.isCompleted,
              onChanged: (value) {
                Provider.of<TodoProvider>(context, listen: false)
                    .toggleTodoCompletion(todo.id);
              },
              shape: CircleBorder(),
              activeColor: Colors.blue,    // Warna background checkbox saat dicentang
              checkColor: Colors.white,
            ),
            title: Text(
              todo.title,
              style: TextStyle(
                decoration: todo.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            subtitle: Text(
              '${todo.dueDate.day}/${todo.dueDate.month}/${todo.dueDate.year}',
            ),
            trailing: todo.isSyncedWithCalendar
                ? Icon(Icons.calendar_today, color: Colors.blue)
                : null,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TodoDetailScreen(todo: todo),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}