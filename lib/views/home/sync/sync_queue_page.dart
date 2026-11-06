import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/api/api_client.dart';
import 'package:gestion_hsse/cores/services/sync_service.dart';
import 'package:gestion_hsse/cores/themes/app_colors.dart';

class SyncQueuePage extends StatefulWidget {
  const SyncQueuePage({super.key});

  @override
  State<SyncQueuePage> createState() => _SyncQueuePageState();
}

class _SyncQueuePageState extends State<SyncQueuePage> {
  bool _isTestingConnection = false;

  Future<void> _testConnection() async {
    setState(() => _isTestingConnection = true);
    final online = await SyncService.instance.checkConnectivity();
    if (!mounted) return;
    setState(() => _isTestingConnection = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: online ? const Color(0xFF15803D) : const Color(0xFFB45309),
        content: Row(
          children: [
            Icon(online ? Icons.wifi : Icons.wifi_off, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                online
                    ? "Connexion au serveur HSSE établie avec succès !"
                    : "Serveur inaccessible. Vérifiez l'adresse IP et votre réseau.",
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _triggerSyncAll() async {
    final success = await SyncService.instance.syncAll(manual: true);
    if (!mounted) return;

    final remaining = SyncService.instance.pendingCount;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: (remaining == 0)
            ? const Color(0xFF15803D)
            : (success ? const Color(0xFF1D4ED8) : Colors.red.shade700),
        content: Row(
          children: [
            Icon(
              (remaining == 0) ? Icons.check_circle : (success ? Icons.sync : Icons.error_outline),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                (remaining == 0)
                    ? "Toutes les inspections ont été synchronisées avec succès !"
                    : (success
                        ? "Synchronisation partielle : $remaining action(s) restante(s)."
                        : "Échec de la synchronisation. Vérifiez la connexion au serveur."),
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPayloadDialog(SyncAction action) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final jsonStr = const JsonEncoder.withIndent('  ').convert(action.payload);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.data_object_rounded, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                action.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${action.method} ${action.endpoint}",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: SelectableText(
                    jsonStr,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF0F172A),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Fermer"),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAction(SyncAction action) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Supprimer cette action ?"),
        content: Text(
          "Êtes-vous sûr de vouloir retirer « ${action.title} » de la file d'attente ? Cette opération annulera l'envoi de cette inspection vers le serveur.",
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await SyncService.instance.removeAction(action.id);
            },
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );
  }

  void _confirmClearQueue() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Vider toute la file d'attente ?"),
        content: const Text(
          "Attention : toutes les inspections en attente de synchronisation sur cet appareil seront définitivement supprimées.",
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await SyncService.instance.clearQueue();
            },
            child: const Text("Tout vider"),
          ),
        ],
      ),
    );
  }

  Color _badgeColorForType(String type) {
    final t = type.toUpperCase();
    if (t.contains('CHECKLIST')) return const Color(0xFF10B981);
    if (t.contains('VMC')) return const Color(0xFF6366F1);
    if (t.contains('EQUIPMENT') || t.contains('MONITORING')) return const Color(0xFFF59E0B);
    if (t.contains('ACTION')) return const Color(0xFFEF4444);
    return AppColors.primary;
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inSeconds < 60) return "À l'instant";
    if (diff.inMinutes < 60) return "Il y a ${diff.inMinutes} min";
    if (diff.inHours < 24) return "Aujourd'hui à ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    return "${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = theme.colorScheme.surface;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text("Synchronisation"),
        actions: [
          IconButton(
            tooltip: "Tester la connexion",
            icon: _isTestingConnection
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  )
                : const Icon(Icons.wifi_find_rounded),
            onPressed: _isTestingConnection ? null : _testConnection,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: SyncService.instance,
        builder: (context, _) {
          final sync = SyncService.instance;
          final isOnline = sync.isOnline;
          final isSyncing = sync.isSyncing;
          final pendingCount = sync.pendingCount;
          final queue = sync.queue;

          return Column(
            children: [
              // 1. Bandeau de statut serveur & connectivité
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isOnline
                                ? const Color(0xFF10B981).withValues(alpha: 0.12)
                                : const Color(0xFFF59E0B).withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isOnline ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                            color: isOnline ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    isOnline ? "Serveur connecté" : "Mode Hors-ligne",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isOnline
                                          ? const Color(0xFF10B981).withValues(alpha: 0.15)
                                          : const Color(0xFFF59E0B).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      isOnline ? "EN LIGNE" : "LOCAL",
                                      style: TextStyle(
                                        color: isOnline ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                ApiClient.baseUrl,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Divider(height: 1, color: borderColor),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          pendingCount > 0
                              ? "$pendingCount inspection(s) en attente"
                              : "Toutes les données sont synchronisées",
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: pendingCount > 0 ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                          ),
                        ),
                        if (sync.lastSyncTime != null)
                          Text(
                            "Dernière synchro : ${_formatDateTime(sync.lastSyncTime!)}",
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: (isSyncing || pendingCount == 0) ? null : _triggerSyncAll,
                        icon: isSyncing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.sync_rounded, size: 20),
                        label: Text(
                          isSyncing
                              ? "Synchronisation en cours..."
                              : (pendingCount > 0
                                  ? "Tout synchroniser maintenant ($pendingCount)"
                                  : "Données à jour"),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Titre de section + Action Vider
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "FILE D'ATTENTE LOCALE (${queue.length})",
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF94A3B8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (queue.isNotEmpty)
                      InkWell(
                        onTap: _confirmClearQueue,
                        borderRadius: BorderRadius.circular(6),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          child: Text(
                            "Tout effacer",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // 3. Liste des éléments à synchroniser
              Expanded(
                child: queue.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.cloud_done_rounded,
                                  color: Color(0xFF10B981),
                                  size: 44,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                "Toutes les inspections sont à jour !",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Aucune inspection ou action n'est en attente de synchronisation sur cet appareil.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                        itemCount: queue.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = queue[index];
                          final badgeColor = _badgeColorForType(item.type);
                          final isFailed = item.status == 'failed';
                          final isItemSyncing = item.status == 'syncing';

                          return Container(
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isFailed
                                    ? Colors.red.withValues(alpha: 0.5)
                                    : borderColor,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // En-tête de la carte : Type + Date
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: badgeColor.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          item.type,
                                          style: TextStyle(
                                            color: badgeColor,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        _formatDateTime(item.createdAt),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // Titre de l'inspection
                                  Text(
                                    item.title,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),

                                  // Endpoint & Méthode
                                  Text(
                                    "${item.method} ${item.endpoint}",
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 11,
                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                    ),
                                  ),

                                  // Message d'erreur si échec
                                  if (isFailed && item.errorMessage != null) ...[
                                    const SizedBox(height: 10),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.error_outline, color: Colors.red, size: 16),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              item.errorMessage!,
                                              style: TextStyle(
                                                fontSize: 11.5,
                                                color: Colors.red.shade700,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          if (item.retryCount > 0)
                                            Text(
                                              "(${item.retryCount}x)",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.red.shade700,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 12),
                                  Divider(height: 1, color: borderColor),
                                  const SizedBox(height: 8),

                                  // Boutons d'action par carte
                                  Row(
                                    children: [
                                      // Bouton données JSON
                                      TextButton.icon(
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          visualDensity: VisualDensity.compact,
                                          foregroundColor: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                                        ),
                                        icon: const Icon(Icons.code_rounded, size: 16),
                                        label: const Text("Données", style: TextStyle(fontSize: 12)),
                                        onPressed: () => _showPayloadDialog(item),
                                      ),
                                      const Spacer(),

                                      // Bouton supprimer de la file
                                      IconButton(
                                        tooltip: "Supprimer",
                                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                        visualDensity: VisualDensity.compact,
                                        onPressed: () => _confirmDeleteAction(item),
                                      ),
                                      const SizedBox(width: 4),

                                      // Bouton ré-essayer / synchroniser unitairement
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          visualDensity: VisualDensity.compact,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        icon: isItemSyncing
                                            ? const SizedBox(
                                                width: 12,
                                                height: 12,
                                                child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white),
                                              )
                                            : const Icon(Icons.sync_rounded, size: 14),
                                        label: Text(
                                          isItemSyncing ? "Envoi..." : "Envoyer",
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                        onPressed: isItemSyncing ? null : () => sync.syncSingleAction(item.id),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
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
}
