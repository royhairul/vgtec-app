import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import '../services/database_service.dart';
import '../models/detection_result.dart';
import 'dart:io';

class DamageDetailScreen extends StatelessWidget {
  final String damageClass;
  final String label;
  final Color color;

  const DamageDetailScreen({
    super.key,
    required this.damageClass,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final database = context.read<AppDatabase>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.background
          : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(label, style: const TextStyle(color: Colors.white)),
      ),
      body: FutureBuilder<List<Detection>>(
        future: database.getDetectionsByClass(damageClass),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSecondary
                          : AppColors.textGray,
                    ),
                  ),
                ],
              ),
            );
          }

          final detections = snapshot.data ?? [];

          if (detections.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surface
                          : AppColors.surfaceWhite,
                      shape: BoxShape.circle,
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Icon(
                      Icons.search_off_rounded,
                      size: 64,
                      color: color.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Belum ada deteksi untuk',
                    style: TextStyle(
                      color: isDark
                          ? Colors.white.withOpacity(0.7)
                          : AppColors.textGray,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Stats header
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, color.withValues(alpha: 0.7)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${detections.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total deteksi $label',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: detections.length,
                  itemBuilder: (context, index) {
                    final detection = detections[index];
                    return _DetectionCard(
                      detection: detection,
                      color: color,
                      onTap: () => _showDetailSheet(context, detection, color),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDetailSheet(
    BuildContext context,
    Detection detection,
    Color color,
  ) {
    final dateFormat = DateFormat('dd MMMM yyyy, HH:mm:ss');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surface : AppColors.surfaceWhite,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.textMuted
                          : AppColors.borderLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: EdgeInsets.zero,
                      children: [
                        // Image
                        if (detection.imagePath.isNotEmpty &&
                            File(detection.imagePath).existsSync())
                          Container(
                            margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                            height: 220,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                File(detection.imagePath),
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        else
                          Container(
                            margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                            height: 180,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.surfaceLight
                                  : AppColors.surfaceLightGray,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.image_not_supported_rounded,
                                size: 48,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.3)
                                    : AppColors.textMuted,
                              ),
                            ),
                          ),

                        // Title
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      color,
                                      color.withValues(alpha: 0.7),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      RoadDamageClass.getDisplayName(
                                        detection.damageClass,
                                      ),
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : AppColors.textDark,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      'Kerusakan Jalan',
                                      style: TextStyle(
                                        color: isDark
                                            ? AppColors.textSecondary
                                            : AppColors.textGray,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: detection.synced
                                      ? AppColors.success.withValues(
                                          alpha: 0.15,
                                        )
                                      : (isDark
                                            ? AppColors.textMuted.withValues(
                                                alpha: 0.15,
                                              )
                                            : AppColors.surfaceLightGray),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: detection.synced
                                        ? AppColors.success.withValues(
                                            alpha: 0.3,
                                          )
                                        : (isDark
                                              ? AppColors.border
                                              : AppColors.borderLight),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      detection.synced
                                          ? Icons.cloud_done_rounded
                                          : Icons.cloud_off_rounded,
                                      size: 14,
                                      color: detection.synced
                                          ? AppColors.success
                                          : AppColors.textMuted,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      detection.synced ? 'Synced' : 'Offline',
                                      style: TextStyle(
                                        color: detection.synced
                                            ? AppColors.success
                                            : AppColors.textMuted,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Details grid
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.background
                                  : AppColors.surfaceLightGray,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.border
                                    : AppColors.borderLight,
                              ),
                            ),
                            child: Column(
                              children: [
                                _DetailRow(
                                  icon: Icons.percent_rounded,
                                  label: 'Confidence',
                                  value:
                                      '${(detection.confidence * 100).toStringAsFixed(1)}%',
                                  valueColor: color,
                                ),
                                Divider(
                                  color: isDark
                                      ? AppColors.border
                                      : AppColors.borderLight,
                                  height: 24,
                                ),
                                _DetailRow(
                                  icon: Icons.location_on_rounded,
                                  label: 'Koordinat',
                                  value:
                                      '${detection.latitude.toStringAsFixed(6)}, ${detection.longitude.toStringAsFixed(6)}',
                                ),
                                Divider(
                                  color: isDark
                                      ? AppColors.border
                                      : AppColors.borderLight,
                                  height: 24,
                                ),
                                _DetailRow(
                                  icon: Icons.access_time_rounded,
                                  label: 'Waktu Deteksi',
                                  value: dateFormat.format(detection.timestamp),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Action buttons
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    side: BorderSide(
                                      color: isDark
                                          ? AppColors.border
                                          : AppColors.borderLight,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                  ),
                                  label: const Text('Tutup'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    final lat = detection.latitude;
                                    final lng = detection.longitude;
                                    final url = Uri.parse(
                                      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
                                    );
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(
                                        url,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    } else {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Tidak dapat membuka Maps',
                                            ),
                                            backgroundColor: AppColors.error,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  icon: const Icon(Icons.map_rounded, size: 18),
                                  label: const Text('Lihat di Map'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _DetectionCard extends StatelessWidget {
  final Detection detection;
  final Color color;
  final VoidCallback onTap;

  const _DetectionCard({
    required this.detection,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surface : AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Thumbnail
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child:
                        detection.imagePath.isNotEmpty &&
                            File(detection.imagePath).existsSync()
                        ? Image.file(
                            File(detection.imagePath),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 80,
                            height: 80,
                            color: isDark
                                ? AppColors.surfaceLight
                                : AppColors.surfaceLightGray,
                            child: Icon(
                              Icons.image_not_supported_rounded,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.3)
                                  : AppColors.textMuted,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 14),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.percent, color: color, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  '${(detection.confidence * 100).toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            detection.synced
                                ? Icons.cloud_done_rounded
                                : Icons.cloud_off_rounded,
                            color: detection.synced
                                ? AppColors.success
                                : AppColors.textMuted,
                            size: 16,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            color: isDark
                                ? Colors.white.withOpacity(0.4)
                                : AppColors.textMuted,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${detection.latitude.toStringAsFixed(4)}, ${detection.longitude.toStringAsFixed(4)}',
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.textSecondary
                                    : AppColors.textGray,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            color: isDark
                                ? Colors.white.withOpacity(0.4)
                                : AppColors.textMuted,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            dateFormat.format(detection.timestamp),
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.textSecondary
                                  : AppColors.textGray,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: isDark
                      ? Colors.white.withOpacity(0.3)
                      : AppColors.textMuted,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surface : AppColors.surfaceLightGray,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.textMuted),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isDark ? AppColors.textMuted : AppColors.textGray,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color:
                      valueColor ??
                      (isDark ? Colors.white : AppColors.textDark),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
