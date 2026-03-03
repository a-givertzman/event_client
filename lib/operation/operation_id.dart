///
/// Реестр всех операций для бэкенда с соответствующими путями (именами событий)
enum OperationId {
  sysDiag(00),
  deviceInfo(20),
  deviceDoc(24),
  temperature(32),
  torque(36),
  pressureState(40),
  motorSpeed(44),
  motorCurrent(48),
  filePdf(100),
  fileHtml(104),
  /// Internal Operation, means no data, nothung to do, isn't expected from the backend
  operationEmpty(10_002),
  /// Internal Operation, means a failure, isn't expected from the backend
  operationFail(10_004);
  // Holds a numeric representation
  final int value;
  /// Returns [OperationId] new instance
  const OperationId(this.value);
  // Serch and retirns by Id
  static OperationId? fromInt(int val) {
    return OperationId.values.cast<OperationId?>().firstWhere(
      (e) => e?.value == val, 
      orElse: () => null,
    );
  }
}
