import 'package:hive/hive.dart';
import '../models/timer_models.dart';

class StorageService {
  static const String sequencesBoxName = 'sequences_box';
  static late Box<TimerSequence> _sequencesBox;

  static Future<void> initialize() async {
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TimerStepAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(TimerSequenceAdapter());
    }
    _sequencesBox = await Hive.openBox<TimerSequence>(sequencesBoxName);
  }

  static List<TimerSequence> getAllSequences() {
    return _sequencesBox.values.toList(growable: false);
  }

  static Future<void> saveSequence(TimerSequence sequence) async {
    await _sequencesBox.put(sequence.id, sequence);
  }

  static Future<void> deleteSequence(String id) async {
    await _sequencesBox.delete(id);
  }

  static TimerSequence? getSequence(String id) {
    return _sequencesBox.get(id);
  }
}
