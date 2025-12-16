import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';

class AddTaskSheet extends StatefulWidget {
  const AddTaskSheet({super.key});

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  // Функция выбора даты
  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Функция сохранения
  void _submitData() {
    if (_titleController.text.isEmpty) return;

    // Вызываем провайдер для сохранения в Firebase
    context.read<TaskProvider>().addTask(
      _titleController.text,
      _descController.text,
      _selectedDate,
    );

    Navigator.of(context).pop(); // Закрываем окно
  }

  @override
  Widget build(BuildContext context) {
    // Padding для того, чтобы клавиатура не перекрывала поля
    return Padding(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Add New Task',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
          ),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
            autofocus: true,
          ),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(labelText: 'Description (optional)'),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text('Date: ${DateFormat('yMMMd').format(_selectedDate)}'),
              const Spacer(),
              TextButton(
                onPressed: _pickDate,
                child: const Text('Choose Date', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitData,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[800],
              foregroundColor: Colors.white,
            ),
            child: const Text('Add Task'),
          ),
        ],
      ),
    );
  }
}