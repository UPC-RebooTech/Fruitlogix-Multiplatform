import '../domain/lot_timeline.dart';

/// Demo lots of the demo orders (same lots as Incidents: ORD-1042 →
/// LOT-2391, ORD-1040 → LOT-2388, ORD-1036 → LOT-2374).
class DemoLotRecords implements LotRecordSource {
  DemoLotRecords({DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;

  @override
  LotRecord? forOrder(String orderCode) {
    final now = _clock();
    DateTime at(int days, int hour, int minute) =>
        DateTime(now.year, now.month, now.day + days, hour, minute);
    return switch (orderCode) {
      'ORD-1042' => LotRecord(
        lotCode: 'LOT-2391',
        harvestedAt: at(-4, 5, 30),
        harvestedBy: 'Agrícola San José',
        inspectedAt: at(-3, 10, 15),
        inspectedBy: 'QC · Ana Torres',
        inspectionResult: InspectionResult.approved,
        loadedAt: at(0, 6, 0),
      ),
      'ORD-1040' => LotRecord(
        lotCode: 'LOT-2388',
        harvestedAt: at(-1, 7, 0),
        harvestedBy: 'Agrícola San José',
      ),
      'ORD-1036' => LotRecord(
        lotCode: 'LOT-2374',
        harvestedAt: at(-13, 6, 45),
        harvestedBy: 'Agrícola San José',
        inspectedAt: at(-12, 9, 30),
        inspectedBy: 'QC · Ana Torres',
        inspectionResult: InspectionResult.approved,
        loadedAt: at(-10, 5, 50),
      ),
      _ => null,
    };
  }
}

/// The platform does not link orders to lots yet: no lot records.
class NoLotRecords implements LotRecordSource {
  const NoLotRecords();

  @override
  LotRecord? forOrder(String orderCode) => null;
}
