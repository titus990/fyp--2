import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'feedback_page.dart';

class ReflexTimerPage extends StatefulWidget {
  const ReflexTimerPage({super.key});

  @override
  State<ReflexTimerPage> createState() => _ReflexTimerPageState();
}

enum GameState {
  idle,       // Waiting to start
  sequence,   // Lights turning on 1 by 1
  ready,      // All 5 lights on, waiting for random delay
  go,         // Lights out! Timer running
  finished,   // User tapped, showing result
  falseStart  // User tapped too early
}

class _ReflexTimerPageState extends State<ReflexTimerPage> {
  GameState _gameState = GameState.idle;
  int _activeLights = 0; // 0 to 5
  Timer? _sequenceTimer;
  Timer? _randomStartTimer;
  DateTime? _startTime;
  Duration? _reactionTime;
  
  // Stats
  int? _bestTime;
  final List<int> _history = [];
  
  // F1 lights are usually 5
  final int _totalLights = 5;

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }

  void _cancelTimers() {
    _sequenceTimer?.cancel();
    _randomStartTimer?.cancel();
  }

  void _handleTap() {
    if (_gameState == GameState.idle || 
        _gameState == GameState.finished || 
        _gameState == GameState.falseStart) {
      _startSequence();
    } else if (_gameState == GameState.sequence || _gameState == GameState.ready) {
      // Tapped before lights went out!
      _triggerFalseStart();
    } else if (_gameState == GameState.go) {
      // Successful reaction
      _finishRace();
    }
  }

  void _startSequence() {
    _cancelTimers();
    setState(() {
      _gameState = GameState.sequence;
      _activeLights = 0;
      _reactionTime = null;
    });

    // Turn on lights one by one every second (standard F1 procedure is approx 1s)
    _sequenceTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _activeLights++;
      });

      if (_activeLights >= _totalLights) {
        timer.cancel();
        _waitForLightsOut();
      }
    });
  }

  void _waitForLightsOut() {
    setState(() {
      _gameState = GameState.ready;
    });

    // F1 lights go out between 0.2 and 3 seconds after the 5th light
    // We'll use a random duration between 200ms and 3000ms
    final randomMillis = 200 + Random().nextInt(2800);
    
    _randomStartTimer = Timer(Duration(milliseconds: randomMillis), () {
      _triggerLightsOut();
    });
  }

  void _triggerLightsOut() {
    if (!mounted) return;
    HapticFeedback.heavyImpact(); // Physical feedback for "Go!"
    setState(() {
      _activeLights = 0;
      _gameState = GameState.go;
      _startTime = DateTime.now();
    });
  }

  void _triggerFalseStart() {
    _cancelTimers();
    HapticFeedback.vibrate();
    setState(() {
      _gameState = GameState.falseStart;
      _activeLights = _totalLights; // Keep lights on to show they failed
    });
  }

  void _finishRace() {
    final now = DateTime.now();
    if (_startTime != null) {
      HapticFeedback.selectionClick();
      final difference = now.difference(_startTime!).inMilliseconds;
      setState(() {
        _reactionTime = Duration(milliseconds: difference);
        _gameState = GameState.finished;
        
        _history.insert(0, difference);
        if (_bestTime == null || difference < _bestTime!) {
          _bestTime = difference;
        }
      });
    }
  }

  Color _getLightColor(int lightIndex) {
    if (_gameState == GameState.falseStart) {
      return Colors.orange; // Aborted start color
    }
    
    if (lightIndex < _activeLights) {
      return Colors.red; // F1 lights are red
    }
    
    return const Color(0xFF333333); // Off state color
  }

  String _getStatusText() {
    switch (_gameState) {
      case GameState.idle:
        return "Tap to start";
      case GameState.sequence:
      case GameState.ready:
        return "Wait for lights out...";
      case GameState.go:
        return "TAP!";
      case GameState.falseStart:
        return "JUMP START!";
      case GameState.finished:
        return "${_reactionTime?.inMilliseconds} ms";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: const Text("Reflex Test"),
        backgroundColor: const Color(0xFF1A1F38),
        elevation: 0,
        actions: [
          IconButton(
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.rate_review,
                color: Colors.white,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FeedbackPage(
                    moduleType: 'reflex_timer',
                    moduleName: 'Reflex Timer',
                  ),
                ),
              );
            },
            tooltip: 'Module Feedback',
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Best Time Display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            color: const Color(0xFF1A1F38),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
                const SizedBox(width: 10),
                Text(
                  "BEST: ${_bestTime != null ? '$_bestTime ms' : '--'}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Main Game Area
          Expanded(
            child: GestureDetector(
              onTapDown: (_) => _handleTap(),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Lights Container
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(_totalLights, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 50),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getLightColor(index),
                            boxShadow: _getLightColor(index) != const Color(0xFF333333)
                                ? [
                                    BoxShadow(
                                      color: _getLightColor(index).withOpacity(0.6),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    )
                                  ]
                                : [],
                          ),
                        );
                      }),
                    ),
                  ),
                  
                  const SizedBox(height: 60),

                  // Status Text
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Text(
                      _getStatusText(),
                      key: ValueKey(_gameState),
                      style: TextStyle(
                        color: _gameState == GameState.falseStart 
                            ? Colors.orange 
                            : _gameState == GameState.go 
                                ? Colors.greenAccent 
                                : Colors.white,
                        fontSize: _gameState == GameState.finished ? 50 : 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // History Panel (Bottom Sheet style)
          Container(
            height: 150,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF1A1F38),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    "Recent Attempts",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: _history.isEmpty
                      ? Center(
                          child: Text(
                            "No attempts yet",
                            style: TextStyle(color: Colors.white.withOpacity(0.3)),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: _history.length,
                          itemBuilder: (context, index) {
                            final time = _history[index];
                            final isBest = time == _bestTime;
                            return Container(
                              margin: const EdgeInsets.only(right: 12, bottom: 20),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isBest 
                                    ? Colors.amber.withOpacity(0.2) 
                                    : Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isBest 
                                      ? Colors.amber.withOpacity(0.5) 
                                      : Colors.transparent,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "$time",
                                    style: TextStyle(
                                      color: isBest ? Colors.amber : Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "ms",
                                    style: TextStyle(
                                      color: isBest 
                                          ? Colors.amber.withOpacity(0.7) 
                                          : Colors.white.withOpacity(0.5),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
