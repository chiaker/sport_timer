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
      appBar: AppBar(title: const Text('Последовательности таймеров')),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<TimerSequence>(
          StorageService.sequencesBoxName,
        ).listenable(),
        builder: (context, Box<TimerSequence> box, _) {
          final sequences = box.values.toList(growable: false);
          if (sequences.isEmpty) {
            return const Center(
              child: Text('Нет сохранённых последовательностей'),
            );
          }
          return ListView.separated(
            itemCount: sequences.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final seq = sequences[index];
              return ListTile(
                title: Text(seq.name),
                subtitle: Text(
                  'Шагов: ${seq.steps.length} • Раунды: ${seq.rounds}',
                ),
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditSequenceScreen(existingSequence: seq),
                    ),
                  );
                  if (!context.mounted) return;
                  if (result == 'saved') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Все хорошо, сохранено')),
                    );
                  }
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.play_arrow),
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
                      icon: const Icon(Icons.delete_forever),
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
      floatingActionButton: FloatingActionButton(
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
        child: const Icon(Icons.add),
      ),
    );
  }
}
