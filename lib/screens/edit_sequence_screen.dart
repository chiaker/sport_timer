import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/timer_models.dart';
import '../services/storage.dart';

class EditSequenceScreen extends StatefulWidget {
  final TimerSequence? existingSequence;
  const EditSequenceScreen({super.key, this.existingSequence});

  @override
  State<EditSequenceScreen> createState() => _EditSequenceScreenState();
}

class _EditSequenceScreenState extends State<EditSequenceScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roundsController = TextEditingController(
    text: '1',
  );
  final List<TimerStep> _steps = [];

  @override
  void initState() {
    super.initState();
    if (widget.existingSequence != null) {
      final seq = widget.existingSequence!;
      _nameController.text = seq.name;
      _roundsController.text = seq.rounds.toString();
      _steps.addAll(seq.steps);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roundsController.dispose();
    super.dispose();
  }

  void _addStep() async {
    final step = await showDialog<TimerStep>(
      context: context,
      builder: (context) => const _EditStepDialog(),
    );
    if (step != null) {
      setState(() {
        _steps.add(step);
      });
    }
  }

  void _editStep(int index) async {
    final step = await showDialog<TimerStep>(
      context: context,
      builder: (context) => _EditStepDialog(initial: _steps[index]),
    );
    if (step != null) {
      setState(() {
        _steps[index] = step;
      });
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите название последовательности')),
      );
      return;
    }
    if (_steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Добавьте хотя бы один шаг')),
      );
      return;
    }
    final rounds = int.tryParse(_roundsController.text);
    if (rounds == null || rounds < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Раунды должны быть положительным целым числом'),
        ),
      );
      return;
    }
    final id = widget.existingSequence?.id ?? _generateId();
    final seq = TimerSequence(
      id: id,
      name: name,
      steps: List.of(_steps),
      rounds: rounds,
    );
    await StorageService.saveSequence(seq);
    if (!mounted) return;
    Navigator.pop(context, 'saved');
  }

  String _generateId() {
    final rand = Random();
    final millis = DateTime.now().millisecondsSinceEpoch;
    final randPart = rand.nextInt(0x7fffffff);
    return '${millis}_$randPart';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingSequence == null
              ? 'Новая последовательность'
              : 'Редактирование',
        ),
        actions: [IconButton(onPressed: _save, icon: const Icon(Icons.save))],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Название',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _roundsController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Раунды (повторы всей последовательности)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _steps.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = _steps.removeAt(oldIndex);
                  _steps.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final step = _steps[index];
                return Card(
                  key: ValueKey('step_$index'),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(step.colorValue),
                    ),
                    title: Text(
                      step.label,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(_formatSeconds(step.durationSeconds)),
                    trailing: Wrap(
                      spacing: 4,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editStep(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded),
                          onPressed: () {
                            setState(() {
                              _steps.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addStep,
        icon: const Icon(Icons.add),
        label: const Text('Добавить шаг'),
      ),
    );
  }

  String _formatSeconds(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

class _EditStepDialog extends StatefulWidget {
  final TimerStep? initial;
  const _EditStepDialog({this.initial});

  @override
  State<_EditStepDialog> createState() => _EditStepDialogState();
}

class _EditStepDialogState extends State<_EditStepDialog> {
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController(
    text: '0',
  );
  final TextEditingController _secondsController = TextEditingController(
    text: '30',
  );
  int _colorValue = Colors.blue.toARGB32();

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _labelController.text = widget.initial!.label;
      final total = widget.initial!.durationSeconds;
      _minutesController.text = (total ~/ 60).toString();
      _secondsController.text = (total % 60).toString();
      _colorValue = widget.initial!.colorValue;
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Новый шаг' : 'Редактировать шаг'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _labelController,
              decoration: const InputDecoration(
                labelText: 'Название шага',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minutesController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Минуты',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _secondsController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Секунды (0-59)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Цвет шага',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final c in [
                  Colors.blue,
                  Colors.green,
                  Colors.red,
                  Colors.orange,
                  Colors.purple,
                  Colors.teal,
                  Colors.amber,
                ])
                  GestureDetector(
                    onTap: () => setState(() => _colorValue = c.toARGB32()),
                    child: CircleAvatar(
                      backgroundColor: Color(c.toARGB32()),
                      child: _colorValue == c.toARGB32()
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () {
            final label = _labelController.text.trim();
            if (label.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Введите название шага')),
              );
              return;
            }
            final minutes = int.tryParse(_minutesController.text) ?? 0;
            final seconds = int.tryParse(_secondsController.text) ?? 0;
            if (seconds < 0 || seconds > 59) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Секунды должны быть в диапазоне 0–59'),
                ),
              );
              return;
            }
            if (minutes < 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Минуты не могут быть отрицательными'),
                ),
              );
              return;
            }
            final totalSeconds = minutes * 60 + seconds;
            if (totalSeconds <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Длительность шага должна быть больше 0'),
                ),
              );
              return;
            }
            Navigator.pop(
              context,
              TimerStep(
                label: label,
                durationSeconds: totalSeconds,
                colorValue: _colorValue,
              ),
            );
          },
          child: const Text('Сохранить'),
        ),
      ],
    );
  }
}
