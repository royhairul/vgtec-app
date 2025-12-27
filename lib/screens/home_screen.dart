import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
import 'dart:io';
import '../main.dart';
import '../providers/theme_provider.dart';
import '../services/database_service.dart';
import '../services/supabase_service.dart';
import '../models/detection_result.dart';
import 'camera_screen.dart';
import 'live_detection_screen.dart';
import 'damage_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  List<Widget> get _pages => [
    _DashboardPage(
      onNavigateToCamera: () {
        setState(() {
          _selectedIndex = 1;
        });
      },
    ),
    const _CameraPage(),
    const _HistoryPage(),
    const _SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
      floatingActionButton: _selectedIndex == 0
          ? _buildAnimatedFAB(context)
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildAnimatedFAB(BuildContext context) {
    return SpeedDial(
      icon: Icons.camera_alt_rounded,
      activeIcon: Icons.close,
      foregroundColor: Colors.white,
      backgroundColor: AppColors.primary,
      activeBackgroundColor: AppColors.primaryDark,
      spacing: 12,
      spaceBetweenChildren: 12,
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
      elevation: 8,
      animationCurve: Curves.easeOutCubic,
      children: [
        SpeedDialChild(
          child: Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.error, Color(0xFFDC2626)],
              ),
            ),
            child: const Icon(
              Icons.videocam_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          backgroundColor: Colors.transparent,
          label: 'Live Scan',
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
          labelBackgroundColor: Colors.white,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LiveDetectionScreen(),
              ),
            );
          },
        ),
        SpeedDialChild(
          child: Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.info, Color(0xFF1D4ED8)],
              ),
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          backgroundColor: Colors.transparent,
          label: 'Ambil Foto',
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
          labelBackgroundColor: Colors.white,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CameraScreen()),
            );
          },
        ),
        SpeedDialChild(
          child: Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.warning, Color(0xFFEA580C)],
              ),
            ),
            child: const Icon(
              Icons.photo_library_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          backgroundColor: Colors.transparent,
          label: 'Galeri',
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
          labelBackgroundColor: Colors.white,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CameraScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surface.withOpacity(0.9)
                  : AppColors.surfaceWhite.withOpacity(0.95),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isDark
                    ? AppColors.border.withOpacity(0.5)
                    : AppColors.borderLight,
                width: 1,
              ),
            ),
            child: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              height: 70,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: [
                _buildNavDestination(
                  Icons.home_rounded,
                  Icons.home_outlined,
                  'Home',
                  0,
                ),
                _buildNavDestination(
                  Icons.camera_alt_rounded,
                  Icons.camera_alt_outlined,
                  'Camera',
                  1,
                ),
                _buildNavDestination(
                  Icons.history_rounded,
                  Icons.history_outlined,
                  'History',
                  2,
                ),
                _buildNavDestination(
                  Icons.settings_rounded,
                  Icons.settings_outlined,
                  'Settings',
                  3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  NavigationDestination _buildNavDestination(
    IconData selectedIcon,
    IconData icon,
    String label,
    int index,
  ) {
    return NavigationDestination(
      icon: Icon(icon, color: AppColors.textMuted),
      selectedIcon: Icon(selectedIcon, color: AppColors.accent),
      label: label,
    );
  }
}

// ============================================================================
// DASHBOARD PAGE
// ============================================================================
class _DashboardPage extends StatelessWidget {
  final VoidCallback onNavigateToCamera;

  const _DashboardPage({required this.onNavigateToCamera});

  @override
  Widget build(BuildContext context) {
    final database = context.read<AppDatabase>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppColors.background, AppColors.surface]
                : [AppColors.backgroundLight, AppColors.surfaceLightGray],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // AppBar
            SliverAppBar(
              floating: true,
              backgroundColor: AppColors.primary,
              elevation: 0,
              title: const Text(
                'Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: Colors.white70),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Apakah Anda yakin ingin keluar?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Batal'),
                          ),
                          FilledButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.of(
                                context,
                              ).pushReplacementNamed('/login');
                            },
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    );
                  },
                  tooltip: 'Logout',
                ),
              ],
            ),

            // Stats Card
            SliverToBoxAdapter(
              child: FutureBuilder<Map<String, int>>(
                future: database.getDetectionCounts(),
                builder: (context, snapshot) {
                  final counts = snapshot.data ?? {};
                  final total = counts.values.fold(
                    0,
                    (sum, count) => sum + count,
                  );

                  return Column(
                    children: [
                      _buildStatsCard(context, total, counts),
                      _buildQuickActions(context),
                      _buildDamageTypesSection(context, counts),
                      const SizedBox(height: 140),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(
    BuildContext context,
    int total,
    Map<String, int> counts,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryLight,
              AppColors.accent,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Content
            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.analytics_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Total Deteksi',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$total',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 56,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text(
                          'kerusakan',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Mini stats - 2x2 grid
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildMiniStat(
                              'Berlubang',
                              counts[RoadDamageClass.berlubang] ?? 0,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildMiniStat(
                              'Retak Buaya',
                              counts[RoadDamageClass.retakBuaya] ?? 0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMiniStat(
                              'Amblas',
                              counts[RoadDamageClass.amblas] ?? 0,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildMiniStat(
                              'Bergelombang',
                              counts[RoadDamageClass.bergelombang] ?? 0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Row(
        children: [
          Expanded(
            child: _QuickActionCard(
              icon: Icons.camera_alt_rounded,
              title: 'Capture',
              subtitle: 'Foto & Deteksi',
              gradient: const [AppColors.info, Color(0xFF1D4ED8)],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CameraScreen()),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _QuickActionCard(
              icon: Icons.videocam_rounded,
              title: 'Live',
              subtitle: 'Real-time Scan',
              gradient: const [AppColors.warning, Color(0xFFEA580C)],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LiveDetectionScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDamageTypesSection(
    BuildContext context,
    Map<String, int> counts,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Jenis Kerusakan',
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _DamageTypeCard(
                label: 'Berlubang',
                count: counts[RoadDamageClass.berlubang] ?? 0,
                icon: Icons.circle_outlined,
                color: AppColors.berlubang,
                damageClass: RoadDamageClass.berlubang,
              ),
              _DamageTypeCard(
                label: 'Retak Buaya',
                count: counts[RoadDamageClass.retakBuaya] ?? 0,
                icon: Icons.auto_graph_rounded,
                color: AppColors.retakBuaya,
                damageClass: RoadDamageClass.retakBuaya,
              ),
              _DamageTypeCard(
                label: 'Amblas',
                count: counts[RoadDamageClass.amblas] ?? 0,
                icon: Icons.trending_down_rounded,
                color: AppColors.amblas,
                damageClass: RoadDamageClass.amblas,
              ),
              _DamageTypeCard(
                label: 'Bergelombang',
                count: counts[RoadDamageClass.bergelombang] ?? 0,
                icon: Icons.waves_rounded,
                color: AppColors.bergelombang,
                damageClass: RoadDamageClass.bergelombang,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// QUICK ACTION CARD
// ============================================================================
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isDark ? AppColors.surface : AppColors.surfaceWhite,
            border: Border.all(
              color: isDark ? AppColors.border : AppColors.borderLight,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(colors: gradient),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.first.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: isDark ? AppColors.textMuted : AppColors.textGray,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// DAMAGE TYPE CARD
// ============================================================================
class _DamageTypeCard extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color color;
  final String damageClass;

  const _DamageTypeCard({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
    required this.damageClass,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DamageDetailScreen(
                damageClass: damageClass,
                label: label,
                color: color,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isDark ? AppColors.surface : AppColors.surfaceWhite,
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: isDark
                        ? Colors.white.withOpacity(0.3)
                        : AppColors.textMuted,
                    size: 12,
                  ),
                ],
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$count',
                      style: textTheme.headlineSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      label,
                      style: textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.textSecondary
                            : AppColors.textGray,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// CAMERA PAGE
// ============================================================================
class _CameraPage extends StatelessWidget {
  const _CameraPage();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.background
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Deteksi Kerusakan',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildDetectionCard(
              context,
              icon: Icons.videocam_rounded,
              title: 'Live Detection',
              description:
                  'Deteksi kerusakan jalan secara real-time menggunakan kamera',
              gradient: const [AppColors.error, Color(0xFFDC2626)],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LiveDetectionScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildDetectionCard(
              context,
              icon: Icons.camera_alt_rounded,
              title: 'Capture & Upload',
              description:
                  'Ambil foto atau upload gambar dari galeri untuk dideteksi',
              gradient: const [AppColors.info, Color(0xFF2563EB)],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CameraScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetectionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: isDark ? AppColors.surface : AppColors.surfaceWhite,
            border: Border.all(
              color: gradient.first.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: gradient),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.first.withOpacity(0.4),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Icon(icon, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  color: isDark ? AppColors.textSecondary : AppColors.textGray,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// HISTORY PAGE
// ============================================================================
class _HistoryPage extends StatefulWidget {
  const _HistoryPage();

  @override
  State<_HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<_HistoryPage> {
  bool _isSelecting = false;
  final Set<int> _selectedIds = {};

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _selectAll(List<Detection> detections) {
    setState(() {
      _selectedIds.addAll(detections.map((d) => d.id));
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedIds.clear();
      _isSelecting = false;
    });
  }

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Data?'),
        content: Text('Hapus ${_selectedIds.length} data yang dipilih?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final database = context.read<AppDatabase>();
      for (final id in _selectedIds) {
        await database.deleteDetection(id);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_selectedIds.length} data berhasil dihapus'),
          backgroundColor: AppColors.success,
        ),
      );
      _clearSelection();
    }
  }

  @override
  Widget build(BuildContext context) {
    final database = context.read<AppDatabase>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.background
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          _isSelecting ? '${_selectedIds.length} dipilih' : 'Riwayat',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: _isSelecting
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _clearSelection,
              )
            : null,
        actions: [
          if (!_isSelecting)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Pilih untuk dihapus',
              onPressed: () {
                setState(() {
                  _isSelecting = true;
                });
              },
            ),
          if (_isSelecting)
            FutureBuilder<List<Detection>>(
              future: database.getAllDetections(),
              builder: (context, snapshot) {
                final detections = snapshot.data ?? [];
                return IconButton(
                  icon: Icon(
                    _selectedIds.length == detections.length
                        ? Icons.deselect
                        : Icons.select_all,
                  ),
                  tooltip: _selectedIds.length == detections.length
                      ? 'Batalkan semua'
                      : 'Pilih semua',
                  onPressed: () {
                    if (_selectedIds.length == detections.length) {
                      setState(() => _selectedIds.clear());
                    } else {
                      _selectAll(detections);
                    }
                  },
                );
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Detection>>(
              future: database.getAllDetections(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                final detections = snapshot.data ?? [];

                if (detections.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surface
                                : AppColors.surfaceWhite,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.inbox_rounded,
                            size: 64,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.3)
                                : AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Belum ada riwayat',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textSecondary
                                : AppColors.textGray,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: detections.length,
                  padding: const EdgeInsets.all(20),
                  itemBuilder: (context, index) {
                    final detection = detections[index];
                    return _HistoryCard(
                      detection: detection,
                      isSelecting: _isSelecting,
                      isSelected: _selectedIds.contains(detection.id),
                      onSelect: () => _toggleSelection(detection.id),
                    );
                  },
                );
              },
            ),
          ),
          // Bottom action bar when selecting
          if (_isSelecting && _selectedIds.isNotEmpty)
            Container(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                16 + MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surface : AppColors.surfaceWhite,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: ElevatedButton.icon(
                  onPressed: _deleteSelected,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.delete_rounded),
                  label: Text('Hapus ${_selectedIds.length} data'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final Detection detection;
  final bool isSelecting;
  final bool isSelected;
  final VoidCallback? onSelect;

  const _HistoryCard({
    required this.detection,
    this.isSelecting = false,
    this.isSelected = false,
    this.onSelect,
  });

  Color _getDamageColor(String damageClass) {
    switch (damageClass) {
      case RoadDamageClass.berlubang:
        return AppColors.berlubang;
      case RoadDamageClass.retakBuaya:
        return AppColors.retakBuaya;
      case RoadDamageClass.amblas:
        return AppColors.amblas;
      case RoadDamageClass.bergelombang:
        return AppColors.bergelombang;
      default:
        return AppColors.textMuted;
    }
  }

  void _showDetailSheet(BuildContext context) {
    final color = _getDamageColor(detection.damageClass);
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
                                _buildDetailRow(
                                  context,
                                  Icons.percent_rounded,
                                  'Confidence',
                                  '${(detection.confidence * 100).toStringAsFixed(1)}%',
                                  valueColor: color,
                                ),
                                Divider(
                                  color: isDark
                                      ? AppColors.border
                                      : AppColors.borderLight,
                                  height: 24,
                                ),
                                _buildDetailRow(
                                  context,
                                  Icons.location_on_rounded,
                                  'Koordinat',
                                  '${detection.latitude.toStringAsFixed(6)}, ${detection.longitude.toStringAsFixed(6)}',
                                ),
                                Divider(
                                  color: isDark
                                      ? AppColors.border
                                      : AppColors.borderLight,
                                  height: 24,
                                ),
                                _buildDetailRow(
                                  context,
                                  Icons.access_time_rounded,
                                  'Waktu Deteksi',
                                  dateFormat.format(detection.timestamp),
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

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
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

  @override
  Widget build(BuildContext context) {
    final color = _getDamageColor(detection.damageClass);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isSelecting ? onSelect : () => _showDetailSheet(context),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.1)
                  : (isDark ? AppColors.surface : AppColors.surfaceWhite),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? color : color.withValues(alpha: 0.3),
                width: isSelected ? 2 : 1.5,
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
                // Selection checkbox
                if (isSelecting)
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isSelected ? color : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected
                              ? color
                              : (isDark
                                    ? AppColors.border
                                    : AppColors.borderLight),
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                  ),
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
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              RoadDamageClass.getDisplayName(
                                detection.damageClass,
                              ),
                              style: TextStyle(
                                color: color,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
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
                            Icons.percent,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.4)
                                : AppColors.textMuted,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${(detection.confidence * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: color,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
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
                                ? Colors.white.withValues(alpha: 0.4)
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

                if (!isSelecting)
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.3)
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

// ============================================================================
// SETTINGS PAGE
// ============================================================================
class _SettingsPage extends StatefulWidget {
  const _SettingsPage();

  @override
  State<_SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<_SettingsPage> {
  bool _isSyncing = false;

  Future<void> _syncToSupabase() async {
    setState(() => _isSyncing = true);

    try {
      final database = Provider.of<AppDatabase>(context, listen: false);
      final supabaseService = Provider.of<SupabaseService>(
        context,
        listen: false,
      );

      final unsyncedDetections = await database.getUnsyncedDetections();

      if (unsyncedDetections.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Semua data sudah tersinkronisasi'),
              backgroundColor: AppColors.info,
            ),
          );
        }
        return;
      }

      int successCount = 0;
      for (var detection in unsyncedDetections) {
        try {
          final detectionResult = DetectionResult(
            id: detection.id,
            damageClass: detection.damageClass,
            confidence: detection.confidence,
            latitude: detection.latitude,
            longitude: detection.longitude,
            imagePath: detection.imagePath,
            timestamp: detection.timestamp,
            synced: detection.synced,
          );

          final success = await supabaseService.uploadDetection(
            detectionResult,
          );
          if (success) {
            await database.markAsSynced(detection.id);
            successCount++;
          }
        } catch (e) {
          print('Error syncing detection ${detection.id}: $e');
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$successCount deteksi berhasil disinkronkan'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal sinkronisasi: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Future<void> _testDatabase() async {
    try {
      final database = Provider.of<AppDatabase>(context, listen: false);
      final allDetections = await database.getAllDetections();
      final unsyncedCount = await database.getUnsyncedDetections().then(
        (list) => list.length,
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.storage_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Status Database'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatusRow('Total Deteksi', '${allDetections.length}'),
                _buildStatusRow('Belum Sync', '$unsyncedCount'),
                _buildStatusRow(
                  'Sudah Sync',
                  '${allDetections.length - unsyncedCount}',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.background
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Pengaturan', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionTitle('Sinkronisasi'),
          _SettingsTile(
            icon: Icons.cloud_upload_rounded,
            iconColor: AppColors.info,
            title: 'Sync ke Cloud',
            subtitle: 'Upload data deteksi ke server',
            trailing: _isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
            onTap: _isSyncing ? null : _syncToSupabase,
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Tampilan'),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return _SettingsTile(
                icon: themeProvider.isDarkMode
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                iconColor: themeProvider.isDarkMode
                    ? Colors.indigo
                    : Colors.amber,
                title: 'Mode Gelap',
                subtitle: themeProvider.isDarkMode
                    ? 'Tema gelap aktif'
                    : 'Tema terang aktif',
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                  activeColor: AppColors.primary,
                ),
                onTap: () => themeProvider.toggleTheme(),
              );
            },
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Database'),
          _SettingsTile(
            icon: Icons.storage_rounded,
            iconColor: AppColors.success,
            title: 'Status Database',
            subtitle: 'Cek status penyimpanan lokal',
            trailing: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.textMuted,
            ),
            onTap: _testDatabase,
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Tentang'),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            iconColor: AppColors.primary,
            title: 'Tentang Aplikasi',
            subtitle: 'Versi 1.0.0',
            trailing: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.textMuted,
            ),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Pavement Detector',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2025 VGTec',
              );
            },
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Akun'),
          _SettingsTile(
            icon: Icons.logout_rounded,
            iconColor: AppColors.error,
            title: 'Logout',
            subtitle: 'Keluar dari aplikasi',
            trailing: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.textMuted,
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Apakah Anda yakin ingin keluar?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
          // Bottom padding for navigation bar
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: isDark ? AppColors.textMuted : AppColors.textGray,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surface : AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.border : AppColors.borderLight,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textMuted
                            : AppColors.textGray,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}
