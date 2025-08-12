import 'package:hive/hive.dart';

class TimerStep {
  final String label;
  final int durationSeconds;
  final int colorValue;

  const TimerStep({
    required this.label,
    required this.durationSeconds,
    required this.colorValue,
  });
}

class TimerSequence {
  final String id;
  final String name;
  final List<TimerStep> steps;
  final int rounds;

  const TimerSequence({
    required this.id,
    required this.name,
    required this.steps,
    this.rounds = 1,
  });

  TimerSequence copyWith({
    String? id,
    String? name,
    List<TimerStep>? steps,
    int? rounds,
  }) {
    return TimerSequence(
      id: id ?? this.id,
      name: name ?? this.name,
      steps: steps ?? this.steps,
      rounds: rounds ?? this.rounds,
    );
  }
}

class TimerStepAdapter extends TypeAdapter<TimerStep> {
  @override
  final int typeId = 1;

  @override
  TimerStep read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return TimerStep(
      label: fields[0] as String,
      durationSeconds: fields[1] as int,
      colorValue: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TimerStep obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.label)
      ..writeByte(1)
      ..write(obj.durationSeconds)
      ..writeByte(2)
      ..write(obj.colorValue);
  }
}

class TimerSequenceAdapter extends TypeAdapter<TimerSequence> {
  @override
  final int typeId = 2;

  @override
  TimerSequence read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return TimerSequence(
      id: fields[0] as String,
      name: fields[1] as String,
      steps: (fields[2] as List).cast<TimerStep>(),
      rounds: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TimerSequence obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.steps)
      ..writeByte(3)
      ..write(obj.rounds);
  }
}
