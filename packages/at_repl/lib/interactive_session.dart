/// Base interface for interactive sessions in the REPL
abstract class InteractiveSession {
  /// Handle input from the user during the interactive session
  /// Returns true if input was handled, false if session should exit
  bool handleInput(String input);

  /// Get the current prompt to display to the user
  String getPrompt();

  /// Check if the session is still active
  bool get isActive;

  /// Exit the session and clean up resources
  void exit();
}
