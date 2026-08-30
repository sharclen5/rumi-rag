import 'package:flutter/material.dart';
import 'package:rumi/models/user.dart';
import 'package:rumi/screens/home/admin/user_tile.dart';
import 'package:rumi/services/auth.dart';
import 'package:rumi/services/database.dart';
import 'package:provider/provider.dart';

class AdminDashboard extends StatefulWidget {
  final VoidCallback? onEnterApp;
  const AdminDashboard({super.key, this.onEnterApp});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  static const _brand = Color.fromARGB(255, 144, 121, 84);
  static const int _perPage = 5;

  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _sortBy = 'name'; // 'name' | 'created'
  int _currentPage = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // filter + sort + paginate — semua client-side
  List<UserProfile> _process(List<UserProfile> all) {
    // 1. filter by search query
    List<UserProfile> result = all.where((u) {
      final query = _searchQuery.toLowerCase();
      final name = '${u.firstName} ${u.lastName}'.toLowerCase();
      return name.contains(query) || u.email.toLowerCase().contains(query);
    }).toList();

    // 2. sort
    if (_sortBy == 'name') {
      result.sort((a, b) {
        final nameA = '${a.firstName} ${a.lastName}'.toLowerCase();
        final nameB = '${b.firstName} ${b.lastName}'.toLowerCase();
        return nameA.compareTo(nameB);
      });
    }
    // 'created' → biarkan urutan asli dari Firestore (insertion order)

    // admin selalu di atas regardless of sort
    result.sort((a, b) {
      if (a.role == 'admin' && b.role != 'admin') return -1;
      if (a.role != 'admin' && b.role == 'admin') return 1;
      return 0;
    });

    return result;
  }

  List<UserProfile> _paginate(List<UserProfile> filtered) {
    final start = _currentPage * _perPage;
    final end = (start + _perPage).clamp(0, filtered.length);
    if (start >= filtered.length) return [];
    return filtered.sublist(start, end);
  }

  int _totalPages(int total) => (total / _perPage).ceil();

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<User?>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 32, 31, 31),
        iconTheme: const IconThemeData(color: Color(0xFFF2DAB1)),
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(color: Color(0xFFF2DAB1)),
        ),
        actions: [
          // sort toggle
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: Color(0xFFF2DAB1)),
            color: const Color(0xFF2A2828),
            onSelected: (val) => setState(() {
              _sortBy = val;
              _currentPage = 0; // reset ke page 1 tiap ganti sort
            }),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'name',
                child: Row(
                  children: [
                    Icon(
                      Icons.sort_by_alpha,
                      color: _sortBy == 'name' ? _brand : Colors.grey.shade400,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Nama (A-Z)',
                      style: TextStyle(
                        color: _sortBy == 'name'
                            ? const Color(0xFFF2DAB1)
                            : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'created',
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: _sortBy == 'created'
                          ? _brand
                          : Colors.grey.shade400,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Terbaru',
                      style: TextStyle(
                        color: _sortBy == 'created'
                            ? const Color(0xFFF2DAB1)
                            : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        constraints: const BoxConstraints(minHeight: double.infinity),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF363434), Color(0xFF1A1A1A)],
            stops: [0.0, 1.0],
          ),
        ),
        child: StreamBuilder<List<UserProfile>>(
          stream: DatabaseService(uid: currentUser!.uid).getAllUsers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: _brand),
              );
            }

            final allUsers = snapshot.data ?? [];
            final filtered = _process(allUsers);
            final pageUsers = _paginate(filtered);
            final totalPages = _totalPages(filtered.length);

            return Column(
              children: [
                // search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(
                      color: Color(0xFFF2DAB1),
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Cari nama atau email...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey.shade500,
                        size: 20,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? GestureDetector(
                              onTap: () => setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                                _currentPage = 0;
                              }),
                              child: Icon(
                                Icons.close,
                                color: Colors.grey.shade500,
                                size: 18,
                              ),
                            )
                          : null,
                      filled: true,
                      fillColor: const Color(0xFF2A2828),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFF4A4646),
                          width: 1.2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFF4A4646),
                          width: 1.2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _brand, width: 1.6),
                      ),
                    ),
                    onChanged: (val) => setState(() {
                      _searchQuery = val;
                      _currentPage = 0; // reset ke page 1 tiap search berubah
                    }),
                  ),
                ),

                // label + total count
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Pengguna',
                        style: const TextStyle(
                          color: Color(0xFFF2DAB1),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${filtered.length} total',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // user list
                Expanded(
                  child: pageUsers.isEmpty
                      ? Center(
                          child: Text(
                            _searchQuery.isNotEmpty
                                ? 'Tidak ada hasil untuk "$_searchQuery"'
                                : 'Belum ada pengguna.',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: pageUsers.length,
                          itemBuilder: (context, index) =>
                              UserTile(user: pageUsers[index]),
                        ),
                ),

                // pagination controls
                if (totalPages > 1)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // prev button
                        IconButton(
                          onPressed: _currentPage > 0
                              ? () => setState(() => _currentPage--)
                              : null,
                          icon: const Icon(Icons.chevron_left),
                          color: const Color(0xFFF2DAB1),
                          disabledColor: Colors.grey.shade700,
                        ),

                        // page indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2828),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF4A4646),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Halaman ${_currentPage + 1} dari $totalPages',
                            style: const TextStyle(
                              color: Color(0xFFF2DAB1),
                              fontSize: 12,
                            ),
                          ),
                        ),

                        // next button
                        IconButton(
                          onPressed: _currentPage < totalPages - 1
                              ? () => setState(() => _currentPage++)
                              : null,
                          icon: const Icon(Icons.chevron_right),
                          color: const Color(0xFFF2DAB1),
                          disabledColor: Colors.grey.shade700,
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
