import 'package:flutter/material.dart';

import '../../../shared/ui/theme/cosecha_palette.dart';
import '../domain/shipment.dart';

class ColdChainCertificateSheet extends StatelessWidget {
  const ColdChainCertificateSheet({
    required this.certificate,
    required this.trackingNumber,
    required this.orderId,
    super.key,
  });

  final ColdChainCertificate certificate;
  final String trackingNumber;
  final String orderId;

  static Future<void> show(
      BuildContext context, {
        required ColdChainCertificate certificate,
        required String trackingNumber,
        required String orderId,
      }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ColdChainCertificateSheet(
        certificate: certificate,
        trackingNumber: trackingNumber,
        orderId: orderId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: CosechaPalette.neutral0,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barra de arrastre superior
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: CosechaPalette.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Cabecera con insignia de certificación
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cold-Chain Certificate',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: CosechaPalette.forest,
                    ),
                  ),
                  Text(
                    certificate.certificateId,
                    style: const TextStyle(fontSize: 12, color: CosechaPalette.neutralVariant),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: CosechaPalette.ripeContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: CosechaPalette.ripe),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified, size: 16, color: CosechaPalette.onRipeContainer),
                    const SizedBox(width: 4),
                    Text(
                      '${certificate.compliancePercentage}% Compliant',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: CosechaPalette.onRipeContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),

          // Rango Óptimo y Datos del Envío
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CosechaPalette.neutral10,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CosechaPalette.outlineVariant),
            ),
            child: Column(
              children: [
                _DetailRow(label: 'Order Reference', value: orderId),
                const SizedBox(height: 6),
                _DetailRow(label: 'Tracking Dispatch', value: trackingNumber),
                const SizedBox(height: 6),
                _DetailRow(label: 'Standard Target', value: certificate.optimalRangeLabel),
                const SizedBox(height: 6),
                _DetailRow(label: 'Monitored Duration', value: '${certificate.totalTripHours} hrs in transit'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Métricas de Temperatura
          const Text(
            'Thermal Journey Metrics',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: CosechaPalette.forest),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: 'Average',
                  value: '${certificate.averageTempC} °C',
                  color: CosechaPalette.glacier,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricTile(
                  label: 'Minimum Peak',
                  value: '${certificate.minTempRecordedC} °C',
                  color: const Color(0xFF1E88E5),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricTile(
                  label: 'Maximum Peak',
                  value: '${certificate.maxTempRecordedC} °C',
                  color: CosechaPalette.mango,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Integridad Criptográfica / Blockchain Audit Hash
          const Text(
            'Integrity & Digital Validation',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: CosechaPalette.forest),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: CosechaPalette.neutral20,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: CosechaPalette.outlineVariant),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_outline, size: 16, color: CosechaPalette.neutralVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    certificate.digitalSignatureHash,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: CosechaPalette.neutralVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Botón de acción: Descargar
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cold-chain certificate exported to PDF successfully.'),
                  ),
                );
              },
              icon: const Icon(Icons.download, size: 18),
              label: const Text(
                'Download Audit Report (PDF)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: CosechaPalette.lime,
                foregroundColor: CosechaPalette.forest,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: CosechaPalette.neutralVariant)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: CosechaPalette.forest)),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: CosechaPalette.neutralVariant)),
        ],
      ),
    );
  }
}