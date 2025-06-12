import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:provider/provider.dart';
import 'package:todo_app_with_firebase/models/todo.dart';
import 'package:todo_app_with_firebase/providers/auth_provider.dart';
import 'package:todo_app_with_firebase/providers/todo_provider.dart';

class TodoDetailScreen extends StatefulWidget {
  final Todo? todo;

  const TodoDetailScreen({Key? key, this.todo}) : super(key: key);

  @override
  _TodoDetailScreenState createState() => _TodoDetailScreenState();
}

class _TodoDetailScreenState extends State<TodoDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late DateTime _dueDate;
  late bool _isCompleted;

  @override
  void initState() {
    super.initState();
    _title = widget.todo?.title ?? '';
    _description = widget.todo?.description ?? '';
    _dueDate = widget.todo?.dueDate ?? DateTime.now().add(const Duration(days: 1));
    _isCompleted = widget.todo?.isCompleted ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final todoProvider = Provider.of<TodoProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          widget.todo == null ? 'Tambah Tugas' : 'Edit Tugas',
          style: TextStyle(color: Colors.white), // Warna teks judul
        ),
        iconTheme: IconThemeData(color: Colors.white), 
        actions: [
          if (widget.todo != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                todoProvider.deleteTodo(widget.todo!.id);
                Navigator.pop(context);
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(
                  labelText: 'Judul',
                  border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10), // Atur radius sesuai keinginan
                ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10), // Atur radius sesuai keinginan
                ),
                ),
                maxLines: 3,
                onSaved: (value) => _description = value ?? '',
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Tanggal Tenggat'),
                subtitle: Text(
                  '${_dueDate.day}/${_dueDate.month}/${_dueDate.year} ${_dueDate.hour}:${_dueDate.minute}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () {
                  DatePicker.showDateTimePicker(
                    context,
                    showTitleActions: true,
                    minTime: DateTime.now(),
                    onConfirm: (date) {
                      setState(() => _dueDate = date);
                    },
                    currentTime: _dueDate,
                  );
                },
              ),
              const SizedBox(height: 16),
              if (widget.todo != null)
                CheckboxListTile(
                  title: const Text('Selesai'),
                  value: _isCompleted,
                  activeColor: Colors.blue,   // Warna background checkbox saat dicentang
                  checkColor: Colors.white,   // Warna tanda centang
                  onChanged: (value) {
                    setState(() => _isCompleted = value!);
                  },
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Changed from primary to backgroundColor
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    final todo = Todo(
                      id: widget.todo?.id ?? '',
                      title: _title,
                      description: _description,
                      dueDate: _dueDate,
                      isCompleted: _isCompleted,
                      isSyncedWithCalendar: widget.todo?.isSyncedWithCalendar ?? false,
                      calendarEventId: widget.todo?.calendarEventId,
                    );

                    final authProvider = Provider.of<AuthProvider>(context, listen: false); // Dapatkan authProvider
                    if (widget.todo == null) {
                      await Provider.of<TodoProvider>(context, listen: false).addTodo(todo, authProvider.user!.uid); // Kirim userId
                    } else {
                      await Provider.of<TodoProvider>(context, listen: false).updateTodo(todo);
                    }

                    Navigator.pop(context);
                  }
                },
                child: Text(
                  widget.todo == null ? 'Simpan' : 'Update',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,  // Ganti dengan warna yang kamu inginkan
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}