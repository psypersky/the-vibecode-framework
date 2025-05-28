import 'package:mobx/mobx.dart';

part 'base_store-example.g.dart';

abstract class BaseStore = _BaseStoreBase with _$BaseStore;

abstract class _BaseStoreBase with Store {
  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  bool hasError = false;

  @action
  void setLoading(bool loading) {
    isLoading = loading;
    if (loading) {
      clearError();
    }
  }

  @action
  void setError(String error) {
    errorMessage = error;
    hasError = true;
    isLoading = false;
  }

  @action
  void clearError() {
    errorMessage = null;
    hasError = false;
  }

  @computed
  bool get canExecuteActions => !isLoading && !hasError;

  Future<T> executeWithLoading<T>(Future<T> Function() operation) async {
    try {
      setLoading(true);
      final result = await operation();
      setLoading(false);
      return result;
    } catch (e) {
      setError(e.toString());
      rethrow;
    }
  }

  void dispose() {
    // Override in subclasses to dispose resources
  }
}