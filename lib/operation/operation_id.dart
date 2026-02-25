///
/// Реестр всех операций для бэкенда
enum OperationId {
  deviceInfo(20),
  deviceDoc(24),
  temperature(32),
  filePdf(36),
  fileHtml(36);
  // Holds a numeric representation
  final int value;
  /// Returns [OperationId] new instance
  const OperationId(this.value);
  // Serch and retirns by Id
  static OperationId? fromInt(int id) {
    return OperationId.values.cast<OperationId?>().firstWhere(
      (e) => e?.value == id, 
      orElse: () => null,
    );
  }
}
