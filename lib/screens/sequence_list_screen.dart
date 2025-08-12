import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/timer_models.dart';
import '../services/storage.dart';
import 'edit_sequence_screen.dart';
import 'run_sequence_screen.dart';

class SequenceListScreen extends StatefulWidget {
  const SequenceListScreen({super.key});

  @override
  State<SequenceListScreen> createState() => _SequenceListScreenState();
}

class _SequenceListScreenState extends State<SequenceListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text('Тренировки'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: ValueListenableBuilder(
          valueListenable: Hive.box<TimerSequence>(
            StorageService.sequencesBoxName,
          ).listenable(),
          builder: (context, Box<TimerSequence> box, _) {
            final sequences = box.values.toList(growable: false);
            if (sequences.isEmpty) {
              return const Center(
                child: Text(
                  'Нет сохранённых последовательностей',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              );
            }
            return ListView.separated(
              itemCount: sequences.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
              itemBuilder: (context, index) {
                final seq = sequences[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.15),
                    child: Text(
                      '${seq.steps.length}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  title: Text(
                    seq.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Шагов: ${seq.steps.length} • Раунды: ${seq.rounds}',
                  ),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            EditSequenceScreen(existingSequence: seq),
                      ),
                    );
                    if (!context.mounted) return;
                    if (result == 'saved') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Все хорошо, сохранено')),
                      );
                    }
                  },
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      IconButton(
                        tooltip: 'Запустить',
                        icon: const Icon(Icons.play_arrow_rounded),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RunSequenceScreen(sequence: seq),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        tooltip: 'Удалить',
                        icon: const Icon(Icons.delete_outline_rounded),
                        onPressed: () async {
                          await StorageService.deleteSequence(seq.id);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditSequenceScreen()),
          );
          if (!context.mounted) return;
          if (result == 'saved') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Все хорошо, сохранено')),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Новая'),
      ),
    );
  }
}
