import 'package:flutter/material.dart';

import '../../../shared/ui/theme/cosecha_palette.dart';
import '../../../shared/ui/theme/theme.dart';
import '../domain/shipment.dart';

class LotTraceabilityCard extends StatelessWidget {
  const LotTraceabilityCard({required this.lot, super.key});

  final TraceableLotItem lot;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: CosechaSpace.xs),
      padding: const EdgeInsets.all(CosechaSpace.inner),
      decoration: BoxDecoration(
        color: CosechaPalette.neutral0,
        borderRadius: CosechaRadius.cardAll,
        border: Border.all(color: CosechaPalette.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.eco_outlined, size: 18, color: CosechaPalette.moss),
                  const SizedBox(width: CosechaSpace.xxs),
                  Text(
                    '${lot.productName} ${lot.variety}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: CosechaPalette.forest,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: CosechaPalette.neutral20,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${lot.quantityKg} kg',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: CosechaPalette.forest,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: CosechaSpace.xs),
          Text(
            lot.lotCode,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: CosechaPalette.glacier,
            ),
          ),
          const SizedBox(height: CosechaSpace.xs),
          _TraceInfoRow(
            icon: Icons.location_on_outlined,
            label: 'Origen',
            value: '${lot.originFarm} (${lot.originRegion})',
          ),
          const SizedBox(height: CosechaSpace.xxs),
          _TraceInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Cosecha',
            value: lot.harvestDate,
          ),
          const SizedBox(height: CosechaSpace.xxs),
          _TraceInfoRow(
            icon: Icons.grade_outlined,
            label: 'Calidad',
            value: lot.qualityGrade,
          ),
          const SizedBox(height: CosechaSpace.sm),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (final cert in lot.certifications)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: CosechaPalette.ripeContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    cert,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: CosechaPalette.onRipeContainer,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TraceInfoRow extends StatelessWidget {
  const _TraceInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: CosechaPalette.neutralVariant),
        const SizedBox(width: CosechaSpace.xxs),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 11, color: CosechaPalette.neutralVariant),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: CosechaPalette.forest,
            ),
          ),
        ),
      ],
    );
  }
}