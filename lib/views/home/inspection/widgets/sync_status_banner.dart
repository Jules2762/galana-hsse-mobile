import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/routes/app_routes.dart';
import 'package:gestion_hsse/cores/services/realtime_service.dart';
import 'package:gestion_hsse/cores/services/sync_service.dart';
import 'package:gestion_hsse/cores/themes/app_colors.dart';

class SyncStatusBanner extends StatelessWidget {
  const SyncStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([SyncService.instance, RealtimeService.instance]),
      builder: (context, _) {
        final sync = SyncService.instance;
        final realtime = RealtimeService.instance;
        final isOnline = sync.isOnline;
        final isSyncing = sync.isSyncing;
        final pendingCount = sync.pendingCount;


        // 1. ÉTAT : SYNCHRONISATION EN COURS
        if (isSyncing) {
          return InkWell(
            onTap: () => Navigator.pushNamed(context, AppRoutes.syncQueue),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Synchronisation en ligne en cours...",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E40AF),
                          ),
                        ),
                        Text(
                          "$pendingCount inspection(s) en cours d'envoi • Touchez pour voir",
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF3B82F6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 18, color: Color(0xFF3B82F6)),
                ],
              ),
            ),
          );
        }

        // 2. ÉTAT : HORS-LIGNE
        if (!isOnline) {
          return InkWell(
            onTap: () => Navigator.pushNamed(context, AppRoutes.syncQueue),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.cloud_off_rounded,
                      color: Color(0xFFD97706),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              "Mode Hors-ligne actif",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF92400E),
                              ),
                            ),
                            if (pendingCount > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF59E0B),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "$pendingCount en attente",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          "Sauvegardé localement • Touchez pour gérer la file",
                          style: TextStyle(
                            fontSize: 10.5,
                            color: Color(0xFFB45309),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20, color: Color(0xFFD97706)),
                    tooltip: "Tester la connexion",
                    onPressed: () async {
                      final online = await sync.checkConnectivity();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            duration: const Duration(seconds: 2),
                            backgroundColor: online ? const Color(0xFF15803D) : const Color(0xFFB45309),
                            content: Text(
                              online
                                  ? "Connexion rétablie ! Lancement de la synchronisation..."
                                  : "Toujours hors-ligne. Les données restent protégées en local.",
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  const Icon(Icons.chevron_right, size: 18, color: Color(0xFFD97706)),
                ],
              ),
            ),
          );
        }

        // 3. ÉTAT : EN LIGNE AVEC PENDING SYNC
        if (pendingCount > 0) {
          return InkWell(
            onTap: () => Navigator.pushNamed(context, AppRoutes.syncQueue),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.sync, color: Color(0xFF16A34A), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$pendingCount inspection(s) prête(s) à être synchronisée(s)",
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF15803D),
                          ),
                        ),
                        const Text(
                          "Touchez pour voir le détail des données",
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      visualDensity: VisualDensity.compact,
                      foregroundColor: const Color(0xFF15803D),
                    ),
                    onPressed: () => sync.syncAll(),
                    child: const Text("Synchroniser", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                  ),
                ],
              ),
            ),
          );
        }

        // 4. ÉTAT : EN LIGNE & SYNCHRONISÉ EN TEMPS RÉEL
        final recentEvent = realtime.latestEvent;
        final isRecent = recentEvent != null &&
            DateTime.now().difference(recentEvent.createdAt).inSeconds < 8;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: isRecent ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isRecent ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF22C55E),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isRecent
                      ? "⚡ En direct : ${recentEvent.title}"
                      : "En ligne • Synchronisation temps réel active",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isRecent ? FontWeight.w700 : FontWeight.w500,
                    color: isRecent ? const Color(0xFF15803D) : const Color(0xFF475569),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt, size: 11, color: Color(0xFF15803D)),
                    SizedBox(width: 2),
                    Text(
                      "LIVE",
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF15803D),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: () => _showQueueDetailsSheet(context),
                borderRadius: BorderRadius.circular(6),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Icon(Icons.info_outline, size: 15, color: Color(0xFF94A3B8)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  static void _showQueueDetailsSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return ListenableBuilder(
          listenable: SyncService.instance,
          builder: (context, _) {
            final sync = SyncService.instance;
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF475569) : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          sync.isOnline ? Icons.cloud_done : Icons.cloud_off,
                          color: sync.isOnline ? const Color(0xFF15803D) : const Color(0xFFD97706),
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sync.isOnline ? "Connectivité API Galana : En ligne" : "Connectivité API Galana : Hors-ligne",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                "${sync.pendingCount} action(s) dans la file d'attente locale",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(height: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    const SizedBox(height: 12),
                    if (sync.queue.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            const Icon(Icons.check_circle_outline, color: Color(0xFF16A34A), size: 40),
                            const SizedBox(height: 8),
                            Text(
                              "Toutes les inspections sont à jour !",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Aucune modification en attente sur l'appareil.",
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...List.generate(sync.queue.length, (index) {
                        final item = sync.queue[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isDark ? const Color(0xFF334155) : AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF0F9D58).withValues(alpha: 0.2) : AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.upload, size: 16, color: AppColors.primary),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                                      ),
                                    ),
                                    Text(
                                      "${item.method} ${item.endpoint}",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  "En attente",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFB45309),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.queue_rounded, size: 18),
                        label: const Text("Ouvrir la file d'attente complète", style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, AppRoutes.syncQueue);
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDark ? Colors.white : null,
                              side: isDark ? const BorderSide(color: Color(0xFF334155)) : null,
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Fermer"),
                          ),
                        ),
                        if (sync.queue.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                              icon: const Icon(Icons.sync, size: 18),
                              label: const Text("Synchroniser"),
                              onPressed: () {
                                Navigator.pop(context);
                                sync.syncAll();
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
