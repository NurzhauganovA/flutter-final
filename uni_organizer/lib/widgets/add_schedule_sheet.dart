import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/schedule_provider.dart';

class AddScheduleSheet extends StatefulWidget {
  const AddScheduleSheet({super.key});

  @override
  State<AddScheduleSheet> createState() => _AddScheduleSheetState();
}

class _AddScheduleSheetState extends State<AddScheduleSheet> {
  final _subjectController = TextEditingController();
  final _locationController = TextEditingController();
  final _teacherController = TextEditingController();
  String _type = 'Lecture';
  int _weekday = 1;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 30);

  final List<String> _types = ['Lecture', 'Lab', 'Seminar', 'Practice'];
  final List<String> _weekdaysTitles = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  Future<void> _pickTime({required bool isStart}) async {
    final initial = isStart ? _startTime : _endTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  Future<void> _submit() async {
    if (_subjectController.text.trim().isEmpty) return;

    final startMinutes = _toMinutes(_startTime);
    final endMinutes = _toMinutes(_endTime);
    if (endMinutes <= startMinutes) return;

    await context.read<ScheduleProvider>().addScheduleItem(
          subject: _subjectController.text.trim(),
          type: _type,
          location: _locationController.text.trim(),
          teacher: _teacherController.text.trim(),
          weekday: _weekday,
          startMinutes: startMinutes,
          endMinutes: endMinutes,
        );

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Add Class to Schedule',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject',
                prefixIcon: Icon(Icons.book),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _type,
                    decoration: const InputDecoration(
                      labelText: 'Type',
                    ),
                    items: _types
                        .map((t) =>
                            DropdownMenuItem<String>(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _type = val;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _weekday,
                    decoration: const InputDecoration(
                      labelText: 'Day',
                    ),
                    items: List.generate(
                      7,
                      (index) => DropdownMenuItem<int>(
                        value: index + 1,
                        child: Text(_weekdaysTitles[index]),
                      ),
                    ),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _weekday = val;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickTime(isStart: true),
                    icon: const Icon(Icons.schedule),
                    label: Text(
                        'From ${_startTime.format(context)}'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickTime(isStart: false),
                    icon: const Icon(Icons.schedule_outlined),
                    label: Text(
                        'To ${_endTime.format(context)}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location (room, building)',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _teacherController,
              decoration: const InputDecoration(
                labelText: 'Teacher (optional)',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}


