import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../core/theme/app_colors.dart';
import '../widgets/search_field.dart';
import '../widgets/section_title.dart';
import '../widgets/confession_card.dart';
import '../widgets/user_list_tile.dart';
import '../mock_data/sample_data.dart';
import '../models/confession.dart';
import '../models/user.dart';
import 'confession_detail_screen.dart';
import 'profile_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // Date selection state (Default is '2026-05-12' - Today)
  String _selectedDate = '2026-05-12';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final anchor = DateTime(2026, 5, 12);
    _selectedDate = now.isAfter(anchor) ? _formatDateString(now) : '2026-05-12';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Chunk helper to match YouTube Music column structure from HomeScreen
  List<List<Confession>> _chunkList(List<Confession> list, int chunkSize) {
    List<List<Confession>> chunks = [];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(
        list.sublist(
          i,
          i + chunkSize > list.length ? list.length : i + chunkSize,
        ),
      );
    }
    return chunks;
  }

  // Format date to standard query string
  String _formatDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Generate date strip list from May 10, 2026 to current date
  List<Map<String, String>> _generateCalendarDays() {
    final List<Map<String, String>> days = [];
    final start = DateTime(2026, 5, 10);
    final now = DateTime.now();
    final anchor = DateTime(2026, 5, 12);

    // Set upper bound to today or our mock anchor, whichever is later
    final endDate = now.isAfter(anchor) ? now : anchor;
    final labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    for (int i = 0; ; i++) {
      final date = start.add(Duration(days: i));
      if (date.isAfter(endDate)) {
        break;
      }

      final yyyymmdd = _formatDateString(date);
      final label = labels[date.weekday % 7];

      days.add({'date': yyyymmdd, 'label': label, 'num': '${date.day}'});
    }

    return days;
  }

  // Date selection picker dialog
  Future<void> _pickDate() async {
    final initialDate =
        DateTime.tryParse(_selectedDate) ?? DateTime(2026, 5, 12);
    final now = DateTime.now();
    final anchor = DateTime(2026, 5, 12);
    final lastDate = now.isAfter(anchor) ? now : anchor;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(lastDate)
          ? lastDate
          : (initialDate.isBefore(DateTime(2026, 5, 10))
                ? DateTime(2026, 5, 10)
                : initialDate),
      firstDate: DateTime(2026, 5, 10),
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accentRed,
              onPrimary: Colors.white,
              surface: AppColors.cardBg,
              onSurface: AppColors.textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.accentRed),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = _formatDateString(picked);
      });
    }
  }

  List<Confession> get _filteredConfessions {
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      return SampleData.mockConfessions.where((c) {
        return c.title.toLowerCase().contains(q) ||
            c.authorName.toLowerCase().contains(q);
      }).toList();
    } else {
      return SampleData.mockConfessions
          .where((c) => c.dateText == _selectedDate)
          .toList();
    }
  }

  // Filter users based on search query
  List<AppUser> get _filteredUsers {
    if (_searchQuery.isEmpty) return [];
    final q = _searchQuery.toLowerCase();
    return SampleData.mockUsers.where((u) {
      return u.displayName.toLowerCase().contains(q) ||
          u.handle.toLowerCase().contains(q);
    }).toList();
  }

  void _openDetail(Confession confession) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConfessionDetailScreen(confession: confession),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Premium Title
              Text(
                'Explore',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),

              // Search Box
              SearchField(
                controller: _searchController,
                hintText: 'Search confessions or usernames...',
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                onClear: () {
                  setState(() {
                    _searchQuery = '';
                  });
                },
              ),

              const SizedBox(height: 16),

              if (_searchQuery.isNotEmpty) ...[
                if (_filteredUsers.isNotEmpty) ...[
                  const SectionTitle(title: 'Matching Users ❤️'),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      return UserListTile(
                        user: user,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProfileScreen(user: user),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],

                SectionTitle(
                  title: 'Matching Confessions ❤️',
                  subtitle: 'Confessions matching "${_searchQuery}"',
                ),
                const SizedBox(height: 12),
                _filteredConfessions.isEmpty
                    ? _buildEmptyState(
                        'No confessions match your search. Try another query.',
                      )
                    : SizedBox(
                        height: 300,
                        child: Builder(
                          builder: (context) {
                            final chunks = _chunkList(_filteredConfessions, 4);
                            return ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: chunks.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(width: 14),
                              itemBuilder: (context, index) {
                                final chunk = chunks[index];
                                return SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.85,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: chunk.map((conf) {
                                      return ConfessionCard(
                                        confession: conf,
                                        isHorizontal: false,
                                        onTap: () => _openDetail(conf),
                                      );
                                    }).toList(),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
              ] else ...[
                const SectionTitle(
                  title: 'Select Prefered Date',
                  subtitle: 'Browse confessions from May 10 to current date',
                ),
                const SizedBox(height: 12),
                Container(
                  height: 72,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _generateCalendarDays().map((day) {
                              final isSelected = _selectedDate == day['date']!;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedDate = day['date']!;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  width: 44,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.pureBlack
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        day['label']!,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? Colors.white70
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        day['num']!,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const VerticalDivider(
                        width: 1,
                        color: AppColors.divider,
                        indent: 8,
                        endIndent: 8,
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(
                          Feather.calendar,
                          color: AppColors.accentRed,
                          size: 20,
                        ),
                        onPressed: _pickDate,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                SectionTitle(
                  title: 'Confessions on Selected Date',
                  subtitle: 'Shared on ${_formatDateLabel(_selectedDate)}',
                ),
                const SizedBox(height: 12),
                _filteredConfessions.isEmpty
                    ? _buildEmptyState('No confessions shared on this day.')
                    : SizedBox(
                        height: 300,
                        child: Builder(
                          builder: (context) {
                            final chunks = _chunkList(_filteredConfessions, 4);
                            return ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: chunks.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(width: 14),
                              itemBuilder: (context, index) {
                                final chunk = chunks[index];
                                return SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.85,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: chunk.map((conf) {
                                      return ConfessionCard(
                                        confession: conf,
                                        isHorizontal: false,
                                        onTap: () => _openDetail(conf),
                                      );
                                    }).toList(),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
              ],
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(color: AppColors.divider),
      ),
      alignment: Alignment.center,
      child: Column(
        children: [
          const Icon(
            Icons.nights_stay_outlined,
            color: AppColors.textSecondary,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateLabel(String dateStr) {
    final parsed = DateTime.tryParse(dateStr);
    if (parsed == null) return dateStr;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(parsed.year, parsed.month, parsed.day);
    final diffDays = today.difference(target).inDays;

    if (diffDays == 0) {
      return 'Today (${DateFormat('MMM d').format(parsed)})';
    }
    if (diffDays == 1) {
      return 'Yesterday (${DateFormat('MMM d').format(parsed)})';
    }

    return DateFormat('MMM d').format(parsed);
  }
}
