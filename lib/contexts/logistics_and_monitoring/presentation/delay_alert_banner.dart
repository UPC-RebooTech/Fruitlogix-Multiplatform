import 'package:flutter/material.dart';

import '../../../shared/ui/theme/cosecha_palette.dart';
import '../../../shared/ui/theme/theme.dart';
import '../domain/shipment.dart';

class DelayAlertBanner extends StatelessWidget {
  const DelayAlertBanner({required this.delay, super.key});

  final ShipmentDelayInfo delay;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(CosechaSpace.inner),
      decoration: BoxDecoration(
        color: CosechaPalette.mangoContainer,
        borderRadius: CosechaRadius.cardAll,
        border: Border.all(color: CosechaPalette.mango),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, size: 20, color: CosechaPalette.onMangoContainer),
              const SizedBox(width: CosechaSpace.xxs),
              const Text(
                'Retraso en Tránsito',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: CosechaPalette.onMangoContainer,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: CosechaPalette.mango,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '+${delay.delayMinutes} min',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: CosechaSpace.xs),
          Text(
            delay.reason,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: CosechaPalette.onMangoContainer,
            ),
          ),
          const SizedBox(height: CosechaSpace.xxs),
          Text(
            'ETA recalculado: ${delay.updatedEta} (anterior: ${delay.originalEta})',
            style: TextStyle(
              fontSize: 11,
              color: CosechaPalette.onMangoContainer.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}