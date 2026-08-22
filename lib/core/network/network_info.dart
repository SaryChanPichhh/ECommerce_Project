/// Abstraction for checking network connectivity.
class NetworkInfo {
  /// Check if the device is connected to the internet.
  /// In production, you might use connectivity_plus package.
  Future<bool> get isConnected async {
    // Simplified implementation — in production, use connectivity_plus.
    return true;
  }
}
