part of command_line_interface;

/// A function that handles a [KeyboardEvent].
typedef bool KeyboardEventHandler(KeyboardEvent event);

/// Handles the binding and unbinding of any key strokes the CLI wants to
/// capture and use.
class KeyBindingManager {
  /// A map of all the [KeyGesture]s that are being handled by the
  /// [KeyBindingManager].
  Map<KeyGesture, KeyboardEventHandler> bindings = new Map();
  StreamSubscription _windowOnKeyDownSubscription;

  /// `true` if the [KeyBindingManger] is capturing user input, otherwise
  /// `false`.
  bool get active => _active;
  bool _active = false;

  /// Returns the number of consecutive presses of the Tab key. Used for
  /// line completion in the shell.
  int get consecutiveTabPresses => _consecutiveTabPresses;
  int _consecutiveTabPresses = 0;

  /// Constructs and initializes a new [KeyBindingManager].
  KeyBindingManager() {
    initialize();
  }

  /// When activated, the [KeyBindingManager] will handle user input if it
  /// has a registered keybinding for the key that was pressed.
  activate() => _active = true;

  /// When deactivated, the [KeyBindingManager] will not handle user input.
  deactivate() => _active = false;

  /// Initializes the window keydown listener.
  initialize() {
    _windowOnKeyDownSubscription = window.onKeyDown.listen(_handleKeyDown);
  }

  /// Stops listening to user keydown events entirely.
  void dispose() {
    _active = false;
    _windowOnKeyDownSubscription?.cancel();
    _windowOnKeyDownSubscription = null;
  }

  void _handleKeyDown(KeyboardEvent event) {
    if (!active) return;
    querySelector('#${CLI.STANDARD_INPUT}')?.focus();
    bindings.keys.where((gesture) => gesture.matches(event)).forEach((gesture) {
      if (new KeyGesture(KeyCode.TAB).matches(event)) {
        _consecutiveTabPresses++;
      } else {
        _consecutiveTabPresses = 0;
      }
      if (bindings[gesture](event)) return;
    });
  }
}
