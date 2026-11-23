import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/components/components.dart';
import '../../../shared/ui/theme/theme.dart';
import '../application/incidents_controller.dart';
import '../domain/incident.dart';
import '../domain/incident_repository.dart';
import '../infrastructure/evidence_picker.dart';
import 'evidence_photos.dart';
import 'incident_status_view.dart';

/// US11 — Report a quality problem with photos taken on the spot.
///
/// Opened inside the shell (both bars visible) from "More → Incidents",
/// from the reception inspection or from an order card. When [initialTarget]
/// is given the order is fixed; otherwise the client picks it.
/// Validation runs when tapping Send (Cosecha rule 11).
class ReportIncidentPage extends StatefulWidget {
  const ReportIncidentPage({
    required this.controller,
    required this.targets,
    required this.picker,
    required this.onSubmitted,
    this.initialTarget,
    super.key,
  });

  final IncidentsController controller;
  final IncidentTargetSource targets;
  final EvidencePicker picker;
  final ValueChanged<Incident> onSubmitted;
  final IncidentTarget? initialTarget;

  @override
  State<ReportIncidentPage> createState() => _ReportIncidentPageState();
}

class _ReportIncidentPageState extends State<ReportIncidentPage> {
  final _formKey = GlobalKey<FormState>();
  final _description = TextEditingController();
  final List<Uint8List> _photos = [];
  late final Future<List<IncidentTarget>> _targets =
      widget.targets.reportableTargets();
  IncidentTarget? _target;

  @override
  void initState() {
    super.initState();
    _target = widget.initialTarget;
  }

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  int get _remaining => NewIncident.maxPhotos - _photos.length;

  Future<void> _addPhotos() async {
    final l10n = AppLocalizations.of(context);
    var source = EvidenceSource.gallery;
    if (widget.picker.supportsCamera) {
      final chosen = await showModalBottomSheet<EvidenceSource>(
        context: context,
        builder: (sheetContext) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              CosechaSpace.md,
              0,
              CosechaSpace.md,
              CosechaSpace.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.qmAddPhoto, style: Theme.of(sheetContext).textTheme.titleLarge),
                const SizedBox(height: CosechaSpace.sm),
                CosechaActionRow(
                  icon: Icons.photo_camera_outlined,
                  title: l10n.qmTakePhoto,
                  onTap: () => Navigator.of(sheetContext).pop(EvidenceSource.camera),
                ),
                const SizedBox(height: CosechaSpace.xs),
                CosechaActionRow(
                  icon: Icons.photo_library_outlined,
                  title: l10n.qmChooseGallery,
                  onTap: () => Navigator.of(sheetContext).pop(EvidenceSource.gallery),
                ),
              ],
            ),
          ),
        ),
      );
      if (chosen == null) return;
      source = chosen;
    }
    try {
      final picked = await widget.picker.pick(source, max: _remaining);
      if (!mounted || picked.isEmpty) return;
      setState(() => _photos.addAll(picked.take(_remaining)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.qmPhotoError)),
      );
    }
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final created = await widget.controller.report(NewIncident(
        target: _target,
        description: _description.text,
        photos: List.of(_photos),
      ));
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.qmSent)));
      widget.onSubmitted(created);
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(
        content: Text(qualityErrorMessage(error, l10n, fallback: l10n.qmSendError)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final submitting = widget.controller.submitting;
        return Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              CosechaSpace.screenMargin,
              CosechaSpace.md,
              CosechaSpace.screenMargin,
              CosechaSpace.lg,
            ),
            children: [
              _TargetField(
                initialTarget: widget.initialTarget,
                targets: _targets,
                selected: _target,
                onChanged: (target) => setState(() => _target = target),
              ),
              const SizedBox(height: CosechaSpace.md),
              CosechaTextField(
                label: l10n.qmDescriptionLabel,
                hint: l10n.qmDescriptionHint,
                helper: l10n.qmDescriptionHelper,
                controller: _description,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                validator: (value) => NewIncident.validateDescription(value) == null
                    ? null
                    : l10n.qmDescriptionError,
              ),
              const SizedBox(height: CosechaSpace.md),
              Text(
                l10n.qmPhotosLabel(NewIncident.maxPhotos),
                style: textTheme.titleSmall?.copyWith(color: context.cosechaContent),
              ),
              const SizedBox(height: CosechaSpace.xs),
              Wrap(
                spacing: CosechaSpace.xs,
                runSpacing: CosechaSpace.xs,
                children: [
                  for (var i = 0; i < _photos.length; i++)
                    _EditablePhoto(
                      bytes: _photos[i],
                      label: l10n.qmPhotoLabel(i + 1),
                      removeLabel: l10n.qmRemovePhoto(i + 1),
                      onRemove: submitting
                          ? null
                          : () => setState(() => _photos.removeAt(i)),
                    ),
                  if (_remaining > 0)
                    _AddPhotoTile(
                      label: l10n.qmAddPhoto,
                      onTap: submitting ? null : _addPhotos,
                    ),
                ],
              ),
              const SizedBox(height: CosechaSpace.xs),
              Text(
                l10n.qmPhotosLocalNote,
                style: textTheme.bodySmall
                    ?.copyWith(color: context.cosechaContentSecondary),
              ),
              const SizedBox(height: CosechaSpace.md),
              if (submitting) ...[
                const CosechaProgressBar(value: null),
                const SizedBox(height: CosechaSpace.sm),
              ],
              CosechaPrimaryButton(
                label: l10n.qmSend,
                icon: Icons.send_outlined,
                onPressed: submitting ? null : _send,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Order of the incident: fixed (info card) or chosen from a list.
class _TargetField extends StatelessWidget {
  const _TargetField({
    required this.initialTarget,
    required this.targets,
    required this.selected,
    required this.onChanged,
  });

  final IncidentTarget? initialTarget;
  final Future<List<IncidentTarget>> targets;
  final IncidentTarget? selected;
  final ValueChanged<IncidentTarget> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final label = Text(
      l10n.qmTargetLabel,
      style: textTheme.titleSmall?.copyWith(color: context.cosechaContent),
    );

    final fixed = initialTarget;
    if (fixed != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          label,
          const SizedBox(height: CosechaSpace.xs),
          CosechaCard(
            tone: CosechaCardTone.tint,
            child: _TargetSummary(target: fixed),
          ),
        ],
      );
    }

    return FormField<IncidentTarget>(
      initialValue: selected,
      // Reads the field value: the parent's [selected] is only updated on
      // its next build.
      validator: (value) => value == null ? l10n.qmTargetRequired : null,
      builder: (field) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          label,
          const SizedBox(height: CosechaSpace.xs),
          FutureBuilder<List<IncidentTarget>>(
            future: targets,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(CosechaSpace.sm),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final target in snapshot.requireData) ...[
                    _SelectableTarget(
                      target: target,
                      selected: target == field.value,
                      onTap: () {
                        field.didChange(target);
                        onChanged(target);
                        if (field.hasError) field.validate();
                      },
                    ),
                    const SizedBox(height: CosechaSpace.xs),
                  ],
                ],
              );
            },
          ),
          if (field.errorText != null) CosechaFieldError(field.errorText!),
        ],
      ),
    );
  }
}

class _SelectableTarget extends StatelessWidget {
  const _SelectableTarget({
    required this.target,
    required this.selected,
    required this.onTap,
  });

  final IncidentTarget target;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: Material(
        color: scheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: CosechaRadius.buttonAll,
          side: BorderSide(
            color: selected ? scheme.primary : scheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(CosechaSpace.inner),
            child: Row(
              children: [
                Icon(
                  selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: selected ? scheme.primary : scheme.outline,
                ),
                const SizedBox(width: CosechaSpace.inner),
                Expanded(child: _TargetSummary(target: target)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TargetSummary extends StatelessWidget {
  const _TargetSummary({required this.target});

  final IncidentTarget target;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final data = CosechaDataText.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.qmTargetValue(target.orderCode, target.lotCode),
          style: data.dataMono.copyWith(
            color: context.cosechaContent,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (target.productSummary != null)
          Text(
            target.productSummary!,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: context.cosechaContentSecondary),
          ),
      ],
    );
  }
}

class _EditablePhoto extends StatelessWidget {
  const _EditablePhoto({
    required this.bytes,
    required this.label,
    required this.removeLabel,
    required this.onRemove,
  });

  final Uint8List bytes;
  final String label;
  final String removeLabel;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox.square(
      dimension: 104,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            child: EvidenceThumbnail(bytes: bytes, label: label),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton.filled(
              tooltip: removeLabel,
              onPressed: onRemove,
              iconSize: CosechaSize.iconSm,
              style: IconButton.styleFrom(
                backgroundColor: scheme.inverseSurface,
                foregroundColor: scheme.onInverseSurface,
              ),
              icon: const Icon(Icons.close),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  const _AddPhotoTile({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        child: Material(
          color: scheme.secondaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: CosechaRadius.buttonAll,
            side: BorderSide(color: scheme.outline),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox.square(
              dimension: 96,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, color: scheme.onSecondaryContainer),
                  const SizedBox(height: CosechaSpace.xxs),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: CosechaSpace.xxs),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(color: scheme.onSecondaryContainer),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
