abstract class PreferencesRepository {
  // String preferences
  Future<String?> getString(String key);
  Future<bool> setString(String key, String value);

  // Boolean preferences
  Future<bool?> getBool(String key);
  Future<bool> setBool(String key, bool value);

  // Integer preferences
  Future<int?> getInt(String key);
  Future<bool> setInt(String key, int value);

  // Double preferences
  Future<double?> getDouble(String key);
  Future<bool> setDouble(String key, double value);

  // List preferences
  Future<List<String>?> getStringList(String key);
  Future<bool> setStringList(String key, List<String> value);

  // Remove preferences
  Future<bool> remove(String key);
  Future<bool> clear();

  // Check if key exists
  Future<bool> containsKey(String key);

  // Get all keys
  Future<Set<String>> getKeys();

  // Batch operations
  Future<bool> setBatch(Map<String, dynamic> data);
  Future<Map<String, dynamic>> getBatch(List<String> keys);
}