import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projectmobile/core/providers/auth_provider.dart';
import 'package:projectmobile/data/models/profile_model.dart';
import 'package:projectmobile/data/providers/provider.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  bool _isUpdating = false;

  Future<void> _updateRole(ProfileModel user, String newRole, String myId) async {
    if (user.id == myId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat mengubah role akun sendiri')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ubah Role'),
        content: Text(
          'Ubah role ${user.fullName ?? user.id} menjadi "$newRole"?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Ubah')),
        ],
      ),
    );

    if (confirmed != true) return;
    setState(() => _isUpdating = true);
    try {
      await ref.read(userRepoProvider).updateUserRole(user.id, newRole);
      ref.invalidate(userListProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Role ${user.fullName ?? user.id} diubah ke $newRole')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengubah role: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _toggleActive(ProfileModel user, String myId) async {
    if (user.id == myId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat menonaktifkan akun sendiri')),
      );
      return;
    }

    final action = user.isActive ? 'Nonaktifkan' : 'Aktifkan';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$action Pengguna'),
        content: Text('$action ${user.fullName ?? user.id}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: user.isActive ? Colors.red : Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(action),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    setState(() => _isUpdating = true);
    try {
      await ref.read(userRepoProvider).setUserActive(user.id, !user.isActive);
      ref.invalidate(userListProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${user.fullName ?? user.id} berhasil di${action.toLowerCase()}kan')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    final myId = auth.user?.id ?? '';
    final usersAsync = ref.watch(userListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Pengguna'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(userListProvider),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Stack(
        children: [
          usersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Gagal memuat data: $e')),
            data: (users) {
              if (users.isEmpty) {
                return const Center(child: Text('Tidak ada pengguna terdaftar'));
              }
              
              // Urutkan agar pengguna saat ini berada di paling atas
              final sortedUsers = List.of(users);
              sortedUsers.sort((a, b) {
                if (a.id == myId) return -1;
                if (b.id == myId) return 1;
                // Urutkan sisanya berdasarkan nama
                return (a.fullName ?? '').compareTo(b.fullName ?? '');
              });

              return ListView.separated(
                itemCount: sortedUsers.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final user = sortedUsers[index];
                  final isMe = user.id == myId;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _roleColor(user.role).withOpacity(0.2),
                      backgroundImage: user.avatarUrl != null
                          ? NetworkImage(user.avatarUrl!)
                          : null,
                      child: user.avatarUrl == null
                          ? Text(
                              (user.fullName?.isNotEmpty == true
                                  ? user.fullName![0].toUpperCase()
                                  : '?'),
                              style: TextStyle(color: _roleColor(user.role)),
                            )
                          : null,
                    ),
                    title: Row(
                      children: [
                        Flexible(child: Text(user.fullName ?? user.id, overflow: TextOverflow.ellipsis)),
                        if (isMe) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Saya', style: TextStyle(fontSize: 10, color: Colors.blue)),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (user.email != null && user.email!.isNotEmpty) ...[
                            Text(user.email!, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            const SizedBox(height: 4),
                          ] else ...[
                            const Text('Email tidak tersedia', style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic)),
                            const SizedBox(height: 4),
                          ],
                          Row(
                            children: [
                              _RoleBadge(role: user.role),
                              const SizedBox(width: 6),
                              _ActiveBadge(isActive: user.isActive),
                            ],
                          ),
                        ],
                      ),
                    ),
                    trailing: isMe
                        ? null
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Dropdown ubah role
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.edit, size: 18),
                                tooltip: 'Ubah Role',
                                onSelected: (newRole) => _updateRole(user, newRole, myId),
                                itemBuilder: (ctx) => ['User', 'Helpdesk', 'Admin']
                                    .where((r) => r != user.role)
                                    .map((r) => PopupMenuItem(value: r, child: Text(r)))
                                    .toList(),
                              ),
                              // Toggle aktif/nonaktif
                              Switch(
                                value: user.isActive,
                                activeColor: Colors.green,
                                onChanged: (_) => _toggleActive(user, myId),
                              ),
                            ],
                          ),
                  );
                },
              );
            },
          ),
          if (_isUpdating)
            const ColoredBox(
              color: Colors.black26,
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin': return Colors.red;
      case 'helpdesk': return Colors.orange;
      default: return Colors.blue;
    }
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});

  Color get _color {
    switch (role.toLowerCase()) {
      case 'admin': return Colors.red;
      case 'helpdesk': return Colors.orange;
      default: return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _color),
      ),
      child: Text(role, style: TextStyle(fontSize: 10, color: _color, fontWeight: FontWeight.w600)),
    );
  }
}

class _ActiveBadge extends StatelessWidget {
  final bool isActive;
  const _ActiveBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: (isActive ? Colors.green : Colors.red).withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isActive ? 'Aktif' : 'Nonaktif',
        style: TextStyle(fontSize: 10, color: isActive ? Colors.green : Colors.red),
      ),
    );
  }
}
