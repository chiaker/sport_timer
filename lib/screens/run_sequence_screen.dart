import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../models/timer_models.dart';

class RunSequenceScreen extends StatefulWidget {
  final TimerSequence sequence;
  const RunSequenceScreen({super.key, required this.sequence});

  @override
  State<RunSequenceScreen> createState() => _RunSequenceScreenState();
}

class _RunSequenceScreenState extends State<RunSequenceScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentStepIndex = 0;
  int _currentRound = 1;
  bool _isRunning = false;

  TimerStep get _currentStep => widget.sequence.steps[_currentStepIndex];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _currentStep.durationSeconds),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _advance();
      }
    });
    _controller.addListener(() {
      // Rebuild for smooth progress and remaining time
      if (mounted) setState(() {});
    });
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    _controller.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  void _start() {
    if (_isRunning) return;
    setState(() => _isRunning = true);
    _controller.forward();
  }

  void _pause() {
    _controller.stop();
    setState(() => _isRunning = false);
  }

  void _reset() {
    _controller.stop();
    setState(() {
      _isRunning = false;
      _currentRound = 1;
      _currentStepIndex = 0;
      _controller.duration = Duration(seconds: _currentStep.durationSeconds);
      _controller.value = 0;
    });
  }

  void _advance() {
    if (_currentStepIndex < widget.sequence.steps.length - 1) {
      setState(() {
        _currentStepIndex += 1;
        _controller.duration = Duration(seconds: _currentStep.durationSeconds);
        _controller.value = 0;
      });
      if (_isRunning) _controller.forward();
    } else {
      if (_currentRound < widget.sequence.rounds) {
        setState(() {
          _currentRound += 1;
          _currentStepIndex = 0;
          _controller.duration = Duration(
            seconds: _currentStep.durationSeconds,
          );
          _controller.value = 0;
        });
        if (_isRunning) _controller.forward();
      } else {
        _controller.stop();
        setState(() => _isRunning = false);
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Готово!')));
      }
    }
  }

  void _prev() {
    if (_currentStepIndex > 0) {
      setState(() {
        _currentStepIndex -= 1;
        _controller.duration = Duration(seconds: _currentStep.durationSeconds);
        _controller.value = 0;
      });
      if (_isRunning) _controller.forward();
    }
  }

  String _format(int s) {
    final m = s ~/ 60;
    final ss = s % 60;
    return '${m.toString().padLeft(2, '0')}:${ss.toString().padLeft(2, '0')}';
  }

  double _progress() {
    return _controller.value.clamp(0.0, 1.0);
  }

  int _remainingSeconds() {
    final total = _currentStep.durationSeconds;
    final elapsed = (total * _controller.value).floor();
    final remaining = total - elapsed;
    return remaining.clamp(0, total);
  }

  @override
  Widget build(BuildContext context) {
    final step = _currentStep;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.sequence.name} • Раунд $_currentRound/${widget.sequence.rounds}',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: Color(step.colorValue).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      step.label,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _format(_remainingSeconds()),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Color(step.colorValue),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(value: _progress()),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 40,
                  icon: const Icon(Icons.skip_previous),
                  onPressed: _prev,
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _isRunning ? _pause : _start,
                  icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                  label: Text(_isRunning ? 'Пауза' : 'Старт'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  iconSize: 40,
                  icon: const Icon(Icons.skip_next),
                  onPressed: _advance,
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.stop_circle_outlined),
              label: const Text('Сброс'),
            ),
            const Spacer(),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                for (int i = 0; i < widget.sequence.steps.length; i++)
                  Chip(
                    label: Text(widget.sequence.steps[i].label),
                    backgroundColor: i == _currentStepIndex
                        ? Color(
                            widget.sequence.steps[i].colorValue,
                          ).withValues(alpha: 0.3)
                        : null,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
