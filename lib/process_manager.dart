library process_manager;

import 'dart:async';
import 'dart:html';
import 'dart:math' show Random;

import 'package:browser_cli/utils.dart' as utils;

part 'src/process_manager/process.dart';

/// Manages the starting, stopping, and manipulation of all processes in the
/// shell.
class ProcessManager {
  /// The randomizer seed for all pseudo-random operations.
  int get randSeed => _randSeed;
  Random _rand;
  int _randSeed;

  /// A [Map] of all processes that are currently running, with the key being
  /// the process id.
  Map<int, Process> get processes => _processes;
  Map<int, Process> _processes = new Map();

  /// The [Stream] of [DivElement] objects that should be output to the shell.
  Stream<DivElement> get onOutput => _outputStreamController.stream;
  Map<int, StreamSubscription> _outputSubscriptions = new Map();
  StreamController<DivElement> _outputStreamController = new StreamController();

  /// Indicates to the command line interface to get input from the user. If
  /// the value is `true`, the input is being requested by the process. If
  /// `false`, it is handled normally by the command line interface.
  Stream<bool> get onTriggerInput => _triggerInputStreamController.stream;
  StreamController<bool> _triggerInputStreamController = new StreamController();

  Map<String, ProcessFactory> _registeredProcessFactories = new Map();

  /// Constructs a new [ProcessManager] with the given randomizer seed. If a
  /// randomizer seed is not provided, one will be created at random.
  ProcessManager({int randomizerSeed}) {
    _randSeed = randomizerSeed ?? new Random().nextInt(utils.MAX_INT);
    _rand = new Random(_randSeed);
  }

  /// Starts a process in the shell.
  bool startProcess(String command, {List args}) {
    var id = _generateId();
    var arguments = args ?? [];
    var process =
        _registeredProcessFactories[command]?.createProcess(id, arguments);
    if (process == null) {
      throw new Exception('$command: command not found');
    }
    processes[id] = process;
    _outputSubscriptions[id] = process.outputStream.listen((output) {
      _handleProcessOutput(id, output);
    });
    process.start().then((_) {
      _triggerInputStreamController.add(false);
    });
    return true;
  }

  /// Kills a running process
  bool killProcess(int processId) {
    if (processes.keys.contains(processId) && processes[processId] != null) {
      processes[processId].kill().then((_) {
        _triggerInputStreamController.add(false);
      });
      return true;
    } else {
      return false;
    }
  }

//  bool bringToForeground(int processId) {
//    // TODO v2.0.0
//    return false;
//  }

//  bool sendToBackground(int processId) {
//    // TODO: v2.0.0
//    return false;
//  }

  /// Used to register every type of process that can be started in the shell.
  registerProcessFactories(List<ProcessFactory> factories) {
    factories.forEach((factory) {
      _registeredProcessFactories[factory.command] = factory;
    });
  }

  _handleProcessOutput(int id, DivElement output) {
    if (processes[id].inForeground) {
      _outputStreamController.add(output);
    }
  }

  int _generateId() {
    var id = _rand.nextInt(utils.MAX_INT);
    var attempts = 0;
    while (processes.keys.contains(id)) {
      id = _rand.nextInt(utils.MAX_INT);
      if (attempts++ > 5000) {
        throw new Exception(
            'Too many attempts trying to create unique process id');
      }
    }
    return id;
  }
}
