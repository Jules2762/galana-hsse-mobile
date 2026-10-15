import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_hsse/cores/services/sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('SyncAction serialization and deserialization', () {
    final now = DateTime.now();
    final action = SyncAction(
      id: 'test_1',
      type: 'VMC_STATUS',
      title: 'Clôture VMC #12',
      endpoint: '/home/vmcs/12/status',
      method: 'PATCH',
      payload: {'status': 'COMPLETED'},
      createdAt: now,
    );

    final json = action.toJson();
    final restored = SyncAction.fromJson(json);

    expect(restored.id, 'test_1');
    expect(restored.type, 'VMC_STATUS');
    expect(restored.title, 'Clôture VMC #12');
    expect(restored.endpoint, '/home/vmcs/12/status');
    expect(restored.method, 'PATCH');
    expect(restored.payload['status'], 'COMPLETED');
    expect(restored.createdAt.toIso8601String(), now.toIso8601String());
  });

  test('SyncService queue management', () async {
    final sync = SyncService.instance;
    await sync.clearQueue();

    expect(sync.pendingCount, 0);

    final action = SyncAction(
      id: 'act_101',
      type: 'EQUIPMENT_UPDATE',
      title: 'Contrôle EXT-P50-01',
      endpoint: '/home/equipments-monitoring/equipments/1',
      method: 'PUT',
      payload: {'tagNumber': 'EXT-P50-01', 'status': 'Conforme'},
      createdAt: DateTime.now(),
    );

    await sync.queueAction(action);
    expect(sync.hasPendingSyncFor('EXT-P50-01'), isTrue);
    expect(sync.hasPendingSyncFor('NON_EXISTENT'), isFalse);

    await sync.clearQueue();
    expect(sync.pendingCount, 0);
  });
}
