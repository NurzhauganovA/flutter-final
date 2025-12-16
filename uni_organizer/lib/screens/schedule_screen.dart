import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/schedule_model.dart';
import '../providers/schedule_provider.dart';
import '../widgets/add_schedule_sheet.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  String _weekdayTitle(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = Provider.of<ScheduleProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => const AddScheduleSheet(),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<ScheduleItem>>(
        stream: scheduleProvider.scheduleStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_note, size: 90, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No classes yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first class to keep track of your timetable.',
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Group by weekday
          final Map<int, List<ScheduleItem>> byDay = {};
          for (final item in items) {
            byDay.putIfAbsent(item.weekday, () => []).add(item);
          }

          final sortedDays = byDay.keys.toList()..sort();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedDays.length,
            itemBuilder: (context, index) {
              final day = sortedDays[index];
              final dayItems = byDay[day]!..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      _weekdayTitle(day),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  ...dayItems!.map(
                    (item) => Dismissible(
                      key: Key(item.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        scheduleProvider.deleteScheduleItem(item.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Class removed from schedule')),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              item.timeRange.split('-')[0].trim(),
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                          title: Text(
                            item.subject,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${item.type} • ${item.timeRange}'),
                              if (item.location.isNotEmpty)
                                Text(
                                  item.location,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              if (item.teacher.isNotEmpty)
                                Text(
                                  item.teacher,
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              );
            },
          );
        },
      ),
    );
  }
}


