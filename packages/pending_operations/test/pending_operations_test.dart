import 'package:pending_operations/pending_operations.dart';
import 'package:test/test.dart';

void main() {
  test('Counts pending operations', () async {
    final pendingOperations = PendingOperations();

    final done = pendingOperations.registerPendingOperation('test');

    expect(pendingOperations.pendingCalls, 1);
    expect(pendingOperations.ongoingOperationsDescription(), 'test');

    done();
    await pendingOperations.awaitEndOfKnownCalls();

    expect(pendingOperations.pendingCalls, 0);
  });
}
